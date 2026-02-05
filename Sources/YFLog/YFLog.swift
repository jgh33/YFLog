// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Bridge

public enum YFLog {
  public enum Level: Int {
    case verbose = 0
    case debug
    case info
    case warning
    case error
    case fatal
  }
  
  @MainActor
  private static var isStarted = false
  private static var currentLevel: Level {
#if DEBUG
    return .debug
#else
    return .info
#endif
  }
  
  @discardableResult @MainActor
  public static func start(logDirectory: URL? = nil, cacheDays: Int = 7, consoleOpen: Bool = true, level: Level? = nil) -> URL {
    guard !isStarted else { return resolvedLogDirectory(logDirectory) }
    
    let logDir = resolvedLogDirectory(logDirectory)
    try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
    
    let openLevel = bridgeLevel(level ?? currentLevel)
    LogBridge.open(withLogDir: logDir.path, cacheDays: cacheDays, consoleOpen: consoleOpen, level: openLevel)
    isStarted = true
    return logDir
  }
  
  public static func flush() {
    LogBridge.flush()
  }
  
  @MainActor
  public static func stop() {
    LogBridge.close()
    isStarted = false
  }
  
  public static func debug(tag: String? = nil, msg: String, file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
    write(level: .debug, tag: tag, msg: msg, file: file, function: function, line: line)
#endif
  }
  
  public static func info(tag: String? = nil, msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    write(level: .info, tag: tag, msg: msg, file: file, function: function, line: line)
  }
  
  public static func warning(tag: String? = nil, msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    write(level: .warning, tag: tag, msg: msg, file: file, function: function, line: line)
  }
  
  public static func error(tag: String? = nil, msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    write(level: .error, tag: tag, msg: msg, file: file, function: function, line: line)
  }
  
  
  //简单log
  public static func justDebug(tag: String? = nil, msg: String) {
#if DEBUG
    write(level: .debug, tag: tag, msg: msg, file: "", function: "", line: 0)
#endif
  }
  
  public static func justInfo(tag: String? = nil, msg: String) {
    write(level: .info, tag: tag, msg: msg, file: "", function: "", line: 0)
  }
  
  public static func justWarning(tag: String? = nil, msg: String) {
    write(level: .warning, tag: tag, msg: msg, file: "", function: "", line: 0)
  }
  
  public static func justError(tag: String? = nil, msg: String) {
    write(level: .error, tag: tag, msg: msg, file: "", function: "", line: 0)
  }
  
  private static func write(level: Level, tag: String?, msg: String, file: String, function: String, line: Int) {
    let filename = file.isEmpty ? "" : URL(fileURLWithPath: file).lastPathComponent
    LogBridge.log(with: bridgeLevel(level), tag: tag, message: msg, file: filename, function: function, line: Int32(line))
  }
  
  private static func resolvedLogDirectory(_ directory: URL?) -> URL {
    if let directory {
      return directory
    }
    let caches = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
    return caches.appendingPathComponent("Logs", isDirectory: true)
  }
  
  private static func bridgeLevel(_ level: Level) -> LogLevel {
    switch level {
    case .verbose:
      return .verbose
    case .debug:
      return .debug
    case .info:
      return .info
    case .warning:
      return .warn
    case .error:
      return .error
    case .fatal:
      return .fatal
    }
  }
}

