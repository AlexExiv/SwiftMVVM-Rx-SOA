//
//  SBImageDowloadServiceProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

public protocol SBImageDowloadServiceProtocol
{
    func RxDownload( url: String ) -> Single<String>
    func RxDownload( url: String, width: Int, height: Int ) -> Single<String>
}
