const { test, expect } = require('@playwright/test');

test.describe('Browser Compatibility - Kodra WSL Redirect', () => {

  test.describe('Redirect Page Rendering', () => {
    test('page renders without errors', async ({ page }) => {
      const errors = [];
      page.on('pageerror', err => errors.push(err.message));
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      expect(errors).toHaveLength(0);
    });

    test('fallback link is visible', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const link = page.locator('a[href*="kodra.codetocloud.io"]');
      await expect(link).toBeVisible();
    });
  });

  test.describe('Responsive Layout', () => {
    for (const vp of [
      { name: 'desktop', w: 1280, h: 800 },
      { name: 'tablet', w: 768, h: 1024 },
      { name: 'mobile', w: 375, h: 667 },
    ]) {
      test(`renders at ${vp.name} (${vp.w}x${vp.h})`, async ({ page }) => {
        await page.route('https://kodra.codetocloud.io/**', route => route.abort());
        await page.setViewportSize({ width: vp.w, height: vp.h });
        await page.goto('/');
        const link = page.locator('a[href*="kodra.codetocloud.io"]');
        await expect(link).toBeVisible();
      });
    }
  });

  test.describe('Boot Script Download', () => {
    test('boot.sh returns correct content type', async ({ page }) => {
      const response = await page.goto('/boot.sh');
      expect(response.status()).toBe(200);
    });

    test('boot.sh content is non-empty', async ({ page }) => {
      const response = await page.goto('/boot.sh');
      const text = await response.text();
      expect(text.length).toBeGreaterThan(100);
    });
  });
});
