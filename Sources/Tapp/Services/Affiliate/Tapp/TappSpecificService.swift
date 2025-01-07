//
//  TappSpecificService.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 16/11/24.
//

import Foundation

protocol TappServiceProtocol {
    func url(request: GenerateURLRequest, completion: GenerateURLCompletion?)
    func handleImpression(url: URL, completion: VoidCompletion?)
    func sendTappEvent(event: TappEvent, completion: VoidCompletion?)
    func secrets(affiliate: Affiliate, completion: SecretsCompletion?)
}
