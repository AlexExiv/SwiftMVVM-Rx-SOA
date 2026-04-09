//
//  FBindProtocol.swift
//  Speaker Box Lite
//
//  Created by ALEXEY ABDULIN on 06/03/2019.
//  Copyright © 2019 Алексей Абдулин. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import SwiftSOAAPI

public protocol SBBindProtocol
{
    var dispBag: DisposeBag { get }
    var bindScheduler: SchedulerType { get }
}

public extension SBBindProtocol
{
    //MARK: - Bind
    func BindT<O: ObservableType, OR: ObserverType> ( from: O, to: OR, map: @escaping (O.Element) -> OR.Element, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .map { map( $0 ) }
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func Bind<O: ObservableType, OR: ObserverType> ( from: O, to: OR, dispBag: DisposeBag? = nil ) where O.Element == OR.Element
    {
        BindT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func BindT<O: ObservableType, T> ( from: O, to: BehaviorRelay<T>, map: @escaping (O.Element) -> T, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .map { map( $0 ) }
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func BindT<O: ObservableType, T> ( from: O, to: PublishRelay<T>, map: @escaping (O.Element) -> T, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .map { map( $0 ) }
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func Bind<O: ObservableType> ( from: O, to: BehaviorRelay<O.Element>, dispBag: DisposeBag? = nil )
    {
        BindT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func Bind<O: ObservableType> ( from: O, to: PublishRelay<O.Element>, dispBag: DisposeBag? = nil )
    {
        BindT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func BindEquatableT<O: ObservableType, T: Equatable> ( from: O, to: BehaviorRelay<T>, map: @escaping (O.Element) -> T, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .map { map( $0 ) }
            .distinctUntilChanged()
            .bindDistinct( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func BindEquatableT<O: ObservableType, T: Equatable> ( from: O, to: PublishRelay<T>, map: @escaping (O.Element) -> T, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .map { map( $0 ) }
            .distinctUntilChanged()
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func BindEquatable<O: ObservableType> ( from: O, to: BehaviorRelay<O.Element>, dispBag: DisposeBag? = nil ) where O.Element: Equatable
    {
        BindEquatableT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func BindEquatable<O: ObservableType> ( from: O, to: PublishRelay<O.Element>, dispBag: DisposeBag? = nil ) where O.Element: Equatable
    {
        BindEquatableT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    //MARK: - 2WAY
    func BindT2Way<V: Equatable, T: Equatable> ( from: BehaviorRelay<V>, to: BehaviorRelay<T>, mapFrom: @escaping (V) -> T, mapTo: @escaping (T) -> V, dispBag: DisposeBag? = nil )
    {
        from
            .asObservable()
            .observe( on: bindScheduler )
            .distinctUntilChanged()
            .map { mapFrom( $0 ) }
            .bindDistinct( to: to )
            .disposed( by: dispBag ?? self.dispBag )
        
        to
            .asObservable()
            .debounce( .milliseconds( 100 ), scheduler: MainScheduler.asyncInstance )
            .observe( on: bindScheduler )
            //.distinctUntilChanged()
            .skip( 1 )
            .map { mapTo( $0 ) }
            .filter { from.value != $0 }
            .bindDistinct( to: from )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func Bind2Way<V: Equatable> ( from: BehaviorRelay<V>, to: BehaviorRelay<V>, dispBag: DisposeBag? = nil )
    {
        BindT2Way( from: from, to: to, mapFrom: { $0 }, mapTo: { $0 }, dispBag: dispBag )
    }

    //MARK: - Actions
    func BindAction<O: ObservableType> ( from: O, action: @escaping (O.Element) -> Void, dispBag: DisposeBag? = nil )
    {
        from
            .observe( on: bindScheduler )
            .subscribe( onNext: { action( $0 ) } )
            .disposed( by: dispBag ?? self.dispBag )
    }
}
