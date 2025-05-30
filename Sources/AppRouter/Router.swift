import SwiftUI

/// A generic navigation router that manages tab-based navigation state with navigation stacks and sheet presentation.
@Observable
@MainActor
public final class Router<Tab: TabType, Destination: DestinationType, Sheet: SheetType> {
    
    // MARK: - Private Properties
    
    /// Navigation paths for each tab
    private var paths: [Tab: [Destination]] = [:]
    
    // MARK: - Public Properties
    
    /// The currently selected tab
    public var selectedTab: Tab
    
    /// The currently presented sheet, if any
    public var presentedSheet: Sheet?
    
    // MARK: - Initialization
    
    /// Creates a new router with the specified initial tab.
    /// - Parameter initialTab: The tab to select when the router is created
    public init(initialTab: Tab) {
        self.selectedTab = initialTab
    }
    
    // MARK: - Path Access
    
    /// Subscript access to navigation paths for each tab
    public subscript(tab: Tab) -> [Destination] {
        get { paths[tab] ?? [] }
        set { paths[tab] = newValue }
    }
    
    /// The navigation path for the currently selected tab
    public var selectedTabPath: [Destination] {
        paths[selectedTab] ?? []
    }
    
    // MARK: - Navigation Methods
    
    /// Pops the navigation stack to the root for the specified tab (or current tab if nil).
    /// - Parameter tab: The tab to pop to root. If nil, uses the currently selected tab.
    public func popToRoot(for tab: Tab? = nil) {
        paths[tab ?? selectedTab] = []
    }
    
    /// Pops the last destination from the navigation stack for the specified tab.
    /// - Parameter tab: The tab to pop from. If nil, uses the currently selected tab.
    public func popNavigation(for tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        if paths[targetTab]?.isEmpty == false {
            paths[targetTab]?.removeLast()
        }
    }
    
    /// Navigates to the specified destination for the specified tab.
    /// - Parameters:
    ///   - destination: The destination to navigate to
    ///   - tab: The tab to navigate in. If nil, uses the currently selected tab.
    public func navigateTo(_ destination: Destination, for tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        if paths[targetTab] == nil {
            paths[targetTab] = [destination]
        } else {
            paths[targetTab]?.append(destination)
        }
    }
    
    // MARK: - Sheet Methods
    
    /// Presents the specified sheet.
    /// - Parameter sheet: The sheet to present
    public func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }
    
    /// Dismisses the currently presented sheet.
    public func dismissSheet() {
        presentedSheet = nil
    }
}