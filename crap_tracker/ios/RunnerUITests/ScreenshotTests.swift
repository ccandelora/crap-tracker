import XCTest

class ScreenshotTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // Wait for app to fully load
        sleep(2)
    }
    
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        
        // Take a screenshot of the home screen
        snapshot("01_HomeScreen")
        
        // Navigate to statistics screen (assuming there's a Stats button)
        if app.buttons["Statistics"].exists {
            app.buttons["Statistics"].tap()
            sleep(1)
            snapshot("02_Stats")
        }
        
        // Navigate to player profile screen (assuming there's a Profile button)
        if app.buttons["Profile"].exists {
            app.buttons["Profile"].tap()
            sleep(1)
            snapshot("03_Profile")
        }
        
        // Navigate to dice roll screen (assuming there's a Roll button)
        if app.buttons["Roll"].exists {
            app.buttons["Roll"].tap()
            sleep(1)
            snapshot("04_Roll")
        }
        
        // Add more navigation and snapshot calls based on your app's specific UI
    }
}

// Helper method to find UI elements by accessibility identifier or label text
extension XCUIApplication {
    func findElement(identifier: String) -> XCUIElement? {
        let element = self.buttons[identifier].firstMatch
        if element.exists {
            return element
        }
        
        // Try other element types if button not found
        let types: [XCUIElement.ElementType] = [.tab, .navigationBar, .cell, .staticText, .other]
        for type in types {
            let typeElement = self.descendants(matching: type)[identifier].firstMatch
            if typeElement.exists {
                return typeElement
            }
        }
        
        return nil
    }
} 