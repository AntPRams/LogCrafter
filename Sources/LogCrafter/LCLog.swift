import Foundation
import OSLog

/// Represents a log message with a specified type, message content, timestamp and file.
public struct LCLog {
    /// The type of the log message.
    let type: LogType
    /// The content of the log message.
    let message: String
    /// The timestamp when the log message was created.
    let timeStamp: Date
    
    /// Initializes a log message with the given type, associated file, and message content.
    ///
    /// - Parameters:
    ///   - type: The type of the log message.
    ///   - message: The content of the log message.
    ///
    /// This initializer creates a log message with the specified type, associated file, message content, and a timestamp indicating when it was created. 
    /// The log message is then published to the LogCrafterManager and, if is not a system message, to the Logger.
    @discardableResult
    public init(_ type: LogType, message: String) {
        self.type = type
        self.message = message
        self.timeStamp = .now
        
        publishLog()
    }
    
    /// Returns the log message as a labeled string with a formatted timestamp and associated file.
    var labeledMessage: String {
        let formattedDate = formatTimestamp()
        return "[\(formattedDate)]\(type.label) - \(message)\n"
    }
}

private extension LCLog {
    /// Formats the timestamp into an HH:mm:ss string.
    ///
    /// - Returns: A formatted string representing the timestamp.
    func formatTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let formattedDate = dateFormatter.string(from: timeStamp)
        
        return formattedDate
    }
    
    /// Publishes the log message to the LogCrafterManager and, if is not a system message, to the Logger.
    func publishLog() {
        LogCrafterManager.shared.appendLogMessage(self)
        
        switch type {
        case .info:
            Logger.logCrafter.info("\(message)")
        case .debug:
            Logger.logCrafter.debug("\(message)")
        case .warning:
            Logger.logCrafter.warning("\(message)")
        case .error:
            Logger.logCrafter.error("\(message)")
        case .fault:
            Logger.logCrafter.critical("\(message)")
        case .custom(let label):
            Logger.logCrafter.info("[\(label)] \(message)")
        case .system:
            break
        }
    }
}
