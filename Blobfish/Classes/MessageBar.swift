//
//  ErrorBar.swift
//  NOCore
//
//  Created by Kasper Welner on 24/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit

public class MessageBar: UIWindow {
    public let label = UILabel(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        self.label.backgroundColor = UIColor.clearColor()
        self.label.textAlignment = NSTextAlignment.Center
        self.label.adjustsFontSizeToFitWidth = true
        if #available(iOS 9, *) {
            self.label.allowsDefaultTighteningForTruncation = true
        }
        self.label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.label.numberOfLines = 1
        self.label.minimumScaleFactor = 0.2
        self.label.textColor = UIColor.whiteColor()
        self.label.font = UIFont.systemFontOfSize(8)
        self.backgroundColor = UIColor.redColor()
        self.hidden = true
        self.windowLevel = UIWindowLevelStatusBar+1;
    }
    
    public override func layoutSubviews() {
        label.frame = self.bounds.insetBy(dx: 8, dy: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
