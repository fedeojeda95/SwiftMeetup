//
//  SearchViewController.swift
//  SwiftMeetup
//
//  Created by Santiago Fernandez on 10/12/17.
//  Copyright © 2017 Xmartlabs SRL. All rights reserved.
//

import RxAlamofire
import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit

class GithubApi {
    
    // Search github repos with query -sorted descending by stars- and get names
    static func search(_ query: String) -> Observable<[String]> {
        return RxAlamofire.requestJSON(.get, "https://api.github.com/search/repositories", parameters: ["q": "\(query)", "sort": "stars", "order": "desc"])
            .map { args -> JSON in
                let (_, jsonObject) = args
                return JSON(jsonObject)
            }
            .map { repos in
                let items = repos["items"].arrayValue
                return items.map { $0["name"].stringValue }
            }
    }
    
}

class ViewModel {
    
    let disposeBag = DisposeBag()
    
    /// The search query
    var query: Variable<String> = Variable("")
    
    /// The loading indicator
    var loading: Variable<Bool> = Variable(false)
    
    /// The search results
    var results: Variable<[String]> = Variable([])
    
    /// Lifecycle
    init() {
        let minCharCount = 3
        let dueTime = 0.3
        
        // When query emits a value with length >= minCharCount dispatch a search action, `clean` results if < minCharCount
        query.asObservable()
            .throttle(dueTime, scheduler: ConcurrentMainScheduler.instance)
            .flatMapLatest { query -> Observable<[String]> in
                if query.count >= minCharCount {
                    self.loading.value = true
                    return GithubApi.search(query)
                } else {
                    return Observable.just([])
                }
            }
            .catchErrorJustReturn([])
            .do(onNext: { _ in
                self.loading.value = false
            })
            .observeOn(MainScheduler.instance)
            .bind(to: results)
            .disposed(by: disposeBag)
    }
}

class SearchViewController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Variables
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    /// Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservables()
    }
    
    /// Helpers
    func setupObservables() {
        // Bind text in searchBar to viewModel
        searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        // Bind results from search to tableView
        viewModel.results
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cellIdentifier", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element
            }
            .disposed(by: disposeBag)
        
        // Bind loading to activity Indicator
        viewModel.loading
            .asObservable()
            .map { !$0 }
            .bind(to: activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Bind loading to show tableview
        viewModel.loading
            .asObservable()
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
}
