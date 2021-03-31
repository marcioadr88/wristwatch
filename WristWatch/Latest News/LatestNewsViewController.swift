//
//  LatestNewsViewController.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-29.
//

import UIKit
import RxSwift
import RxCocoa

private let newsApiClient = NewsAPIClientImpl(baseURL: "https://newsapi.org",
                                              //apiKey: "e2c0bd1a7ce94d39beb67a8e0a086897",
                                              apiKey: "2a979b17bb884e61b60fe7e740887ee3",
                                              version: "v2")

private let networkRepository = NetworkRepository(newsApiClient: newsApiClient)

class LatestNewsViewController: UIViewController, UITableViewDelegate {
    private let cellId = "articleCell"
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = LatestNewsViewModel(newsRepository: networkRepository)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadArticles(fromScratch: true)
    }
    
    private func loadArticles(fromScratch: Bool) {
        viewModel.loadArticles(keyword: "watches", fromScratch: fromScratch)
    }
    
    private func setupTableView() {
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        viewModel
            .error
            .filter { $0 != nil }
            .map({ error -> String in
                error?.localizedDescription ?? "Could not load feed"
            })
            .observe(on: MainScheduler.instance)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let errorMessage):
                    let alertVC = AlertUtils
                        .buildAlertController(title: "Error",
                                              message: errorMessage) { _ in
                            self.viewModel.clearError()
                        }
                    
                    self.present(alertVC, animated: true, completion: nil)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] _ in
                self.loadArticles(fromScratch: true)
            }).disposed(by: disposeBag)
        
        viewModel
            .loading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel
            .articles
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: ArticleCell.self)) { (_, article, cell) in
                cell.article = article
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            self.loadArticles(fromScratch: false)
        }
    }
    
}
