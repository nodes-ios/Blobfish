//
//  NSURLResponse+ErrorRepresentable.swift
//  Blobfish
//
//  Created by Kasper Welner on 28/02/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Alamofire

private enum ErrorCode: Int {
    case zero                   = 0
    case noConnection           = 4096
    case notConnectedToInternet = -1009
    case networkConnectionLost  = -1005
    case parsingFailed          = 2048
    case clientTimeOut          = -1001
    case badRequest             = 400
    case unauthorized           = 401
    case forbidden              = 403
    case notFound               = 404
    case preconditionFailed     = 412
    case tooManyRequests        = 429
    case noAcceptHeader         = 440
    case noToken                = 441
    case invalidToken           = 442
    case expiredToken           = 443
    case invalid3rdPartyToken   = 444
    case entityNotFound         = 445
    case blockedUser            = 447
    case internalServerError    = 500
    case notImplemented         = 501
    case badGateway             = 502
    case serviceUnavailable     = 503
    case gatewayTimeout         = 504
    case unknownError           = -1
}

//This abomination exists because you cannot extend a generic class with static variables yet
extension Blobfish {
    
    public struct AlamofireConfig {
        
        /**
         Gets the message and titles useful for showing in connection error alert view.
         
         - returns: A tuple containing message text and alert style. For .Alert style, please pass along text string for 'OK' and optionally 'Retry'. If retry string is nil, alert will only show OK button.
         */
        
        
        public static var blobForConnectionError:(_ code:Int) -> Blob? = { code in
            print("Warning! Please assign values to all 'messageFor***' static properties on AlamofireBlobfishConfiguration.. Using default values...")
            var title = "_Something went wrong. Please check your connection and try again"
            
            return Blob(title:title, style: .overlay)
        }
        
        /**
         Gets the message and titles for showing unkown error alert view.
         
         - returns: A tuple containing message text and ok text.
         */
        
        
        public static var blobForUnknownError:(_ code:Int, _ localizedStringForCode:String) -> Blob? = { (code, localizedStringForCode) in
            print("Warning! Please assign values to all 'messageFor***' static properties on AlamofireBlobfishConfiguration.. Using default values...")
            let title = "_An error occured"
            let action = Blob.AlertAction(title: "OK", handler: nil)
            return Blob(title: title, style: .alert(message:"(\(code) " + localizedStringForCode + ")", actions: [action]))
        }
        
        /**
         Gets the message and titles for showing token expired/missing error alert view.
         
         - returns: A tuple containing message text and ok text.
         */
        
        
        public static var blobForTokenExpired:() -> Blob? = {
            var title = "_You session has expired. Please log in again"
            fatalError("errorForTokenExpired is not set on AlamofireBlobfishConfiguration")
        }
        
        /**
         This is used if the API you're consuming has set up global error codes.
         
         **Example:** You api returns *441* whenever you try to make a call with an expired token.
         You want to tell the user and log him out, so you return [441 : ErrorCategory.Token].
         
         Both HTTP response codes and NSError codes can be specified.
         
         - note: Error codes unique for specific endpoints should be handled BEFORE passing
         the response to Blobfish.
         
         - returns: A dictionary whose keys are error codes and values are ErrorCategories.
         */
        
        public static var customStatusCodeMapping:() -> [Int : ErrorCategory] = {
            return [:]
        }
        
        public enum ErrorCategory {
            case connection
            case token
            case unknown
            case none
        }
    }
}

extension Alamofire.Response: Blobable {
    
    /**
     This Blobfish extension allows you to pass a Response object to Blobfish. 
     It splits the response up in 4 different types:
     
     - *Connection* - shown as overlay
     - *Unknown* - shown as Alert.
     - *Token invalid/expired* - shown as alert.
     - *None* - show nothing
     
     Please add the appropriate strings and actions to the AlamofireResponseConfiguration object.
     */
    
    public var blob:Blob? {
        
        guard case let .failure(resultError) = result else { return nil }
        
        let errorCode   = (resultError as NSError).code
        let statusCode  = response?.statusCode ?? errorCode
        
        switch (self.errorCategory) {
           
        case .none:
            return nil
            
        case .token:
            return Blobfish.AlamofireConfig.blobForTokenExpired()
            
        case .connection:
            return Blobfish.AlamofireConfig.blobForConnectionError(statusCode )
            
        default:
            var localizedMessageForStatusCode:String = ""
            localizedMessageForStatusCode = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            
            return Blobfish.AlamofireConfig.blobForUnknownError(statusCode , localizedMessageForStatusCode)
        }
    }
    
    /**
     A overall classification of the response (and error), assigning it to an *ErrorCategory* case.
     
     - returns: The type of error
     */
    
    public var errorCategory:Blobfish.AlamofireConfig.ErrorCategory {
        
        guard case let .failure(resultError) = result else { return .none }
        
        let errorCode   = (resultError as NSError).code
        let statusCode  = response?.statusCode ?? errorCode
        
        if let customMapping = Blobfish.AlamofireConfig.customStatusCodeMapping()[statusCode] {
            return customMapping
        }
        
        let apiError    = ErrorCode(rawValue: statusCode ) ?? .unknownError
        switch (apiError) {
            
        case .unauthorized, .forbidden:
            return .token
            
        case .noConnection, .zero, .clientTimeOut, .notConnectedToInternet, .networkConnectionLost, .invalid3rdPartyToken:
            return .connection
            
        default:
            return .unknown
        }
    }
}
