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

@main
struct ChinchillaCTL: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "chinchilla",
        abstract: "A plain SQL-file based database migration toolkit.",
        discussion: """
        chinchilla is an SQL database migration tool. Use it to generate SQL migration files \
        and apply/roll-back your migrations.

        Chinchilla may also be used as a library to embed performing migrations into your Swift projects. \
        Check out https://github.com/slashmo/chinchilla to learn more.
        """,
        version: "0.1.0",
        subcommands: []
    )
}
