import XCTest
@testable import AppRouter

// Test types for SimpleRouter
enum SimpleDestination: DestinationType {
    case detail(String)
    case list
    case settings
    
    static func from(path: String, parameters: [String: String]) -> SimpleDestination? {
        switch path {
        case "list":
            return .list
        case "settings":
            return .settings
        case "detail":
            if let id = parameters["id"] {
                return .detail(id)
            }
            return .detail("default")
        default:
            return nil
        }
    }
}

enum SimpleSheet: SheetType {
    case compose
    case settings
    
    var id: Int { hashValue }
}

@MainActor
final class SimpleRouterTests: XCTestCase {
    
    var router: SimpleRouter<SimpleDestination, SimpleSheet>!
    
    override func setUp() {
        super.setUp()
        router = SimpleRouter()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(router.path.isEmpty)
        XCTAssertNil(router.presentedSheet)
    }
    
    func testNavigation() {
        router.navigateTo(.detail("test"))
        XCTAssertEqual(router.path.count, 1)
        
        router.navigateTo(.list)
        XCTAssertEqual(router.path.count, 2)
        
        router.navigateTo(.settings)
        XCTAssertEqual(router.path.count, 3)
    }
    
    func testPopNavigation() {
        router.navigateTo(.detail("test"))
        router.navigateTo(.list)
        router.navigateTo(.settings)
        
        router.popNavigation()
        XCTAssertEqual(router.path.count, 2)
        
        router.popNavigation()
        XCTAssertEqual(router.path.count, 1)
        
        router.popNavigation()
        XCTAssertTrue(router.path.isEmpty)
        
        // Should handle empty path gracefully
        router.popNavigation()
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testPopToRoot() {
        router.navigateTo(.detail("test"))
        router.navigateTo(.list)
        router.navigateTo(.settings)
        
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testSheetPresentation() {
        router.presentSheet(.compose)
        XCTAssertEqual(router.presentedSheet, .compose)
        
        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
        
        router.presentSheet(.settings)
        XCTAssertEqual(router.presentedSheet, .settings)
        
        // Test replacing current sheet
        router.presentSheet(.compose)
        XCTAssertEqual(router.presentedSheet, .compose)
    }
    
    func testNavigationAndSheetTogether() {
        // Test that navigation and sheet state are independent
        router.navigateTo(.detail("test"))
        router.presentSheet(.compose)
        
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.presentedSheet, .compose)
        
        router.popNavigation()
        XCTAssertTrue(router.path.isEmpty)
        XCTAssertEqual(router.presentedSheet, .compose) // Sheet should remain
        
        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
    }
    
    // MARK: - URL Routing Tests
    
    func testURLNavigationToSingleDestination() {
        let result = router.navigate(to: "myapp://list")
        XCTAssertTrue(result)
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path[0], .list)
    }
    
    func testURLNavigationToDestinationWithParameters() {
        let result = router.navigate(to: "myapp://detail?id=test123")
        XCTAssertTrue(result)
        XCTAssertEqual(router.path.count, 1)
        
        if case let .detail(id) = router.path[0] {
            XCTAssertEqual(id, "test123")
        } else {
            XCTFail("Expected detail destination with id")
        }
    }
    
    func testURLNavigationToMultipleDestinations() {
        let result = router.navigate(to: "myapp://list/detail/settings?id=456")
        XCTAssertTrue(result)
        XCTAssertEqual(router.path.count, 3)
        
        XCTAssertEqual(router.path[0], .list)
        if case let .detail(id) = router.path[1] {
            XCTAssertEqual(id, "456")
        } else {
            XCTFail("Expected detail destination with id")
        }
        XCTAssertEqual(router.path[2], .settings)
    }
    
    func testURLNavigationWithInvalidDestination() {
        let result = router.navigate(to: "myapp://invalid")
        XCTAssertFalse(result) // Should fail for SimpleRouter since no valid destinations
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testURLNavigationWithMalformedURL() {
        let result = router.navigate(to: "not a url")
        XCTAssertFalse(result)
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testURLNavigationWithEmptyHost() {
        let result = router.navigate(to: "myapp://")
        XCTAssertFalse(result)
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testURLNavigationClearsExistingPath() {
        // Set up existing navigation
        router.navigateTo(.detail("existing"))
        router.navigateTo(.list)
        XCTAssertEqual(router.path.count, 2)
        
        // Navigate via URL - should replace existing path
        let result = router.navigate(to: "myapp://settings")
        XCTAssertTrue(result)
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path[0], .settings)
    }
}