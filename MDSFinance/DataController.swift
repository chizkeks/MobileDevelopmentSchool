//
//  DataController.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 29.03.2021.
//

import Foundation
import UIKit

var imageCache = NSCache<NSString, AnyObject>()

class DataController {
    //Все отображаемые на UI акции
    var StockItems = [Stock]()
    //Только "избранные" акции
    var FavoriteStockItems = [Stock]()
    //Все доступные в АПИ тикеты и наименования компаний
    var AllAvailableTickets: [AllAvailableTicketsResponse] = []
    weak var delegate: DataControllerDelegate?
    
    //Заполнение "избранных" акций
    func fillFavoritesStocks() {
        self.FavoriteStockItems = self.StockItems.filter {
            stock in
            return stock.isFavorite
        }
    }
    
    //Обновляет информации об "избранности" акции, для акций, которые отображаются на UI
    func updateStockItemsFavoritesStatus(for stock: Stock){
        if let indexInStockItems = self.StockItems.firstIndex(where: {$0.identifier == stock.identifier}) {
            self.StockItems[indexInStockItems].isFavorite = stock.isFavorite
        }
    }
    
    func actualizeFavoriteStocksItems(with stock: Stock) {
        if let indexInStockItems = self.FavoriteStockItems.firstIndex(where: {$0.identifier == stock.identifier}) {
            //Если нашли в "избранном", но статус поменялся, то удаляем
            if !stock.isFavorite {
                self.FavoriteStockItems.remove(at: indexInStockItems)
            }
        }
        //Если не нашли, но статус "избранная", то нужно добавить
        else {
            self.FavoriteStockItems.append(stock)
        }
    }
    
    // Заполняет дефолтным набором акций
    func initDefaultStockItems() {
        self.StockItems.append(Stock(companyName: "Yandex, LLC", companySymbol: "YNDX"))
        self.StockItems.append(Stock(companyName: "Apple Inc.", companySymbol: "AAPL"))
        self.StockItems.append(Stock(companyName: "Alphabet Class A", companySymbol: "GOOGL"))
        self.StockItems.append(Stock(companyName: "Amazon.com", companySymbol: "AMZN"))
        self.StockItems.append(Stock(companyName: "Tesla Motors", companySymbol: "TSLA"))
        self.StockItems.append(Stock(companyName: "Twitter Inc.", companySymbol: "TWTR"))
        self.StockItems.append(Stock(companyName: "Mastercard", companySymbol: "MA"))
        self.StockItems.append(Stock(companyName: "Bank of America Corp.", companySymbol: "BAC"))
        self.StockItems.append(Stock(companyName: "Microsoft Corporation", companySymbol: "MSFT"))
        self.StockItems.append(Stock(companyName: "Facebook Inc.", companySymbol: "FB"))
        for index in self.StockItems.indices {
            self.requestStockPrice(for: index)
        }
        self.fillFavoritesStocks()
    }
    
    //Запрос цены по акции
    func requestStockPrice(for index: Int) {
        let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(StockItems[index].companySymbol)&token=\(APIkeys.finnhubSandBox)")!
        //let url = URL(string: "https://cloud.iexapis.com/stable/\(StockItems[index].companySymbol)/quote/?token=\(apiToken)")!
        let dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {return}
            //Распарсим результат
            do {
                let jsonResult = try JSONDecoder().decode(QuoteApiResponse.self, from: data)
                //StockItems[indexInModel]
                DispatchQueue.main.async {
                    self.StockItems[index].price = jsonResult.c
                    self.StockItems[index].priceChange = jsonResult.c/jsonResult.o
                    self.delegate?.priceHasBeenModified(forRow: index)
                }
            } catch {}
        }
        dataTask.resume()
        //Подгрузим логотип компании
        //self.uploadCompanyLogo(for: self.StockItems[index].companySymbol, at: index)
        StockItems[index].getCompanyLogo()
    }
    
    //Получение всех доступных в используемом API тикетов
    public func getAllAvailableTickets() {
        print("Trying to get all tickets")
        let url = URL(string: "https://cloud.iexapis.com/stable/ref-data/symbols?token=\(APIkeys.iextradingCloud)")!
        let dataTask = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {return}
            //Распарсим результат
            do {
                let jsonResult = try JSONDecoder().decode([AllAvailableTicketsResponse].self, from: data)
                //StockItems[indexInModel]
                DispatchQueue.main.async {
                    self?.AllAvailableTickets = jsonResult
                }
            } catch {}
        }
        dataTask.resume()
    }
}
