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
import Yams

public enum FileConfigParser {
    public static func config(at path: String) throws -> FileConfig {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            throw FileConfigError.missingFile(path: path)
        }

        do {
            let yaml = try String(contentsOfFile: path)
            return try config(from: yaml)
        } catch let error as FileConfigError {
            throw error
        } catch {
            throw FileConfigError.malformedFile(path: path)
        }
    }

    private static func config(from yaml: String) throws -> FileConfig {
        let decoder = YAMLDecoder()

        do {
            let config = try decoder.decode(FileConfig.self, from: Data(yaml.utf8))
            return config
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                if let configError = context.underlyingError as? FileConfigError {
                    throw configError
                }
                throw error
            default:
                throw error
            }
        }
    }
}

public enum FileConfigError: Error, Equatable {
    case missingFile(path: String)
    case malformedFile(path: String)
    case unsupportedVersion(version: String, supportedVersions: [String])
}
