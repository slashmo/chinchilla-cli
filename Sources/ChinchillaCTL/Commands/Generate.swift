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

import ArgumentParser
import ChinchillaConfig
import ChinchillaCTLCore
import Foundation
import Logging

struct Generate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate 'up' and 'down' SQL migration files with a given name.",
        discussion: """
        Generates two SQL files for a given migration name. The '.up.sql' file is used \
        for performing the migration, whereas '.down.sql' is used to revert the migration. \
        For example, if an 'up.sql' file creates a table, the corresponding 'down.sql' file should drop that table.
        """
    )

    @OptionGroup private var options: GlobalOptions

    @Argument private var name: String

    func run() async throws {
        let environment = ProcessInfo.processInfo.environment
        let logger = LoggingSystem.bootstrappedLogger(options: options, environment: environment)

        let fileConfig = try FileConfigLoader.fileConfig(explicitPath: options.fileConfigPath, logger: logger)
        let migrationsFolderURL = try ConfigValueResolver.migrationsFolderURL(
            explicitPath: options.migrationsFolderPath,
            environment: environment,
            fileConfig: fileConfig,
            logger: logger
        )

        try FileGenerator.generateMigrationFiles(named: name, in: migrationsFolderURL, logger: logger)
    }
}
