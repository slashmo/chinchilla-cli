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

import ChinchillaConfig
@testable import Logging
import XCTest

final class ConfigValueResolverTests: XCTestCase {
    private var foldersToDelete = Set<URL>()

    override func setUp() async throws {
        LoggingSystem.bootstrapInternal { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }
    }

    override func tearDown() async throws {
        for url in foldersToDelete {
            XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
        }
    }

    func test_migrationsFolderURL_withExistingFolderAtExplicitPath_returnsURL() throws {
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertNoThrow(
            try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
        )
        foldersToDelete.insert(migrationsFolderURL)

        let logger = Logger(label: #function)
        let url = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: migrationsFolderURL.path,
            environment: ["MIGRATIONS_PATH": "environment"],
            fileConfig: .v1(FileConfig.V1(migrationsFolderPath: "config")),
            logger: logger
        )

        XCTAssertEqual(url.path, migrationsFolderURL.path)
    }

    func test_migrationsFolderURL_withExistingFolderAtEnvironmentVariablePath_returnsURL() throws {
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertNoThrow(
            try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
        )
        foldersToDelete.insert(migrationsFolderURL)

        let logger = Logger(label: #function)
        let url = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: nil,
            environment: ["MIGRATIONS_PATH": "\(migrationsFolderURL.path)"],
            fileConfig: .v1(FileConfig.V1(migrationsFolderPath: "config")),
            logger: logger
        )

        XCTAssertEqual(url.path, migrationsFolderURL.path)
    }

    func test_migrationsFolderURL_withExistingFolderAtFileConfigPath_returnsURL() throws {
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertNoThrow(
            try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
        )
        foldersToDelete.insert(migrationsFolderURL)

        let logger = Logger(label: #function)
        let url = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: nil,
            environment: [:],
            fileConfig: .v1(FileConfig.V1(migrationsFolderPath: migrationsFolderURL.path)),
            logger: logger
        )

        XCTAssertEqual(url.path, migrationsFolderURL.path)
    }

    func test_migrationsFolderURL_withoutFileConfig_withExistingFolderAtDefaultLocation_returnsURL() throws {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let migrationsFolderURL = currentDirectoryURL.appendingPathComponent("migrations")
        XCTAssertNoThrow(
            try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
        )
        foldersToDelete.insert(migrationsFolderURL)

        let logger = Logger(label: #function)
        let url = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: nil,
            environment: [:],
            fileConfig: nil,
            logger: logger
        )

        XCTAssertEqual(url.path, migrationsFolderURL.path)
    }

    func test_migrationsFolderURL_withFileConfigButNoMigrationsPath_withExistingFolderAtDefaultLocation_returnsURL() throws {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let migrationsFolderURL = currentDirectoryURL.appendingPathComponent("migrations")
        XCTAssertNoThrow(
            try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
        )
        foldersToDelete.insert(migrationsFolderURL)

        let logger = Logger(label: #function)
        let url = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: nil,
            environment: [:],
            fileConfig: .v1(FileConfig.V1(migrationsFolderPath: nil)),
            logger: logger
        )

        XCTAssertEqual(url.path, migrationsFolderURL.path)
    }

    func test_migrationsFolderURL_withMissingFolderAtExplicitLocation_throwsConfigError() throws {
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let logger = Logger(label: #function)

        do {
            let url = try ConfigValueResolver.migrationsFolderURL(
                explicitPath: migrationsFolderURL.path,
                environment: [:],
                fileConfig: nil,
                logger: logger
            )
            XCTFail("Expected config error, got url: \(url)")
        } catch is ConfigError {}
    }
}
