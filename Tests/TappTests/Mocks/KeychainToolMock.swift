import Foundation
@testable import Tapp

final class KeychainToolMock: KeychainToolProtocol {
    var configuration: TappConfiguration = .mock

    var saveCalled: Bool = false
    var saveKeyReceived: String?
    var saveCodableReceived: (any Codable)?
    func save(key: String, codable: any Codable) {
        if let config = codable as? TappConfiguration {
            configuration = config
        }

        saveCalled = true
        saveKeyReceived = key
        saveCodableReceived = codable
    }

    var getCalled: Bool = false
    func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy) -> Decodable? {
        getCalled = true

        return configuration
    }

    var deleteCalled: Bool = false
    var deleteKeyReceived: String?
    func delete(key: String) {
        deleteCalled = true
        deleteKeyReceived = key
    }
}

extension TappConfiguration {
    static var mock: TappConfiguration {
        return TappConfiguration(authToken: "authToken",
                                 env: .sandbox,
                                 tappToken: "tappToken",
                                 affiliate: .adjust,
                                 bundleID: "bundleID")
    }
}
