//
//  NetworkManager.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  NetworkManager.swift
//  wanilla_referral_engine/Services/Network

import Foundation

public class NetworkManager {
    public func postRequest(url: String, params: [String: Any], completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.apiError("Invalid API URL.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }

            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(.apiError("Failed to parse response.")))
                return
            }

            completion(.success(jsonResponse))
        }
        task.resume()
    }
}
