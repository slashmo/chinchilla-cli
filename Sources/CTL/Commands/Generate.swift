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
import ChinchillaCTLCore
import struct Foundation.URL

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

    @Option(name: .customShort("f")) private var folderPath: String = "./migrations"
    @Argument private var name: String

    func run() async throws {
        try MigrationFileGenerator.generateMigrationFiles(named: name, in: URL(fileURLWithPath: folderPath))
    }
}

extension MigrationFileGeneratorError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidMigrationName(let name):
            #"The given migration name "\#(name)" is invalid. Migration names must not be empty."#
        case .invalidMigrationsFolder(let path):
            #"Cannot find migrations folder at "\#(path)". Please make sure it exists or change the path using "-f"."#
        }
    }
}
