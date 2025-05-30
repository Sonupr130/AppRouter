import SwiftUI

/// A type that can serve as a navigation destination.
public protocol DestinationType: Hashable {}

/// A type that can be presented as a sheet.
public protocol SheetType: Hashable, Identifiable {}

/// A type that can serve as a tab in a tab-based navigation system.
/// Only needed when using the full Router<Tab, Destination, Sheet> for tab-based navigation.
public protocol TabType: Hashable, CaseIterable, Identifiable, Sendable {
    /// The icon name (SF Symbol) for this tab
    var icon: String { get }
}