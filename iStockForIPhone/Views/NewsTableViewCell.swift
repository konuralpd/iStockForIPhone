//
//  NewsTableViewCell.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder

class NewsTableViewCell: UITableViewCell {
    
    private let newsImage: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let newsLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .boldSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    static let identifier = "NewsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            newsImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            newsImage.widthAnchor.constraint(equalToConstant: 90),
            newsImage.heightAnchor.constraint(equalToConstant: 90),
            
            
            newsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsLabel.leadingAnchor.constraint(equalTo: newsImage.trailingAnchor, constant: 8),
            newsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            dateLabel.bottomAnchor.constraint(equalTo: newsImage.bottomAnchor, constant: -4),
            dateLabel.leadingAnchor.constraint(equalTo: newsImage.trailingAnchor, constant: 8)
        ])
    }
    
    func set(news: NewsResponseElement) {
        let url = URL(string: news.image ?? "")
        newsImage.sd_setImage(with: url)
        newsLabel.text = news.headline
        dateLabel.text = String.string(from: news.datetime!)
    }
    
    private func configure() {
        contentView.addSubviews(newsImage, newsLabel)
        contentView.addSubview(dateLabel)
        
    
    }
    
   
    
}
