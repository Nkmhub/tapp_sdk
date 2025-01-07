//
//  KeychainHelper.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 9/11/24.
//

import Foundation
import Security

protocol KeychainHelperProtocol {
    func save(config: TappConfiguration)
    var config: TappConfiguration? { get }
}

final class KeychainHelper: KeychainHelperProtocol {
    enum StorageError: Error {
        case noValue
    }

    static let shared = KeychainHelper()
    
    private init() {}

    private var keychainKey: String {
        return "tapp_c"
    }

    func save(config: TappConfiguration) {
        save(key: keychainKey, codable: config)
    }

    var config: TappConfiguration? {
        return get(key: keychainKey, type: TappConfiguration.self)
    }

    private func save(key: String, codable: any Codable) {
        let encoder: JSONEncoder = JSONEncoder()
        guard let data = try? encoder.encode(codable) else { return }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecValueData as String: data]

        SecItemDelete(query as CFDictionary) // Remove existing item
        SecItemAdd(query as CFDictionary, nil)
    }

    private func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> T? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = decodingStrategy

        return try? decoder.decode(type, from: data) as T
    }

    private func delete(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }    
}
