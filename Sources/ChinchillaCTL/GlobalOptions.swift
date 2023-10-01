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
import Logging

struct GlobalOptions: ParsableArguments {
    @Option(
        name: [.customShort("l"), .customLong("log")],
        help: ArgumentHelp(
            discussion: """
            The minimum log level. Overrides the environment variable `LOG_LEVEL`.
            Defaults to `.info` if neither are present.
            """
        )
    ) var logLevel: Logger.Level?

    @Option(
        name: [.customShort("c"), .customLong("config")],
        help: ArgumentHelp(
            discussion: """
            A relative or absolute path to a Chinchilla configuration YAML file.
            If not specified, Chinchilla will use the `chinchilla.yml` file in your \
            current directory if it exists.
            """
        )
    ) var fileConfigPath: String?

    @Option(
        name: [.customShort("m"), .customLong("migrations")],
        help: ArgumentHelp(
            discussion: """
            The folder containing all SQL migration files.
            If not specified, Chinchilla will determine the migrations folder in the specified order:
              1. Read `MIGRATIONS_PATH` from the environment.
              2. Read `migrations_path` from config file.
              3. Fall back to a `migrations` folder in your current directory.
            """
        )
    ) var migrationsFolderPath: String?
}
