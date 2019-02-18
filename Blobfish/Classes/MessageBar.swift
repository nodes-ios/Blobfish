//
//  ErrorBar.swift
//  NOCore
//
//  Created by Kasper Welner on 24/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit

public class MessageBar: UIWindow {
    public let label = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame.origin.y = LayoutUtils.safeAreaTop()
        label.frame.size.height = 18.0
        self.addSubview(label)
        
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        if #available(iOS 9, *) {
            self.label.allowsDefaultTighteningForTruncation = true
        }
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        
        backgroundColor = UIColor.red
        isHidden = true
        windowLevel = UIWindowLevelStatusBar+1;
    }
    
    public override func layoutSubviews() {
        
        label.frame = self.bounds.insetBy(dx: 8, dy: 0)
        label.frame.origin.y = LayoutUtils.safeAreaTop()
        label.frame.size.height = 18.0
        
        if LayoutUtils.hasTopNotch() {
            label.center = CGPoint(x: center.x, y: center.y + 14)
        } else {
            label.center = self.center
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
