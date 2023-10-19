import Foundation
import OSLog

/// Manages and handles log messages for debugging and development.
public class LogCrafterManager {
    
    // MARK: - Properties
    
    static public let shared = LogCrafterManager()
    private var logMessages = [LCLog]()
    private let logCrafterManagerQueue = DispatchQueue(label: "LogCrafterManager.Queue", attributes: .concurrent)
    
    // MARK: - Init
    
    /// Private initializer to ensure a single shared instance.
    private init() { }
    
    /// Starts logging operations, including capturing output to console. On a physical device, this method will have no effect.
    ///
    /// - Note: This method is primarily intended for use in the simulator, where system messages can be displayed.
    ///
    /// This method should be called at the app's launch, primarily in the `AppDelegate`.
    public func bootOperation() {
        #if targetEnvironment(simulator)
        openConsolePipe()
        #endif
    }
    
    // MARK: - Data accessors
    
    /// Appends a log message to the manager's log messages.
    ///
    /// - Parameter message: The log message to append.
    ///
    /// This method appends a log message to the manager, making it available for later retrieval or display.
    /// Additionally, it triggers a notification named `.didReceiveLogMessage` for the new message that was appended.
    func appendLogMessage(_ message: LCLog) {
        logCrafterManagerQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            logMessages.append(message)
        }
        NotificationCenter.default.post(
            name: .didReceiveLogMessage,
            object: message,
            userInfo: nil
        )
    }
    
    /// Retrieves the concatenated text representation of log messages.
    ///
    /// - Returns: A string containing the log messages in the manager.
    ///
    /// This method retrieves all stored log messages and returns them as a single string for display or further processing.
    /// Its being used primarly to have the log available to copy to the clipboard.
    func getLogText() -> String {
        logCrafterManagerQueue.sync {
            logMessages.map { "\($0.labeledMessage)"}.joined(separator: "\n")
        }
    }
    
    /// Retrieves all log messages stored in the manager.
    ///
    /// - Returns: An array of `LCLog` objects.
    func getLogMessages() -> [LCLog] {
        logCrafterManagerQueue.sync {
            return logMessages
        }
    }
    
    /// Filters log messages based on a query string.
    ///
    /// - Parameter query: The query string used to filter log messages.
    /// - Returns: An array of `LCLog` objects matching the query.
    ///
    /// This method filters log messages based on a query string, returning only the log messages that contain the query.
    func filterLog(query: String) -> [LCLog] {
        logCrafterManagerQueue.sync {
            return logMessages.filter { logMessage in
                logMessage.message.contains(query)
            }
        }
    }
    
    /// Clears all stored log messages.
    func clearLog() {
        logCrafterManagerQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            logMessages.removeAll()
        }
    }
}

private extension LogCrafterManager {
    
    /// Sets up and captures console output to the manager.
    ///
    /// - Note: This method only works when debugging in the simulator and has no effect when running the app on physical devices.
    ///
    /// This method establishes a Pipe to capture console output and redirects it to the manager for storage.
    /// It also observes data coming from the Pipe and filters it to create log messages.
    func openConsolePipe() {
        let pipe = Pipe()
        
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        // Observe the data coming from the Pipe
        NotificationCenter.default.addObserver(
            forName: .NSFileHandleDataAvailable,
            object: pipe.fileHandleForReading,
            queue: nil
        ) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let output = pipe.fileHandleForReading.availableData
                if let outputString = String(data: output, encoding: .utf8) {
                    filter(outputString)
                }
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    /// Filters and processes console output to create log messages.
    ///
    /// - Parameter outputString: The console output to be processed into log messages.
    ///
    /// This method processes console output by filtering, formatting, and converting it into log messages stored in the manager.
    func filter(_ outputString: String) {
        let stringComponents = outputString.components(separatedBy: "\n")
        let filteredComponents = stringComponents.filter { !$0.contains("[LCFT]") }
        let filteredString = filteredComponents.joined(separator: "\n")
        if !filteredString.isEmpty {
            LCLog(.system, message: filteredString)
        }
    }
}
