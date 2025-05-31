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
  case userDetail(String)
  case postDetail(String)

  static func from(path: String, fullPath: [String], parameters: [String: String])
    -> TestDestination?
  {
    guard let currentIndex = fullPath.firstIndex(of: path) else {
      return nil
    }

    let previousComponent = currentIndex > 0 ? fullPath[currentIndex - 1] : nil

    switch (previousComponent, path) {
    case ("users", "detail"):
      let id = parameters["id"] ?? "unknown"
      return .userDetail(id)
    case ("posts", "detail"):
      let id = parameters["id"] ?? "unknown"
      return .postDetail(id)
    case (_, "list"):
      return .list
    case (_, "detail"):
      if let id = parameters["id"] {
        return .detail(id)
      }
      return .detail("default")
    case (nil, "users"), (nil, "posts"):
      return nil  // These are just path segments, not destinations
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
      XCTAssertEqual(id, "default")  // Should get default since no parameter
    } else {
      XCTFail("Expected detail destination with id")
    }
  }

  func testURLNavigationWithInvalidDestination() {
    let result = router.navigate(to: "myapp://invalid")
    XCTAssertFalse(result)  // Should fail since no valid destinations
    XCTAssertTrue(router.selectedTabPath.isEmpty)  // No destinations added
  }

  func testURLNavigationWithMalformedURL() {
    let result = router.navigate(to: "not a url")
    XCTAssertFalse(result)
    XCTAssertTrue(router.selectedTabPath.isEmpty)  // Should remain unchanged
  }

  func testURLNavigationWithEmptyHost() {
    let result = router.navigate(to: "myapp://")
    XCTAssertFalse(result)
    XCTAssertTrue(router.selectedTabPath.isEmpty)  // Should remain unchanged
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

  // MARK: - Contextual URL Routing Tests

  func testContextualUserDetailRoute() {
    let result = router.navigate(to: "myapp://users/detail?id=user123")
    XCTAssertTrue(result)
    XCTAssertEqual(router.selectedTabPath.count, 1)

    if case let .userDetail(id) = router.selectedTabPath[0] {
      XCTAssertEqual(id, "user123")
    } else {
      XCTFail("Expected userDetail destination")
    }
  }

  func testContextualPostDetailRoute() {
    let result = router.navigate(to: "myapp://posts/detail?id=post456")
    XCTAssertTrue(result)
    XCTAssertEqual(router.selectedTabPath.count, 1)

    if case let .postDetail(id) = router.selectedTabPath[0] {
      XCTAssertEqual(id, "post456")
    } else {
      XCTFail("Expected postDetail destination")
    }
  }

  func testContextualRoutingDifferentiatesDetailTypes() {
    // Test that users/detail and posts/detail create different destination types
    let userResult = router.navigate(to: "myapp://users/detail?id=123")
    XCTAssertTrue(userResult)

    if case .userDetail = router.selectedTabPath[0] {
      // Expected
    } else {
      XCTFail("Expected userDetail destination")
    }

    let postResult = router.navigate(to: "myapp://posts/detail?id=123")
    XCTAssertTrue(postResult)

    if case .postDetail = router.selectedTabPath[0] {
      // Expected
    } else {
      XCTFail("Expected postDetail destination")
    }
  }

  func testNonContextualDetailStillWorks() {
    // Test that the original detail route without context still works
    let result = router.navigate(to: "myapp://detail?id=generic")
    XCTAssertTrue(result)
    XCTAssertEqual(router.selectedTabPath.count, 1)

    if case let .detail(id) = router.selectedTabPath[0] {
      XCTAssertEqual(id, "generic")
    } else {
      XCTFail("Expected generic detail destination")
    }
  }

  func testContextualRoutingWithoutParameters() {
    let result = router.navigate(to: "myapp://users/detail")
    XCTAssertTrue(result)
    XCTAssertEqual(router.selectedTabPath.count, 1)

    if case let .userDetail(id) = router.selectedTabPath[0] {
      XCTAssertEqual(id, "unknown")  // Should get default value
    } else {
      XCTFail("Expected userDetail destination with default id")
    }
  }
}
