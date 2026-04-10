//
//  CPPreloaderController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

@MainActor
public protocol SBPreloaderControllerProtocol
{
    func Show( title: String )
    func Hide()
}

@MainActor
open class SBPreloaderController: UIViewController, SBPreloaderControllerProtocol
{
    private static var resourceBundle: Bundle
    {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle( for: Self.self )
#endif
    }
    
    static func Create() -> SBPreloaderController
    {
        return UIStoryboard( name: "Preloader", bundle: resourceBundle ).instantiateViewController( withIdentifier: "SBPreloaderController" ) as! SBPreloaderController;
    }
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    //MARK: - Actions
    open func Show( title: String = "" )
    {
        if let rWnd = UIApplication.shared.keyWindow
        {
            view.frame = rWnd.bounds;
            rWnd.addSubview( view );
            
            titleLab?.text = title;
            activity?.startAnimating();
        }
    }
    
    open func Hide()
    {
        view.removeFromSuperview();
    }
}
