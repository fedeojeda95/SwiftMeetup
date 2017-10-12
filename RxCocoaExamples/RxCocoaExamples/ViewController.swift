//
//  ViewController.swift
//  RxCocoaExamples
//
//  Created by Federico Ojeda on 10/10/17.
//  Copyright © 2017 Federico Ojeda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseManager = DatabaseManager()
        
        databaseManager
            .getData()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(String.self)
            .subscribe(
                onNext:  { [weak self] value in
                    self?.showAlert("Tapped `\(value)`")
                }
            )
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(
                onNext: { [weak self] indexPath in
                    self?.showAlert("Tapped Detail @ \(indexPath.section),\(indexPath.row)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}

