//
//  DetailsViewController.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit
import ProgressHUD
class DetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private var stories: [NewsResponseElement] = []
    
    private var metrics: Metrics?
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick]) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        title = "Details"
        setUpTableView()
        fetchData()
        fetchNews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.8) + 100))
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            NetworkManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.enter()
        
        NetworkManager.shared.financialMetrics(for: symbol) { [weak self] result in
            guard let self = self else { return }
            defer {
                group.leave()
            }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.renderChartView()
        }
        
        renderChartView()
    }
    
    private func renderChartView() {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.8) + 100))
        
        var viewModels = [MetricsCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol", value: "\(metrics.TenDayAverageTradingVolume)"))
        }
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map { $0.c}, showLegend: true, showAxisBool: true), metricViewModels: viewModels)
        tableView.tableHeaderView = headerView
    }
    
    private func fetchNews() {
        NetworkManager.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    let filteredResponse = news.filter { new in
                        return new.image != ""
                    }
                    self.stories = filteredResponse
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
        cell.set(news: stories[indexPath.row])
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: !PersistenceManager.shared.controlWatchlistAlreadyContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

extension DetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        ProgressHUD.showSucceed("Successfully this company added to your favorites.")
    }
    
    
}
