//
//  Error.swift
//  Blobfish
//
//  Created by Kasper Welner on 13/03/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import UIKit

public struct Blob {
    let title: String
    let style: Style
    
    public enum Style {
        case Overlay
        case Alert(message:String?, actions: [UIAlertAction])
    }
}