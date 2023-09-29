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

final class FileConfigParserTests: XCTestCase {
    private var tempFolderURL: URL!

    override func setUp() async throws {
        tempFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempFolderURL, withIntermediateDirectories: false)
    }

    override func tearDown() async throws {
        try FileManager.default.removeItem(at: tempFolderURL)
    }

    func test_configAtPath_withValidV1Config_returnsConfig() throws {
        let filePath = tempFolderURL.appendingPathComponent("chinchilla.yml").path
        let fileContents = """
        version: 1.0
        migrations_path: ./migrations
        """
        XCTAssertNoThrow(try fileContents.write(toFile: filePath, atomically: false, encoding: .utf8))

        let config = try FileConfigParser.config(at: filePath)

        XCTAssertEqual(config, FileConfig.v1(.init(migrationsFolderPath: "./migrations")))
    }

    func test_configAtPath_withoutFileAtPath_throwsMissingFileError() throws {
        let missingFilePath = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("chinchilla.yml")
            .path

        do {
            let config = try FileConfigParser.config(at: missingFilePath)
            XCTFail("Successfully parsed config: \(config)")
        } catch FileConfigError.missingFile(path: missingFilePath) {}
    }

    func test_configAtPath_withNonYAMLContents_throwsMalformedFileError() throws {
        let filePath = tempFolderURL.appendingPathComponent("chinchilla.yml").path

        XCTAssertNoThrow(try #"{"wrong": "format"}"#.write(toFile: filePath, atomically: false, encoding: .utf8))

        do {
            let config = try FileConfigParser.config(at: filePath)
            XCTFail("Successfully parsed config: \(config)")
        } catch FileConfigError.malformedFile(path: filePath) {}
    }

    func test_configAtPath_withUnsupportedVersion_throwsUnsupportedVersionError() throws {
        let filePath = tempFolderURL.appendingPathComponent("chinchilla.yml").path
        let fileContents = """
        version: 42.0
        """
        XCTAssertNoThrow(try fileContents.write(toFile: filePath, atomically: false, encoding: .utf8))

        do {
            let config = try FileConfigParser.config(at: filePath)
            XCTFail("Successfully parsed config: \(config)")
        } catch FileConfigError.unsupportedVersion(version: "42.0", supportedVersions: ["1.0"]) {}
    }
}
