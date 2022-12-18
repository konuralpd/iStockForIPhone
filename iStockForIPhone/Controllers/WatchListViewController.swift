//
//  ViewController.swift
//  iStockForIPhone
//
//  Created by Mac on 16.12.2022.
//

import UIKit
import ProgressHUD
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    private var panel: FloatingPanelController?
    
    private var watchListMap: [String: [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var lightTransparentBG: UIView = {
       let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.15)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var appNameLabel: UILabel = {
       let label = UILabel()
        label.text = "iStocks"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "deepPurple")
        setUpSearchController()
        setUpTableView()
        fetchWatchlistData()
        setUpUI()
        setUpFloatingPanel()
        setUpObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList, object: nil, queue: .main, using: { [weak self] _ in
            guard let self = self else { return }
            self.viewModels.removeAll()
            self.fetchWatchlistData()
        })
    }
    
    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchList
        let group = DispatchGroup()
        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()
            NetworkManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.createViewModels()
            self.tableView.reloadData()
        }
        
    }
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = getChangePercentage(for: candleSticks)
            viewModels.append(.init(symbol: symbol, price: getLatestClosingPrice(from: candleSticks) , changeColor: changePercentage < 0 ? .systemRed : .systemGreen, changePercentage: "\(changePercentage)", companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company", chartViewModel: .init(data: candleSticks.reversed().map { $0.c }, showLegend: false, showAxisBool: false)))
        }
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(for data: [CandleStick]) -> Double {
        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
        guard let latestClose = data.first?.c,
            let priorClose = data.first(where: { Calendar.current.isDate($0.d, inSameDayAs: priorDate) })?.c
        else {
            return 0 }
        let diff = 1 - (priorClose/latestClose)
        let diffString = String(format: "%.02f", diff)
        return Double(diffString) ?? 0
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let first = data.first?.c else { return "" }

        return .formatted(number: first)
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 40,right: 0)
        tableView.separatorStyle = .none
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpFloatingPanel() {
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .black.withAlphaComponent(0.4)
        let newsVc = NewsViewController(type: .topStories)
        panel.set(contentViewController: newsVc)
        panel.addPanel(toParent: self)
        panel.delegate = self
        panel.track(scrollView: newsVc.tableView)
    }
    
    //Searchbar
    private func setUpSearchController() {
        let resultVC = SearchResultViewController()
        resultVC.delegate = self
        let searchController = UISearchController(searchResultsController: resultVC)
        searchController.searchBar.placeholder = "Search for Market"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    
    
    private func setUpUI() {
        view.addSubview(lightTransparentBG)
        lightTransparentBG.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            
            lightTransparentBG.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            lightTransparentBG.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            lightTransparentBG.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            lightTransparentBG.heightAnchor.constraint(equalToConstant: 60),
            
            
            appNameLabel.centerYAnchor.constraint(equalTo: lightTransparentBG.centerYAnchor),
            appNameLabel.centerXAnchor.constraint(equalTo: lightTransparentBG.centerXAnchor)
           
            
        ])
    }


}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, let resultsVC = searchController.searchResultsController as? SearchResultViewController, !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            NetworkManager.shared.search(query: searchText) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard self != nil else { return }
                        resultsVC.update(with: response.result!)
                        if response.result?.count == 0 {
                            ProgressHUD.show("No market data found.", icon: .question)
                            searchController.searchBar.text = ""
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard self != nil else { return }
                        resultsVC.update(with: [])
                        print(error)
                    }
                }
            }
        })
        
        
       
    }
}

extension WatchListViewController: SearchResultViewControllerDelegate {
    func searchResultViewControllerDidSelect(searchResults: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = DetailsViewController(symbol: searchResults.displaySymbol ?? "APPL", companyName: searchResults.resultDescription ?? "Apple", candleStickData: [])
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResults.resultDescription
        present(navVC, animated: true)
    }
    
    
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        self.lightTransparentBG.isHidden = fpc.state == .full
        self.appNameLabel.isHidden = fpc.state == .full
        self.tableView.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else { return UITableViewCell() }
        cell.configure(with: viewModels[indexPath.row])
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 12
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(named: "deepPurple")?.cgColor
  
        
        cell.getCompanyLogo(for: viewModels[indexPath.row].symbol)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = viewModels[indexPath.row]
        let vc = DetailsViewController(symbol: viewModel.symbol, companyName: viewModel.companyName, candleStickData: watchListMap[viewModel.symbol] ?? [])
        let navViewController = UINavigationController(rootViewController: vc)
        present(navViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            viewModels.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
            PersistenceManager.shared.deleteFromWatchList(symbol: viewModels[indexPath.row].symbol)
            
            tableView.endUpdates()
        }
    }
  

}
