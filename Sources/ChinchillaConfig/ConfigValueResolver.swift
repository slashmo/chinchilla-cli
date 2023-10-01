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
import Logging

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

    public static func migrationsFolderURL(
        explicitPath: String?,
        environment: [String: String],
        fileConfig: FileConfig?,
        logger: Logger
    ) throws -> URL {
        let fileManager = FileManager.default

        let url: URL = {
            let fallback: () -> URL = {
                let currentDirectoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
                return currentDirectoryURL.appendingPathComponent("migrations")
            }

            if let explicitPath {
                return URL(fileURLWithPath: explicitPath)
            }

            if let environmentValue = environment["MIGRATIONS_PATH"] {
                return URL(fileURLWithPath: environmentValue)
            }

            guard let fileConfig else { return fallback() }

            let configValue = switch fileConfig {
            case .v1(let v1): v1.migrationsFolderPath
            }

            if let configValue {
                return URL(fileURLWithPath: configValue)
            }

            return fallback()
        }()

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            logger.critical("Migrations folder does not exist.", metadata: ["path": "\(url.path)"])
            throw ConfigError()
        }

        return url
    }
}
