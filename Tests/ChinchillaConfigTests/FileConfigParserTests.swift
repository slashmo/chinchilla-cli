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

final class FileConfigParserTests: XCTestCase {
    override func setUp() async throws {
        LoggingSystem.bootstrapInternal { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }
    }

    func test_config_withValidV1Config_returnsDecodedConfig() throws {
        let logger = Logger(label: #function)
        let yaml = """
        version: 1.0
        migrations_path: ./migrations
        """

        let config = try FileConfigParser.config(from: yaml, logger: logger)
        XCTAssertEqual(config, .v1(FileConfig.V1(migrationsFolderPath: "./migrations")))
    }

    func test_config_withValidV1Config_withoutMigrationsPath_returnsDecodedConfig() throws {
        let logger = Logger(label: #function)
        let yaml = "version: 1.0"

        let config = try FileConfigParser.config(from: yaml, logger: logger)
        XCTAssertEqual(config, .v1(FileConfig.V1(migrationsFolderPath: nil)))
    }

    func test_config_withMissingVersion_throwsConfigError() throws {
        let logger = Logger(label: #function)
        let yaml = "migrations_path: ./migrations"

        do {
            let config = try FileConfigParser.config(from: yaml, logger: logger)
            XCTFail("Successfully decoded config: \(config)")
        } catch is ConfigError {}
    }

    func test_config_withUnsupportedVersion_throwsConfigError() throws {
        let logger = Logger(label: #function)
        let yaml = "version: 42.0"

        do {
            let config = try FileConfigParser.config(from: yaml, logger: logger)
            XCTFail("Successfully decoded config: \(config)")
        } catch is ConfigError {}
    }
}
