//
//  LogfileUtils.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 3/13/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation


extension URL {
    static func logsDirectory() throws -> URL {
        try documentsDirectory().appendingPathComponent("logs",isDirectory: true)
    }
}

struct LogfileHelper {
    
    static func allLogfiles() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: try URL.logsDirectory(), includingPropertiesForKeys: [URLResourceKey.attributeModificationDateKey], options: .skipsSubdirectoryDescendants)
    }
    
    static func latestLogfile() throws -> URL? {
        try allLogfiles().sorted(by: { (a, b) -> Bool in
            guard let aDate = try a.resourceValues(forKeys: [.attributeModificationDateKey]).attributeModificationDate,
                  let bDate = try b.resourceValues(forKeys: [.attributeModificationDateKey]).attributeModificationDate
            else {
                return false
            }
            
            return aDate > bDate
        }).first
    }
}
