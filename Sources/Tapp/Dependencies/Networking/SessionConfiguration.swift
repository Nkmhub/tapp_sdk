//
//  SessionConfiguration.swift
//

import Foundation

typealias Percentage = Double
typealias ProgressDelegate = URLSessionDelegate
typealias ProgressHandler = (Percentage) -> Void

protocol SessionConfigurationProtocol: URLSessionTaskDelegate {
    var configuration: URLSessionConfiguration { get }

    func add(task: URLSessionDataTaskProtocol, handler: ProgressHandler?)
}

final class SessionConfiguration: NSObject, SessionConfigurationProtocol {
    let configuration: URLSessionConfiguration

    fileprivate var progressHandlersByTaskID = [Int: ProgressHandler]()

    init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
        super.init()
    }

    func add(task: URLSessionDataTaskProtocol, handler: ProgressHandler?) {
        progressHandlersByTaskID[task.identifier] = handler
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let handler = progressHandlersByTaskID[task.taskIdentifier]
        handler?(progress)

        if progress >= 1.0 {
            progressHandlersByTaskID[task.taskIdentifier] = nil
        }
    }
}
