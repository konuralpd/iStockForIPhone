//
//  NewsHeaderView.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {

   static let identifier = "NewsHeaderView"
   static let preferredHeight: CGFloat = 60
    
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let companyLogo: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let button: UIButton = {
       let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = UIColor(patternImage: UIImage(named: "buttonBG")!)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(label, button, companyLogo)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        label.frame = CGRect(x: UIScreen.main.bounds.midX / 2, y: 0, width: contentView.width - 24, height: contentView.height)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            companyLogo.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            companyLogo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            companyLogo.widthAnchor.constraint(equalToConstant: 48),
            companyLogo.heightAnchor.constraint(equalToConstant: 48)
        ])
        button.sizeToFit()
        button.frame = CGRect(x: contentView.width - button.width - 20, y: (contentView.height - button.height) / 2, width: button.width + 20, height: button.height)
    }
    
    @objc func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
        getCompanyLogo(for: viewModel.title)
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
