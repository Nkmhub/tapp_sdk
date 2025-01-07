//
//  NetworkManager.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  NetworkManager.swift
//  wanilla_referral_engine/Services/Network

import Foundation

import Foundation

public class NetworkManager {

    // POST Request
    public func postRequest(
        url: String,
        params: [String: Any],
        headers: [String: String] = [:],
        completion: @escaping (Result<[String: Any], TappError>) -> Void
    ) {
        performRequest(url: url, method: "POST", params: params, headers: headers, completion: completion)
    }

    // GET Request
    public func getRequest(
        url: String,
        headers: [String: String] = [:],
        completion: @escaping (Result<[String: Any], TappError>) -> Void
    ) {
        performRequest(url: url, method: "GET", params: nil, headers: headers, completion: completion)
    }

    // PUT Request
    public func putRequest(
        url: String,
        params: [String: Any],
        headers: [String: String] = [:],
        completion: @escaping (Result<[String: Any], TappError>) -> Void
    ) {
        performRequest(url: url, method: "PUT", params: params, headers: headers, completion: completion)
    }

    // DELETE Request
    public func deleteRequest(
        url: String,
        headers: [String: String] = [:],
        completion: @escaping (Result<[String: Any], TappError>) -> Void
    ) {
        performRequest(url: url, method: "DELETE", params: nil, headers: headers, completion: completion)
    }

    // Private generic request handler
    private func performRequest(
        url: String,
        method: String,
        params: [String: Any]?,
        headers: [String: String],
        completion: @escaping (Result<[String: Any], TappError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.apiError(message:"Invalid API URL.", endpoint: "performRequest")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // Add request body for methods that support it
        if let params = params, method != "GET" {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Add custom headers
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiError(message: error.localizedDescription, endpoint: url.absoluteString)))
                return
            }

            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(.apiError(message:"Failed to parse response.", endpoint: url.absoluteString)))
                return
            }

            completion(.success(jsonResponse))
        }
        task.resume()
    }
}
