//
//  CPViewModel.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 17/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@MainActor
open class SBViewModel: @MainActor SBBindProtocol
{
    public enum Message
    {
        case Close, CloseScenario, Close2Top, Message( title: String, message: String ), Error( error: String ), Custom( tag: Int, userInfo: Any? ), Show( tag: Int, sender: Any? = nil ), Alert( title: String? = nil, message: String, buttons: [String], placeholder: String? = nil, text: String? = nil, result: ((btn: Int, text: String)) -> Void )
    }
    
    public enum AlertButton: Int
    {
        case positive = 0, negative, neutral
    }
    
    private(set) weak var parent: SBViewModel?
    
    public let rxMessages = PublishRelay<Message>()
    public let rxPermanentMessages = PublishRelay<Message>()
    
    public let rxIsLogin = BehaviorRelay( value: false )
    public let rxLoading = BehaviorRelay( value: false )
    public let rxScreenLoading = BehaviorRelay( value: "" )
    
    public let bindScheduler: SchedulerType = MainScheduler.asyncInstance
    public let dispBag = DisposeBag()
    
    public init( parent: SBViewModel? = nil )
    {
        self.parent = parent
    }
    
    open func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        assertionFailure( "There is no such view model \(id)" )
        return SBViewModel( parent: self )
    }
    
    open func RefreshData()
    {
        
    }
    
    //MARK: - SEND MESSAGES
    open func SendClose()
    {
        rxScreenLoading.accept( "" )
        rxPermanentMessages.accept( .Close )
    }
    
    open func SendCloseScenario()
    {
        rxScreenLoading.accept( "" )
        rxPermanentMessages.accept( .CloseScenario )
    }
    
    open func SendClose2Top()
    {
        rxScreenLoading.accept( "" )
        rxPermanentMessages.accept( .Close2Top )
    }
    
    open func SendMessage( title: String = "", message: String = "" )
    {
        rxMessages.accept( .Message( title: title, message: message ) )
    }
    
    open func SendError( error: Error, hidePreloaders: Bool = true )
    {
        SendError( error: (error as NSError).domain, hidePreloaders: hidePreloaders )
    }
    
    open func SendError( error: String, hidePreloaders: Bool = true )
    {
        if hidePreloaders
        {
            rxLoading.accept( false )
            rxScreenLoading.accept( "" )
        }
        
        rxMessages.accept( .Error( error: error ) )
    }
    
    open func RouteTo( tag: Int, sender: Any? = nil )
    {
        rxMessages.accept( .Show( tag: tag, sender: sender ) )
    }
    
    open func SendMessage( tag: Int, userInfo: Any? = nil )
    {
        rxMessages.accept( .Custom( tag: tag, userInfo: userInfo ) )
    }
    
    open func ShowAlert( title: String? = nil, message: String, positive: String, negative: String? = nil, neutral: String? = nil, result: ((SBViewModel.AlertButton) -> Void)? = nil )
    {
        var buttons = [positive]
        if let n = negative
        {
            buttons.append( n )
        }
        if let n = neutral
        {
            buttons.append( n )
        }
        
        rxMessages.accept( .Alert( title: title, message: message, buttons: buttons, result: { result?( SBViewModel.AlertButton( rawValue: $0.btn )! ) } ) )
    }
    
    open func ShowAlertText( title: String? = nil, message: String, positive: String, negative: String, placeholder: String? = nil, text: String? = nil, result: (((btn: SBViewModel.AlertButton, text: String)) -> Void)? = nil )
    {
        let buttons = [positive, negative]

        rxMessages.accept( .Alert( title: title, message: message, buttons: buttons, placeholder: placeholder ?? "", text: text ?? "", result: { result?( (SBViewModel.AlertButton( rawValue: $0.btn )!, $0.text) ) } ) )
    }
    
    
}

@MainActor
public protocol SBTabViewModel
{
    var tabViewModelsMap: [Int: SBViewModel]? { get }
    var tabViewModelsArray: [SBViewModel]? { get }
}

public extension SBTabViewModel
{
    var tabViewModelsMap: [Int: SBViewModel]? { nil }
    var tabViewModelsArray: [SBViewModel]? { nil }
}

@MainActor
public protocol SBPagesViewModel
{
    var pageViewModelsArray: [SBViewModel] { get }
    var rxPageIndex: BehaviorRelay<Int> { get }
    func GetPageVM( i: Int ) -> SBViewModel
}

public extension SBPagesViewModel
{
    func GetPageVM( i: Int ) -> SBViewModel
    {
        preconditionFailure( "GetPageVM was not implemented" )
    }
}
