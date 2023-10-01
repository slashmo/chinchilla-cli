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

public enum FileConfig: Codable, Hashable {
    case v1(V1)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VersionCodingKeys.self)
        do {
            let version = try container.decode(Version.self, forKey: .version)
            switch version {
            case .v1_0:
                self = try .v1(V1(from: decoder))
            }
        } catch {
            throw try FileConfigDecodingError.unsupportedVersion(
                version: container.decode(String.self, forKey: .version)
            )
        }
    }

    public struct V1: Codable, Hashable {
        public let migrationsFolderPath: String?

        public init(migrationsFolderPath: String?) {
            self.migrationsFolderPath = migrationsFolderPath
        }

        private enum CodingKeys: String, CodingKey {
            case migrationsFolderPath = "migrations_path"
        }
    }

    enum Version: String, Codable, CaseIterable {
        case v1_0 = "1.0"
    }

    private enum VersionCodingKeys: String, CodingKey {
        case version
    }
}

enum FileConfigDecodingError: Error, Equatable {
    case unsupportedVersion(version: String)
}
