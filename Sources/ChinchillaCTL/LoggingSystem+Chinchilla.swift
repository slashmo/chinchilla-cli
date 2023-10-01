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

extension LoggingSystem {
    static func bootstrappedLogger(options: GlobalOptions, environment: [String: String]) -> Logger {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = options.logLevel ?? environment["LOG_LEVEL"].flatMap(Logger.Level.init) ?? .info
            return handler
        }
        return Logger(label: "Chinchilla")
    }
}
