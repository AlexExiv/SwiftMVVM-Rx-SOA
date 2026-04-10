//
//  ReverseController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 01.09.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import BaseMVVM

@MainActor
class ReverseController: UITableViewController
{
    let rxItems = BehaviorRelay<[(String, [Item])]>( value: [] )
    let messageProvider = SBPairDataProvider<String, Item>( reverse: true )
    
    let dispBag = DisposeBag()
    var lastId = 0
    var cellHeights = [Int: Double]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        rxItems
            .debounce( .seconds( 1 ), scheduler: MainScheduler.asyncInstance )
            .bind( to: messageProvider, tableView: tableView, all: UITableView.RowAnimation.none )
            .disposed( by: dispBag )
        
        Observable<Int>
            .interval( .seconds( 4 ), scheduler: MainScheduler.asyncInstance )
            .subscribe( onNext: { _ in self.Prev() } )
            .disposed( by: dispBag )
    }
    
    override func viewDidAppear( _ animated: Bool )
    {
        super.viewDidAppear( animated )
        Prev()
    }
    
    func Prev()
    {
        var items = rxItems.value
        let appendToFirst = Int.random( in: 0...1 ) == 1
        if appendToFirst && !items.isEmpty
        {
            let num = Int.random( in: 1...3 )
            for _ in 0..<num
            {
                let id = GenID()
                items[0].1.insert( Item( id: id, value: "Message #\(id)" ), at: 0 )
            }
        }
        
        for _ in 0..<5
        {
            let num = Int.random( in: 2...10 )
            var sec = [Item]()
            for _ in 0..<num
            {
                let id = GenID()
                sec.append( Item( id: id, value: "Message #\(id)" ) )
            }
            
            items.insert( ("Section \(items.count)", sec), at: 0 )
        }
        
        rxItems.accept( items )
    }
    
    func GenID() -> Int
    {
        lastId += 1
        return lastId
    }
    
    override func numberOfSections( in tableView: UITableView ) -> Int
    {
        messageProvider.count
    }
    
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        messageProvider[section].items.count
    }
    
    override func tableView( _ tableView: UITableView, titleForHeaderInSection section: Int ) -> String?
    {
        messageProvider[section].header
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        35
    }
    
    override func tableView( _ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath ) -> CGFloat
    {
        cellHeights[messageProvider[indexPath.section].items[indexPath.row].id] ?? UITableView.automaticDimension
    }
    
    override func tableView( _ tableView: UITableView, heightForHeaderInSection section: Int ) -> CGFloat
    {
        35
    }
    
    override func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat
    {
        let h = cellHeights[messageProvider[indexPath.section].items[indexPath.row].id] ?? CGFloat.random( in: 44.0...135.0 )
        cellHeights[messageProvider[indexPath.section].items[indexPath.row].id] = h
        return h
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath )
        cell.textLabel?.text = messageProvider[indexPath.section].items[indexPath.row].value
        return cell
    }
    /*
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y < 2.0 && messageProvider.count > 0
        {
            Prev()
        }
    }*/
}
