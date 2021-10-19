//
//  PagesMainViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay
import BaseMVVM

class PagesMainViewModel: ViewModel
{
    let pagesVM = PagesViewModel()
    let rxResetTitle = BehaviorRelay( value: "" )
    
    override init()
    {
        super.init()
        
        pagesVM.BindT( from: pagesVM.rxPageIndex, to: rxResetTitle, map: { "Page \($0)" } )
    }
    
    override func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        switch id
        {
        case "PagesController":
            return pagesVM
        default:
            return super.GetChildVM( id: id )
        }
    }
    
    func Reset()
    {
        pagesVM.rxPageIndex.accept( 0 )
    }
}