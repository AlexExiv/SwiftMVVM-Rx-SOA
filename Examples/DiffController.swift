//
//  ViewController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import BaseMVVM

struct Item: SBDiffEntity
{
    let id: Int
    let value: String
    
    func IsTheSame( entity: SBDiffEntity ) -> Bool
    {
        guard let n = entity as? Item else { return false }
        return n.id == id
    }
    
    func IsContentChanged( entity: SBDiffEntity ) -> Bool
    {
        guard let n = entity as? Item else { return false }
        return n.value != value
    }
}

@MainActor
class DiffController: UITableViewController
{
    let allItems = [[Item( id: 1, value: "Test 1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 3, value: "Test 3" ),
                    Item( id: 4, value: "Test 4" )],
                    
                    [Item( id: 3, value: "Test 3" ),
                     Item( id: 1, value: "Test 1" ),
                     Item( id: 4, value: "Test 4" ),
                     Item( id: 2, value: "Test 2" )],
    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 5, value: "Test 5" )],
                    
                    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 3, value: "Test new3" ),
                    Item( id: 5, value: "Test 5" )],
                    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 5, value: "Test 5" ),
                    Item( id: 6, value: "Test 6" ),
                    Item( id: 7, value: "Test 7" )],
    
                    [Item( id: 3, value: "Test new1" ),
                    Item( id: 1, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 2, value: "Test 5" ),
                    Item( id: 6, value: "Test 6" ),
                    Item( id: 9, value: "Test 7" )]]

    let allItems1 = [[Item( id: 10, value: "Test 10" ),
                    Item( id: 20, value: "Test 20" ),
                    Item( id: 30, value: "Test 30" ),
                    Item( id: 40, value: "Test 40" )],
                    
                    [Item( id: 30, value: "Test 30" ),
                     Item( id: 10, value: "Test 10" ),
                     Item( id: 40, value: "Test 40" ),
                     Item( id: 20, value: "Test 20" )],
    
                    [Item( id: 10, value: "Test new01" ),
                    Item( id: 20, value: "Test 20" ),
                    Item( id: 40, value: "Test new40" ),
                    Item( id: 50, value: "Test 50" )],
                    
                    
                    [Item( id: 10, value: "Test new10" ),
                    Item( id: 20, value: "Test 20" ),
                    Item( id: 30, value: "Test new30" ),
                    Item( id: 50, value: "Test 50" )],
                    
                    [Item( id: 10, value: "Test new10" ),
                    Item( id: 20, value: "Test 20" ),
                    Item( id: 40, value: "Test new40" ),
                    Item( id: 50, value: "Test 50" ),
                    Item( id: 60, value: "Test 60" ),
                    Item( id: 70, value: "Test 70" )],
    
                    [Item( id: 30, value: "Test new10" ),
                    Item( id: 10, value: "Test 20" ),
                    Item( id: 40, value: "Test new40" ),
                    Item( id: 20, value: "Test 50" ),
                    Item( id: 60, value: "Test 60" ),
                    Item( id: 90, value: "Test 70" )]]

    var curInd = 0
    var curItems: [Item]! = nil
    var maxGenValue = 100
    var rxP = BehaviorRelay<[(String, [Item])]>( value: [] )
    let dispBag = DisposeBag()
    let dataProvider = SBPairDataProvider<String, Item>( logging: true )
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Reset( nil )
        //SBDiffCalculator.BindUpdates( from: rxP, table: tableView, scheduler: MainScheduler.asyncInstance, dispBag: dispBag )
        
        rxP
            .bind( to: dataProvider, tableView: tableView )
            .disposed( by: dispBag )
    }

    @IBAction func Reset(_ sender: Any?)
    {
        curInd = 0
        rxP.accept( [("Section 0", allItems[0]), ("Section 1", allItems1[0])] )
        //curItems = allItems[0]
        //tableView.reloadData()
    }
    
    @IBAction func Left(_ sender: Any)
    {
        curInd = (allItems.count + curInd - 1)%allItems.count
        var sections = [[Item]]()
        sections.append( allItems[curInd] )
        if curInd % 2 == 0
        {
            sections.append( allItems1[curInd] )
        }
        
        SetData( items: sections )
    }
    
    @IBAction func Right(_ sender: Any)
    {
        curInd = (allItems.count + curInd + 1)%allItems.count
        var sections = [[Item]]()
        sections.append( allItems[curInd] )
        if curInd % 2 == 0
        {
            sections.append( allItems1[curInd] )
        }
        
        SetData( items: sections )
    }
    
    func SetData( items: [[Item]] )
    {
        rxP.accept( items.enumerated().map { ("Section \($0.offset)", $0.element) } )
        /*let calc = SBDiffCalculator( oldItems: curItems, newItems: items )
        curItems = items
        calc.Calc()
        calc.Dispatch( to: tableView )*/
    }
    
    func AddData( items: [Item] )
    {
        var values = rxP.value.last!
        values.1.append( contentsOf: items )
        var newItems = rxP.value.count > 1 ? Array( rxP.value[0..<(rxP.value.count - 1)] ) : []
        newItems.append( values )
        rxP.accept( newItems )
        /*
        let old = curItems ?? []
        curItems.append( contentsOf: items )
        let calc = SBDiffCalculator( oldItems: old, newItems: curItems )
        //curItems = items
        calc.Calc()
        calc.Dispatch( to: tableView )*/
    }
    
    //MARK: -
    override func numberOfSections( in tableView: UITableView ) -> Int
    {
        dataProvider.count
    }
    
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        dataProvider[section].items.count
    }
    
    override func tableView( _ tableView: UITableView, titleForHeaderInSection section: Int ) -> String?
    {
        "Section \(section)"
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath )
        cell.textLabel?.text = dataProvider[indexPath.section].items[indexPath.row].value
        return cell
    }
    
    override func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath )
    {
        if indexPath.row == dataProvider[dataProvider.count - 1].items.count - 1
        {
            DispatchQueue.main.async {
                let items = Array( self.maxGenValue..<(self.maxGenValue + 100) ).map { Item( id: $0, value: "Generate \($0)" ) }
                self.AddData( items: items )
                self.maxGenValue += 100
            }
        }
    }
}
