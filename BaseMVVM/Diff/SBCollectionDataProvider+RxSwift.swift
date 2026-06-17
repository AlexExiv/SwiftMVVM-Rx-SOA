//
//  SBCollectionDataProvider+RxSwift.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 12.05.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

@MainActor
public extension ObservableType
{
    func bind<VM: SBDiffEntity>( to: SBArrayDataProvider<VM>, tableView: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable where Element == Array<VM>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBArrayCollectionSection( items: [$0] ), to: tableView, change: change, insert: insert, delete: delete, all: all ) } )
    }
    
    func bind<VM: SBDiffEntity>( to: SBArrayDataProvider<VM>, tableView: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable where Element == Array<[VM]>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBArrayCollectionSection( items: $0 ), to: tableView, change: change, insert: insert, delete: delete, all: all ) } )
    }
    
    func bind<VM: SBDiffEntity>( to: SBArrayDataProvider<VM>, collectionView: UICollectionView ) -> Disposable where Element == Array<VM>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBArrayCollectionSection( items: [$0] ), to: collectionView ) } )
    }
    
    func bind<VM: SBDiffEntity>( to: SBArrayDataProvider<VM>, collectionView: UICollectionView ) -> Disposable where Element == Array<[VM]>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBArrayCollectionSection( items: $0 ), to: collectionView ) } )
    }
    
    func bind<K: Hashable, VM: SBDiffEntity>( to: SBDictionaryDataProvider<K, VM>, tableView: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil, sort: @escaping (Dictionary<K, [VM]>.Keys) -> [K] ) -> Disposable where Element == Dictionary<K, [VM]>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBMapCollectionSection( items: $0, indices: sort( $0.keys ) ), to: tableView, change: change, insert: insert, delete: delete, all: all ) } )
    }
    
    func bind<K: Hashable, VM: SBDiffEntity>( to: SBDictionaryDataProvider<K, VM>, collectionView: UICollectionView, sort: @escaping (Dictionary<K, [VM]>.Keys) -> [K] ) -> Disposable where Element == Dictionary<K, [VM]>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBMapCollectionSection( items: $0, indices: sort( $0.keys ) ), to: collectionView ) } )
    }
    
    func bind<HVM, VM: SBDiffEntity>( to: SBPairDataProvider<HVM, VM>, tableView: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable where Element == Array<(HVM, [VM])>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBPairCollectionSection( items: $0 ), to: tableView, change: change, insert: insert, delete: delete, all: all ) } )
    }
    
    func bind<HVM, VM: SBDiffEntity>( to: SBPairDataProvider<HVM, VM>, collectionView: UICollectionView ) -> Disposable where Element == Array<(HVM, [VM])>
    {
        observe( on: MainScheduler.instance ).subscribe( onNext: { to.Dispatch( newItems: SBPairCollectionSection( items: $0 ), to: collectionView ) } )
    }
}
