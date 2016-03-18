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
    case Zero                   = 0
    case NoConnection           = 4096
    case NotConnectedToInternet = -1009
    case NetworkConnectionLost  = -1005
    case ParsingFailed          = 2048
    case ClientTimeOut          = -1001
    case BadRequest             = 400
    case Unauthorized           = 401
    case Forbidden              = 403
    case NotFound               = 404
    case PreconditionFailed     = 412
    case TooManyRequests        = 429
    case NoAcceptHeader         = 440
    case NoToken                = 441
    case InvalidToken           = 442
    case ExpiredToken           = 443
    case Invalid3rdPartyToken   = 444
    case EntityNotFound         = 445
    case BlockedUser            = 447
    case InternalServerError    = 500
    case UnknownError           = -1
}

//This abomination exists because you cannot extend a generic class with static variables yet
extension Blobfish {
    
    public struct AlamofireConfig {
        
        /**
         Gets the message and titles useful for showing in connection error alert view.
         
         - returns: A tuple containing message text and alert style. For .Alert style, please pass along text string for 'OK' and optionally 'Retry'. If retry string is nil, alert will only show OK button.
         */
        
        
        public static var blobForConnectionError:(code:Int) -> Blob = { code in
            print("Warning! Please assign values to all 'messageFor***' static properties on AlamofireBlobfishConfiguration.. Using default values...")
            var title = "_Something went wrong. Please check your connection and try again"
            
            return Blob(title:title, style: .Overlay)
        }
        
        /**
         Gets the message and titles for showing unkown error alert view.
         
         - returns: A tuple containing message text and ok text.
         */
        
        
        public static var blobForUnknownError:(code:Int, localizedStringForCode:String) -> Blob = { (code, localizedStringForCode) in
            print("Warning! Please assign values to all 'messageFor***' static properties on AlamofireBlobfishConfiguration.. Using default values...")
            let title = "_An error occured"
            let action = Blob.AlertAction(title: "OK", handler: nil)
            return Blob(title: title, style: .Alert(message:"(\(code) " + localizedStringForCode + ")", actions: [action]))
        }
        
        /**
         Gets the message and titles for showing token expired/missing error alert view.
         
         - returns: A tuple containing message text and ok text.
         */
        
        
        public static var blobForTokenExpired:() -> Blob = {
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
            case Connection
            case Token
            case Unknown
            case None
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
        
        guard case let .Failure(resultError) = result else { return nil }
        
        let errorCode   = (resultError as NSError).code
        let statusCode  = response?.statusCode ?? errorCode
        
        switch (self.errorCategory) {
           
        case .None:
            return nil
            
        case .Token:
            return Blobfish.AlamofireConfig.blobForTokenExpired()
            
        case .Connection:
            return Blobfish.AlamofireConfig.blobForConnectionError(code: statusCode ?? 0)
            
        default:
            var localizedMessageForStatusCode:String = ""
            localizedMessageForStatusCode = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            
            return Blobfish.AlamofireConfig.blobForUnknownError(code: statusCode ?? (errorCode ?? -1), localizedStringForCode: localizedMessageForStatusCode)
        }
    }
    
    /**
     A overall classification of the response (and error), assigning it to an *ErrorCategory* case.
     
     - returns: The type of error
     */
    
    public var errorCategory:Blobfish.AlamofireConfig.ErrorCategory {
        
        guard case let .Failure(resultError) = result else { return .None }
        
        let errorCode   = (resultError as NSError).code
        let statusCode  = response?.statusCode ?? errorCode
        
        if let customMapping = Blobfish.AlamofireConfig.customStatusCodeMapping()[statusCode] {
            return customMapping
        }
        
        let apiError    = ErrorCode(rawValue: statusCode ?? 0) ?? .UnknownError
        switch (apiError) {
            
        case .Unauthorized, .Forbidden:
            return .Token
            
        case .NoConnection, .Zero, .ClientTimeOut, .NotConnectedToInternet, .NetworkConnectionLost, .Invalid3rdPartyToken:
            return .Connection
            
        default:
            return .Unknown
        }
    }
}