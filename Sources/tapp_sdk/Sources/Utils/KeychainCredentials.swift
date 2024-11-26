////
////  KeychainCredentials.swift
////  tapp_sdk
////
////  Created by Nikolaos Tseperkas on 9/11/24.
////
//import Foundation
//
//struct KeychainCredentials {
//    // MARK: - App Token
//    static var appToken: String? {
//        get {
//            return KeychainHelper.shared.get(key: "appToken")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "appToken", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "appToken")
//            }
//        }
//    }
//    
//    // MARK: - Auth Token
//    static var authToken: String? {
//        get {
//            return KeychainHelper.shared.get(key: "authToken")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "authToken", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "authToken")
//            }
//        }
//    }
//    
//    // MARK: - Tapp Token
//    static var tappToken: String? {
//        get {
//            return KeychainHelper.shared.get(key: "tappToken")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "tappToken", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "tappToken")
//            }
//        }
//    }
//    
//    // MARK: - Environment
//    static var environment: String? {
//        get {
//            return KeychainHelper.shared.get(key: "environment")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "environment", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "environment")
//            }
//        }
//    }
//    
//    // MARK: - MMP
//    static var mmp: String? {
//        get {
//            return KeychainHelper.shared.get(key: "mmp")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "mmp", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "mmp")
//            }
//        }
//    }
//    
//    // MARK: - Bundle_id
//    static var bundleId: String? {
//        get {
//            return KeychainHelper.shared.get(key: "bundleId")
//        }
//        set {
//            if let value = newValue {
//                KeychainHelper.shared.save(key: "bundleId", value: value)
//            } else {
//                KeychainHelper.shared.delete(key: "bundleId")
//            }
//        }
//    }
//    
//    // MARK: - Processed Referral Engine Flag
//    static var hasProcessedReferralEngine: Bool {
//        get {
//            return KeychainHelper.shared.getBool(key: "hasProcessedReferralEngine")
//        }
//        set {
//            KeychainHelper.shared.save(key: "hasProcessedReferralEngine", value: newValue)
//        }
//    }
//    
//    // Add other keys as needed
//}
//
