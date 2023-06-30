//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  SigningTests.swift
//
//  Created by Nacho Soto on 1/13/23.

import CryptoKit
import Nimble
import XCTest

@testable import RevenueCat

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
class SigningTests: TestCase {

    fileprivate typealias PrivateKey = Curve25519.Signing.PrivateKey
    fileprivate typealias PublicKey = Curve25519.Signing.PublicKey

    private let (privateKey, publicKey) = SigningTests.createRandomKey()
    private let (privateIntermediateKey, publicIntermediateKey) = SigningTests.createRandomKey()

    override func setUpWithError() throws {
        try super.setUpWithError()

        try AvailabilityChecks.iOS13APIAvailableOrSkipTest()
    }

    func testLoadDefaultPublicKey() throws {
        let key = try XCTUnwrap(Signing.loadPublicKey() as? PublicKey)

        expect(key.rawRepresentation).toNot(beEmpty())
    }

    func testVerifySignatureWithInvalidSignatureReturnsFalseAndLogsError() throws {
        let logger = TestLogHandler()

        let message = "Hello World"
        let nonce = "nonce"
        let requestDate: UInt64 = 1677005916012
        let signature = "this is not a signature"

        expect(Signing.verify(
            signature: signature,
            with: .init(
                message: message.asData,
                nonce: nonce.asData,
                etag: nil,
                requestDate: requestDate
            ),
            publicKey: Signing.loadPublicKey()
        )) == false

        logger.verifyMessageWasLogged("Signature is not base64: \(signature)")
    }

    func testVerifySignatureWithExpiredIntermediateSignatureReturnsFalseAndLogsError() throws {
        let message = "Hello World"
        let nonce = "0123456789ab"
        let etag: String? = nil
        let requestDate = Date().millisecondsSince1970
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyPastExpiration)
        let salt = Self.createSalt()
        let parameters: Signing.SignatureParameters = .init(
            message: message.asData,
            nonce: nonce.asData,
            etag: etag,
            requestDate: requestDate
        )

        let signature = try self.sign(parameters: parameters, salt: salt.asData)
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        let logger = TestLogHandler()

        expect(Signing.verify(
            signature: fullSignature.base64EncodedString(),
            with: parameters,
            publicKey: self.publicKey
        )) == false

        logger.verifyMessageWasLogged("Intermediate key expired", level: .warn)
    }

    func testVerifySignatureWithInvalidIntermediateSignatureExpirationReturnsFalseAndLogsError() throws {
        let message = "Hello World"
        let nonce = "0123456789ab"
        let etag = "etag"
        let requestDate = Date().millisecondsSince1970
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: nil)
        let salt = Self.createSalt()
        let parameters: Signing.SignatureParameters = .init(
            message: message.asData,
            nonce: nonce.asData,
            etag: etag,
            requestDate: requestDate
        )

        let signature = try self.sign(parameters: parameters, salt: salt.asData)
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        let logger = TestLogHandler()

        expect(Signing.verify(
            signature: fullSignature.base64EncodedString(),
            with: parameters,
            publicKey: self.publicKey
        )) == false

        logger.verifyMessageWasLogged(Strings.signing.intermediate_key_invalid(Self.invalidIntermediateKeyExpiration),
                                      level: .warn)
    }

    func testVerifySignatureWithInvalidSignature() throws {
        expect(Signing.verify(
            signature: "invalid signature".asData.base64EncodedString(),
            with: .init(
                message: "Hello World".asData,
                nonce: "nonce".asData,
                etag: nil,
                requestDate: 1677005916012
            ),
            publicKey: Signing.loadPublicKey()
        )) == false
    }

    func testVerifySignatureLogsWarningWhenIntermediateSignatureIsInvalid() throws {
        let logger = TestLogHandler()

        let signature = String(repeating: "x", count: Signing.SignatureComponent.totalSize)
            .asData

        _ = Signing.verify(signature: signature.base64EncodedString(),
                           with: .init(
                            message: "Hello World".asData,
                            nonce: "nonce".asData,
                            etag: nil,
                            requestDate: 1677005916012
                           ),
                           publicKey: Signing.loadPublicKey())

        logger.verifyMessageWasLogged("Intermediate key failed verification",
                                      level: .warn)
    }

    func testVerifySignatureLogsWarningWhenFail() throws {
        let logger = TestLogHandler()

        let message = "Hello World"
        let nonce = "nonce"
        let requestDate: UInt64 = 1677005916012
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let salt = Self.createSalt()

        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            // Invalid signature
            signature: String(repeating: "x", count: Signing.SignatureComponent.payload.size).asData
        )
        expect(
            Signing.verify(
                signature: fullSignature.base64EncodedString(),
                with: .init(
                    message: message.asData,
                    nonce: nonce.asData,
                    etag: nil,
                    requestDate: requestDate
                ),
                publicKey: self.publicKey
            )
        ) == false

        logger.verifyMessageWasLogged(Strings.signing.signature_failed_verification,
                                      level: .warn)
    }

    func testVerifySignatureLogsWarningWhenSizeIsIncorrect() throws {
        let logger = TestLogHandler()

        let signature = "invalid signature".asData

        _ = Signing.verify(signature: signature.base64EncodedString(),
                           with: .init(
                            message: "Hello World".asData,
                            nonce: "nonce".asData,
                            etag: nil,
                            requestDate: 1677005916012
                           ),
                           publicKey: Signing.loadPublicKey())

        logger.verifyMessageWasLogged(Strings.signing.signature_invalid_size(signature),
                                      level: .warn)
    }

    func testVerifySignatureWithValidSignature() throws {
        let message = "Hello World"
        let nonce = "nonce"
        let requestDate: UInt64 = 1677005916012
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let salt = Self.createSalt()

        let signature = try self.sign(
            parameters: .init(
                message: message.asData,
                nonce: nonce.asData,
                etag: nil,
                requestDate: requestDate
            ),
            salt: salt.asData
        )
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        expect(Signing.verify(
            signature: fullSignature.base64EncodedString(),
            with: .init(
                message: message.asData,
                nonce: nonce.asData,
                etag: nil,
                requestDate: requestDate
            ),
            publicKey: self.publicKey
        )) == true
    }

    func testVerifySignatureWithValidSignatureIncludingEtag() throws {
        let message = "Hello World"
        let nonce = "nonce"
        let requestDate: UInt64 = 1677005916012
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let etag = "97d4f0d2353d784a"
        let salt = Self.createSalt()

        let signature = try self.sign(
            parameters: .init(
                message: message.asData,
                nonce: nonce.asData,
                etag: etag,
                requestDate: requestDate
            ),
            salt: salt.asData
        )
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        expect(Signing.verify(
            signature: fullSignature.base64EncodedString(),
            with: .init(
                message: message.asData,
                nonce: nonce.asData,
                etag: etag,
                requestDate: requestDate
            ),
            publicKey: self.publicKey
        )) == true
    }

    func testVerifyKnownSignatureWithNonceAndEtag() throws {
        /*
         Signature retrieved with:
        curl -v 'https://api.revenuecat.com/v1/subscribers/login' \
        -X GET \
        -H 'X-Nonce: MTIzNDU2Nzg5MGFi' \
        -H 'Authorization: Bearer {api_key}'
         */

        Logger.logLevel = .verbose

        // swiftlint:disable line_length
        let response = """
        {"request_date":"2023-06-29T19:23:42Z","request_date_ms":1688066622298,"subscriber":{"entitlements":{},"first_seen":"2023-06-29T19:23:42Z","last_seen":"2023-06-29T19:23:42Z","management_url":null,"non_subscriptions":{},"original_app_user_id":"login","original_application_version":null,"original_purchase_date":null,"other_purchases":{},"subscriptions":{}}}\n
        """
        let expectedSignature = "XX8Mh8DTcqPC5A48nncRU3hDkL/v3baxxqLIWnWJzg1tTAAA7ok0iXupT2bjju/BSHVmgxc0XiwTZXBmsGuWEXa9lsyoFi9HMF4aAIOs4Y+lYE2i4USJCP7ev07QZk7D2b6ZBSkFSDzefa+cDeSEtlG+AB3lQ9F7qXf7kg2GqVQR3D7ayNFwey4c2p/WMZYfx5tJaKVzOPWQPtM3jmfByfOZd6rLkE+SYycExStyDpUACWcA"
        // swiftlint:enable line_length

        let nonce = try XCTUnwrap(Data(base64Encoded: "MTIzNDU2Nzg5MGFi"))
        let requestDate: UInt64 = 1688066622299
        let etag = "9d74782403a43274"

        expect(
            Signing.verify(
                signature: expectedSignature,
                with: .init(
                    message: response.asData,
                    nonce: nonce,
                    etag: etag,
                    requestDate: requestDate
                ),
                publicKey: Signing.loadPublicKey()
            )
        ) == true
    }

    func testVerifyKnownSignatureWithNoNonceAndNoEtag() throws {
        /*
         Signature retrieved with:
        curl -v 'https://api.revenuecat.com/v1/subscribers/test/offerings' \
        -X GET \
        -H 'Authorization: Bearer {api_key}' \
        -H 'X-Platform: iOS'
         */

        XCTExpectFailure("Waiting on backend to generate a valid signature for this test")

        // swiftlint:disable line_length
        let response = """
        {"current_offering_id":"default","offerings":[{"description":"Default","identifier":"default","packages":[]}]}\n
        """
        let expectedSignature = "drCCA+6YAKOAjT7b2RosYNTrRexVWnu+dR5fw/JuKeAAAAAA0FnsHKjqgSrOj+YkdU2TZfLfpMfx8w9miUkqxyWMI0h2z0weWLNlF1MPG7ZrL+vOEQi+LvYkcffxprzcn1uSAVfQSkHeWl4NJ4IDusH1iegd46IlIRN+o2Ej9KsKv+NWQUgQZ5gMt5GJ25GydlA772xmGGFGgxCnfa+/mFDQ4WpODkbtkiFheRxEsbUs8zQJ"
        // swiftlint:enable line_length

        let requestDate: UInt64 = 1687455094309

        expect(
            Signing.verify(
                signature: expectedSignature,
                with: .init(
                    message: response.asData,
                    nonce: nil,
                    etag: nil,
                    requestDate: requestDate
                ),
                publicKey: Signing.loadPublicKey()
            )
        ) == true
    }

    func testVerifyKnownSignatureOfEmptyResponseWithNonceAndNoEtag() throws {
        /*
         Signature retrieved with:
        curl -v 'https://api.revenuecat.com/v1/health' \
        -X GET \
        -H 'X-Nonce: MTIzNDU2Nzg5MGFi'
         */

        // swiftlint:disable line_length
        let response = "\"\"\n"
        let expectedSignature = "XX8Mh8DTcqPC5A48nncRU3hDkL/v3baxxqLIWnWJzg1tTAAA7ok0iXupT2bjju/BSHVmgxc0XiwTZXBmsGuWEXa9lsyoFi9HMF4aAIOs4Y+lYE2i4USJCP7ev07QZk7D2b6ZBVIcfv+kOk0mmfI22o3ZId31m88mVG2BqPPQpNfyQYjmwjymg00WqlSHY2Yqgq20fK0wEdG8RDJEqsMOPOo93kO+wGvlkOvlEqMF39vXtOMI"
        // swiftlint:enable line_length

        let nonce = try XCTUnwrap(Data(base64Encoded: "MTIzNDU2Nzg5MGFi"))
        let requestDate: UInt64 = 1688066733210

        expect(
            Signing.verify(
                signature: expectedSignature,
                with: .init(
                    message: response.asData,
                    nonce: nonce,
                    etag: nil,
                    requestDate: requestDate
                ),
                publicKey: Signing.loadPublicKey()
            )
        ) == true
    }

    func testVerifyKnownSignatureOf304Response() throws {
        /*
         Signature retrieved with:
        curl -v 'https://api.revenuecat.com/v1/subscribers/login' \
        -X GET \
        -H 'X-Nonce: MTIzNDU2Nzg5MGFi'
        -H 'Authorization: Bearer {api_key}'
        -H 'X-RevenueCat-ETag: 97d4f0d2353d784a'
         */

        // swiftlint:disable line_length
        let expectedSignature = "XX8Mh8DTcqPC5A48nncRU3hDkL/v3baxxqLIWnWJzg1tTAAA7ok0iXupT2bjju/BSHVmgxc0XiwTZXBmsGuWEXa9lsyoFi9HMF4aAIOs4Y+lYE2i4USJCP7ev07QZk7D2b6ZBT0H1sSsBkbLM0LwwTSwTceDJXijNlz0tStn0Qi0dPRwFL+LN7vcsNqhJFq0+zqm2St/cKHJKxK+1HB+1S0lr0isIHY2G7PVmR2s3Zynx90M"
        // swiftlint:enable line_length

        let nonce = try XCTUnwrap(Data(base64Encoded: "MTIzNDU2Nzg5MGFi"))
        let requestDate: UInt64 = 1688066798532
        let etag = "9d74782403a43274"

        expect(
            Signing.verify(
                signature: expectedSignature,
                with: .init(
                    message: nil, // 304 response
                    nonce: nonce,
                    etag: etag,
                    requestDate: requestDate
                ),
                publicKey: Signing.loadPublicKey()
            )
        ) == true
    }

    func testResponseVerificationWithNoProvidedKey() throws {
        let request = HTTPRequest.createWithResponseVerification(method: .get, path: .health)
        let response = HTTPResponse<Data?>(statusCode: .success, responseHeaders: [:], body: Data())
        let verifiedResponse = response.verify(request: request, publicKey: nil)

        expect(verifiedResponse.verificationResult) == .notRequested
    }

    func testResponseVerificationWithNoSignatureInResponse() throws {
        let request = HTTPRequest.createWithResponseVerification(method: .get, path: .health)
        let logger = TestLogHandler()

        let response = HTTPResponse<Data?>(statusCode: .success, responseHeaders: [:], body: Data())
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .failed

        logger.verifyMessageWasLogged(Strings.signing.signature_was_requested_but_not_provided(request),
                                      level: .warn)
    }

    func testResponseVerificationWithInvalidSignature() throws {
        let request = HTTPRequest.createWithResponseVerification(method: .get, path: .health)
        let response = HTTPResponse<Data?>(
            statusCode: .success,
            responseHeaders: [
                HTTPClient.ResponseHeader.signature.rawValue: "invalid_signature"
            ],
            body: Data()
        )
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .failed
    }

    func testResponseVerificationWithNonceWithValidSignature() throws {
        let message = "Hello World"
        let nonce = "0123456789ab"
        let requestDate = Date().millisecondsSince1970
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let salt = Self.createSalt()

        let signature = try self.sign(parameters: .init(message: message.asData,
                                                        nonce: nonce.asData,
                                                        etag: nil,
                                                        requestDate: requestDate),
                                      salt: salt.asData)
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        let request = HTTPRequest(method: .get, path: .health, nonce: nonce.asData)
        let response = HTTPResponse<Data?>(
            statusCode: .success,
            responseHeaders: [
                HTTPClient.ResponseHeader.signature.rawValue: fullSignature.base64EncodedString(),
                HTTPClient.ResponseHeader.requestDate.rawValue: String(requestDate)
            ],
            body: message.asData
        )
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .verified
    }

    func testResponseVerificationWithNonceAndEtag() throws {
        let nonce = "0123456789ab"
        let etag = "97d4f0d2353d784a"
        let requestDate = Date().millisecondsSince1970
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let salt = Self.createSalt()

        let signature = try self.sign(parameters: .init(message: nil,
                                                        nonce: nonce.asData,
                                                        etag: etag,
                                                        requestDate: requestDate),
                                      salt: salt.asData)
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        let request = HTTPRequest(method: .get, path: .health, nonce: nonce.asData)
        let response = HTTPResponse<Data?>(
            statusCode: .success,
            responseHeaders: [
                HTTPClient.ResponseHeader.signature.rawValue: fullSignature.base64EncodedString(),
                HTTPClient.ResponseHeader.requestDate.rawValue: String(requestDate),
                HTTPClient.ResponseHeader.eTag.rawValue: etag
            ],
            body: nil
        )
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .verified
    }

    func testResponseVerificationWithoutNonceWithValidSignature() throws {
        let message = "Hello World"
        let requestDate = Date().millisecondsSince1970
        let intermediateKey = try self.createIntermediatePublicKeyData(expiration: Self.intermediateKeyFutureExpiration)
        let salt = Self.createSalt()

        let signature = try self.sign(parameters: .init(message: message.asData,
                                                        nonce: nil,
                                                        etag: nil,
                                                        requestDate: requestDate),
                                      salt: salt.asData)
        let fullSignature = Self.fullSignature(
            intermediateKey: intermediateKey,
            salt: salt,
            signature: signature
        )

        let request = HTTPRequest(method: .get, path: .health, nonce: nil)
        let response = HTTPResponse<Data?>(
            statusCode: .success,
            responseHeaders: [
                HTTPClient.ResponseHeader.signature.rawValue: fullSignature.base64EncodedString(),
                HTTPClient.ResponseHeader.requestDate.rawValue: String(requestDate)
            ],
            body: message.asData
        )
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .verified
    }

    func testResponseVerificationWithoutNonceAndNoSignatureReturnsNotRequested() throws {
        let message = "Hello World"
        let requestDate = Date().millisecondsSince1970

        let logger = TestLogHandler()

        let request = HTTPRequest(method: .get, path: .health, nonce: nil)
        let response = HTTPResponse<Data?>(
            statusCode: .success,
            responseHeaders: [
                HTTPClient.ResponseHeader.requestDate.rawValue: String(requestDate)
            ],
            body: message.asData
        )
        let verifiedResponse = response.verify(request: request, publicKey: self.publicKey)

        expect(verifiedResponse.verificationResult) == .notRequested

        logger.verifyMessageWasNotLogged(Strings.signing.signature_was_requested_but_not_provided(request),
                                         allowNoMessages: true)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
private extension SigningTests {

    static func createRandomKey() -> (PrivateKey, PublicKey) {
        let key = PrivateKey()

        return (key, key.publicKey)
    }

    func sign(parameters: Signing.SignatureParameters, salt: Data) throws -> Data {
        return try self.sign(key: self.privateIntermediateKey, parameters: parameters, salt: salt)
    }

    func sign(key: PrivateKey, parameters: Signing.SignatureParameters, salt: Data) throws -> Data {
        return try key.signature(for: salt + parameters.asData)
    }

    static func fullSignature(intermediateKey: Data, salt: String, signature: Data) -> Data {
        return intermediateKey + salt.asData + signature
    }

    static func createSalt() -> String {
        return Array(repeating: "a", count: Signing.SignatureComponent.salt.size).joined()
    }

    /// - Parameter expiration: pass `nil` to create a "0" expiration date.
    func createIntermediatePublicKeyData(expiration: Date?) throws -> Data {
        let intermediateKey = self.publicIntermediateKey.rawRepresentation
        let expiration = expiration.map(\.dataRepresentation) ?? Self.invalidIntermediateKeyExpiration
        let signature = try self.privateKey.signature(for: expiration + intermediateKey)

        precondition(intermediateKey.count == Signing.SignatureComponent.intermediatePublicKey.size)
        precondition(expiration.count == Signing.SignatureComponent.intermediateKeyExpiration.size)
        precondition(signature.count == Signing.SignatureComponent.intermediateKeySignature.size)

        return intermediateKey + expiration + signature
    }

    static let intermediateKeyFutureExpiration = Date().addingTimeInterval(DispatchTimeInterval.days(5).seconds)
    static let intermediateKeyPastExpiration = Date().addingTimeInterval(DispatchTimeInterval.days(5).seconds * -1)
    static let invalidIntermediateKeyExpiration = Data(
        repeating: 0,
        count: Signing.SignatureComponent.intermediateKeyExpiration.size
    )

}

private extension Date {

    /// Khepri encodes expiration as UInt32 little-endian of the number of days since 1970
    var dataRepresentation: Data {
        let days = DispatchTimeInterval(self.timeIntervalSince1970).days
        return UInt32(days).littleEndianData
    }

}
