import SwiftUI
import AppRouter

// MARK: - Example App with URL Deep Linking

@main
struct URLRoutingExampleApp: App {
    var body: some Scene {
        WindowGroup {
            URLRoutingContentView()
        }
    }
}

// MARK: - Destination Types

enum Destination: DestinationType {
    case list
    case detail(id: String)
    case profile(userId: String)
    case settings
    
    // Required for URL deep linking
    static func from(path: String, parameters: [String: String]) -> Destination? {
        switch path {
        case "list":
            return .list
        case "detail":
            let id = parameters["id"] ?? "unknown"
            return .detail(id: id)
        case "profile":
            let userId = parameters["userId"] ?? "guest"
            return .profile(userId: userId)
        case "settings":
            return .settings
        default:
            return nil
        }
    }
}

enum Sheet: SheetType {
    case compose
    case help
    
    var id: Int { hashValue }
}

// MARK: - Main Content View

struct URLRoutingContentView: View {
    @State private var router = SimpleRouter<Destination, Sheet>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { destination in
                    destinationView(for: destination)
                }
                .navigationTitle("URL Routing Demo")
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .environment(router)
        .onOpenURL { url in
            // This is the key integration with SwiftUI's URL handling
            print("📱 Received URL: \(url)")
            let success = router.navigate(to: url)
            print(success ? "✅ Navigation successful" : "❌ Navigation failed")
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .list:
            ListView()
        case .detail(let id):
            DetailView(id: id)
        case .profile(let userId):
            ProfileView(userId: userId)
        case .settings:
            SettingsView()
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        NavigationStack {
            switch sheet {
            case .compose:
                ComposeView()
            case .help:
                HelpView()
            }
        }
    }
}

// MARK: - Views

struct HomeView: View {
    @Environment(SimpleRouter<Destination, Sheet>.self) private var router
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔗 URL Deep Linking Demo")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Text("Try these deep links:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                DeepLinkButton(
                    title: "List View",
                    url: "myapp://list",
                    router: router
                )
                
                DeepLinkButton(
                    title: "Detail with ID",
                    url: "myapp://detail?id=123",
                    router: router
                )
                
                DeepLinkButton(
                    title: "User Profile",
                    url: "myapp://profile?userId=john",
                    router: router
                )
                
                DeepLinkButton(
                    title: "Navigation Stack",
                    url: "myapp://list/detail?id=456",
                    router: router
                )
                
                DeepLinkButton(
                    title: "Settings",
                    url: "myapp://settings",
                    router: router
                )
            }
            
            Divider()
            
            Text("📋 Current Navigation Path:")
                .font(.headline)
            
            if router.path.isEmpty {
                Text("Root")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(router.path.enumerated()), id: \.offset) { index, destination in
                    HStack {
                        Text("\(index + 1).")
                        Text("\(String(describing: destination))")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("🗂 Show Compose Sheet") {
                    router.presentSheet(.compose)
                }
                .buttonStyle(.borderedProminent)
                
                if !router.path.isEmpty {
                    Button("↩️ Pop Navigation") {
                        router.popNavigation()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🏠 Pop to Root") {
                        router.popToRoot()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

struct DeepLinkButton: View {
    let title: String
    let url: String
    let router: SimpleRouter<Destination, Sheet>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(title) {
                router.navigate(to: url)
            }
            .buttonStyle(.bordered)
            
            Text(url)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 16)
        }
    }
}

struct ListView: View {
    @Environment(SimpleRouter<Destination, Sheet>.self) private var router
    
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { index in
                Button("Item \(index)") {
                    router.navigateTo(.detail(id: "item-\(index)"))
                }
            }
        }
        .navigationTitle("List")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DetailView: View {
    let id: String
    @Environment(SimpleRouter<Destination, Sheet>.self) private var router
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📄 Detail View")
                .font(.largeTitle)
            
            Text("ID: \(id)")
                .font(.title2)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Button("Go to Settings") {
                router.navigateTo(.settings)
            }
            .buttonStyle(.borderedProminent)
            
            Button("View Profile") {
                router.navigateTo(.profile(userId: "user-from-detail"))
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Detail")
    }
}

struct ProfileView: View {
    let userId: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("👤 Profile View")
                .font(.largeTitle)
            
            Text("User ID: \(userId)")
                .font(.title2)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome, \(userId)!")
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("App Settings") {
                HStack {
                    Text("Notifications")
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
                
                HStack {
                    Text("Dark Mode")
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
            }
            
            Section("About") {
                Text("URL Routing Demo v1.0")
                Text("Built with AppRouter")
            }
        }
        .navigationTitle("Settings")
    }
}

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("✍️ Compose")
                .font(.largeTitle)
            
            TextEditor(text: .constant("Write something..."))
                .border(Color.gray, width: 1)
                .frame(height: 200)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Compose")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct HelpView: View {
    var body: some View {
        VStack {
            Text("Help")
                .font(.largeTitle)
            
            Text("This is a help view")
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - URL Scheme Configuration

/*
 Add this to your Info.plist to handle the "myapp://" URL scheme:
 
 <key>CFBundleURLTypes</key>
 <array>
     <dict>
         <key>CFBundleURLName</key>
         <string>myapp.deeplink</string>
         <key>CFBundleURLSchemes</key>
         <array>
             <string>myapp</string>
         </array>
     </dict>
 </array>
 
 Test URLs in iOS Simulator:
 xcrun simctl openurl booted "myapp://list"
 xcrun simctl openurl booted "myapp://detail?id=test123"
 xcrun simctl openurl booted "myapp://profile?userId=alice"
 xcrun simctl openurl booted "myapp://list/detail?id=deep-link"
 */