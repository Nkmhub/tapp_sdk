//
//  Logger.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

final class Logger {
    public static func logError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }

    public static func logInfo(_ message: String) {
        print("Info: \(message)")
    }
}
