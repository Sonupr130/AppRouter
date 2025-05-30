import SwiftUI

// MARK: - Environment Extensions

extension EnvironmentValues {
    /// The currently active tab in the environment
    @Entry public var currentTab: (any TabType)? = nil
}