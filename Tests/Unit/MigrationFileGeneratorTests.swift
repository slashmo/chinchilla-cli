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
import XCTest

final class MigrationFileGeneratorTests: XCTestCase {
    private var migrationsFolderURL: URL!

    override func setUp() async throws {
        migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
    }

    override func tearDown() async throws {
        try FileManager.default.removeItem(at: migrationsFolderURL)
    }

    func test_generateMigrationFiles_withValidName_withValidMigrationsFolder_generatesUpFile() throws {
        let date = Date(timeIntervalSince1970: 1_695_928_506)

        XCTAssertNoThrow(
            try MigrationFileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL, currentDate: date)
        )

        let upFileURL = migrationsFolderURL.appendingPathComponent("20230928191506_test.up.sql")
        let contents = try String(contentsOf: upFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withValidName_withValidMigrationsFolder_generatesDownFile() throws {
        let date = Date(timeIntervalSince1970: 1_695_928_506)

        XCTAssertNoThrow(
            try MigrationFileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL, currentDate: date)
        )

        let downFileURL = migrationsFolderURL.appendingPathComponent("20230928191506_test.down.sql")
        let contents = try String(contentsOf: downFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withCurrentDate_generatesUpFile() throws {
        XCTAssertNoThrow(try MigrationFileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL))

        let migrationFileURLs = try FileManager.default.contentsOfDirectory(
            at: migrationsFolderURL,
            includingPropertiesForKeys: nil
        )
        let upFileURL = try XCTUnwrap(migrationFileURLs.first(where: { $0.lastPathComponent.hasSuffix("up.sql") }))
        let contents = try String(contentsOf: upFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withCurrentDate_generatesDownFile() throws {
        XCTAssertNoThrow(try MigrationFileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL))

        let migrationFileURLs = try FileManager.default.contentsOfDirectory(
            at: migrationsFolderURL,
            includingPropertiesForKeys: nil
        )
        let downFileURL = try XCTUnwrap(migrationFileURLs.first(where: { $0.lastPathComponent.hasSuffix("down.sql") }))
        let contents = try String(contentsOf: downFileURL)
        XCTAssertEqual(contents, "\n")
    }

    func test_generateMigrationFiles_withEmptyName_throwsError() throws {
        do {
            try MigrationFileGenerator.generateMigrationFiles(named: "", in: migrationsFolderURL)
        } catch MigrationFileGeneratorError.invalidMigrationName("") {}
    }

    func test_generateMigrationFiles_withNonExistingFolderURL_throwsError() throws {
        let migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try MigrationFileGenerator.generateMigrationFiles(named: "test", in: migrationsFolderURL)
        } catch MigrationFileGeneratorError.invalidMigrationsFolder(path: migrationsFolderURL.path) {}
    }
}
