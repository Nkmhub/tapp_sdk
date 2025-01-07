//
//  Enviroment.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 1/11/24.
//

@objc
public enum Environment: Int, Codable, Equatable {
    case sandbox = 0
    case production = 1
}
