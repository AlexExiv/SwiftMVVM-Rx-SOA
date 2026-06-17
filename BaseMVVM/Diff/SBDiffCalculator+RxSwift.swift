//
//  SBDiffCalculator+RxSwift.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

@MainActor
public extension SBDiffCalculator
{
    static func RxCalc( oldItems: SBDiffEntitySection, newItems: SBDiffEntitySection ) -> Single<SBDiffCalculator>
    {
        return Single.create {
            sub in
            let calc = SBDiffCalculator( oldItems: oldItems, newItems: newItems )
            //calc.AsyncCalc { sub( .success( $0 ) ) }
            calc.Calc()
            sub( .success( calc ) )
            return Disposables.create()
        }
    }
    
    static func RxCalc( oldItems: [[SBDiffEntity]], newItems: [[SBDiffEntity]] ) -> Single<SBDiffCalculator>
    {
        return RxCalc( oldItems: SBDefaultSection( items: oldItems ), newItems: SBDefaultSection( items: newItems ) )
    }
    
    static func RxCalc( oldItems: [SBDiffEntity], newItems: [SBDiffEntity] ) -> Single<SBDiffCalculator>
    {
        return RxCalc( oldItems: [oldItems], newItems: [newItems] )
    }
}

@MainActor
public extension Single where Element == SBDiffCalculator
{
    func bind( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable
    {
        return asObservable().bind( to: to, change: change, insert: insert, delete: delete, all: all )
    }
    
    func bind( to: UICollectionView ) -> Disposable
    {
        return asObservable().bind( to: to )
    }
}

@MainActor
public extension ObservableType where Element == SBDiffCalculator
{
    func bind( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable
    {
        return subscribe( onNext: { $0.Dispatch( to: to, change: change, insert: insert, delete: delete, all: all ) } )
    }
    
    func bind( to: UICollectionView ) -> Disposable
    {
        return subscribe( onNext: { $0.Dispatch( to: to ) } )
    }
}

@MainActor
public extension SBDiffCalculator
{
    static func BindUpdates<O: ObservableType, E: SBDiffEntity>( from: O, table: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil, scheduler: SchedulerType, dispBag: DisposeBag ) where O.Element == Array<E>
    {
        from
            .take( 1 )
            .observeOn( MainScheduler.instance )
            .subscribe( onNext: { _ in table.reloadData() } )
            .disposed( by: dispBag )
        
        Observable
            .zip( from, from.skip( 1 ) )
            .observeOn( MainScheduler.instance )
            .concatMap { SBDiffCalculator.RxCalc( oldItems: $0.0, newItems: $0.1 ) }
            .bind( to: table, change: change, insert: insert, delete: delete, all: all )
            .disposed( by: dispBag )
    }
    
    static func BindUpdates<O: ObservableType, E: SBDiffEntity>( from: O, collection: UICollectionView, scheduler: SchedulerType, dispBag: DisposeBag ) where O.Element == Array<E>
    {
        from
            .take( 1 )
            .observeOn( MainScheduler.instance )
            .subscribe( onNext: { _ in collection.reloadData() } )
            .disposed( by: dispBag )
        
        Observable
            .zip( from, from.skip( 1 ) )
            .concatMap { SBDiffCalculator.RxCalc( oldItems: $0.0, newItems: $0.1 ) }
            .observeOn( MainScheduler.instance )
            .bind( to: collection )
            .disposed( by: dispBag )
    }
}
