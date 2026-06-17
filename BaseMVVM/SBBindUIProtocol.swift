//
//  CPBindUIProtocol.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

@MainActor
public protocol SBBindUIProtocol: @MainActor SBBindProtocol
{
    associatedtype ViewModel: SBViewModel
    var viewModel: ViewModel! { get }
}

public extension SBBindUIProtocol where Self: UIViewController
{
    //MARK: - FROM DATA TO TITLE
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UILabel )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.text )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UILabel ) where O.Element == String
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> NSAttributedString, to: UILabel )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.attributedText )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UILabel ) where O.Element: NSAttributedString
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UITextView )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.text )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UITextView ) where O.Element == String
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UITextField )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.text )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UITextField ) where O.Element == String
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UIImageView )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .map( { UIImage( named: $0 ) } )
            .observe( on: bindScheduler )
            .bind( to: to.rx.image )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UIImageView ) where O.Element == String
    {
        BindT( from:  from, map: { $0 }, to: to )
    }
    
    func Bind<O: ObservableType>( text: O? = nil, detail: O? = nil, to: UITableViewCell ) where O.Element == String
    {
        if let text = text, let textLabel = to.textLabel
        {
            text
                .distinctUntilChanged()
                .observe( on: bindScheduler )
                .bind( to: textLabel.rx.text )
                .disposed( by: dispBag )
        }
        
        if let detail = detail, let detailLabel = to.detailTextLabel
        {
            detail
                .distinctUntilChanged()
                .observe( on: bindScheduler )
                .bind( to: detailLabel.rx.text )
                .disposed( by: dispBag )
        }
    }
    
    //MARK: - UINavigationItem
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UINavigationItem )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.title )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UINavigationItem ) where O.Element == String
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    //MARK: - UIButton
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, to: UIButton )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.title( for: .normal ) )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, to: UIButton ) where O.Element == String
    {
        BindT( from: from, map: { $0 }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> String, toIcon: UIButton, renderingMode: UIImage.RenderingMode = .alwaysOriginal )
    {
        from.asObservable()
            .map { map( $0 ) }
            .distinctUntilChanged()
            .map { UIImage( named: $0 )?.withRenderingMode( renderingMode ) }
            .observe( on: bindScheduler )
            .bind( to: toIcon.rx.image( for: .normal ) )
            .disposed( by: dispBag )
    }
    
    //MARK: - FROM DATA TO COLOR
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> UIColor, toBG: UIView )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( onNext: { toBG.backgroundColor = $0 } )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, toBG: UIView ) where O.Element: UIColor
    {
        BindT( from: from, map: { $0 }, toBG: toBG )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> UIColor, toTC: UIView )
    {
        let driver = from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
        
        var disp: Disposable? = nil
        
        if let label = toTC as? UILabel
        {
            disp = driver.bind( onNext: { label.textColor = $0 } )
        }
        else if let textView = toTC as? UITextView
        {
            disp = driver.bind( onNext: { textView.textColor = $0 } )
        }
        else if let textField = toTC as? UITextField
        {
            disp = driver.bind( onNext: { textField.textColor = $0 } )
        }
        
        disp?.disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, toTC: UIView ) where O.Element: UIColor
    {
        BindT( from: from, map: { $0 }, toTC: toTC )
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> CGFloat, toAlpha: UIView )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( toAlpha.rx.alpha )
            .disposed( by: dispBag )
    }
    
    //MARK: - HIDDEN
    func BindHidden<O: ObservableType>( from: O, map: @escaping (O.Element) -> Bool, to: UIView, duration: TimeInterval = 0 )
    {
//        if duration == 0.0
//        {
//            from
//                .asDriver()
//                .map( { map( $0 ) } )
//                .drive( to.rx.isHidden )
//                .disposed( by: dispBag )
//        }
//        else
//        {
            from
                .map { map( $0 ) }
                .distinctUntilChanged()
                .observe( on: bindScheduler )
                .bind( onNext:
                {
                    hidden in
                    
                    if !hidden
                    {
                        to.isHidden = false
                    }
                    
                    UIView.animate( withDuration: duration, animations: { to.alpha = hidden ? 0.0 : 1.0 }, completion: { (b) in to.isHidden = hidden })
                })
                .disposed( by: dispBag )
//        }
    }
    
    func BindHidden<O: ObservableType>( from: O, invert: Bool = false, to: UIView, duration: TimeInterval = 0 ) where O.Element == Bool
    {
        return BindHidden( from: from, map: { $0 != invert }, to: to, duration: duration )
    }
    
    //MARK: - ENABLE
    func BindEnabled<O: ObservableType>( from: O, map: @escaping (O.Element) -> Bool, to: UIControl )
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.isEnabled )
            .disposed( by: dispBag )
    }
    
    func BindEnabled<O: ObservableType>( from: O, invert: Bool = false, to: UIControl ) where O.Element == Bool
    {
        BindEnabled( from: from, map: { $0 != invert }, to: to )
    }
    
    func BindT<O: ObservableType>( from: O, map: @escaping (O.Element) -> Bool, to: UISwitch ) where O.Element == Bool
    {
        from
            .map { map( $0 ) }
            .distinctUntilChanged()
            .observe( on: bindScheduler )
            .bind( to: to.rx.isOn )
            .disposed( by: dispBag )
    }
    
    func Bind<O: ObservableType>( from: O, invert: Bool = false, to: UISwitch ) where O.Element == Bool
    {
        BindT( from: from, map: { $0 != invert }, to: to )
    }
    
    //MARK: - 2WAY
    func Bind2Way( from: BehaviorRelay<String>, to: UITextField )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.text )
            .disposed( by: dispBag )
        
        to.rx.text
            .asDriver()
            .map( { $0! } )
            .filter( { from.value != $0 } )
            //.distinctUntilChanged()
            .drive( from )
            .disposed( by: dispBag )
    }
    
    func Bind2Way( from: BehaviorRelay<String>, to: UITextView )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.text )
            .disposed( by: dispBag )
        
        to.rx.text
            .asDriver()
            .map( { $0! } )
            .filter( { from.value != $0 } )
            //.distinctUntilChanged()
            .drive( from )
            .disposed( by: dispBag )
    }
    
    func Bind2Way( from: BehaviorRelay<Bool>, to: UISwitch )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.isOn )
            .disposed( by: dispBag )
        
        to.rx.isOn
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            //.distinctUntilChanged()
            .skip( 1 )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag )
    }
    
    func Bind2Way( from: BehaviorRelay<Int>, to: UISegmentedControl )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.selectedSegmentIndex )
            .disposed( by: dispBag )
        
        to.rx.selectedSegmentIndex
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            //.distinctUntilChanged()
            .skip( 1 )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag )
    }
    
    func Bind2WayEnumInt<T: RawRepresentable>( from: BehaviorRelay<T>, to: UISegmentedControl ) where T.RawValue == Int
    {
        from
            .asDriver()
            .map( { $0.rawValue } )
            .distinctUntilChanged()
            .drive( to.rx.selectedSegmentIndex )
            .disposed( by: dispBag )
        
        to.rx.selectedSegmentIndex
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            .skip( 1 )
            .map( { T( rawValue: $0 )! } )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag )
    }
    
    func Bind2Way<T: BinaryFloatingPoint>( from: BehaviorRelay<T>, to: UISlider )
    {
        from
            .asDriver()
            .map( { Float( $0 ) } )
            .distinctUntilChanged()
            .drive( to.rx.value )
            .disposed( by: dispBag )
        
        to.rx.value
            .asDriver()
            //.delay( 0.2 )
            .skip( 1 )
            .map( { T( $0 ) } )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag )
    }
    
    //MARK: - ACTIONS
    func BindClickAction( control: UIControl, action: @escaping (() -> Void) )
    {
        control.rx
            .controlEvent( .touchUpInside )
            .subscribe( onNext: { _ in action() } )
            .disposed( by: dispBag )
    }
}
