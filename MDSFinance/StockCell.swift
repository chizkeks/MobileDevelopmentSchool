//
//  StockCell.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 26.03.2021.
//

import UIKit

protocol StockCellDelegate: class {
    func stockMarkedAsFavorite(cell: UITableViewCell)
}
class StockCell: UITableViewCell {
    
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyLogoImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var favStarButton: UIButton!
    
    weak var delegate: StockCellDelegate?
    
    static let cellIdentifier = "CellID"
    var dataController: DataController
    
    @objc public func handleMarkedAsFavorite() {
        delegate?.stockMarkedAsFavorite(cell: self)
    }
    
    public func setFavoriteButton() {
        favStarButton?.addTarget(self, action: #selector(handleMarkedAsFavorite), for: .touchUpInside)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.dataController = DataController()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.dataController = DataController()
       super.init(coder: aDecoder)
    }
    
    
    public func displayStockInfo(for index: Int) {
        self.companyNameLabel?.text = dataController.StockItems[index].companyName
        self.companySymbolLabel?.text = dataController.StockItems[index].companySymbol
        self.priceLabel?.text = "\(dataController.StockItems[index].price)"
        
        if dataController.StockItems[index].priceChange > 0 {
            self.priceChangeLabel?.text = "+$\(String(format: "%.2f",dataController.StockItems[index].priceChange))"
            self.priceChangeLabel?.textColor = UIColor.green
        }
        else if dataController.StockItems[index].priceChange < 0 {
            self.priceChangeLabel?.text = "-$\(String(format: "%.2f",abs(dataController.StockItems[index].priceChange)))"
            self.priceChangeLabel?.textColor = UIColor.red
        }
        else {
            self.priceChangeLabel?.text = "\(String(format: "%.2f",dataController.StockItems[index].priceChange))"
            self.priceChangeLabel?.textColor = UIColor.black
        }
        self.companyNameLabel?.sizeToFit()
        uploadCompanyLogo(for: dataController.StockItems[index].companySymbol)
    }
    
    //MARK:- Получение  логотипа по тикету акции
    public func uploadCompanyLogo(for symbol: String) {
        //companyLogo.image = [UIImage imageWithContentsOfURL: url
        
        let url = URL(string: "https://storage.googleapis.com/iex/api/logos/\(symbol).png")!
        let dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {return}
            DispatchQueue.main.async {
                self.companyLogoImage.image = UIImage(data: data)
            }
        }
        dataTask.resume()
    }
    
}
