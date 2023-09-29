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

public enum FileConfigLoader {
    public static func fileConfig(explicitPath: String?, verbose: Bool) throws -> FileConfig? {
        if let explicitPath {
            if verbose {
                print(#"📄 Using configuration file: "\#(explicitPath)"."#)
            }

            return try FileConfigParser.config(at: explicitPath)
        }

        // use config file at default location if it exists
        let defaultConfigFilePath = defaultConfigFilePath()

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: defaultConfigFilePath, isDirectory: &isDirectory), !isDirectory.boolValue {
            print(#"📄 Using configuration file: "\#(defaultConfigFilePath)"."#)
            return try FileConfigParser.config(at: defaultConfigFilePath)
        } else {
            if verbose {
                print("📄 No configuration file found.")
            }
            return nil
        }
    }

    private static func defaultConfigFilePath() -> String {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("chinchilla.yml").path
    }

    private static let fileManager = FileManager.default
}
