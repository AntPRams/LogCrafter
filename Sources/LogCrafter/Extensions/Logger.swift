import OSLog

// A extension needed to filter the system messages to avoid repetition in the logs
extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let logCrafter = Logger(subsystem: subsystem, category: "LCFT")
}
