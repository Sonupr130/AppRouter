import SwiftUI

/// A type that can serve as a navigation destination.
public protocol DestinationType: Hashable {
    /// Creates a destination from a URL path component and query parameters
    /// - Parameters:
    ///   - path: The URL path component
    ///   - parameters: Query parameters from the URL
    /// - Returns: A destination instance if the path matches, nil otherwise
    static func from(path: String, parameters: [String: String]) -> Self?
}

/// A type that can be presented as a sheet.
public protocol SheetType: Hashable, Identifiable {}

/// A type that can serve as a tab in a tab-based navigation system.
/// Only needed when using the full Router<Tab, Destination, Sheet> for tab-based navigation.
public protocol TabType: Hashable, CaseIterable, Identifiable, Sendable {
    /// The icon name (SF Symbol) for this tab
    var icon: String { get }
}