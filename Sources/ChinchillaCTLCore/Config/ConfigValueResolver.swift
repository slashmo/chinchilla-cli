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

import Foundation

public enum ConfigValueResolver {
    public static func value<T>(
        explicitValue: String?,
        environment: [String: String],
        environmentVariable: String,
        config: FileConfig?,
        getConfigValue: (FileConfig) -> String?,
        mapStringValue: (String) throws -> T,
        fallback: () -> T
    ) rethrows -> T {
        if let explicitValue {
            return try mapStringValue(explicitValue)
        }

        if let environmentValue = environment[environmentVariable] {
            return try mapStringValue(environmentValue)
        }

        guard let config else { return fallback() }

        if let configValue = getConfigValue(config) {
            return try mapStringValue(configValue)
        }

        return fallback()
    }

    public static func migrationsFolderURL(explicitValue: String?, fileConfig: FileConfig?, verbose: Bool) -> URL {
        let mapStringValue: (String) -> URL = { URL(fileURLWithPath: $0) }
        let fallback: () -> URL = {
            let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent("migrations")
            print(#"📦 Using default migrations folder: "\#(url.path)"."#)
            return url
        }

        if let explicitValue {
            if verbose {
                print(#"📦 Using migrations folder from -m flag: "\#(explicitValue)"."#)
            }
            return mapStringValue(explicitValue)
        }

        if let environmentValue = ProcessInfo.processInfo.environment["MIGRATIONS_PATH"] {
            print(#"📦 Using migrations folder from environment variable: "\#(environmentValue)"."#)
            return mapStringValue(environmentValue)
        }

        guard let fileConfig else { return fallback() }

        let configValue = switch fileConfig {
        case .v1(let v1): v1.migrationsFolderPath
        }

        if let configValue {
            print(#"📦 Using migrations folder from config file: "\#(configValue)"."#)
            return mapStringValue(configValue)
        }

        return fallback()
    }
}
