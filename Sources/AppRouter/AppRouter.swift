/// AppRouter - A generic tab-based navigation router for SwiftUI
///
/// This library provides a reusable navigation state management solution for SwiftUI apps
/// that use tab-based navigation with navigation stacks and sheet presentation.
///
/// ## Key Features
/// - Generic tab system that works with any tab type
/// - Per-tab navigation stacks
/// - Sheet presentation management
/// - SwiftUI @Observable integration
/// - Thread-safe @MainActor implementation
///
/// ## Usage
///
/// 1. Define your tab type conforming to `TabType`:
/// ```swift
/// enum AppTab: String, TabType, CaseIterable {
///     case home, profile, settings
///     
///     var id: String { rawValue }
///     var icon: String {
///         switch self {
///         case .home: return "house"
///         case .profile: return "person"
///         case .settings: return "gear"
///         }
///     }
/// }
/// ```
///
/// 2. Define your destination and sheet types:
/// ```swift
/// enum Destination: DestinationType {
///     case detail(String)
///     case list
/// }
///
/// enum Sheet: SheetType {
///     case settings
///     case profile
///     var id: Int { hashValue }
/// }
/// ```
///
/// 3. Create a type alias for cleaner syntax:
/// ```swift
/// typealias AppRouter = Router<AppTab, Destination, Sheet>
/// ```
///
/// 4. Create and use the router:
/// ```swift
/// @State private var router = AppRouter(initialTab: .home)
///
/// var body: some View {
///     TabView(selection: $router.selectedTab) {
///         ForEach(AppTab.allCases) { tab in
///             NavigationStack(path: $router[tab]) {
///                 ContentView()
///             }
///             .tabItem {
///                 Label(tab.rawValue, systemImage: tab.icon)
///             }
///             .tag(tab)
///         }
///     }
///     .sheet(item: $router.presentedSheet) { sheet in
///         SheetView(sheet: sheet)
///     }
///     .environment(router)
/// }
/// ```
///
/// 5. Use the router in child views:
/// ```swift
/// struct ContentView: View {
///     @Environment(AppRouter.self) private var router
///     
///     var body: some View {
///         Button("Navigate") {
///             router.navigateTo(.detail("example"))
///         }
///     }
/// }
/// ```