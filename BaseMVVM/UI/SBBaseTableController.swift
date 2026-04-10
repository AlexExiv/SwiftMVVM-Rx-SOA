//
//  CPBaseTableController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

@MainActor
open class SBBaseTableController<VM: SBViewModel>: UITableViewController, SBMVVMHolderProtocol, SBMVVMHolderUIBase
{
    public var preloaderView: SBPreloaderView!
    public var screenPreloaderCntrl: SBPreloaderControllerProtocol!
    
    public let dispBag = DisposeBag()
    open var bindScheduler: SchedulerType = MainScheduler.asyncInstance
    
    private(set) public var viewModel: VM! = nil
    private(set) public var isInitRx = false
    private var messagesDisp: Disposable? = nil
    
    var cellHeights = [Int: CGFloat]()
    private var _tableView: UITableView? = nil
    private(set) var table2bottom = false
    private var footerView: UIView? = nil
    private var footerHeight: CGFloat = 0.0
    private var headerView: UIView? = nil
    private var headerHeight: CGFloat = 0.0
    
    override open var tableView: UITableView!
    {
        get
        {
            return _tableView == nil ? super.tableView : _tableView!
        }
        set
        {
            super.tableView = newValue
        }
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        isInitRx = isInitRx || InvokeInitRx( b: viewModel != nil )
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
    
    //MARK: - MVVM
    open func InitRx()
    {
        InvokeInitPermanentMessages().disposed( by: dispBag )
        BindLoading( table: tableView )
        BindScreenLoading()
    }
    
    public func BindVM( vm: SBViewModel )
    {
        viewModel = (vm as! VM)
        isInitRx = isInitRx || InvokeInitRx( b: isViewLoaded )
    }

    open func BindRefreshTable()
    {
        tableView.refreshControl = UIRefreshControl()
        BindRefreshTable( refresh: tableView.refreshControl! )
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
    
    //MARK: - EXCHANGE VIEWS
    func ExchangeTableView()
    {
        if _tableView == nil
        {
            _tableView = tableView
            _tableView?.removeFromSuperview()
            
            view = UIView()
            view.backgroundColor = UIColor.white
            view.addSubview( _tableView! )
            
            DidExchangedTableView()
        }
    }
    
    open func DidExchangedTableView()
    {
        
    }
    
    func UpdateConstaints()
    {
        guard let _tableView = _tableView else
        {
            return
        }
        
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[_tableView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["_tableView": _tableView] ) )
        
        if (footerView == nil) && (headerView == nil)
        {
            view.addConstraint( NSLayoutConstraint( item: _tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0 ) )
            view.addConstraint( NSLayoutConstraint( item: _tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0 ) )
        }
        else if let footerView = footerView
        {
            footerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview( footerView )
            view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|-(0)-[footerView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["footerView": footerView] ) )
            
            if table2bottom
            {
                if let headerView = headerView
                {
                    view.addSubview( headerView )
                    view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[headerView(\(headerHeight))]-(0)-[_tableView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["_tableView": _tableView, "headerView": headerView] ) )
                }
                else
                {
                    view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[_tableView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["_tableView": _tableView] ) )
                }
                
                view.addConstraint( NSLayoutConstraint( item: footerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: footerHeight ) )
            }
            else
            {
                if let headerView = headerView
                {
                    view.addSubview( headerView )
                    view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[headerView(\(headerHeight))]-(0)-[_tableView]-(0)-[footerView(\(footerHeight))]", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["headerView": headerView, "footerView": footerView, "_tableView": _tableView] ) )
                }
                else
                {
                    view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[_tableView]-(0)-[footerView(\(footerHeight))]", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["footerView": footerView, "_tableView": _tableView] ) )
                }
            }
            
            footerView.bottomAnchor.constraint( equalTo: BottomGuide ).isActive = true
        }
        else if let headerView = headerView
        {
            view.addSubview( headerView )
            view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:[headerView(\(headerHeight))]-(0)-[_tableView]", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["headerView": headerView, "_tableView": _tableView] ) )
            view.addConstraint( NSLayoutConstraint( item: _tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0 ) )
        }
        
        if let headerView = headerView
        {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint( NSLayoutConstraint( item: headerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 0.0 ) )
            view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|-(0)-[headerView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["headerView": headerView] ) )
        }
    }
    
    public func Add( footer: UIView, height: CGFloat, table2bottom: Bool = false )
    {
        footerView = footer
        footerHeight = height
        self.table2bottom = table2bottom
        ExchangeTableView()
        UpdateConstaints()
        updateViewConstraints()
    }
    
    public func Add( header: UIView, height: CGFloat )
    {
        headerView = header
        headerHeight = height
        ExchangeTableView()
        UpdateConstaints()
        updateViewConstraints()
    }
    
    //MARK - UITableViewDelegate
    override open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeights[indexPath.section*10000 + indexPath.row] ?? UITableView.automaticDimension
    }

    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cellHeights[indexPath.section*10000 + indexPath.row] = cell.bounds.size.height
    }
    
    //MARK: - SEGUE
    override open func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue, sender: sender )
    }
}
