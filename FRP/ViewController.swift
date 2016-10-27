//
//  ViewController.swift
//  FRP
//
//  Created by Keith Russell on 6/21/16.
//  Copyright © 2016 Keith Russell. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var myLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var shownCities = [String]() // Data source for UITableView
    let allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"] // Our mocked API data source
    let disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated (protect against retain cycle)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        searchBar
        .rx_text //Observable property from RxCocoa
            .throttle(0.5, scheduler: MainScheduler.instance) //wait 0.5s
            .distinctUntilChanged() //If they didnt occur, check if the new value is the same as old
            .filter{ $0.characters.count > 0 }
            .subscribeNext{[unowned self] (query) in // here we will be notified of every new value
                self.shownCities = self.allCities.filter{$0.hasPrefix(query)} // We now do our "API Request" to find cities.
                self.tableView.reloadData() //and reload tableview
                self.myLbl.text = query
        }
        .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDataSource
/// Here we have standard data source extension for ViewController

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cityPrototypeCell", forIndexPath: indexPath)
        cell.textLabel?.text = shownCities[indexPath.row]
        
        return cell
    }
}

