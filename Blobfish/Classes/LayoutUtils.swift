//
//  LayoutUtils.swift
//  Blobfish
//
//  Created by Andrew Lloyd - Nodes on 06/02/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

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
}
