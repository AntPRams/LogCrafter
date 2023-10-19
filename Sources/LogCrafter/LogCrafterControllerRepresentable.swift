import UIKit

/// A protocol that simplifies the presentation of the LogCrafter Console for log viewing and management.
///
/// Conforming view controllers can easily present the LogCrafter Console Controller by implementing the `logCrafterConsole()` method.
/// This interface serves the purpose of providing a straightforward tool for displaying the LogCrafter Console.
public protocol LogCrafterControllerRepresentable: AnyObject {
    
    func logCrafterConsole() -> UIViewController
}

/// A default implementation of the `LogCrafterControllerRepresentable` protocol.
public extension LogCrafterControllerRepresentable {
    
    /// Presents a LogCrafter console view controller with default configuration.
    ///
    /// - Returns: A `LogCrafterConsoleController` instance that displays the LogCrafter console.
    ///
    /// This default implementation creates an instance of `LogCrafterController` and configures its sheet presentation properties for size and realted behaviors.
    ///
    /// Example usage:
    /// ```
    /// class SomeViewController: UIViewController, LogCrafterControllerRepresentable {
    ///     func presentConsole() {
    ///         let viewController = logCrafterConsole()
    ///         present(viewController, animated: true)
    ///     }
    /// }
    /// ```
    func logCrafterConsole() -> UIViewController {
        let viewController = LogCrafterConsoleController()
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        return viewController
    }
}
