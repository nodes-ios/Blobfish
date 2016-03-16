//
//  NSURLResponse+ErrorRepresentable.swift
//  Blobfish
//
//  Created by Kasper Welner on 28/02/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Serializable

extension Parser.Error: Blobable {
    
    public enum ErrorCode: Int {
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
    
    public enum ErrorType {
        case Connection
        case Token
        case Unknown
    }
    
    public var blob:Blob {
        
        let errorCode   = error?.code
        let statusCode  = response?.statusCode ?? errorCode
        
        switch (self.errorType) {
            
        case .Token:
            return self.dynamicType.blobForTokenExpired()
            
        case .Connection:
            return self.dynamicType.blobForConnectionError(code: statusCode ?? 0)
            
        default:
            var localizedMessageForStatusCode:String = ""
            if let statusCode = statusCode {
                localizedMessageForStatusCode = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            }
            
            return self.dynamicType.blobForUnknownError(code: statusCode ?? (errorCode ?? -1), localizedStringForCode: localizedMessageForStatusCode)
        }
    }
    
    public var errorType:ErrorType {
        
        let errorCode   = error?.code
        let statusCode  = response?.statusCode ?? errorCode
        let apiError    = ErrorCode(rawValue: statusCode ?? 0) ?? .UnknownError
        switch (apiError) {
            
        case .Unauthorized, .Forbidden, .NoToken, .InvalidToken, .BlockedUser:
            return .Token
            
        case .NoConnection, .Zero, .ClientTimeOut, .NotConnectedToInternet, .NetworkConnectionLost, .Invalid3rdPartyToken:
            return .Connection
            
        default:
            return .Unknown
        }
    }
    
    // MARK: - Error Strings
    
    /**
     Gets the message and titles useful for showing in connection error alert view.
     
     - returns: A tuple containing message text and alert style. For .Alert style, please pass along text string for 'OK' and optionally 'Retry'. If retry string is nil, alert will only show OK button.
     */
    
    
    public static var blobForConnectionError:(code:Int) -> Blob = { code in
        print("Warning! Please assign values to all 'messageFor***' static properties on Serializable.Parser.Error.. Using default values...")
        var title = "_Something went wrong. Please check your connection and try again"
        
        return Blob(title:title, style: .Overlay)
    }
    
    
    
    /**
     Gets the message and titles for showing unkown error alert view.
     
     - returns: A tuple containing message text and ok text.
     */
    public static var blobForUnknownError:(code:Int, localizedStringForCode:String) -> Blob = { (code, localizedStringForCode) in
        print("Warning! Please assign values to all 'messageFor***' static properties on Serializable.Parser.Error.. Using default values...")
        let title = "_An error occured"
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        return Blob(title: title, style: .Alert(message:"(\(code) " + localizedStringForCode + ")", actions: [action]))
    }
    
    /**
     Gets the message and titles for showing token expired/missing error alert view.
     
     - returns: A tuple containing message text and ok text.
     */
    public static var blobForTokenExpired:() -> Blob = {
        var title = "_You session has expired. Please log in again"
        fatalError("errorForTokenExpired is not set on Serializable.Parser.Error extension")
    }
}