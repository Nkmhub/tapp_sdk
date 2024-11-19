//
//  KeychainHelper.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 9/11/24.
//

import Foundation
import Security

class KeychainHelper {
    enum StorageError: Error {
        case noValue
    }

    static let shared = KeychainHelper()
    
    private init() {}

    private var keychainKey: String {
        return "tapp_c"
    }

    public func save(config: ReferralEngineInitConfig) {
        save(key: keychainKey, codable: config)
    }

    public var config: ReferralEngineInitConfig? {
        return get(key: keychainKey, type: ReferralEngineInitConfig.self)
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
//
//    func get(key: String) -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        var result: AnyObject?
//        SecItemCopyMatching(query as CFDictionary, &result)
//        guard let data = result as? Data else { return nil }
//        return String(data: data, encoding: .utf8)
//    }
//
//    func save(key: String, value: Bool) {
//        save(key: key, value: value ? "true" : "false")
//    }
//
//    func getBool(key: String) -> Bool {
//        return get(key: key) == "true"
//    }
    
}
