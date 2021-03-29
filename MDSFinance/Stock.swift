//
//  Stock.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 26.03.2021.
//

import Foundation

struct Stock {
    var identifier : String
    var companyName : String
    var companySymbol : String
    var price : Double
    var priceChange : Double
    var isFavorite : Bool
    
    init() {
        self.identifier = UUID().uuidString
        self.companyName = ""
        self.companySymbol = ""
        self.price = 0.0
        self.priceChange = 0.0
        self.isFavorite = false
    }
    
    init(companyName: String, companySymbol: String, price: Double, priceChange: Double) {
        self.identifier = UUID().uuidString
        self.companyName = companyName
        self.companySymbol = companySymbol
        self.price = price
        self.priceChange = priceChange
        self.isFavorite = false
    }
    
    init(companyName: String, companySymbol: String) {
        self.identifier = UUID().uuidString
        self.companyName = companyName
        self.companySymbol = companySymbol
        self.price = 0.0
        self.priceChange = 0.0
        self.isFavorite = false
    }
    
    mutating func setStockInfo(name: String, symbol: String, price: Double, priceChange: Double) {
        self.companyName = name
        self.companySymbol = symbol
        self.price = price
        self.priceChange = priceChange
    }
}
