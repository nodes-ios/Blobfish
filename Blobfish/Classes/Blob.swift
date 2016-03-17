//
//  Error.swift
//  Blobfish
//
//  Created by Kasper Welner on 13/03/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import UIKit

/**
 A *Blob* is an entitiy that encapsulates all the information needed
 by Blobfish to show a meaningful error message. This includes text, style,
 button titles and actions.
 */

public struct Blob {
    /**
     The displayed title. if *style* is *.Overlay*, this will be all the user sees.
     */
    let title: String
    
    /**
     The display style of the overlay.
     */
    let style: Style
    
    /**
    The default implementation of Blobfish shows a
    status bare overlay for *.Overlay* and a native *UIAlertController* alert for the *.Alert* case.
    */
    public enum Style {
        case Overlay
        case Alert(message:String?, actions: [AlertAction])
    }
    
    /**
     The default implementation of Blobfish shows a
     status bare overlay for *.Overlay* and a native *UIAlertController* alert for the *.Alert* case.
     */
    public struct AlertAction {
        public let title: String
        public let handler:(()->Void)?
    }
}