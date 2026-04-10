//
//  SBBaseTabBarController.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/11/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

@MainActor
open class SBBaseTabBarController<VM: SBViewModel & SBTabViewModel>: UITabBarController, SBMVVMHolderProtocol, SBMVVMHolderUIBase
{
    public var preloaderView: SBPreloaderView!
    public var screenPreloaderCntrl: SBPreloaderControllerProtocol!
    
    public let dispBag = DisposeBag()
    open var bindScheduler: SchedulerType = MainScheduler.asyncInstance
    
    private(set) public var viewModel: VM! = nil
    private(set) public var isInitRx = false
    private var messagesDisp: Disposable? = nil
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        isInitRx = isInitRx || InvokeInitRx( b: viewModel != nil )
        BindTabViewModels()
    }
    
    override open func viewWillAppear( _ animated: Bool )
    {
        super.viewWillAppear( animated )
        messagesDisp = InvokeInitMessages()
    }
    
    override open func viewWillDisappear( _ animated: Bool )
    {
        super.viewWillDisappear(animated)
        messagesDisp?.dispose()
    }
    
    open override func setViewControllers( _ viewControllers: [UIViewController]?, animated: Bool )
    {
        super.setViewControllers( viewControllers, animated: animated )
        BindTabViewModels()
    }
    
    //MARK: - MVVM
    open func InitRx()
    {
        InvokeInitPermanentMessages().disposed( by: dispBag )
        BindScreenLoading()
    }
    
    public func BindVM( vm: SBViewModel )
    {
        viewModel = (vm as! VM)
        isInitRx = isInitRx || InvokeInitRx( b: isViewLoaded )
    }
    
    public func BindTabVM( i: Int, id: String )
    {
        (viewControllers?[i] as? SBMVVMHolderProtocol)?.BindVM( vm: viewModel.GetChildVM( id: id ) )
    }
    
    public func BindTabVM( vms: [SBViewModel] )
    {
        if let vcs = viewControllers
        {
            precondition( vms.count == vcs.count, "The number of tabs view models is not equals to the number of view controllers" )
            vcs.enumerated().forEach { ($0.element as? SBMVVMHolderProtocol)?.BindVM( vm: vms[$0.offset] ) }
        }
    }
    
    public func BindTabVM( vms: [Int: SBViewModel] )
    {
        viewControllers?.forEach { ($0 as? SBMVVMHolderProtocol)?.BindVM( vm: vms[$0.tabBarItem.tag]! ) }
    }
    
    open func DispatchMessage( message: SBViewModel.Message )
    {
        _DispatchMessage( message: message )
    }
    
    open func RouteTo( tag: Int, sender: Any? )
    {
        
    }
    
    open func CreatePreloaderView()
    {
        preloaderView = SBPreloaderView( withStyle: .gray )
    }
    
    open func CreateScreenPreloaderCntrl()
    {
        screenPreloaderCntrl = SBPreloaderController.Create()
    }
    
    func BindTabViewModels()
    {
        if let tm = viewModel.tabViewModelsMap
        {
            BindTabVM( vms: tm )
        }
        else if let ta = viewModel.tabViewModelsArray
        {
            BindTabVM( vms: ta )
        }
        else
        {
            preconditionFailure( "The view model \(viewModel.debugDescription) is not implementing children view models" )
        }
    }
    
    //MARK: - SEGUE
    override open func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue, sender: sender )
    }
}
