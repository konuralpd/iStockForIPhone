//
//  WatchListTableViewCell.swift
//  iStockForIPhone
//
//  Created by Mac on 18.12.2022.
//

import UIKit
import SDWebImageSVGCoder
import SDWebImage


class WatchListTableViewCell: UITableViewCell {
    
    struct ViewModel {
        let symbol: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let companyName: String
        let chartViewModel: ChartView.ViewModel
        
    }
    
    private let companyLogo: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "apple")
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let symbolLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let miniChartView : ChartView = {
       let chart = ChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.clipsToBounds = true
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
   static let identifier = "WatchlistTableViewCell"
    
    static let prefferedHeight: CGFloat = 160
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(companyLogo, symbolLabel, companyLabel, priceLabel, changeLabel, miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//
//        symbolLabel.sizeToFit()
//        companyLabel.sizeToFit()
//        priceLabel.sizeToFit()
//        changeLabel.sizeToFit()
//        companyLogo.sizeToFit()
        
        NSLayoutConstraint.activate([
            companyLogo.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            companyLogo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            companyLogo.widthAnchor.constraint(equalToConstant: 42),
            companyLogo.heightAnchor.constraint(equalToConstant: 42),
            
            symbolLabel.topAnchor.constraint(equalTo: companyLogo.topAnchor, constant: 4),
            symbolLabel.leadingAnchor.constraint(equalTo: companyLogo.trailingAnchor, constant: 8),
            
            companyLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            companyLabel.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
            
            priceLabel.trailingAnchor.constraint(equalTo: changeLabel.trailingAnchor),
            priceLabel.topAnchor.constraint(equalTo: companyLogo.topAnchor, constant: -4),
            
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            changeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            changeLabel.heightAnchor.constraint(equalToConstant: 28),
            changeLabel.widthAnchor.constraint(equalToConstant: 64),
            
            miniChartView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            miniChartView.trailingAnchor.constraint(equalTo: changeLabel.leadingAnchor, constant: -16),
            miniChartView.heightAnchor.constraint(equalToConstant: contentView.frame.size.height / 1.2),
            miniChartView.widthAnchor.constraint(equalToConstant: contentView.frame.size.width / 3)
        ])
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        symbolLabel.text = nil
//        companyLabel.text = nil
//        priceLabel.text = nil
        changeLabel.text = nil
//        companyLogo.image = nil
//        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        let newPercentange = viewModel.changePercentage.replacingOccurrences(of: "-", with: "", options: [.anchored], range: nil)
        changeLabel.text = "%\(newPercentange)"
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }

    public func getCompanyLogo(for symbol: String) {
        NetworkManager.shared.getCompanyLogo(for: symbol) { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success(let response):
                let url = URL(string: response.logo ?? "")
                let bitmapSize = CGSize(width: 48, height: 48)
                DispatchQueue.main.async {
                    self.companyLogo.sd_setImage(with: url, placeholderImage: UIImage(named: "apple"), context: [.imageThumbnailPixelSize: bitmapSize])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    

}
