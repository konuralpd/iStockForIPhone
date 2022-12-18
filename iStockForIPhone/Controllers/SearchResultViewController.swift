//
//  SearchResultViewController.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultViewControllerDidSelect(searchResults: SearchResult)
}

class SearchResultViewController: UIViewController {
    
    weak var delegate: SearchResultViewControllerDelegate?
    
    private var results: [SearchResult] = []
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        setUpTableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "deepPurple")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.results = results
            self.tableView.isHidden = results.isEmpty
            self.tableView.reloadData()
        }
    }
    
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
        let result = results[indexPath.row]
        
        cell.set(stock: result)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = results[indexPath.row]
        delegate?.searchResultViewControllerDidSelect(searchResults: result)
    }
    
}
