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
    
    
    public func displayStockInfo(for dataSource: Stock) {
        self.companyNameLabel?.text =  dataSource.companyName
        self.companySymbolLabel?.text = dataSource.companySymbol
        self.priceLabel?.text = "$\(dataSource.price)"
        
        if dataSource.priceChange > 0 {
            self.priceChangeLabel?.text = "+$\(String(format: "%.2f",dataSource.priceChange))"
            self.priceChangeLabel?.textColor = UIColor.green
        }
        else if dataSource.priceChange < 0 {
            self.priceChangeLabel?.text = "-$\(String(format: "%.2f",abs(dataSource.priceChange)))"
            self.priceChangeLabel?.textColor = UIColor.red
        }
        else {
            self.priceChangeLabel?.text = "\(String(format: "%.2f",dataSource.priceChange))"
            self.priceChangeLabel?.textColor = UIColor.black
        }
        //self.companyNameLabel?.sizeToFit()
        
        self.favStarButton?.tintColor = dataSource.isFavorite ? UIColor.systemYellow : UIColor.lightGray

        self.companyLogoImage.image = dataSource.logo
        //dataSource. uploadCompanyLogo(for: dataSource.companySymbol)
        
    }
    
}
