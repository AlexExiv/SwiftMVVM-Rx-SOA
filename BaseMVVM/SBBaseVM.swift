//
//  CPBaseVM.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 19/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

@MainActor
open class SBBaseVM
{
    public private(set) weak var parent: SBViewModel?
    
    public init( parent: SBViewModel? = nil )
    {
        self.parent = parent
    }
    
    open func IsEqual( vm: SBBaseVM ) -> Bool
    {
        return false
    }
    
    open func IsContentSame( vm: SBBaseVM ) -> Bool
    {
        return false
    }

    static public func == ( l: SBBaseVM, r: SBBaseVM ) -> Bool
    {
        return l.IsEqual( vm: r )
    }
    
    static public func ~= ( l: SBBaseVM, r: SBBaseVM ) -> Bool
    {
        return l.IsContentSame( vm: r )
    }
}
