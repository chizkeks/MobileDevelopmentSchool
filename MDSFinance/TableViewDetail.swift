//
//  TableViewDetail.swift
//  MDSFinance
//
//  Created by Ilya Pavlov on 01.04.2021.
//

import Foundation
import UIKit

class TableViewDetail: UIViewController {
    
    @IBOutlet weak var stockSymbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    
    var selectedStock : Stock!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stockSymbol.text = selectedStock.companySymbol
        stockSymbol?.sizeToFit()
        companyName.text = selectedStock.companyName
        companyName?.sizeToFit()
        companyLogo.image = selectedStock.logo
    }
}
