//
//  URLSession+Protocols.swift
//

import Foundation

typealias NetworkServiceCompletion = (_ result: Result<Data, Error>) -> Void
typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

protocol URLSessionDataTaskProtocol {
    var identifier: Int { get }
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {
    var identifier: Int {
        return taskIdentifier
    }
}

protocol URLSessionProtocol {
    func internalDataTask(with request: URLRequest, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol
    func internalUploadDataTask(with request: URLRequest, data: Data, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func internalDataTask(with request: URLRequest, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return dataTask(with: request) { (data, response, error) in
            taskCompletion(data, response, error)
        }
    }

    func internalUploadDataTask(with request: URLRequest, data: Data, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return uploadTask(with: request, from: data) { data, response, error in
            taskCompletion(data, response, error)
        }
    }
}
