# AppRouter

A generic, reusable navigation router for SwiftUI applications. Supports both simple single-stack navigation and complex tab-based navigation with independent navigation stacks and sheet presentation.

## Features

- 🎯 **Simple Router** - `SimpleRouter` for single NavigationStack apps
- 🏷️ **Tab Router** - `Router` for tab-based apps with independent navigation per tab
- 📄 **Sheet Management** - Built-in sheet presentation and dismissal
- 🔄 **SwiftUI Integration** - Uses `@Observable` for reactive state updates
- 🧵 **Thread Safe** - `@MainActor` implementation ensures UI safety
- 📱 **iOS 17+ Ready** - Built for modern SwiftUI patterns

## Installation

### Swift Package Manager

Add this package to your project:

```swift
dependencies: [
    .package(url: "https://github.com/dimillian/AppRouter.git", from: "1.0.0")
]
```

## Quick Start

AppRouter provides two routers depending on your app's navigation needs:

- **`SimpleRouter`** - For apps with a single NavigationStack
- **`Router`** - For apps with tab-based navigation

### Option 1: Simple Navigation (Single Stack)

Perfect for apps that don't use tabs and just need a single navigation stack with sheet support.

```swift
import SwiftUI
import AppRouter

// 1. Define your destination and sheet types
enum Destination: DestinationType {
    case detail(id: String)
    case settings
    case profile(userId: String)
}

enum Sheet: SheetType {
    case compose
    case settings
    
    var id: Int { hashValue }
}

// 2. Use SimpleRouter
struct ContentView: View {
    @State private var router = SimpleRouter<Destination, Sheet>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .environment(router)
    }
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .detail(let id):
            DetailView(id: id)
        case .settings:
            SettingsView()
        case .profile(let userId):
            ProfileView(userId: userId)
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .compose:
            ComposeView()
        case .settings:
            SettingsSheet()
        }
    }
}

// 3. Navigate from anywhere in your app
struct HomeView: View {
    @Environment(SimpleRouter<Destination, Sheet>.self) private var router
    
    var body: some View {
        VStack {
            Button("Go to Detail") {
                router.navigateTo(.detail(id: "123"))
            }
            
            Button("Show Compose Sheet") {
                router.presentSheet(.compose)
            }
        }
    }
}
```

### Option 2: Tab-Based Navigation

For apps that use TabView with independent navigation stacks per tab.

#### 1. Define Your Tab Type

```swift
import AppRouter

enum AppTab: String, TabType, CaseIterable {
    case home, profile, settings
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .profile: return "person"  
        case .settings: return "gear"
        }
    }
}
```

#### 2. Define Destination and Sheet Types

```swift
enum Destination: DestinationType {
    case detail(id: String)
    case list
    case profile(userId: String)
}

enum Sheet: SheetType {
    case settings
    case profile
    case compose
    
    var id: Int { hashValue }
}
```

#### 3. Use the Tab Router

```swift
import SwiftUI
import AppRouter

struct ContentView: View {
    @State private var router = Router<AppTab, Destination, Sheet>(initialTab: .home)
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack(path: $router[tab]) {
                    HomeView()
                        .navigationDestination(for: Destination.self) { destination in
                            destinationView(for: destination)
                        }
                }
                .tabItem {
                    Label(tab.rawValue.capitalized, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .detail(let id):
            DetailView(id: id)
        case .list:
            ListView()
        case .profile(let userId):
            ProfileView(userId: userId)
        }
    }
    
    @ViewBuilder  
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .settings:
            SettingsView()
        case .profile:
            ProfileSheet()
        case .compose:
            ComposeView()
        }
    }
}
```

## API Reference

### SimpleRouter

For single NavigationStack apps:

```swift
@Observable @MainActor
public final class SimpleRouter<Destination: DestinationType, Sheet: SheetType>
```

#### Properties
- `path: [Destination]` - Navigation path
- `presentedSheet: Sheet?` - Currently presented sheet

#### Methods
- `navigateTo(_:)` - Navigate to a destination
- `popNavigation()` - Pop last destination from stack
- `popToRoot()` - Clear navigation stack
- `presentSheet(_:)` - Present a sheet
- `dismissSheet()` - Dismiss current sheet

### Router

For tab-based apps with independent navigation per tab:

```swift
@Observable @MainActor
public final class Router<Tab: TabType, Destination: DestinationType, Sheet: SheetType>
```

#### Properties
- `selectedTab: Tab` - Currently selected tab
- `presentedSheet: Sheet?` - Currently presented sheet
- `selectedTabPath: [Destination]` - Navigation path for current tab

#### Methods
- `navigateTo(_:for:)` - Navigate to a destination  
- `popNavigation(for:)` - Pop last destination from stack
- `popToRoot(for:)` - Clear navigation stack for tab
- `presentSheet(_:)` - Present a sheet
- `dismissSheet()` - Dismiss current sheet

### Protocols

#### DestinationType  
```swift
public protocol DestinationType: Hashable {}
```

#### SheetType
```swift
public protocol SheetType: Hashable, Identifiable {}
```

#### TabType
```swift
public protocol TabType: Hashable, CaseIterable, Identifiable, Sendable {
    var icon: String { get }
}
```
*Only needed for tab-based navigation*

## Examples

### Type Aliases for Cleaner Syntax

To avoid verbose generic syntax throughout your app, create a type alias:

```swift
// Define once in your app
typealias AppRouter = Router<AppTab, Destination, Sheet>
typealias AppSimpleRouter = SimpleRouter<Destination, Sheet>

// Then use the cleaner syntax everywhere
@Environment(AppRouter.self) private var router
@State private var router = AppRouter(initialTab: .home)
```

### Navigate Programmatically

```swift
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack {
            Button("Go to Detail") {
                router.navigateTo(.detail(id: "123"))
            }
            
            Button("Show Settings") {
                router.presentSheet(.settings)
            }
            
            Button("Go to Profile Tab") {
                router.selectedTab = .profile
                router.navigateTo(.profile(userId: "user123"), for: .profile)
            }
        }
    }
}
```

### Environment Integration

```swift
struct App: View {
    @State private var router = Router<AppTab, Destination, Sheet>(initialTab: .home)
    
    var body: some View {
        ContentView()
            .environment(router)
            .environment(\.currentTab, router.selectedTab)
    }
}
```

## Requirements

- iOS 17.0+
- macOS 14.0+
- tvOS 17.0+  
- watchOS 10.0+
- Swift 5.9+

## License

MIT License - see LICENSE file for details