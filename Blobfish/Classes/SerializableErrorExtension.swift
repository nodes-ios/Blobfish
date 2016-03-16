//
//  NSURLResponse+ErrorRepresentable.swift
//  Blobfish
//
//  Created by Kasper Welner on 28/02/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Serializable

public enum APIError: Int {
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

extension Parser.Error: ErrorRepresentable {
    public func blobfishError() -> Error {
        
        let errorCode   = error?.code
        let statusCode  = response?.statusCode ?? errorCode
        let apiError    = APIError(rawValue: statusCode ?? 0) ?? .UnknownError
        switch (apiError) {
            
        case .Unauthorized, .Forbidden, .NoToken, .InvalidToken, .BlockedUser:
            let message = self.dynamicType.messageForTokenExpiredError()
            return Error.Token(message: message.message, okButtonText: message.ok)
            
        case .NoConnection, .Zero, .ClientTimeOut, .NotConnectedToInternet, .NetworkConnectionLost, .Invalid3rdPartyToken:
            let alert = self.dynamicType.messageForConnectionError(code: statusCode ?? 0)
            return Error.Connection(message: alert.message, style:alert.style)
        
        default:
            var localizedMessageForStatusCode:String = ""
            if let statusCode = statusCode {
               localizedMessageForStatusCode = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            }
            
            let alert = self.dynamicType.messageForUnknownError(code: statusCode ?? abs(errorCode) ?? -1, localizedStringForCode: localizedMessageForStatusCode)
            return Error.Unknown(message: alert.message,
                                 okButtonText: alert.buttonText)
        }
    }
    
    /*
 if errorCode == .ClientTimeOut {
 message = (message:message.message + "\n(timeout)", ok:message.ok, retry: message.retry)
 }
 */
 
    // MARK: - Error Strings
    
    /**
     Gets the message and titles useful for showing in connection error alert view.
     
     - returns: A tuple containing message text and alert style. For .Alert style, please pass along text string for 'OK' and optionally 'Retry'. If retry string is nil, alert will only show OK button.
     */
    
    public static var messageForConnectionError:(code:Int) -> (message:String, style:Error.Style) = { code in
        print("Warning! Please assign values to all 'messageFor***' static properties on Serializable.Parser.Error.. Using default values...")
        var message = "_Something went wrong. Please check your connection and try again"
        
        return (message, .Overlay)
    }
    
    
    
    /**
     Gets the message and titles for showing unkown error alert view.
     
     - returns: A tuple containing message text and ok text.
     */
    public static var messageForUnknownError:(code:Int, localizedStringForCode:String) -> (message: String, buttonText:String) = { (code, localizedStringForCode) in
        print("Warning! Please assign values to all 'messageFor***' static properties on Serializable.Parser.Error.. Using default values...")
        return ("_An error occured" + " \n(\(code) " + localizedStringForCode + ")", "_ok")
    }
    
    /**
     Gets the message and titles for showing token expired/missing error alert view.
     
     - returns: A tuple containing message text and ok text.
     */
    public static var messageForTokenExpiredError:() -> (message: String, ok:String) = {
        print("Warning! Please assign values to all 'messageFor***' static properties on Serializable.Parser.Error.. Using default values...")
        var message = "_You session has expired. Please log in again"
        return (message, "_ok")
    }
}