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
 the *Blobable* protocol to it whenever you  have a request that fails with a non-endpoint-specific error.
 */


public class Blobfish {
    
    private static let once = {
        NotificationCenter.default.addObserver(Blobfish.sharedInstance, selector: #selector(Blobfish.aCallWentThrough(_:)), name: "APICallSucceededNotification" as NSNotification.Name, object: nil)
    }
    
    private var reachability = try? Reachability.reachabilityForInternetConnection() {
        didSet {
            self.reachabilityInitialization()
        }
    }
    
    public typealias ErrorHandlerAlertCompletion = (retryButtonClicked:Bool) -> Void
    public typealias ErrorHandlerShowAlertBlock = (title:String, message:String?, actions:[Blob.AlertAction]) -> Void
    
    public static let sharedInstance = Blobfish()
    
    var alertWindow = UIWindow(frame: UIScreen.main().bounds) {
        didSet {
            alertWindow.windowLevel = UIWindowLevelAlert + 1
        }
    }
    
    var alreadyShowingAlert:Bool { return (Blobfish.sharedInstance.alertWindow.isHidden == false) }

    
    private func reachabilityInitialization() {
        if reachability?.whenReachable == nil {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.hideOverlayBar()
                })
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
      _ = Blobfish.once()
        
    }
    /*
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
    */
    
    lazy var overlayBar = MessageBar(frame: UIApplication.shared().statusBarFrame)
    
    
    // MARK: - Error Alert Block
    
    /**
    The content of this closure is responsible for showing showing the UI for an error whose style is MessageStyle.Alert. The default value shows a native alert using UIAlertController.
    
    Override this to use a custom alert for your app.
    */
    
    public var showAlertBlock: ErrorHandlerShowAlertBlock = {
        (title, message, actions) in
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: .default, handler: { (_) in
                Blobfish.hideAlertWindow()
                action.handler?()
            }))
        }
        
        Blobfish.sharedInstance.presentViewController(alert)
        
    }
    
    /**
    This method can be used for presenting a custom viewcontroller while still using the Blobfish boilerplate code for keeping track of already presented alerts. IMPORTANT: If this method is used you must call Blobfish.hideAlertWindow() somewhere in every alert action to regain interaction with app
    */
    
    public func presentViewController(_ viewController:UIViewController) {
        
        if Blobfish.sharedInstance.alertWindow.rootViewController == nil {
            Blobfish.sharedInstance.alertWindow.rootViewController = UIViewController()
        }
        
        Blobfish.sharedInstance.alertWindow.makeKeyAndVisible()
        Blobfish.sharedInstance.alertWindow.rootViewController!.present(viewController, animated: true, completion: nil)
    }
    
    /**
     This method is used for manually hiding the window used for displaying alerts. MUST be called after dismissing a custom viewcontroller presented with Blobfish.sharedInstance.presentViewController(viewController:UIViewController)
     */
    
    public static func hideAlertWindow() {
        Blobfish.sharedInstance.alertWindow.isHidden = true
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
        if (self.overlayBar.isHidden) { // Not already shown
            // Do not re-animate
            self.overlayBar.frame.origin.y = -overlayBar.frame.height
        }
        
        self.overlayBar.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.overlayBar.frame.origin.y = 0
            }) { (finished) -> Void in
                
                self.statusBarDidChangeFrame()
        }
    }
    
    public func hideOverlayBar(_ animated:Bool = true) {

        if !animated  || overlayBar.isHidden == true {
            self.overlayBar.isHidden = true
            return
        }
        
        self.overlayBar.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            
            self.overlayBar.frame.origin.y = -self.overlayBar.frame.size.height
            
            }) { (finished) -> Void in
                
                self.overlayBar.isHidden = true
        }
    }
    
    private func statusBarDidChangeFrame(_ note: Notification) {
        statusBarDidChangeFrame()
    }
    
    public func statusBarDidChangeFrame() {
        let orientation = UIApplication.shared().statusBarOrientation
        
        self.overlayBar.transform = transformForOrientation(orientation)
        
        var frame = UIApplication.shared().statusBarFrame
        
        if UIInterfaceOrientationIsLandscape(orientation) {
            frame = frame.rectByReversingSize()
            if  UIDevice.current().userInterfaceIdiom == .phone {
                frame.origin.x = frame.size.width - frame.origin.x
            }
            else if orientation == UIInterfaceOrientation.landscapeRight {
                if let width = UIApplication.shared().keyWindow?.bounds.height {
                    frame.origin.x = width - frame.size.width
                }
            }
        }

        
        self.overlayBar.frame = frame
    }
    
    @objc func aCallWentThrough(_ note: Notification) {
        DispatchQueue.main.async(execute: { () -> Void in
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
    
    public func handle(_ blobable:Blobable) {
        guard let blob = blobable.blob else { return }
        
        switch (blob.style) {
        case .overlay:
            showOverlayBlock(title: blob.title)
            
        case let .alert(message, actions):
            showAlertBlock(title: blob.title, message: message, actions: actions)
        }
    }
    
    //MARK: Utils
    
    private func degreesToRadians(_ degrees: CGFloat) -> CGFloat { return (degrees * CGFloat(M_PI) / CGFloat(180.0)) }
    
    private func transformForOrientation(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {
        
        switch (orientation) {
            
        case UIInterfaceOrientation.landscapeLeft:
            return CGAffineTransform(rotationAngle: -degreesToRadians(90))
            
        case UIInterfaceOrientation.landscapeRight:
            return CGAffineTransform(rotationAngle: degreesToRadians(90))
            
        case UIInterfaceOrientation.portraitUpsideDown:
            return CGAffineTransform(rotationAngle: degreesToRadians(180))
            
        default:
            return CGAffineTransform(rotationAngle: degreesToRadians(0))
        }
    }
}

internal extension CGRect {
    func rectByReversingSize() -> CGRect {
        return CGRect(origin: self.origin, size: CGSize(width: self.size.height, height: self.size.width))
    }
}
