import Foundation

/// Helper for shared URL navigation logic
internal enum URLNavigationHelper {
    /// Navigates to a URL by parsing its components and applying destinations
    /// - Parameters:
    ///   - url: The URL to navigate to
    ///   - applyDestinations: Closure that applies the parsed destinations
    /// - Returns: True if navigation was successful, false otherwise
    static func navigate<Destination: DestinationType>(
        url: URL,
        applyDestinations: ([Destination]) -> Void
    ) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        // Extract path components from host and path (e.g., myapp://detail/list)
        var pathComponents: [String] = []
        
        // Start with host as first component
        if let host = components.host {
            pathComponents.append(host)
        }
        
        // Add path components if they exist
        if !components.path.isEmpty {
            let pathParts = components.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
            pathComponents.append(contentsOf: pathParts)
        }
        
        guard !pathComponents.isEmpty else { return false }
        
        let queryParameters = parseQueryParameters(from: components.queryItems)
        
        // Convert path components to destinations
        var destinations: [Destination] = []
        for pathComponent in pathComponents {
            if let destination = Destination.from(path: pathComponent, parameters: queryParameters) {
                destinations.append(destination)
            }
        }
        
        guard !destinations.isEmpty else { return false }
        
        applyDestinations(destinations)
        return true
    }
    
    /// Parses query parameters from URL components
    /// - Parameter queryItems: Array of URLQueryItem from URLComponents
    /// - Returns: Dictionary of query parameters
    private static func parseQueryParameters(from queryItems: [URLQueryItem]?) -> [String: String] {
        guard let queryItems = queryItems else { return [:] }
        
        var parameters: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                parameters[item.name] = value
            }
        }
        return parameters
    }
}