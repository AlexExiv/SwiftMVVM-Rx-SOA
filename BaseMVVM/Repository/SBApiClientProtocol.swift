//
//  ApiClientProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

public struct JsonWrapper
{
    public let result: Any
    
    /// Returns the map representation of json or empty map if json is not map convartable
    public func asMap() -> [String: Any]
    {
        return (result as? [String: Any]) ?? [String: Any]()
    }
    
    /// Returns the array representation of json or empty array if json is not array convartable
    public func asArray() -> [[String: Any]]
    {
        return (result as? [[String: Any]]) ?? [[String: Any]]()
    }
}

public protocol SBApiPropertiesProvider
{
    func OnProvideProperties() -> [String: String]
}

public protocol SBApiTokenResetListener
{
    func OnTokenReset()
}

public typealias ErrorDispatcher = (URL?, Int, JsonWrapper) -> String
public typealias ErrorExtraDispatcher = (Int, JsonWrapper) -> [String: Any]

public enum HTTPMethod: String
{
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE", deleteBody = "DELETE_BODY", header = "HEADER"
}

public let ERROR_MESSAGE_KEY = "ERROR_MESSAGE_KEY"
public let ERROR_URL_KEY = "ERROR_URL_KEY"

public typealias ClienParams = [String: any Any & Sendable]

public protocol SBApiClientProtocol
{
    var resetTokenCodes: [Int] { get set }
    var errorDispatcher: ErrorDispatcher? { get set }
    var errorExtraDispatcher: ErrorExtraDispatcher? { get set }
    
    func Register( provider: SBApiPropertiesProvider )
    func Register( listener: SBApiTokenResetListener )
    
    func RxJSON( path: String ) -> Single<JsonWrapper>
    func RxJSON( path: String, params: ClienParams? ) -> Single<JsonWrapper>
    func RxJSON( path: String, method: HTTPMethod, params: ClienParams? ) -> Single<JsonWrapper>
    func RxJSON( path: String, method: HTTPMethod, params: ClienParams?, headers: [String: String]? ) -> Single<JsonWrapper>
    
    /// Download the resource from the specified path
    /// - Parameter path: path to the resource can be realtive and absolute.
    func RxDownload( path: String, store: String? ) -> Single<URL?>
    func RxDownload( path: String, store: String?, params: ClienParams? ) -> Single<URL?>
    func RxDownload( path: String, store: String?, params: ClienParams?, headers: [String: String]? ) -> Single<URL?>
    
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String] ) -> Single<JsonWrapper>
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]? ) -> Single<JsonWrapper>
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
}

public struct SBApiClientFactory
{
    
}
