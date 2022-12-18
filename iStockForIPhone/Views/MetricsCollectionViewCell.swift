//
//  MetricsCollectionViewCell.swift
//  iStockForIPhone
//
//  Created by Mac on 19.12.2022.
//

import UIKit

class MetricsCollectionViewCell: UICollectionViewCell {
    static let identifier = "MetricsCollectionViewCell"
    
    private var horizontalStackView: UIStackView!

    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let valueLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.clipsToBounds = true
        addSubviews(nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        valueLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 3, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)

        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        nameLabel.text = nil
//        valueLabel.text = nil
        
    }
    
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value


    }
}
