//
//  SBAlamofireApiClient.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public extension SBApiClientFactory
{
    static func CreateAlamofire( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default ) -> SBApiClientProtocol
    {
        return SBAlamofireApiClient( baseURL: baseURL, defaultEncoding: defaultEncoding )
    }
}

class SBAlamofireApiClient: SBApiClientProtocol
{
    var tokenHeader: String = "Authorization"
    var deviceHeader: String = "X-Device-ID"
    var languageHeader: String = "X-User-Language"
    
    var errorDispatcher: ErrorDispatcher? = nil
    var userInfoProvider: SBApiUserInfoProvider? = nil
    var deviceInfoProvider: SBApiDeviceInfoProvider? = nil
    
    let baseURL: String
    let defaultEncoding: ParameterEncoding
    
    init( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default )
    {
        self.baseURL = baseURL
        self.defaultEncoding = defaultEncoding
    }
    
    func RegisterProvider( user: SBApiUserInfoProvider )
    {
        userInfoProvider = user
    }
    
    func RegisterProvider( device: SBApiDeviceInfoProvider )
    {
        deviceInfoProvider = device
    }
    
    
    //MARK: - JSON REQUESTS
    func RxJSON( path: String ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: .get, params: nil )
    }
    
    func RxJSON( path: String, params: [String: Any]? ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: .get, params: params, headers: nil )
    }
    
    func RxJSON( path: String, method: HTTPMethod, params: [String: Any]? ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: method, params: params, headers: nil )
    }
    
    func RxJSON( path: String, method: HTTPMethod, params: [String : Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
    {
        let _method = method == .deleteBody ? .delete : Alamofire.HTTPMethod( rawValue: method.rawValue )!
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            if let self_ = self
            {
                var rFullHeaders = HTTPHeaders();
                
                if let provider = self_.userInfoProvider
                {
                    rFullHeaders[self_.tokenHeader] = provider.token
                }

                if let provider = self_.deviceInfoProvider
                {
                    rFullHeaders[self_.deviceHeader] = provider.deviceId
                    rFullHeaders[self_.languageHeader] = provider.interfaceLanguage
                }
                
                if let headers = headers
                {
                    rFullHeaders.Merge( src: headers );
                }
                
                let sURL = "\(self_.baseURL)/\(path)";
                #if DEBUG
                var _debugMess = "\n\nBEGIN REQUEST \nMETHOD: \(method.rawValue) \nURL: \(sURL)"
                if let params = params
                {
                    _debugMess += "\nPARAMETERS: \(params)"
                }
                if !rFullHeaders.isEmpty
                {
                    _debugMess += "\nHEADERS: \(rFullHeaders)"
                }
                _debugMess += "\n\n"
                print( _debugMess )
                #endif
                let encoding = (method == .get || method == .delete) ? URLEncoding.default : self_.defaultEncoding
                let rReq = Alamofire.request( sURL, method: _method, parameters: params, encoding: encoding, headers: rFullHeaders )
                    .responseJSON( completionHandler:
                        {
                            (response) in
                            
                            #if DEBUG
                            var _debugMess = "\n\nEND REQUEST \nMETHOD: \(method.rawValue) \nURL: \(sURL) \nRESPONSE CODE: \(response.response?.statusCode ?? 0)"
                            if let r = response.result.value
                            {
                                _debugMess += "\nRESPONSE BODY: \(r)"
                            }
                            _debugMess += "\n\n"
                            print( _debugMess )
                            #endif
                            if 200..<400 ~= (response.response?.statusCode ?? 0) && response.result.isSuccess
                            {
                                subs( .success( JsonWrapper( result: response.result.value! ) ) );
                            }
                            else
                            {
                                if let code = response.response?.statusCode, (code == 401 || code == 403)
                                {
                                    self_.userInfoProvider?.ResetLogin()
                                }
                                
                                subs( .error( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: response.result.value ) ) );
                            }
                    });
                
                return Disposables.create
                {
                    rReq.cancel();
                }
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - DOWNLOAD REQUESTS
    func RxDownload( path: String, store: String? ) -> Single<URL?>
    {
        return RxDownload( path: path, store: store, params: nil )
    }
    
    func RxDownload( path: String, store: String?, params: [String: Any]? ) -> Single<URL?>
    {
        return RxDownload( path: path, store: store, params: params, headers: nil )
    }
    
    func RxDownload( path: String, store: String?, params: [String: Any]?, headers: [String: String]? ) -> Single<URL?>
    {
        if path.isEmpty
        {
            return Single.just( nil );
        }

        var docPath = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last!
        if let s = store
        {
            docPath.appendPathComponent( s )
        }
        docPath.appendPathComponent( path.urlPath )
        docPath.appendPathComponent( path.lastURLComponent )
        
        if FileManager.default.fileExists( atPath: docPath.path )
        {
            return Single.just( docPath );
        }
        
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            
            if let self_ = self
            {
                print( "DOWNLOAD URL - \(path)" );
                let downloadReq = Alamofire.download( path.starts( with: "http://" ) || path.starts( with: "https://" ) ? path : "\(self_.baseURL)/\(path)", method: .get, parameters: params, headers: headers )
                {
                    (_, _)  in
                    return ( destinationURL: docPath, options: [.removePreviousFile, .createIntermediateDirectories] )
                }
                .responseData( completionHandler:
                {
                    ( response ) in
                    
                    var delFile = false;
                    if let error = response.error
                    {
                        delFile = true;
                        subs( .error( error as NSError ) );
                    }
                    else if 200..<400 ~= response.response!.statusCode
                    {
                        subs( .success( docPath ) );
                    }
                    else
                    {
                        delFile = true;
                        do
                        {
                            let rJSON = try JSONSerialization.jsonObject( with: response.result.value!, options: JSONSerialization.ReadingOptions( rawValue: 0 ) );
                            subs( .error( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: rJSON ) ) )
                        }
                        catch
                        {
                            
                        }
                    }
                    
                    if delFile
                    {
                        do
                        {
                            try FileManager.default.removeItem( atPath: docPath.path )
                        }
                        catch
                        {
                            
                        }
                    }
                });
                
                return Disposables.create
                {
                    if let _ = downloadReq.task
                    {
                        downloadReq.cancel();
                    }
                }
            }
            else
            {
                subs( .error( NSError( domain: "", code: 0, userInfo: nil ) ) );
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - UPLOAD REQUESTS
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String] ) -> Single<JsonWrapper>
    {
        return RxUpload( path: path, method: method, datas: datas, names: names, fileNames: fileNames, mimeTypes: mimeTypes, params: nil, headers: nil )
    }
    
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]? ) -> Single<JsonWrapper>
    {
        return RxUpload( path: path, method: method, datas: datas, names: names, fileNames: fileNames, mimeTypes: mimeTypes, params: params, headers: nil )
    }
    
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
    {
        let _method = Alamofire.HTTPMethod( rawValue: method.rawValue )!
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            if let self_ = self
            {
                var rFullHeaders = HTTPHeaders();
                
                if let provider = self_.userInfoProvider
                {
                    rFullHeaders[self_.tokenHeader] = provider.token
                    print( "X-Access-Token: \(provider.token)" )
                }

                if let provider = self_.deviceInfoProvider
                {
                    rFullHeaders[self_.deviceHeader] = provider.deviceId
                    print( "X-Device-ID: \(provider.deviceId)" )
                    
                    rFullHeaders[self_.deviceHeader] = provider.interfaceLanguage
                    print( "X-User-Language: \(provider.interfaceLanguage)" )
                }
                
                if let headers = headers
                {
                    rFullHeaders.Merge( src: headers );
                }
                
                let sURL = "\(self_.baseURL)/\(path)";
                #if DEBUG
                print( "REQUEST URL - \(sURL)" );
                print( "METHOD - \(method.rawValue)" );
                print( "PARAMETERS - \(params)" );
                #endif
                
                let multipartFormData: (MultipartFormData) -> Void =
                {
                    mfd in
                    params?.forEach
                    {
                        if let v = $0.value as? String
                        {
                            mfd.append( v.data( using: .utf8 )!, withName: $0.key )
                        }
                        else if let v = $0.value as? Int
                        {
                            mfd.append( String( v ).data( using: .utf8 )!, withName: $0.key )
                        }
                        else if let v = $0.value as? Double
                        {
                            mfd.append( String( v ).data( using: .utf8 )!, withName: $0.key )
                        }
                    }
                    
                    for i in 0..<datas.count
                    {
                        mfd.append( datas[i], withName: names[i], fileName: fileNames[i], mimeType: mimeTypes[i] )
                    }
                }
                
                let urlReq = try! URLRequest( url: sURL, method: _method, headers: rFullHeaders )
                Alamofire.upload( multipartFormData: multipartFormData, with: urlReq, encodingCompletion:
                {
                    result in
                    switch result
                    {
                    case .success( let upload, _, _ ):
                        upload.responseJSON
                        {
                            (response: DataResponse) in
                            #if DEBUG
                            print( "RESPONSE - \(response.result.value)" );
                            #endif
                            let iCode = response.response?.statusCode ?? 0;
                            if 200..<400 ~= iCode
                            {
                                subs( .success( JsonWrapper( result: response.result.value! )  ) );
                            }
                            else
                            {
                                if let code = response.response?.statusCode, (code == 401 || code == 403)
                                {
                                    self_.userInfoProvider?.ResetLogin()
                                }
                                
                                subs( .error( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: response.result.value ) ) );
                            }
                        }
                    case .failure( let error ):
                        break
                    }
                })
               
                return Disposables.create()
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - COMMON
    func ParseError( error: Error?, status: Int, json: Any? ) -> NSError
    {
        var message = "";
        var errStatus = 0;
        
        if let error = error
        {
            errStatus = error._code;
            switch errStatus
            {
            case -1009:
                message = "Нет интернет соединения. Попробуйте позже."
                
            case -1001:
                message = "Истекло время ожидания. Попробуйте позже."
                
            default:
                message = error.localizedDescription;
            }
        }
        else if status >= 400
        {
            errStatus = status
            if let dispatcher = errorDispatcher, let json = json
            {
                message = dispatcher( status, JsonWrapper( result: json ) )
            }
            else
            {
                message = "Неизвестная ошибка";
            }
        }
        else
        {
            message = "Неизвестная ошибка";
        }
        
        return NSError( domain: message, code: errStatus, userInfo: [ERROR_MESSAGE_KEY : message] );
    }
}
