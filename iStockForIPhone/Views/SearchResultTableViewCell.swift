//
//  SearchResultTableViewCell.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    static let identifier = "SearchResultTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(stock: SearchResult) {
        textLabel?.text = stock.symbol
        detailTextLabel?.text = stock.resultDescription
        textLabel?.font = .boldSystemFont(ofSize: 18)
        detailTextLabel?.textColor = .lightGray
        backgroundColor = .black.withAlphaComponent(0.1)
    }
    
    

}
