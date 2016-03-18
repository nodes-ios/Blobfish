//
//  Policeman.swift
//  NOCore
//
//  Created by Chris Combs/Kasper Welner on 27/07/15.
//  Copyright (c) 2015 Nodes. All rights reserved.
//

import UIKit
import Reachability

/**
 Blobfish can present general error messages related to URL Requests in a meaningful way. Pass an object conforming to 
 the *Blobable* protocol to it whenever you have a request that fails with a non-endpoint-specific error.
 */

public class Blobfish {
    
    private static var dispatchOnceToken: dispatch_once_t = 0
    
    private var reachability = try? Reachability.reachabilityForInternetConnection() {
        didSet {
            self.reachabilityInitialization()
        }
    }
    
    public typealias ErrorHandlerAlertCompletion = (retryButtonClicked:Bool) -> Void
    public typealias ErrorHandlerShowAlertBlock = (title:String, message:String?, actions:[Blob.AlertAction]) -> Void
    
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
    The content of this closure is responsible for showing showing the UI for an error whose style is MessageStyle.Alert. The default value shows a native alert using UIAlertController.
    
    Override this to use a custom alert for your app.
    */
    
    public var showAlertBlock: ErrorHandlerShowAlertBlock = {
        (title, message, actions) in
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: .Default, handler: { (_) in
                Blobfish.hideAlertWindow()
                action.handler?()
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
    
    public var showOverlayBlock: (title:String) -> Void = { message in
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
    
    public func hideOverlayBar(animated:Bool = true) {

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
    
    
    // MARK: - Blob handling
    
    /**
     Takes a *Blobable* object and displays an error message according to the *blob* returned by the object.
     
     - parameter blobable:               An instance conforming to *Blobable*
     */
    
    public func handle(blobable:Blobable) {
        guard let blob = blobable.blob else { return }
        
        switch (blob.style) {
        case .Overlay:
            showOverlayBlock(title: blob.title)
            
        case let .Alert(message, actions):
            showAlertBlock(title: blob.title, message: message, actions: actions)
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
