//
//  SessionConfiguration.swift
//

import Foundation

typealias Percentage = Double
typealias ProgressDelegate = URLSessionDelegate
typealias ProgressHandler = (Percentage) -> Void

protocol SessionConfigurationProtocol: URLSessionTaskDelegate {
    var configuration: URLSessionConfiguration { get }
}

final class SessionConfiguration: NSObject, SessionConfigurationProtocol {
    let configuration: URLSessionConfiguration

    init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
        super.init()
    }
}
