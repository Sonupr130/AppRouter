import SwiftUI

/// A simple navigation router for single-stack navigation with sheet presentation.
/// Use this when you don't need tab-based navigation, just a single NavigationStack.
@Observable
@MainActor
public final class SimpleRouter<Destination: DestinationType, Sheet: SheetType> {
    
    // MARK: - Public Properties
    
    /// The navigation path for the router
    public var path: [Destination] = []
    
    /// The currently presented sheet, if any
    public var presentedSheet: Sheet?
    
    // MARK: - Initialization
    
    /// Creates a new simple router
    public init() {}
    
    // MARK: - Navigation Methods
    
    /// Pops the navigation stack to the root
    public func popToRoot() {
        path = []
    }
    
    /// Pops the last destination from the navigation stack
    public func popNavigation() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    /// Navigates to the specified destination
    /// - Parameter destination: The destination to navigate to
    public func navigateTo(_ destination: Destination) {
        path.append(destination)
    }
    
    // MARK: - Sheet Methods
    
    /// Presents the specified sheet
    /// - Parameter sheet: The sheet to present
    public func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }
    
    /// Dismisses the currently presented sheet
    public func dismissSheet() {
        presentedSheet = nil
    }
}