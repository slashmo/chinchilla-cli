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

public enum FileConfigLoader {
    public static func fileConfig(explicitPath: String?, logger: Logger) throws -> FileConfig? {
        if let configFilePath = configFilePath(explicitPath: explicitPath) {
            do {
                let contents = try String(contentsOfFile: configFilePath)
                let config = try FileConfigParser.config(from: contents, logger: logger)
                logger.info("Loaded configuration file.", metadata: ["path": "\(configFilePath)"])
                return config
            } catch {
                logger.critical("Failed to load configuration file.")
                throw error
            }
        }

        logger.info("No configuration file found.")
        return nil
    }

    private static func configFilePath(explicitPath: String?) -> String? {
        if let explicitPath {
            return explicitPath
        }

        // use config file at default location if it exists
        let defaultConfigFilePath = Self.defaultConfigFilePath()

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: defaultConfigFilePath, isDirectory: &isDirectory), !isDirectory.boolValue {
            return defaultConfigFilePath
        }

        return nil
    }

    private static func defaultConfigFilePath() -> String {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("chinchilla.yml").path
    }

    private static let fileManager = FileManager.default
}
