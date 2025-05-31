import Foundation
import SwiftUI

// MARK: - Environment Extensions

extension EnvironmentValues {
  /// The currently active tab in the environment
  @Entry public var currentTab: (any TabType)? = nil
}

// MARK: - URL Extensions

extension URL {
  /// Creates a URL for deep linking with the specified destinations
  /// - Parameters:
  ///   - scheme: The URL scheme (e.g., "myapp")
  ///   - destinations: Array of destinations to navigate through
  ///   - parameters: Query parameters to include
  /// - Returns: A URL for deep linking, or nil if construction fails
  public static func deepLink<Destination: DestinationType>(
    scheme: String,
    destinations: [Destination],
    parameters: [String: String] = [:]
  ) -> URL? {
    guard !destinations.isEmpty else { return nil }

    var components = URLComponents()
    components.scheme = scheme

    // Use host for the first destination
    components.host = String(describing: destinations.first!)

    // Add remaining destinations as path if they exist
    if destinations.count > 1 {
      components.path =
        "/" + destinations.dropFirst().map { String(describing: $0) }.joined(separator: "/")
    }

    if !parameters.isEmpty {
      components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }

    return components.url
  }
}
