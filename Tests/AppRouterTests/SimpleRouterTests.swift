import XCTest
@testable import AppRouter

// Test types for SimpleRouter
enum SimpleDestination: DestinationType {
    case detail(String)
    case list
    case settings
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
}