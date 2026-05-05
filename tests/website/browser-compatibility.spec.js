const { test, expect } = require('@playwright/test');

test.describe('Browser Compatibility - Kodra WSL Redirect', () => {

  test.describe('Redirect Page Rendering', () => {
    test('page responds with 200', async ({ request }) => {
      const response = await request.get('/');
      expect(response.status()).toBe(200);
    });

    test('page contains valid HTML structure', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('<!DOCTYPE html>');
      expect(html).toContain('<html');
      expect(html).toContain('</html>');
    });

    test('fallback link is present in HTML', async ({ request }) => {
      const response = await request.get('/');
      const html = await response.text();
      expect(html).toContain('href="https://kodra.codetocloud.io/#wsl"');
    });
  });

  test.describe('Boot Script Download', () => {
    test('boot.sh returns 200', async ({ request }) => {
      const response = await request.get('/boot.sh');
      expect(response.status()).toBe(200);
    });

    test('boot.sh content is non-empty', async ({ request }) => {
      const response = await request.get('/boot.sh');
      const text = await response.text();
      expect(text.length).toBeGreaterThan(100);
    });
  });
});
