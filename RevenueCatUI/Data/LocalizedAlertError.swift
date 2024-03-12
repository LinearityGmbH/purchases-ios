//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  LocalizedAlertError.swift
//
//  Created by Nacho Soto on 7/21/23.

import RevenueCat
import SwiftUI

public struct LocalizedAlertError: LocalizedError {
    public let errorDescription: String?
    public let failureReason: String?
    public let recoverySuggestion: String?

    public init(errorDescription: String?, failureReason: String?, recoverySuggestion: String?) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }

    public init(error: NSError) {
        errorDescription = "\(error.domain) \(error.code)"
        failureReason = switch error {
        case is ErrorCode:
            error.description
        default:
            error.localizedDescription
        }
        recoverySuggestion = error.localizedRecoverySuggestion
    }
}
