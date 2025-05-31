import XCTest
@testable import AppRouter

// Test types
enum TestTab: String, TabType, CaseIterable {
    case home, profile, settings
    
    var id: String { rawValue }
    var icon: String { "house" }
}

enum TestDestination: DestinationType {
    case detail(String)
    case list
    
    static func from(path: String, parameters: [String: String]) -> TestDestination? {
        switch path {
        case "list":
            return .list
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

enum TestSheet: SheetType {
    case settings
    case profile
    
    var id: Int { hashValue }
}

@MainActor
final class AppRouterTests: XCTestCase {
    
    var router: Router<TestTab, TestDestination, TestSheet>!
    
    override func setUp() {
        super.setUp()
        router = Router(initialTab: .home)
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(router.selectedTab, .home)
        XCTAssertNil(router.presentedSheet)
        XCTAssertTrue(router.selectedTabPath.isEmpty)
    }
    
    func testNavigation() {
        router.navigateTo(.detail("test"))
        XCTAssertEqual(router.selectedTabPath.count, 1)
        
        router.navigateTo(.list)
        XCTAssertEqual(router.selectedTabPath.count, 2)
    }
    
    func testPopNavigation() {
        router.navigateTo(.detail("test"))
        router.navigateTo(.list)
        
        router.popNavigation()
        XCTAssertEqual(router.selectedTabPath.count, 1)
        
        router.popNavigation()
        XCTAssertTrue(router.selectedTabPath.isEmpty)
    }
    
    func testPopToRoot() {
        router.navigateTo(.detail("test"))
        router.navigateTo(.list)
        
        router.popToRoot()
        XCTAssertTrue(router.selectedTabPath.isEmpty)
    }
    
    func testPerTabNavigation() {
        router.navigateTo(.detail("home"), for: .home)
        router.navigateTo(.list, for: .profile)
        
        XCTAssertEqual(router[.home].count, 1)
        XCTAssertEqual(router[.profile].count, 1)
        XCTAssertTrue(router[.settings].isEmpty)
    }
    
    func testSheetPresentation() {
        router.presentSheet(.settings)
        XCTAssertEqual(router.presentedSheet, .settings)
        
        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
    }
    
    func testTabSwitching() {
        router.selectedTab = .profile
        XCTAssertEqual(router.selectedTab, .profile)
        
        router.navigateTo(.detail("profile"))
        XCTAssertEqual(router.selectedTabPath.count, 1)
        
        router.selectedTab = .home
        XCTAssertTrue(router.selectedTabPath.isEmpty)
        XCTAssertEqual(router[.profile].count, 1)
    }
    
    // MARK: - URL Routing Tests
    
    func testURLNavigationToSingleDestination() {
        let result = router.navigate(to: "myapp://list")
        XCTAssertTrue(result)
        XCTAssertEqual(router.selectedTabPath.count, 1)
        XCTAssertEqual(router.selectedTabPath[0], .list)
    }
    
    func testURLNavigationToDestinationWithParameters() {
        let result = router.navigate(to: "myapp://detail?id=123")
        XCTAssertTrue(result)
        XCTAssertEqual(router.selectedTabPath.count, 1)
        
        if case let .detail(id) = router.selectedTabPath.first {
            XCTAssertEqual(id, "123")
        } else {
            XCTFail("Expected detail destination with id")
        }
    }
    
    func testURLNavigationToMultipleDestinations() {
        let result = router.navigate(to: "myapp://list/detail")
        XCTAssertTrue(result)
        XCTAssertEqual(router.selectedTabPath.count, 2)
        
        XCTAssertEqual(router.selectedTabPath[0], .list)
        if case let .detail(id) = router.selectedTabPath[1] {
            XCTAssertEqual(id, "default") // Should get default since no parameter
        } else {
            XCTFail("Expected detail destination with id")
        }
    }
    
    func testURLNavigationWithInvalidDestination() {
        let result = router.navigate(to: "myapp://invalid")
        XCTAssertFalse(result) // Should fail since no valid destinations
        XCTAssertTrue(router.selectedTabPath.isEmpty) // No destinations added
    }
    
    func testURLNavigationWithMalformedURL() {
        let result = router.navigate(to: "not a url")
        XCTAssertFalse(result)
        XCTAssertTrue(router.selectedTabPath.isEmpty) // Should remain unchanged
    }
    
    func testURLNavigationWithEmptyHost() {
        let result = router.navigate(to: "myapp://")
        XCTAssertFalse(result)
        XCTAssertTrue(router.selectedTabPath.isEmpty) // Should remain unchanged
    }
    
    func testURLNavigationReplacesExistingPath() {
        // Set up existing navigation
        router.navigateTo(.detail("existing"))
        router.navigateTo(.list)
        XCTAssertEqual(router.selectedTabPath.count, 2)
        
        // Navigate via URL - should replace existing path
        let result = router.navigate(to: "myapp://detail?id=newValue")
        XCTAssertTrue(result)
        XCTAssertEqual(router.selectedTabPath.count, 1)
        
        if case let .detail(id) = router.selectedTabPath[0] {
            XCTAssertEqual(id, "newValue")
        } else {
            XCTFail("Expected detail destination with new value")
        }
    }
}