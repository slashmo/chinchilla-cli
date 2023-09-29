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

import ChinchillaCTLCore
import Foundation

extension FileGeneratorError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidMigrationName(let name):
            """
            The given migration name "\(name)" is invalid. \
            Migration names must not be empty and can't contain dots.
            """
        case .invalidMigrationsFolder(let path):
            #"Cannot find migrations folder at "\#(path)"."#
        }
    }
}

extension FileConfigError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingFile(let path):
            let url = URL(fileURLWithPath: path)
            return #"Could not find config file at "\#(url.path)"."#
        case .malformedFile(let path):
            let url = URL(fileURLWithPath: path)
            return #"The config file at "\#(url.path)" is malformed."#
        case .unsupportedVersion(let version, let supportedVersions):
            return """
            The config file uses an unsupported version ("\(version)"). Supported versions are: \(supportedVersions).
            """
        }
    }
}
