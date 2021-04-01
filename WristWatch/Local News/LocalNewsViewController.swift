//
//  LocalNewsViewController.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-31.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices
import RealmSwift

private let database = RealmDatabase()

let localRepository = LocalRepository(database: database)

class LocalNewsViewController: UIViewController, UITableViewDelegate {
    private let cellId = "localArticleCell"
    private let toCreateOrEditVCSegueId = "toCreateOrEditVC"
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = NewsViewModel(newsRepository: localRepository)
    
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
                    .items(cellIdentifier: cellId, cellType: LocalArticleCell.self)) { (_, article, cell) in
                cell.article = article
            }
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
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Archive action
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit") { [unowned self] (_, _, completionHandler) in
            let article = self.viewModel.articles.value[indexPath.row]
            self.performSegue(withIdentifier: self.toCreateOrEditVCSegueId, sender: article)
            
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        // Trash action
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") {  [unowned self] (_, _, completionHandler) in
            let article = self.viewModel.articles.value[indexPath.row]
            self.viewModel.delete(article: article)
            self.loadArticles(fromScratch: true)

            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return configuration
    }
    
    @IBAction func newPostTapped(_ sender: Any) {
        performSegue(withIdentifier: toCreateOrEditVCSegueId, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toCreateOrEditVCSegueId,
           let navVC = segue.destination as? UINavigationController,
           let vc = navVC.topViewController as? CreateOrEditPostViewController {
            vc.delegate = self
            vc.article = sender as? Article
        }
    }
}

extension LocalNewsViewController: CreateOrEditPostViewControllerDelegate {
    func postsUpdated() {
        loadArticles(fromScratch: true)
    }
}
