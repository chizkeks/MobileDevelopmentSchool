//
//  JsonParsingStructs.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 29.03.2021.
//

import Foundation

struct SearchAPIResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let symbol: String
}

struct QuoteApiResponse: Codable {
    let o:  Double
    let c: Double
}
