//
//  NetworkErrors.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 14.04.2022.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalid URL"
        case .unableToComplete:
            return "Unable to complete your request"
        case .invalidResponse:
            return "Invalid response from the server"
        case .invalidData:
            return "The data received from the server was invalid"
        }
    }
}
