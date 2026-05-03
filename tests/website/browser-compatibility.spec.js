const { test, expect } = require('@playwright/test');

const TEST_PAGES = ['/'];

test.describe('Browser Compatibility - Kodra WSL', () => {

  test.describe('Scroll Functionality', () => {
    test('page scrolls with mouse wheel', async ({ page }) => {
      await page.goto('/');
      const initialScroll = await page.evaluate(() => window.scrollY);
      await page.mouse.wheel(0, 500);
      await page.waitForTimeout(500);
      const newScroll = await page.evaluate(() => window.scrollY);
      expect(newScroll).toBeGreaterThan(initialScroll);
    });

    test('page scrolls bidirectionally', async ({ page }) => {
      await page.goto('/');
      await page.mouse.wheel(0, 500);
      await page.waitForTimeout(300);
      const midScroll = await page.evaluate(() => window.scrollY);
      await page.mouse.wheel(0, -300);
      await page.waitForTimeout(300);
      const upScroll = await page.evaluate(() => window.scrollY);
      expect(upScroll).toBeLessThan(midScroll);
    });

    test('programmatic scrollTo works', async ({ page }) => {
      await page.goto('/');
      await page.evaluate(() => window.scrollTo({ top: 1000, behavior: 'instant' }));
      await page.waitForTimeout(300);
      const scroll = await page.evaluate(() => window.scrollY);
      expect(scroll).toBeGreaterThanOrEqual(500);
    });
  });

  test.describe('CSS Property Validation', () => {
    test('html and body allow scrolling', async ({ page }) => {
      await page.goto('/');
      for (const sel of ['html', 'body']) {
        const overflow = await page.evaluate(s => {
          const style = getComputedStyle(document.querySelector(s));
          return { overflowY: style.overflowY, overflowX: style.overflowX };
        }, sel);
        expect(overflow.overflowY).not.toBe('hidden');
      }
    });

    test('no full-screen blocking pseudo-elements', async ({ page }) => {
      await page.goto('/');
      const blocking = await page.evaluate(() => {
        const els = document.querySelectorAll('*');
        for (const el of els) {
          for (const pseudo of ['::before', '::after']) {
            const style = getComputedStyle(el, pseudo);
            if (style.content !== 'none' && style.content !== '""' && style.content !== "''") {
              const pos = style.position;
              if ((pos === 'fixed' || pos === 'absolute') && style.pointerEvents !== 'none') {
                const w = parseInt(style.width); const h = parseInt(style.height);
                if (w > window.innerWidth * 0.8 && h > window.innerHeight * 0.8) return true;
              }
            }
          }
        }
        return false;
      });
      expect(blocking).toBe(false);
    });
  });

  test.describe('Footer Rendering', () => {
    test('footer is visible', async ({ page }) => {
      await page.goto('/');
      const footer = page.locator('footer');
      if (await footer.count() > 0) {
        await footer.scrollIntoViewIfNeeded();
        await expect(footer).toBeVisible();
      }
    });
  });

  test.describe('Mobile Touch Targets', () => {
    test('buttons meet 44px minimum', async ({ page }) => {
      await page.goto('/');
      await page.waitForTimeout(500);
      const smallTargets = await page.evaluate(() => {
        const btns = document.querySelectorAll('a.btn, button:not(.copy-btn), [role="button"]');
        let small = 0;
        btns.forEach(b => {
          const rect = b.getBoundingClientRect();
          if (rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44)) small++;
        });
        return small;
      });
      expect(smallTargets).toBeLessThanOrEqual(2);
    });
  });

  test.describe('Navigation', () => {
    test('nav links exist and work', async ({ page }) => {
      await page.goto('/');
      const nav = page.locator('nav');
      if (await nav.count() > 0) {
        const links = await nav.locator('a').count();
        expect(links).toBeGreaterThan(0);
      }
    });
  });

  test.describe('Responsive Layout', () => {
    for (const vp of [
      { name: 'desktop', w: 1280, h: 800 },
      { name: 'tablet', w: 768, h: 1024 },
      { name: 'mobile', w: 375, h: 667 },
    ]) {
      test(`renders at ${vp.name} (${vp.w}x${vp.h})`, async ({ page }) => {
        await page.setViewportSize({ width: vp.w, height: vp.h });
        await page.goto('/');
        const hero = page.locator('.hero');
        if (await hero.count() > 0) {
          await expect(hero).toBeVisible();
        }
      });
    }
  });

  test.describe('Terminal Block', () => {
    test('install command is visible', async ({ page }) => {
      await page.goto('/');
      const terminal = page.locator('.terminal');
      if (await terminal.count() > 0) {
        await expect(terminal.first()).toBeVisible();
        const text = await terminal.first().textContent();
        expect(text).toContain('kodra.wsl.codetocloud.io');
      }
    });
  });

  test.describe('Image Loading', () => {
    test('no broken images', async ({ page }) => {
      await page.goto('/');
      const broken = await page.evaluate(() => {
        const imgs = document.querySelectorAll('img');
        let count = 0;
        imgs.forEach(img => { if (!img.complete || img.naturalWidth === 0) count++; });
        return count;
      });
      expect(broken).toBe(0);
    });
  });
});
