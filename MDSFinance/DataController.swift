//
//  DataController.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 29.03.2021.
//

import Foundation

class DataController {
    var StockItems = [Stock]()
    //ЗДЕСЬ МОЖЕТ БЫТЬ ВАШ ТОКЕН (Finnhub.com)
    var apiToken = ""
    weak var delegate: DataControllerDelegate?
    //Запрос цены по акции
    func requestStockPrice(for index: Int) {
        let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(StockItems[index].companySymbol)&token=\(apiToken)")!
        let dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {return}
            //Распарсим результат
            //self.parseQuote(data: data)
            do {
                let jsonResult = try JSONDecoder().decode(QuoteApiResponse.self, from: data)
                //StockItems[indexInModel]
                DispatchQueue.main.async {
                    self.StockItems[index].price = jsonResult.c
                    self.StockItems[index].priceChange = jsonResult.c/jsonResult.o
                    self.delegate?.priceHasBeenModified()
                }
            } catch {}
        }
        dataTask.resume()
    }
}
