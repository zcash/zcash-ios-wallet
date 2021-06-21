//
//  SimpleLogger.swift
//  wallet
//
//  Created by Francisco Gindre on 3/9/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit


class SimpleLogger: ZcashLightClientKit.Logger {
    enum LogLevel: Int {
        case debug
        case error
        case warning
        case event
        case info
    }
    
    enum LoggerType {
        case printerLog
    }
    
    var level: LogLevel
    var loggerType: LoggerType
    
    init(logLevel: LogLevel, type: LoggerType = .printerLog) {
        self.level = logLevel
        self.loggerType = type
    }
    
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue == LogLevel.debug.rawValue else { return }
        log(level: "DEBUG 🐞", message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.error.rawValue else { return }
        log(level: "ERROR 💥", message: message, file: file, function: function, line: line)
    }
    
    func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
           guard level.rawValue <= LogLevel.warning.rawValue else { return }
           log(level: "WARNING ⚠️", message: message, file: file, function: function, line: line)
    }

    func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.event.rawValue else { return }
        log(level: "EVENT ⏱", message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        guard level.rawValue <= LogLevel.info.rawValue else { return }
        log(level: "INFO ℹ️", message: message, file: file, function: function, line: line)
    }
    
    private func log(level: String, message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        let fileName = (String(describing: file) as NSString).lastPathComponent
        switch loggerType {
        case .printerLog:
            print("[\(level)] \(fileName) - \(function) - line: \(line) -> \(message)")
        }
    }
}

#if ENABLE_LOGGING

import zealous_logger
class SimpleFileLogger: ZcashLightClientKit.Logger {
    
    let logger: zealous_logger.Logger
    
    init(logsDirectory: URL, alsoPrint: Bool = true, level: LogLevel = .debug) {
        self.logger = ZealousLogger.logger(.fileLogger(logsDirectory: logsDirectory, alsoPrint: alsoPrint), level: level)
    }
    
    func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        self.logger.debug("DEBUG 🐞 - \(message)", file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        self.logger.error("ERROR 💥 - \(message)", file: file, function: function, line: line)
    }
    
    func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        self.logger.warn("WARNING ⚠️ - \(message)", file: file, function: function, line: line)
    }

    func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        self.logger.event("EVENT ⏱ - \(message)", file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        self.logger.info("INFO ℹ️ - \(message)", file: file, function: function, line: line)
    }
    
}

#endif
