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

final class FileConfigLoaderTests: XCTestCase {
    private var filesToDelete = Set<URL>()

    override func setUp() async throws {
        LoggingSystem.bootstrapInternal { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }
    }

    override func tearDown() async throws {
        for url in filesToDelete {
            XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
        }
    }

    func test_fileConfig_withValidFileAtExplicitPath_returnsFileConfig() throws {
        let logger = Logger(label: #function)
        let url = temporaryConfigFileURL()
        try createTemporaryFile(contents: "version: 1.0", at: url)

        let config = try XCTUnwrap(FileConfigLoader.fileConfig(explicitPath: url.path, logger: logger))

        XCTAssertEqual(config, .v1(FileConfig.V1(migrationsFolderPath: nil)))
    }

    func test_fileConfig_withInvalidFileAtExplicitPath_throwsFileConfigError() throws {
        let logger = Logger(label: #function)
        let url = temporaryConfigFileURL()
        try createTemporaryFile(contents: "", at: url)

        do {
            let config = try FileConfigLoader.fileConfig(explicitPath: url.path, logger: logger)
            if let config {
                XCTFail("Successfully loaded config: \(config)")
            } else {
                XCTFail("Successfully skipped loading")
            }
        } catch is ConfigError {}
    }

    func test_fileConfig_withExistingValidFileAtDefaultPath_returnsFileConfig() throws {
        let logger = Logger(label: #function)
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = currentDirectoryURL.appendingPathComponent("chinchilla.yml")
        try createTemporaryFile(contents: "version: 1.0", at: url)

        let config = try XCTUnwrap(FileConfigLoader.fileConfig(explicitPath: nil, logger: logger))

        XCTAssertEqual(config, .v1(FileConfig.V1(migrationsFolderPath: nil)))
    }

    func test_fileConfig_withoutFileAtDefaultPath_returnsNil() throws {
        let logger = Logger(label: #function)

        XCTAssertNil(try FileConfigLoader.fileConfig(explicitPath: nil, logger: logger))
    }

    private func createTemporaryFile(contents: String, at url: URL) throws {
        XCTAssertNoThrow(try Data(contents.utf8).write(to: url))
        filesToDelete.insert(url)
    }

    private func temporaryConfigFileURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).yml")
    }
}
