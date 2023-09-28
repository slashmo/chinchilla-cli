//===----------------------------------------------------------------------===//
//
// This source file is part of the Chinchilla open source project
//
// Copyright (c) 2023 Moritz Lang and the Chinchilla project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

public enum MigrationFileGenerator {
    public static func generateMigrationFiles(named name: String, in folderURL: URL) throws {
        try generateMigrationFiles(named: name, in: folderURL, currentDate: Date())
    }

    static func generateMigrationFiles(
        named name: String,
        in folderURL: URL,
        currentDate: @autoclosure () -> Date
    ) throws {
        guard !name.isEmpty else {
            throw MigrationFileGeneratorError.invalidMigrationName(name)
        }

        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw MigrationFileGeneratorError.invalidMigrationsFolder(path: folderURL.path)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")

        let id = dateFormatter.string(from: currentDate())
        let upURL = folderURL.appendingPathComponent("\(id)_\(name).up.sql")
        let downURL = folderURL.appendingPathComponent("\(id)_\(name).down.sql")

        try "\n".write(to: upURL, atomically: false, encoding: .utf8)
        try "\n".write(to: downURL, atomically: false, encoding: .utf8)
    }
}

public enum MigrationFileGeneratorError: Error {
    case invalidMigrationName(String)
    case invalidMigrationsFolder(path: String)
}
