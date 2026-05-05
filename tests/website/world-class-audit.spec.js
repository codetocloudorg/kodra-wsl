const { test, expect } = require('@playwright/test');

test.describe('World-Class Audit - Kodra WSL Redirect', () => {

  test.describe('Redirect Page HTML', () => {
    test('page has meta refresh to unified site', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('http-equiv="refresh"');
      expect(html).toContain('kodra.codetocloud.io/#wsl');
    });

    test('page has JS redirect to unified site', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('window.location.replace');
      expect(html).toContain('kodra.codetocloud.io/#wsl');
    });

    test('fallback link to unified site exists', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('href="https://kodra.codetocloud.io/#wsl"');
    });
  });

  test.describe('SEO', () => {
    test('title is present and valid', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      const match = html.match(/<title>(.*?)<\/title>/);
      expect(match).toBeTruthy();
      expect(match[1].length).toBeGreaterThan(0);
      expect(match[1].length).toBeLessThanOrEqual(70);
      expect(match[1].toLowerCase()).toContain('kodra');
    });

    test('viewport meta tag exists', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('name="viewport"');
      expect(html).toContain('width=device-width');
    });

    test('canonical URL points to unified site', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('rel="canonical"');
      expect(html).toContain('kodra.codetocloud.io');
    });

    test('robots meta is noindex', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('name="robots"');
      expect(html).toContain('noindex');
    });
  });

  test.describe('Security', () => {
    test('redirect target uses HTTPS', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      const match = html.match(/url=(https?:\/\/[^"]+)/);
      expect(match).toBeTruthy();
      expect(match[1]).toMatch(/^https:\/\//);
    });
  });

  test.describe('Performance', () => {
    test('redirect page responds quickly', async ({ request }) => {
      const start = Date.now();
      await request.get('/');
      const elapsed = Date.now() - start;
      expect(elapsed).toBeLessThan(3000);
    });
  });

  test.describe('Boot Script', () => {
    test('boot.sh is accessible', async ({ request }) => {
      const response = await request.get('/boot.sh');
      expect(response.status()).toBe(200);
    });

    test('boot.sh starts with valid shebang', async ({ request }) => {
      const response = await request.get('/boot.sh');
      const text = await response.text();
      expect(text.trimStart()).toMatch(/^#!\/usr\/bin\/env bash/);
    });

    test('boot.sh references kodra-wsl repo', async ({ request }) => {
      const response = await request.get('/boot.sh');
      const text = await response.text();
      expect(text).toContain('kodra-wsl');
    });
  });
});
