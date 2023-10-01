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

@testable import ChinchillaCTLCore
@testable import Logging
import XCTest

final class FileGeneratorTests: XCTestCase {
    private var migrationsFolderURL: URL!

    override func setUp() async throws {
        LoggingSystem.bootstrapInternal { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }

        migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
    }

    override func tearDown() async throws {
        try FileManager.default.removeItem(at: migrationsFolderURL)
    }

    func test_generateMigrationFiles_withValidName_withValidMigrationsFolder_generatesUpFile() throws {
        let logger = Logger(label: #function)
        let date = Date(timeIntervalSince1970: 1_695_928_506)

        XCTAssertNoThrow(
            try FileGenerator.generateMigrationFiles(
                named: "test",
                in: migrationsFolderURL,
                logger: logger,
                currentDate: date
            )
        )

        let upFileURL = migrationsFolderURL.appendingPathComponent("20230928191506_test.up.sql")
        let contents = try String(contentsOf: upFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withValidName_withValidMigrationsFolder_generatesDownFile() throws {
        let logger = Logger(label: #function)
        let date = Date(timeIntervalSince1970: 1_695_928_506)

        XCTAssertNoThrow(
            try FileGenerator.generateMigrationFiles(
                named: "test",
                in: migrationsFolderURL,
                logger: logger,
                currentDate: date
            )
        )

        let downFileURL = migrationsFolderURL.appendingPathComponent("20230928191506_test.down.sql")
        let contents = try String(contentsOf: downFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withCurrentDate_generatesUpFile() throws {
        let logger = Logger(label: #function)

        XCTAssertNoThrow(
            try FileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL, logger: logger)
        )

        let migrationFileURLs = try FileManager.default.contentsOfDirectory(
            at: migrationsFolderURL,
            includingPropertiesForKeys: nil
        )
        let upFileURL = try XCTUnwrap(migrationFileURLs.first(where: { $0.lastPathComponent.hasSuffix("up.sql") }))
        let contents = try String(contentsOf: upFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withCurrentDate_generatesDownFile() throws {
        let logger = Logger(label: #function)

        XCTAssertNoThrow(
            try FileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL, logger: logger)
        )

        let migrationFileURLs = try FileManager.default.contentsOfDirectory(
            at: migrationsFolderURL,
            includingPropertiesForKeys: nil
        )
        let downFileURL = try XCTUnwrap(migrationFileURLs.first(where: { $0.lastPathComponent.hasSuffix("down.sql") }))
        let contents = try String(contentsOf: downFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withEmptyName_throwsFileGeneratorError() throws {
        let logger = Logger(label: #function)

        do {
            try FileGenerator.generateMigrationFiles(named: "", in: migrationsFolderURL, logger: logger)
        } catch is FileGeneratorError {}
    }

    func test_generateMigrationFiles_withNonExistingFolderURL_throwsFileGeneratorError() throws {
        let logger = Logger(label: #function)
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try FileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL, logger: logger)
        } catch is FileGeneratorError {}
    }
}
