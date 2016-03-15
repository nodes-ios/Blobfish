//
//  Error.swift
//  Blobfish
//
//  Created by Kasper Welner on 13/03/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

public enum Error {
    case Connection(message: String, style: Style)
    case Token(message: String, okButtonText:String)
    case Unknown(message: String, okButtonText:String)
    
    public enum Style {
        case Overlay
        case Alert(okButtonText:String, retryButtonText: String?)
    }
}