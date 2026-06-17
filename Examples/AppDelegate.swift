//
//  AppDelegate.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var commonComps = CommonComponents( initial: true )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let cntrl = UIStoryboard( name: "Main", bundle: nil ).instantiateInitialViewController() as! SBNavigationController
        cntrl.BindVM( vm: MainViewModel() )
        
        window = UIWindow()
        window?.rootViewController = cntrl//UIStoryboard( name: "CloseTop", bundle: nil ).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

