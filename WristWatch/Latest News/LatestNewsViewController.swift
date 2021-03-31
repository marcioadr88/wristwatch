//
//  LatestNewsViewController.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-29.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

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
        setupRefreshControl()
        
        // present an alert when on errors
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
                            self.viewModel.clearError() // clear the error
                        }
                    
                    self.present(alertVC, animated: true, completion: nil)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // configure cell
        viewModel
            .articles
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: cellId, cellType: ArticleCell.self)) { (_, article, cell) in
                cell.article = article
            }
            .disposed(by: disposeBag)
        
        // handle item selected
        tableView
            .rx
            .modelSelected(Article.self)
            .subscribe(onNext: { [unowned self] article in
                if let url = URL(string: article.url) {
                    let sfSafariVC = SFSafariViewController(url: url)
                    
                    self.present(sfSafariVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // set tableview delegate
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // automatic table row height's dimension
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupRefreshControl() {
        // setup refresh control
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
        // handle refresh control value changed
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] _ in
                self.loadArticles(fromScratch: true)
            }).disposed(by: disposeBag)
        
        // bind refresh control
        viewModel
            .loading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
    
        // load next page when the user scroll to bottom
        if offsetY > contentHeight - scrollView.frame.height {
            self.loadArticles(fromScratch: false)
        }
    }
    
}
