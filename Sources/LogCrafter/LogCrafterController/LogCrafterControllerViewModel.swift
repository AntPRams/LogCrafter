import UIKit
import Combine

protocol LogCrafterControllerViewModelInterface {
    
    var logTextPublisher: CurrentValueSubject<AttributedString, Never> { get set }
    
    func applyAttributes(to message: LCLog) -> AttributedString
    func copyLog()
    func clearLog()
    func search(for query: String)
}

final class LogCrafterControllerViewModel: LogCrafterControllerViewModelInterface {
    
    // MARK: - Properties
    
    var logTextPublisher = CurrentValueSubject<AttributedString, Never>("")
    private var performingSearch = false
    private var searchQuery = ""
    private var manager: LogCrafterManager
    
    // MARK: - Init
    
    /// Initializes a LogViewer with a `LogCrafterManager` instance.
    ///
    /// - Parameter manager: A `LogCrafterManager` instance.
    init(manager: LogCrafterManager = LogCrafterManager.shared) {
        self.manager = manager
        addLogObserver()
        applyLog(from: LogCrafterManager.shared.getLogMessages())
    }
    
    // MARK: - Actions
    
    /// Copies the log messages to the clipboard.
    func copyLog() {
        UIPasteboard.general.string = LogCrafterManager.shared.getLogText()
    }
    
    /// Clears the log messages in the `LogCrafterManager`.
    func clearLog() {
        manager.clearLog()
        logTextPublisher.send(AttributedString(""))
    }
        
    /// Searches for log messages containing the specified query and updates the displayed log.
    ///
    /// - Parameter query: The search query to filter log messages.
    ///
    /// This method updates the displayed log based on the provided search query. If the query is empty, it displays all log messages. Otherwise, it filters log messages that contain the query (case-insensitive).
    func search(for query: String) {
        searchQuery = query
        guard query.isEmpty else {
            let logs = LogCrafterManager.shared.getLogMessages()
            let filteredLogs = logs.filter { $0.labeledMessage.lowercased().contains(query.lowercased()) }
            applyLog(from: filteredLogs)
            return
        }
        applyLog(from: LogCrafterManager.shared.getLogMessages())
    }
}

// MARK: - Helpers

extension LogCrafterControllerViewModel {
    
    /// Applies formatting attributes to a log message and returns an attributed string.
    ///
    /// - Parameter message: The log message to format.
    /// - Returns: An attributed string with applied formatting attributes.
    ///
    /// This method formats a log message with specific attributes, including paragraph spacing, text color, and font style. It returns the message as an attributed string suitable for display.
    func applyAttributes(to message: LCLog) -> AttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        var attributedString = AttributedString(message.labeledMessage)
        paragraphStyle.paragraphSpacing = 10
        attributedString.mergeAttributes(.init([.paragraphStyle: paragraphStyle]))
        attributedString.foregroundColor = message.type.color
        attributedString.font = message.type == .system ? .boldSystemFont(ofSize: 14) : .systemFont(ofSize: 14)
        
        return attributedString
    }
    
    /// Adds an observer to receive notifications of new log messages.
    ///
    /// This method sets up an observer for the `.didReceiveLogMessage` notification, which is posted when a new log message is received. When a new log message is received, it triggers the `handleNewLogMessage(notification:)` method.
    func addLogObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewLogMessage(notification:)),
            name: .didReceiveLogMessage,
            object: nil
        )
    }
    
    /// Handles a new log message received via notification.
    ///
    /// - Parameter notification: The notification containing the log message.
    ///
    /// This method is called when a new log message is received via the `.didReceiveLogMessage` notification. It formats the log message, checks if it matches the current search query, and updates the displayed log text accordingly.
    ///
    /// Example usage:
    /// - This method is automatically called when a new log message is received via notification.
    @objc private func handleNewLogMessage(notification: Notification) {
        if let message = notification.object as? LCLog {
            if message.labeledMessage.lowercased().contains(searchQuery.lowercased()) || searchQuery.isEmpty {
                let formattedMessage = applyAttributes(to: message)
                var combination: AttributedString = logTextPublisher.value
                combination.append(formattedMessage)
                logTextPublisher.send(combination)
            }
        }
    }

    /// Applies formatting to an array of log messages and updates the displayed log.
    ///
    /// - Parameter log: An array of log messages to format and display.
    ///
    /// This method processes an array of log messages by applying formatting attributes to each message. It then updates the displayed log with the formatted content.
    func applyLog(from log: [LCLog]) {
        var logAttributedText = AttributedString("")
        log.forEach { message in
            logAttributedText.append(applyAttributes(to: message))
            logTextPublisher.send(logAttributedText)
        }
    }
}
