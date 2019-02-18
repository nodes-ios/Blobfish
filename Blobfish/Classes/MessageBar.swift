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
//        label.frame.size.height = 16.0
        self.addSubview(label)
        
        self.label.backgroundColor = UIColor.clear
        self.label.textAlignment = NSTextAlignment.center
        self.label.adjustsFontSizeToFitWidth = true
        if #available(iOS 9, *) {
            self.label.allowsDefaultTighteningForTruncation = true
        }
        self.label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.label.numberOfLines = 1
//        self.label.minimumScaleFactor = 0.5
        self.label.textColor = UIColor.white
        self.label.font = UIFont.preferredFont(forTextStyle: .callout)
        self.backgroundColor = UIColor.red
        self.isHidden = true
        self.windowLevel = UIWindowLevelStatusBar+1;
    }
    
    public override func layoutSubviews() {
        label.frame = self.bounds.insetBy(dx: 8, dy: 0)
        label.frame.origin.y = LayoutUtils.safeAreaTop()
        label.center = self.center
//        label.frame.size.height = 16.0
        label.sizeToFit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


