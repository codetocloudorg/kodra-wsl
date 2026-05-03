const { test, expect } = require('@playwright/test');

test.describe('World-Class Audit - Kodra WSL', () => {

  test.describe('Accessibility', () => {
    test('page has proper heading hierarchy', async ({ page }) => {
      await page.goto('/');
      const headings = await page.evaluate(() => {
        const hs = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
        return Array.from(hs).map(h => ({ tag: h.tagName, text: h.textContent.trim().substring(0, 50) }));
      });
      expect(headings.length).toBeGreaterThan(0);
      const hasH1 = headings.some(h => h.tag === 'H1');
      expect(hasH1).toBe(true);
    });

    test('images have alt text', async ({ page }) => {
      await page.goto('/');
      const missingAlt = await page.evaluate(() => {
        const imgs = document.querySelectorAll('img');
        return Array.from(imgs).filter(img => !img.alt && !img.getAttribute('aria-hidden')).length;
      });
      expect(missingAlt).toBe(0);
    });

    test('page has landmark regions', async ({ page }) => {
      await page.goto('/');
      const landmarks = await page.evaluate(() => ({
        nav: document.querySelectorAll('nav, [role="navigation"]').length,
        main: document.querySelectorAll('main, [role="main"]').length,
        footer: document.querySelectorAll('footer, [role="contentinfo"]').length,
      }));
      expect(landmarks.nav).toBeGreaterThanOrEqual(1);
      expect(landmarks.main + landmarks.footer).toBeGreaterThanOrEqual(1);
    });

    test('interactive elements are focusable', async ({ page }) => {
      await page.goto('/');
      const unfocusable = await page.evaluate(() => {
        const els = document.querySelectorAll('a[href], button, input, select, textarea');
        return Array.from(els).filter(el => el.tabIndex < 0 && !el.closest('[aria-hidden="true"]')).length;
      });
      expect(unfocusable).toBe(0);
    });
  });

  test.describe('Performance', () => {
    test('page loads within 5 seconds', async ({ page }) => {
      const start = Date.now();
      await page.goto('/', { waitUntil: 'domcontentloaded' });
      const loadTime = Date.now() - start;
      expect(loadTime).toBeLessThan(5000);
    });

    test('page weight is under 2MB', async ({ page }) => {
      let totalSize = 0;
      page.on('response', response => {
        const headers = response.headers();
        const size = parseInt(headers['content-length'] || '0');
        totalSize += size;
      });
      await page.goto('/');
      expect(totalSize).toBeLessThan(2 * 1024 * 1024);
    });
  });

  test.describe('SEO', () => {
    test('title is present and valid', async ({ page }) => {
      await page.goto('/');
      const title = await page.title();
      expect(title.length).toBeGreaterThan(0);
      expect(title.length).toBeLessThanOrEqual(70);
      expect(title.toLowerCase()).toContain('kodra wsl');
    });

    test('meta description exists and is valid', async ({ page }) => {
      await page.goto('/');
      const desc = await page.getAttribute('meta[name="description"]', 'content');
      expect(desc).toBeTruthy();
      expect(desc.length).toBeLessThanOrEqual(160);
    });

    test('viewport meta tag exists', async ({ page }) => {
      await page.goto('/');
      const viewport = await page.getAttribute('meta[name="viewport"]', 'content');
      expect(viewport).toBeTruthy();
      expect(viewport).toContain('width=device-width');
    });

    test('canonical URL exists', async ({ page }) => {
      await page.goto('/');
      const canonical = await page.getAttribute('link[rel="canonical"]', 'href');
      expect(canonical).toBeTruthy();
      expect(canonical).toContain('kodra.wsl.codetocloud.io');
    });

    test('Open Graph tags exist', async ({ page }) => {
      await page.goto('/');
      for (const prop of ['og:title', 'og:description', 'og:image', 'og:url']) {
        const content = await page.getAttribute(`meta[property="${prop}"]`, 'content');
        expect(content).toBeTruthy();
      }
    });

    test('JSON-LD structured data exists', async ({ page }) => {
      await page.goto('/');
      const jsonLd = await page.evaluate(() => {
        const script = document.querySelector('script[type="application/ld+json"]');
        if (!script) return null;
        try { return JSON.parse(script.textContent); } catch { return null; }
      });
      expect(jsonLd).toBeTruthy();
      expect(jsonLd['@type']).toBe('SoftwareApplication');
    });
  });

  test.describe('Security', () => {
    test('external resources use HTTPS', async ({ page }) => {
      await page.goto('/');
      const insecure = await page.evaluate(() => {
        const els = document.querySelectorAll('[src], [href]');
        return Array.from(els).filter(el => {
          const url = el.getAttribute('src') || el.getAttribute('href') || '';
          return url.startsWith('http://') && !url.includes('localhost');
        }).length;
      });
      expect(insecure).toBe(0);
    });
  });

  test.describe('Content Validation (WSL-Specific)', () => {
    test('install command contains WSL URL', async ({ page }) => {
      await page.goto('/');
      const text = await page.textContent('body');
      expect(text).toContain('kodra.wsl.codetocloud.io');
    });

    test('page mentions WSL2 or WSL', async ({ page }) => {
      await page.goto('/');
      const text = await page.textContent('body');
      const mentionsWSL = text.includes('WSL2') || text.includes('WSL');
      expect(mentionsWSL).toBe(true);
    });

    test('tool list includes key tools', async ({ page }) => {
      await page.goto('/');
      const text = await page.textContent('body');
      for (const tool of ['Azure CLI', 'Docker', 'kubectl', 'Terraform']) {
        expect(text).toContain(tool);
      }
    });

    test('stats row shows 25+ tools', async ({ page }) => {
      await page.goto('/');
      const text = await page.textContent('body');
      expect(text).toContain('25+');
    });

    test('GitHub link points to kodra-wsl repo', async ({ page }) => {
      await page.goto('/');
      const ghLink = await page.evaluate(() => {
        const links = document.querySelectorAll('a[href*="github.com"]');
        return Array.from(links).map(l => l.href);
      });
      const hasWSLRepo = ghLink.some(l => l.includes('kodra-wsl'));
      expect(hasWSLRepo).toBe(true);
    });
  });

  test.describe('Visual Regression', () => {
    // Visual regression snapshots differ between local and CI rendering
    // environments (fonts, anti-aliasing, GPU). Skip in CI; run locally
    // with: npx playwright test --grep "Visual Regression"
    test.skip(!!process.env.CI, 'Visual regression skipped in CI — rendering differs');

    for (const vp of [
      { name: 'desktop', w: 1280, h: 800 },
      { name: 'tablet', w: 768, h: 1024 },
      { name: 'mobile', w: 375, h: 667 },
    ]) {
      test(`screenshot at ${vp.name}`, async ({ page }) => {
        await page.setViewportSize({ width: vp.w, height: vp.h });
        await page.goto('/');
        await page.waitForLoadState('networkidle');
        await expect(page).toHaveScreenshot(`${vp.name}-full.png`, {
          fullPage: true,
          maxDiffPixelRatio: 0.05,
        });
      });
    }
  });
});
