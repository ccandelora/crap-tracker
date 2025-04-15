import XCTest

class ScreenshotTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        
        // Take a screenshot of the home screen
        snapshot("01_HomeScreen")
        
        // Add code to navigate to other screens for additional screenshots
        // For example:
        // app.buttons["Next Screen"].tap()
        // snapshot("02_NextScreen")
        
        // Add more navigation and snapshot calls as needed
    }
}
