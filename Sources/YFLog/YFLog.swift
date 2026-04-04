// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Bridge
import Logging

public enum YFLog {}

extension YFLog {

    public static func bootstrap(fileURL: URL? = nil, cacheDays: Int = 7) {
        let url = resolvedLogDirectory(fileURL)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        #if DEBUG
        let consoleOpen = true
        let level = LogLevel.debug
        #else
        let consoleOpen = false
        let level = LogLevel.info
        #endif
        LogBridge.open(withLogDir: url.path, cacheDays: cacheDays, consoleOpen: consoleOpen, level: level)
        LoggingSystem.bootstrap { label in
            return YFLogHandler(label: label)
        }
    }
  
  
    public static func flush() {
        LogBridge.flush()
    }
    
    @MainActor
    public static func stop() {
        LogBridge.close()
    }
  
  private static func resolvedLogDirectory(_ directory: URL?) -> URL {
    if let directory {
      return directory
    }
    let caches = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
    return caches.appendingPathComponent("Logs", isDirectory: true)
  }
  
}

struct YFLogHandler: LogHandler {
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .debug
    private let label: String
    
    init(label: String) {
        self.label = label
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
        
    public func log(event: LogEvent) {
        LogBridge.log(with: bridgeLevel(event.level), tag: label, message: event.message.description, file: event.file, function: event.function, line: Int32(event.line))
    }
    
    private func bridgeLevel(_ level: Logging.Logger.Level) -> LogLevel {
        switch level {
        case .trace:      return .debug
        case .debug:      return .debug
        case .info:       return .info
        case .notice:     return .info
        case .warning:    return .warn
        case .error:      return .error
        case .critical:   return .verbose
        }
    }
}
