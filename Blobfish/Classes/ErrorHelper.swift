//
//  Policeman.swift
//  NOCore
//
//  Created by Chris Combs/Kasper Welner on 27/07/15.
//  Copyright (c) 2015 Nodes. All rights reserved.
//

import UIKit
import Reachability


public class Blobfish {
    
    private static var dispatchOnceToken: dispatch_once_t = 0
    
    private lazy var reachability = try? Reachability.reachabilityForInternetConnection()
    
    public typealias ErrorHandlerAlertCompletion = (retryButtonClicked:Bool) -> Void
    public typealias ErrorHandlerShowAlertBlock = (message:String, ok:String, retry:String?, completion:ErrorHandlerAlertCompletion?) -> Void
    
    public typealias ErrorHandlerResponseTokenExpiredBlock = (message: String, button: String) -> Void
    public typealias ErrorHandlerResponseNoConnectionBlock = (message: String, style: Error.Style, errorHandler: ConnectionErrorHandler?, retryHandler: ConnectionRetryHandler?) -> Void
    public typealias ErrorHandlerResponseDefaultBlock      = (message: String, button: String) -> Void
    
    public typealias ConnectionErrorHandler = ((message: String, ok:String?, retry: String?) -> Bool)
    public typealias ConnectionRetryHandler = (() -> Void)
    
    public static let sharedInstance = Blobfish()
    
    var alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds) {
        didSet {
            alertWindow.windowLevel = UIWindowLevelAlert + 1
        }
    }
    
    var alreadyShowingAlert:Bool { return (Blobfish.sharedInstance.alertWindow.hidden == false) }

    
    private func reachabilityInitialization() {
        if reachability?.whenReachable == nil {
            reachability?.whenReachable = { reachability in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hideOverlayBar()
                })
            }
        }
        
        reachability?.whenUnreachable = { reachability in
            /*
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                Blobfish.sharedInstance.overlayBar.label.text = self.messageForConnectionError().message
                if let configurationClosure = Blobfish.sharedInstance.overlayBarConfiguration {
                    configurationClosure(type: ErrorType.Connection, bar: Blobfish.sharedInstance.overlayBar)
                }
                self.showOverlayBar()
            })
 */
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        dispatch_once(&Blobfish.dispatchOnceToken) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Blobfish.aCallWentThrough(_:)), name: "APICallSucceededNotification", object: nil)
        }
    }
    
    lazy var overlayBar = MessageBar(frame: UIApplication.sharedApplication().statusBarFrame)
    
    // MARK: - Error Alert Block
    
    /**
    The content of this closure is executed after a message about expired token has been showed. Send the user to your login screen from here.
    */
    
    public var tokenExpiredCompletionBlock: (() -> Void)?
    
    var isShowingTokenExpiredAlert = false;
    
    // MARK: - Error Alert Block
    
    /**
    The content of this closure is responsible for showing showing the UI for an error whose style is MessageStyle.Alert. The default value shows a native alert using UIAlertController.
    
    Override this to use a custom alert for your app.
    */
    
    public var showAlertBlock: ErrorHandlerShowAlertBlock = {
        (message, ok, retry, completion) in
        
        let alert = UIAlertController(title: message, message:nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: ok,style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            Blobfish.hideAlertWindow()
            completion?(retryButtonClicked: false)
        }))
        
        if let retry = retry {
            alert.addAction(UIAlertAction(title: retry, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                Blobfish.hideAlertWindow()
                completion?(retryButtonClicked: true)
            }))
        }
        
        if Blobfish.sharedInstance.alertWindow.rootViewController == nil {
            Blobfish.sharedInstance.alertWindow.rootViewController = UIViewController()
        }
        
        Blobfish.sharedInstance.alertWindow.makeKeyAndVisible()
        Blobfish.sharedInstance.alertWindow.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    private static func hideAlertWindow() {
        Blobfish.sharedInstance.alertWindow.hidden = true
    }
    
    //MARK: - Message Overlay
    /**
    The content of this closure is responsible for showing showing the UI for an error whose style is Overlay. The default value shows a native alert using UIAlertController.
    
    Override this to use a custom alert for your app.
    
    If you want to customize the appearance of the overlay bar, see the overlayBarConfiguration property.
    */
    
    public var showOverlayBlock: (message:String) -> Void = { message in
        Blobfish.sharedInstance.reachabilityInitialization()
        Blobfish.sharedInstance.overlayBar.label.text = message
        Blobfish.sharedInstance.showOverlayBar()
    }
    
    /**
     The content of this closure is responsible for showing showing the UI for an error whose style is Overlay. The default value shows a native alert using UIAlertController.
     
     Override this to use a custom alert for your app.
     
     If you want to customize the appearance of the overlay bar, see the overlayBarConfiguration property.
     */
    
    public var overlayBarConfiguration:((bar:MessageBar) -> Void)?
    
    //MARK: - Private overlay methods
    
    private func showOverlayBar() {
        if (self.overlayBar.hidden) { // Not already shown
            // Do not re-animate
            self.overlayBar.frame.origin.y = -overlayBar.frame.height
        }
        
        self.overlayBar.hidden = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.overlayBar.frame.origin.y = 0
            }) { (finished) -> Void in
                
                self.statusBarDidChangeFrame()
        }
    }
    
    private func hideOverlayBar(animated:Bool = true) {

        if !animated  || overlayBar.hidden == true {
            self.overlayBar.hidden = true
            return
        }
        
        self.overlayBar.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.overlayBar.frame.origin.y = -self.overlayBar.frame.size.height
            
            }) { (finished) -> Void in
                
                self.overlayBar.hidden = true
        }
    }
    
    private func statusBarDidChangeFrame(note: NSNotification) {
        statusBarDidChangeFrame()
    }
    
    public func statusBarDidChangeFrame() {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        self.overlayBar.transform = transformForOrientation(orientation)
        
        var frame = UIApplication.sharedApplication().statusBarFrame
        
        if UIInterfaceOrientationIsLandscape(orientation) {
            frame = frame.rectByReversingSize()
            if  UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                frame.origin.x = frame.size.width - frame.origin.x
            }
            else if orientation == UIInterfaceOrientation.LandscapeRight {
                if let width = UIApplication.sharedApplication().keyWindow?.bounds.height {
                    frame.origin.x = width - frame.size.width
                }
            }
        }

        
        self.overlayBar.frame = frame
    }
    
    @objc func aCallWentThrough(note: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let reachability = self.reachability where reachability.isReachable() {
                self.hideOverlayBar()
            }
        })
    }
    
    
    // MARK: - Response Error Blocks
    
    /**
    Default implementation shows an alert about expired token and after hiding it runs the `tokenExpiredCompletionBlock`.
    
    Can be set to custom implementation an is run if the `ErrorHandler` is handling a response error and the `APIError` is equal to
    `.Unauthorized`, `.Forbidden`, `.NoToken` or `.InvalidToken`.
    */
    public var responseErrorTokenBlock: ErrorHandlerResponseTokenExpiredBlock = {
        (message, button) in
        
        if !Blobfish.sharedInstance.isShowingTokenExpiredAlert {
            Blobfish.sharedInstance.isShowingTokenExpiredAlert = true
            
            Blobfish.sharedInstance.showAlertBlock(
                message: message,
                ok: button,
                retry: nil)
                { (_) in
                    if let block = Blobfish.sharedInstance.tokenExpiredCompletionBlock {
                        block()
                    } else {
                        fatalError("ErrorHandler ERROR: tokenExpiredCompletionBlock MUST be set!")
                    }

                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(15.0 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        Blobfish.sharedInstance.isShowingTokenExpiredAlert = false
                        })
            }
        }
    }
    
    /**
     Default implementation shows an alert about connection problems and optionally presents a retry button if a `ConnectionRetryHandler` was provided.
     
     Can be set to custom implementation an is run if the `ErrorHandler` is handling a response error and the `APIError` is equal to
     `.NoConnection`, `.Zero`, or `.ClientTimeOut`.
     */
    public var responseErrorConnectionBlock: ErrorHandlerResponseNoConnectionBlock = {
        (message, style:Error.Style, errorHandler, retryHandler) in
        
        var showAlert = true
        
        var okButtonText:String? = nil
        var retryButtonText:String? = nil
        
        
        if case let .Alert(buttonText, retryText) = style {
            
            if retryText == nil && retryHandler != nil {
                fatalError("ErrorHandler fatal error! \n Please supply value for 'retry' in 'messageForConnectionError' block, when connectionAlertStyle is .Alert style.")
            }
            
            okButtonText = buttonText
            retryButtonText = retryText
        }
        
        if let handler = errorHandler {
            showAlert = handler(message:message, ok:okButtonText, retry:retryButtonText)
        }
        
        switch style {
            
        case .Overlay:
            if let configurationClosure = Blobfish.sharedInstance.overlayBarConfiguration {
                configurationClosure(bar: Blobfish.sharedInstance.overlayBar)
            }
            Blobfish.sharedInstance.showOverlayBlock(message: message)
            
        case .Alert:
            Blobfish.sharedInstance.showAlertBlock(
                message: message,
                ok: okButtonText!,
                retry: retryHandler != nil ? retryButtonText! : nil)
            { (retryButtonClicked) in
                if let retryHandler = retryHandler where retryButtonClicked {
                    retryHandler()
                }
            }
        }
    }
    
    /**
     Default implementation shows an alert with an error code, other than connection or token error code.
     
     Can be set to custom implementation an is run if the `ErrorHandler` is handling a response error and the `APIError` is any other
     than token errors or connection errors.
     */
    public var responseErrorDefaultBlock: ErrorHandlerResponseDefaultBlock = {
        (message, button) in
        
        Blobfish.sharedInstance.showAlertBlock(
            message: message,
            ok: button,
            retry: nil,
            completion: nil)
    }
    
    // MARK: - Response Error Handling
    
    /**
     Evaluates the given response and runs the appropriate error block.
     
     - parameter response:               The API Response to evaluate
     
     - parameter connectionErrorHandler: (Optional.) This gets passed to the connection error block. Is called on connection error in the default block. Return **true** to show an alert, return **false** to suppress the alert. If you suppress the alert, you are responsible for presenting UI to the user yourself.
     
     - parameter retryHandler:           (Optional.) This gets passed to the connection error block. If **non-nil** in the default block, connection error alert will show a retry button, triggering this closure. Does nothing if *connectionErrorHandler* returns **false**.
     */
    
    public func handleError(error:ErrorRepresentable, connectionErrorHandler: ConnectionErrorHandler? = nil, retryHandler: ConnectionRetryHandler? = nil) {
        switch (error.blobfishError()) {
        case let .Connection(message, style):
            responseErrorConnectionBlock(message: message, style: style, errorHandler: connectionErrorHandler, retryHandler: retryHandler)
            
        case let .Token(message, okButtonText):
            responseErrorTokenBlock(message: message, button: okButtonText)
            
        case let .Unknown(message, okButtonText):
            responseErrorDefaultBlock(message: message, button: okButtonText)
        }
    }
    
    //MARK: Utils
    
    private func degreesToRadians(degrees: CGFloat) -> CGFloat { return (degrees * CGFloat(M_PI) / CGFloat(180.0)) }
    
    private func transformForOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
        
        switch (orientation) {
            
        case UIInterfaceOrientation.LandscapeLeft:
            return CGAffineTransformMakeRotation(-degreesToRadians(90))
            
        case UIInterfaceOrientation.LandscapeRight:
            return CGAffineTransformMakeRotation(degreesToRadians(90))
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            return CGAffineTransformMakeRotation(degreesToRadians(180))
            
        default:
            return CGAffineTransformMakeRotation(degreesToRadians(0))
        }
    }
}

internal extension CGRect {
    func rectByReversingSize() -> CGRect {
        return CGRect(origin: self.origin, size: CGSizeMake(self.size.height, self.size.width))
    }
}
