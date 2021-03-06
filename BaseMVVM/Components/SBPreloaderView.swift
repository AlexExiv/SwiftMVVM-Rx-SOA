//
//  CPPreloaderView.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

open class SBPreloaderView: UIView
{
    public private(set) var indicator: UIActivityIndicatorView? = nil;
    
    public var animating: Bool
    {
        set
        {
            newValue ? indicator?.startAnimating() : indicator?.stopAnimating();
        }
        get
        {
            return indicator?.isAnimating ?? false;
        }
    }
    
    public init( withStyle: UIActivityIndicatorView.Style )
    {
        super.init( frame: CGRect( x: 0.0, y: 0.0, width: 50.0, height: 50.0 ) );
        
        indicator = UIActivityIndicatorView( style: withStyle );
        indicator?.startAnimating();
        
        addSubview( indicator! );
    }
    
    public required init?( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder );
    }
    
    override public init( frame: CGRect )
    {
        super.init( frame: frame )
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews();
        indicator?.center = CGPoint( x: self.bounds.size.width/2.0, y: self.bounds.size.height/2.0 );
    }
}
