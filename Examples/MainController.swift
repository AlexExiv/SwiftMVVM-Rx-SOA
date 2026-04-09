//
//  MainController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class MainController: SBBaseTableController<MainViewModel>
{
    @IBOutlet weak var dialogCell: UITableViewCell!
    @IBOutlet weak var loginCell: UITableViewCell!
    
    override func InitRx()
    {
        super.InitRx()
        
        Bind( detail: viewModel.rxDialogResult, to: dialogCell )
        Bind( detail: viewModel.rxUserLogin, to: loginCell )
    }
    
    override func RouteTo( tag: Int, sender: Any? )
    {
        weak var _self = self
        switch tag
        {
        case MainViewModel.MESSAGE_SHOW_DIALOG:
            UIAlertController
                .DialogText( title: "This is a title", message: "I'm a message. Are you agree?", placeholder: "Write you message here", text: "", ok: ABTN_YES, okAction: { _self?.viewModel.rxDialogResult.accept( $0 ) }, cancel: ABTN_NO, cancelAction: { _self?.viewModel.rxDialogResult.accept( "No" ) } )
                .Show( cntrl: self )
            
        default:
            break
        }
        
    }
    
    override func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        switch indexPath.row
        {
        case 0:
            viewModel.ShowDialog()
        case 1:
            performSegue( withIdentifier: "DiffController", sender: nil )
        case 2:
            viewModel.ToggleLogin()
        case 5:
            performSegue( withIdentifier: "ReverseController", sender: nil )
            
        default:
            break
        }
        
    }
}
