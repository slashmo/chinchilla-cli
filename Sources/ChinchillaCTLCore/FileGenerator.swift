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
import Logging

public enum FileGenerator {
    public static func generateMigrationFiles(named name: String, in folderURL: URL, logger: Logger) throws {
        try generateMigrationFiles(named: name, in: folderURL, logger: logger, currentDate: Date())
    }

    static func generateMigrationFiles(
        named name: String,
        in folderURL: URL,
        logger: Logger,
        currentDate: @autoclosure () -> Date
    ) throws {
        guard !name.isEmpty, !name.contains(".") else {
            logger.critical("The given migration name is invalid.", metadata: ["name": "\(name)"])
            throw FileGeneratorError()
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")

        let id = dateFormatter.string(from: currentDate())
        let upURL = folderURL.appendingPathComponent("\(id)_\(name).up.sql")
        let downURL = folderURL.appendingPathComponent("\(id)_\(name).down.sql")

        try createMigrationFile(at: upURL, logger: logger)
        try createMigrationFile(at: downURL, logger: logger)

        logger.info("Generated migration files.", metadata: ["id": "\(id)"])
    }

    private static func createMigrationFile(at url: URL, logger: Logger) throws {
        let fileManager = FileManager.default

        guard !fileManager.fileExists(atPath: url.path),
              fileManager.createFile(atPath: url.path, contents: Data("\n".utf8))
        else {
            logger.critical("Failed to generate migration file.", metadata: ["path": "\(url.path)"])
            throw FileGeneratorError()
        }
    }
}

public struct FileGeneratorError: Error, CustomStringConvertible {
    public let description = "FileGenerator"
}
