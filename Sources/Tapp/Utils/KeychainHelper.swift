//
//  KeychainHelper.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 9/11/24.
//

import Foundation
import Security

protocol KeychainHelperProtocol {
    func save(configuration: TappConfiguration)
    var config: TappConfiguration? { get }
    var hasConfig: Bool { get }
}

final class KeychainHelper: KeychainHelperProtocol {
    enum StorageError: Error {
        case noValue
    }

    static let shared = KeychainHelper()

    let keychainTool: KeychainToolProtocol
    init(keychainTool: KeychainToolProtocol = KeychainTool()) {
        self.keychainTool = keychainTool
    }

    private var keychainKey: String {
        return "tapp_c"
    }

    func save(configuration: TappConfiguration) {
        if let config, let url = config.originURL {
            configuration.set(originURL: url)
        }

        save(key: keychainKey, codable: configuration)
    }

    var config: TappConfiguration? {
        return get(key: keychainKey, type: TappConfiguration.self) as? TappConfiguration
    }

    var hasConfig: Bool {
        return config != nil
    }

    private func save(key: String, codable: any Codable) {
        keychainTool.save(key: key, codable: codable)
    }

    private func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> (any Decodable)? {
        return keychainTool.get(key: key, type: type, decodingStrategy: decodingStrategy)
    }

    func delete(key: String) {
        return keychainTool.delete(key: key)
    }
}

protocol KeychainToolProtocol {
    func save(key: String, codable: any Codable)
    func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy) -> Decodable?
    func delete(key: String)
}

final class KeychainTool: KeychainToolProtocol {
    func save(key: String, codable: any Codable) {
        let encoder: JSONEncoder = JSONEncoder()
        guard let data = try? encoder.encode(codable) else { return }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecValueData as String: data]

        SecItemDelete(query as CFDictionary) // Remove existing item
        SecItemAdd(query as CFDictionary, nil)
    }

    func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy) -> Decodable? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = decodingStrategy

        return try? decoder.decode(type, from: data) as T
    }

    func delete(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}
