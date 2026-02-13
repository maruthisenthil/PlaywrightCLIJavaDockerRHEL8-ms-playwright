package com.playwright.tests;

import com.microsoft.playwright.*;
import org.testng.annotations.*;
import java.nio.file.Paths;
import static org.testng.Assert.*;

public class SimpleTest {
    
    private Playwright playwright;
    private Browser browser;
    private BrowserContext context;
    
    @BeforeClass
    public void setUp() {
        playwright = Playwright.create();
        
        // Get headless setting from system property
        boolean headless = Boolean.parseBoolean(
            System.getProperty("headless", "true")
        );
        
        System.out.println("🎭 Browser Mode: " + (headless ? "HEADLESS" : "HEADED (Visible)"));
        
        // Launch browser with headed mode for VNC
        browser = playwright.chromium().launch(
            new BrowserType.LaunchOptions()
                .setHeadless(headless)
                .setSlowMo(1000)  // Slow down so you can see actions!
        );
        
        // Create context with video recording
        context = browser.newContext(
            new Browser.NewContextOptions()
                .setRecordVideoDir(Paths.get("test-results/videos"))
                .setViewportSize(1920, 1080)
        );
        
        System.out.println("✅ Browser started successfully!");
    }
    
    @Test
    public void testGoogleSearch() {
        System.out.println("🧪 Starting Google Search Test...");
        
        Page page = context.newPage();
        
        // Step 1: Navigate to Google
        System.out.println("📍 Navigating to Google...");
        page.navigate("https://www.google.com");
        page.screenshot(new Page.ScreenshotOptions()
            .setPath(Paths.get("test-results/screenshots/01-google-homepage.png")));
        
        // Step 2: Accept cookies if present
        try {
            page.click("button:has-text('Accept all')", new Page.ClickOptions().setTimeout(3000));
            System.out.println("✅ Accepted cookies");
        } catch (Exception e) {
            System.out.println("ℹ️ No cookie banner");
        }
        
        // Step 3: Search for something
        System.out.println("⌨️ Typing search query...");
        page.fill("textarea[name='q']", "Playwright Automation");
        page.screenshot(new Page.ScreenshotOptions()
            .setPath(Paths.get("test-results/screenshots/02-typed-query.png")));
        
        // Step 4: Submit search
        System.out.println("🔍 Submitting search...");
        page.press("textarea[name='q']", "Enter");
        page.waitForLoadState();
        page.screenshot(new Page.ScreenshotOptions()
            .setPath(Paths.get("test-results/screenshots/03-search-results.png")));
        
        // Verify results
        String title = page.title();
        System.out.println("📄 Page title: " + title);
        assertTrue(title.contains("Playwright"), "Search results should contain 'Playwright'");
        
        System.out.println("✅ Test completed successfully!");
    }
    @AfterClass
    public void tearDown() {
        System.out.println("🧹 Cleaning up...");
        
        if (context != null) {
            context.close();
            System.out.println("✅ Browser context closed");
        }
        
        if (browser != null) {
            browser.close();
            System.out.println("✅ Browser closed");
        }
        
        if (playwright != null) {
            playwright.close();
            System.out.println("✅ Playwright closed");
        }
    }
}