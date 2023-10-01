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
import Yams

public enum FileConfigParser {
    public static func config(from yaml: String, logger: Logger) throws -> FileConfig {
        let decoder = YAMLDecoder()

        do {
            return try decoder.decode(FileConfig.self, from: Data(yaml.utf8))
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                if let configError = context.underlyingError as? FileConfigDecodingError {
                    switch configError {
                    case .unsupportedVersion(let version):
                        logger.critical("The given configuration version is not supported.", metadata: [
                            "version": "\(version)",
                            "supported_versions": "\(FileConfig.Version.allCases.map(\.rawValue))",
                        ])
                    }
                    break
                }
            case .keyNotFound(let key, _):
                logger.critical("Missing required config key.", metadata: ["key": "\(key.stringValue)"])
            default:
                break
            }

            throw ConfigError()
        } catch {
            throw ConfigError()
        }
    }
}
