//
//  ViewController.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 26.03.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StockCellDelegate, DataControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allStocksButton: UIButton!
    @IBOutlet weak var favoriteStocksButton: UIButton!
    
    let searchController = UISearchController()
    /*let tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshStocksInfo(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing stocks information ...")
        return refreshControl
    }()*/
    // Для поиска через API
    var searchResultsAPI: [SearchResult] = []
    
    var searchedStockItems : [Stock] = []
    var filteredStocks = [Stock]()
    
    //true - если нажата кнопка "Favorites", false - "Stocks"
    var isFavoriteTabChosen = false
    //если true -  отображаем кнопки "Stocks" & "Favorites", иначе - нет
    var hideTabButtons = false
    
    private let dataController = DataController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Delegates
        dataController.delegate = self
        tableView.delegate = self
        // Установим высоту строки
        tableView.rowHeight = 80
        //Подгрузим дефолтные данные
        dataController.initDefaultStockItems()
        tableView.reloadData()
        //Проинициализируем search controller
        initSearchController()
        //Обновим отображение "Stocks" и "Favorites"
        updateTabsLabels()
        dataController.getAllAvailableTickets()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //Refresh control
        //tableView.refreshControl = tableRefreshControl
        
        //Скроем пустые ячейки
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshStocksInfo(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing stocks information ...")
        tableView.addSubview(refreshControl)
    }
    
    //Для отображения строки поиска сразу при загрузке
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.performWithoutAnimation {
            searchController.isActive = true
            searchController.isActive = false
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
        if(searchController.isActive) {
            return filteredStocks.count
        }
        else if (self.isFavoriteTabChosen) {
            return dataController.FavoriteStockItems.count
        }
        else {
            return dataController.StockItems.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.cellIdentifier, for: indexPath) as! StockCell

        cell.dataController = dataController
        cell.delegate = self
        cell.setFavoriteButton()
        
        if(searchController.isActive) {
            cell.displayStockInfo(for : filteredStocks[indexPath.row])
        }
        else if self.isFavoriteTabChosen {
            cell.displayStockInfo(for : dataController.FavoriteStockItems[indexPath.row])
        }
        else {
            cell.displayStockInfo(for : dataController.StockItems[indexPath.row])
        }
        
        return cell
    }
    
    //MARK:- Pull to Refresh
    @objc func refreshStocksInfo(sender: UIRefreshControl) {
        print("Refreshing info")
        for index in dataController.StockItems.indices {
            dataController.requestStockPrice(for: index)
        }
        /*UIView.performWithoutAnimation {
            self.tableView.reloadData()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }*/
        sender.endRefreshing()
    }
    
    //MARK:- "Бесконечный" скроллинг
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100-scrollView.frame.size.height) {
            //fetch more data
            //print("We're ready to fetch more data")
        }
    }
    //MARK:- Работа с "вкладками" Stocks и Favorites
    //Нажатие на "вкладку" Stocks
    @IBAction func touchStocksButton(_ sender: Any) {
        self.isFavoriteTabChosen = false
        updateTabsLabels()
    }
    //Нажатие на "вкладку" Favorites
    @IBAction func touchFavoritesButton(_ sender: Any) {
        self.isFavoriteTabChosen = true
        updateTabsLabels()
    }
    //Обновление отображения "вкладок" на UI
    func updateTabsLabels() {
        if self.isFavoriteTabChosen {
            favoriteStocksButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            favoriteStocksButton.setTitleColor(.black, for: .normal)
            
            allStocksButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            allStocksButton.setTitleColor(.lightGray, for: .normal)
        } else {
            allStocksButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            allStocksButton.setTitleColor(.black, for: .normal)

            favoriteStocksButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            favoriteStocksButton.setTitleColor(.lightGray, for: .normal)
        }
        tableView.reloadData()
    }
    //Скрывает/показывает "вкладки" на UI
    func showTabButtonsOnScreen() {
        if self.hideTabButtons {
            allStocksButton.isHidden = true
            favoriteStocksButton.isHidden = true
        } else {
            allStocksButton.isHidden = false
            favoriteStocksButton.isHidden = false
        }
    }
    
    //MARK:- Детальная информация по акции
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "stockDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "stockDetailSegue") {
            let indexPath = tableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? TableViewDetail
            let selectedStock: Stock!
                        
            if(searchController.isActive) {
                selectedStock = filteredStocks[indexPath.row]
            }
            else {
                selectedStock = dataController.StockItems[indexPath.row]
            }
            tableViewDetail!.selectedStock = selectedStock
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //MARK:- Для работы с searchBar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.hideTabButtons = true
        showTabButtonsOnScreen()
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideTabButtons = false
        showTabButtonsOnScreen()

    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        filterForSearchTextAndScopeButton(searchText: searchText)
    }
    
    func filterForSearchTextAndScopeButton(searchText: String) {
        filteredStocks=[]
        /*filteredStocks = dataController.StockItems.filter {
            stock in
            //let scopeMatch = (scopeButton=="All"||(scopeButton=="Favorites"&&stock.isFavorite))
            if(searchController.searchBar.text != "") {
                let searchNameMatch = stock.companyName.lowercased().contains(searchText.lowercased())
                let searchTickerMatch = stock.companySymbol.lowercased().contains(searchText.lowercased())
                return (searchNameMatch || searchTickerMatch)
            }
            else {return true}
        }*/
        
        let filteredSt = dataController.AllAvailableTickets.filter {
            ticket in
            //let scopeMatch = (scopeButton=="All"||(scopeButton=="Favorites"&&stock.isFavorite))
            if(searchController.searchBar.text != "") {
                let searchNameMatch = ticket.name.lowercased().contains(searchText.lowercased())
                let searchTickerMatch = ticket.symbol.lowercased().contains(searchText.lowercased())
                return (searchNameMatch || searchTickerMatch)
            }
            else {return false}
        }
        
        for fst in filteredSt {
            filteredStocks.append(Stock(companyName: fst.name, companySymbol: fst.symbol))
        }
        tableView.reloadData()
    }
    
    //MARK: - Функции для инициализации
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Find company or ticker"

        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        //searchController.searchBar.scopeButtonTitles = ["All", "Favorites"]
        searchController.searchBar.delegate = self
        
    }
    //MARK: - Функции делегата
    //Произошло нажатии на кнопку "избранное"
    func stockMarkedAsFavorite(cell: UITableViewCell) {
        let stockCell = cell as! StockCell
        guard let indexPathTouched = tableView.indexPath(for: cell) else {return}
        
        //Если нажали и активен поиск
        if(searchController.isActive) {
            filteredStocks[indexPathTouched.row].isFavorite = filteredStocks[indexPathTouched.row].isFavorite ? false : true
            stockCell.favStarButton?.tintColor = filteredStocks[indexPathTouched.row].isFavorite ? UIColor.systemYellow : UIColor.lightGray
            
            //Обновим данные ещё и в основном массиве акций
            dataController.updateStockItemsFavoritesStatus(for: filteredStocks[indexPathTouched.row])
            //Актуализируем список избранных акций
            dataController.actualizeFavoriteStocksItems(with: filteredStocks[indexPathTouched.row])
        }
        //Если нажали с "вкладки" Favorites
        else if self.isFavoriteTabChosen{
            dataController.FavoriteStockItems[indexPathTouched.row].isFavorite = dataController.FavoriteStockItems[indexPathTouched.row].isFavorite ? false : true
            stockCell.favStarButton?.tintColor = dataController.FavoriteStockItems[indexPathTouched.row].isFavorite ? UIColor.systemYellow : UIColor.lightGray
            
            //Обновим данные ещё и в основном массиве акций
            dataController.updateStockItemsFavoritesStatus(for: dataController.FavoriteStockItems[indexPathTouched.row])
            //Актуализируем список избранных акций
            dataController.actualizeFavoriteStocksItems(with: dataController.FavoriteStockItems[indexPathTouched.row])
            //Перезагрузим, что убранная акция ушла
            tableView.reloadData()
        }
        //Если нажали с "вкладки" Stocks
        else {
            dataController.StockItems[indexPathTouched.row].isFavorite = dataController.StockItems[indexPathTouched.row].isFavorite ? false : true
            stockCell.favStarButton?.tintColor = dataController.StockItems[indexPathTouched.row].isFavorite ? UIColor.systemYellow : UIColor.lightGray
            //Актуализируем список избранных акций
            dataController.actualizeFavoriteStocksItems(with: dataController.StockItems[indexPathTouched.row])
        }
    }
    
    func priceHasBeenModified(forRow : Int) {
        //tableView.reloadData()
        let indexPath = IndexPath(item: forRow, section: 0)
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows?.firstIndex(of: indexPath as IndexPath) {
            if visibleIndexPaths != NSNotFound {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //MARK: - Запросы
    // Поиск акций (ищем символ для акции по имени компании)
    func searchQuotes(query: String) {
        let urlString = "https://finnhub.io/api/v1/search?q=\(query)&token=\(APIkeys.finnhubSandBox)"
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

