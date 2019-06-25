//
//  LayoutUtils.swift
//  Blobfish
//
//  Created by Andrew Lloyd - Nodes on 06/02/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public struct LayoutUtils {
    
    public static func extraLabelHeightForMessageBar() -> CGFloat {
        //16.0 is the height of the label in the message bar
        return safeAreaTop() > 0.0 ? 16.0 : 0.0
    }
    
    public static func safeAreaTop() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                return window.safeAreaInsets.top
            }
        }
        
        return 0.0
    }
    
    public static func hasTopNotch() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
}
