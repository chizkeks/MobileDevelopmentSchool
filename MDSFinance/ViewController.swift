//
//  ViewController.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 26.03.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, StockCellDelegate, UISearchBarDelegate, DataControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // Для поиска через API
    var searchResultsAPI: [SearchResult] = []
    
    var searchedStockItems : [Stock] = []
    private let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.delegate = self
        tableView.rowHeight = 80
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //Скроем пустые ячейки
        tableView.tableFooterView = UIView()
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
    /* Для поиска
     Не успел сделать :((
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedStockItems = searchText.isEmpty ? dataController.StockItems : dataController.StockItems.filter { (item: Stock) -> Bool in
            return item.companyName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            tableView.reloadData()
        }
 */
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
        cell.delegate = self
        cell.setFavoriteButton()
        cell.displayStockInfo(for: indexPath.row)
        return cell
    }
    
    //MARK: - Функции делегата
    func stockMarkedAsFavorite(cell: UITableViewCell) {
        let stockCell = cell as! StockCell
        guard let indexPathTouched = tableView.indexPath(for: cell) else {return}
        dataController.StockItems[indexPathTouched.row].isFavorite = dataController.StockItems[indexPathTouched.row].isFavorite ? false : true
        stockCell.favStarButton?.tintColor = dataController.StockItems[indexPathTouched.row].isFavorite ? UIColor.systemYellow : UIColor.lightGray
    }
    
    func priceHasBeenModified() {
        tableView.reloadData()
    }
    
    //MARK: - Запросы
    // Поиск акций (ищем символ для акции по имени компании)
    func searchQuotes(query: String) {
        let urlString = "https://finnhub.io/api/v1/search?q=\(query)&token=\(dataController.apiToken)"
        guard let url = URL(string: urlString) else {return}
        let dataTask = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                self?.allertCreatorJSON(title: "❗️Network error", message: "Couldn't connect to the Internet")
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(SearchAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.searchResultsAPI = jsonResult.result
                }
            }
            catch {
                self?.allertCreatorJSON(title: "❗️JSON parsing error:", message: error.localizedDescription)
            }
            
        }.resume()
    }
    // MARK: - Функции для оповещения
    
     func allertCreatorJSON (title titleMessage: String, message allertMessage: String) {
        let alertController = UIAlertController(title: titleMessage, message: allertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

