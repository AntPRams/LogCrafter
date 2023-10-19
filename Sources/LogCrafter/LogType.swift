import UIKit

/// An enumeration that represents different types of log messages.
public enum LogType: Equatable {
    case info
    case debug
    case warning
    case error
    case fault
    case system
    case custom(String)
    
    /// The color associated with the log type, which can be used for styling.
    var color: UIColor {
        switch self {
            
        case .info, .debug, .custom(_): return .label
        case .warning, .error: return .systemOrange
        case .fault: return .red
        case .system: return .systemBlue
        }
    }
    
    /// The label associated with the log type, typically displayed in log messages.
    var label: String {
        switch self {
        case .info: return "[INFO]"
        case .debug: return "[DEBUG]"
        case .warning: return "[WARNING]"
        case .error: return "[ERROR]"
        case .fault: return "[FAULT]"
        case .system: return "[SYSTEM]"
        case .custom(let customLabel): return "[\(customLabel)]"
        }
    }
}
