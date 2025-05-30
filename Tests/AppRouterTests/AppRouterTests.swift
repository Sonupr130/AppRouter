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
}