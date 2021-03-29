//
//  FavoritesViewController.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 29.03.2021.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource {

    private let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Probably wrong
        //tableView.register(StockCell.self, forCellReuseIdentifier: "CellID")
        //tableView.rowHeight = 80
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        dataController.StockItems.append(Stock(companyName: "Yandex, LLC", companySymbol: "YNDX"))
        dataController.StockItems.append(Stock(companyName: "Apple Inc.", companySymbol: "AAPL"))
        dataController.StockItems.append(Stock(companyName: "Alphabet Class A", companySymbol: "GOOGL"))
        dataController.StockItems.append(Stock(companyName: "Amazon.com", companySymbol: "AMZN"))
        dataController.StockItems.append(Stock(companyName: "Tesla Motors", companySymbol: "TSLA"))
        dataController.StockItems.append(Stock(companyName: "Twitter Inc.", companySymbol: "TWTR"))
        dataController.StockItems.append(Stock(companyName: "Mastercard", companySymbol: "MA"))
        dataController.StockItems.append(Stock(companyName: "Bank of America Corp.", companySymbol: "BAC"))
        dataController.StockItems.append(Stock(companyName: "Microsoft Corporation", companySymbol: "MSFT"))
        dataController.StockItems.append(Stock(companyName: "Facebook Inc.", companySymbol: "FB"))
        for index in dataController.StockItems.indices {
            dataController.requestStockPrice(for: index)
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataController.StockItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.cellIdentifier, for: indexPath) as! StockCell
        
        cell.dataController = dataController
        //Делегат
        //cell.delegate = self
        if(cell.dataController.StockItems[indexPath.row].isFavorite) {
            cell.setFavoriteButton()
            cell.displayStockInfo(for: indexPath.row)
        }
        return cell
    }
}
