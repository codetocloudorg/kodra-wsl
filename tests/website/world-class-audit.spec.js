const { test, expect } = require('@playwright/test');

test.describe('World-Class Audit - Kodra WSL Redirect', () => {

  test.describe('Redirect Behavior', () => {
    test('page has meta refresh to unified site', async ({ page }) => {
      // Intercept navigation to prevent actual redirect
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const refresh = await page.getAttribute('meta[http-equiv="refresh"]', 'content');
      expect(refresh).toBeTruthy();
      expect(refresh).toContain('kodra.codetocloud.io/#wsl');
    });

    test('page has JS redirect to unified site', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const scriptContent = await page.evaluate(() => {
        const scripts = document.querySelectorAll('script');
        return Array.from(scripts).map(s => s.textContent).join('');
      });
      expect(scriptContent).toContain('kodra.codetocloud.io/#wsl');
    });

    test('fallback link to unified site exists', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const link = await page.getAttribute('a[href*="kodra.codetocloud.io"]', 'href');
      expect(link).toContain('kodra.codetocloud.io/#wsl');
    });
  });

  test.describe('SEO', () => {
    test('title is present and valid', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const title = await page.title();
      expect(title.length).toBeGreaterThan(0);
      expect(title.length).toBeLessThanOrEqual(70);
      expect(title.toLowerCase()).toContain('kodra');
    });

    test('viewport meta tag exists', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const viewport = await page.getAttribute('meta[name="viewport"]', 'content');
      expect(viewport).toBeTruthy();
      expect(viewport).toContain('width=device-width');
    });

    test('canonical URL points to unified site', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const canonical = await page.getAttribute('link[rel="canonical"]', 'href');
      expect(canonical).toBeTruthy();
      expect(canonical).toContain('kodra.codetocloud.io');
    });

    test('robots meta is noindex', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const robots = await page.getAttribute('meta[name="robots"]', 'content');
      expect(robots).toBeTruthy();
      expect(robots).toContain('noindex');
    });
  });

  test.describe('Security', () => {
    test('redirect target uses HTTPS', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      await page.goto('/');
      const refresh = await page.getAttribute('meta[http-equiv="refresh"]', 'content');
      expect(refresh).toContain('https://');
    });
  });

  test.describe('Performance', () => {
    test('redirect page loads within 3 seconds', async ({ page }) => {
      await page.route('https://kodra.codetocloud.io/**', route => route.abort());
      const start = Date.now();
      await page.goto('/', { waitUntil: 'domcontentloaded' });
      const loadTime = Date.now() - start;
      expect(loadTime).toBeLessThan(3000);
    });
  });

  test.describe('Boot Script', () => {
    test('boot.sh is accessible', async ({ page }) => {
      const response = await page.goto('/boot.sh');
      expect(response.status()).toBe(200);
    });

    test('boot.sh starts with valid shebang', async ({ page }) => {
      const response = await page.goto('/boot.sh');
      const text = await response.text();
      expect(text.trimStart()).toMatch(/^#!\/usr\/bin\/env bash/);
    });

    test('boot.sh references kodra-wsl repo', async ({ page }) => {
      const response = await page.goto('/boot.sh');
      const text = await response.text();
      expect(text).toContain('kodra-wsl');
    });
  });
});
