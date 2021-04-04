//
//  Stock.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 26.03.2021.
//
import UIKit
import Foundation

class Stock {
    var identifier : String
    var companyName : String
    var companySymbol : String
    var price : Double
    var priceChange : Double
    var logo: UIImage?
    var isFavorite : Bool
    
    init() {
        self.identifier = UUID().uuidString
        self.companyName = ""
        self.companySymbol = ""
        self.price = 0.0
        self.priceChange = 0.0
        self.logo = UIImage()
        self.isFavorite = false
    }
    
    init(companyName: String, companySymbol: String, price: Double, priceChange: Double) {
        self.identifier = UUID().uuidString
        self.companyName = companyName
        self.companySymbol = companySymbol
        self.price = price
        self.priceChange = priceChange
        self.logo = UIImage()
        self.isFavorite = false
    }
    
    init(companyName: String, companySymbol: String) {
        self.identifier = UUID().uuidString
        self.companyName = companyName
        self.companySymbol = companySymbol
        self.price = 0.0
        self.priceChange = 0.0
        self.logo = UIImage()
        self.isFavorite = false
    }
    
     func setStockInfo(name: String, symbol: String, price: Double, priceChange: Double) {
        self.companyName = name
        self.companySymbol = symbol
        self.price = price
        self.priceChange = priceChange
    }
    
    //Получение  логотипа по тикету акции
    public  func getCompanyLogo() {
        //companyLogo.image = [UIImage imageWithContentsOfURL: url
        let url = "https://storage.googleapis.com/iex/api/logos/\(self.companySymbol).png"
        if let image = imageCache.object(forKey: NSString(string: url)) as? UIImage {
            self.logo = image
        } else {
            let dataTask = URLSession.shared.dataTask(with: URL(string: url)!) {
                data, response, error in
                guard
                    error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                else {return}
                let downloadedImage = UIImage(data: data)
                imageCache.setObject(downloadedImage as AnyObject, forKey: NSString(string: url))
                DispatchQueue.main.async {
                    self.logo = downloadedImage
                }
            }
            dataTask.resume()
        }
    }
}
