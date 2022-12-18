//
//  StockDetailHeaderView.swift
//  iStockForIPhone
//
//  Created by Mac on 18.12.2022.
//

import UIKit

class StockDetailHeaderView: UIView {

   private let chartView = ChartView()
    
    private var metricViewModels: [MetricsCollectionViewCell.ViewModel] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black.withAlphaComponent(0.1)
        collectionView.register(MetricsCollectionViewCell.self, forCellWithReuseIdentifier: MetricsCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: height-100, width: width, height: 100)
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height-100)
    }
    
    func configure(chartViewModel: ChartView.ViewModel, metricViewModels: [MetricsCollectionViewCell.ViewModel]) {
        chartView.configure(with: chartViewModel)
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
}

extension StockDetailHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricsCollectionViewCell.identifier, for: indexPath) as? MetricsCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
    
}
