//
//  NewsViewController.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit
import SafariServices
import ProgressHUD

class NewsViewController: UIViewController {
     
    public var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private var stories = [NewsResponseElement]()
    private let type: Type
    
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top News from Market"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setUpTableView()
        fetchNews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchNews() {
        NetworkManager.shared.news(for: .topStories) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let filteredResponse = response.filter { new in
                        return new.source != "Bloomberg"
                    }
                    self.stories = filteredResponse
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }


}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
        let new = stories[indexPath.row]
        cell.set(news: new)
        cell.backgroundColor = UIColor(named: "deepPurple")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: false))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let new = stories[indexPath.row]
        guard let url = URL(string: new.url ?? "") else {
            ProgressHUD.showFailed("Cannot open the new.")
            return
            
        }
        
        open(url: url)
    }

}
