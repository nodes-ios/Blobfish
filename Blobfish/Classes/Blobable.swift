//
//  ErrorRepresentable.swift
//  Blobfish
//
//  Created by Kasper Welner on 28/02/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

/**
 If a class or struct conforms to *Blobable*, it can return a *Blob* and thus 
 be used by Blobfish to display an error message.
 */

public protocol Blobable {
    var blob:Blob? { get }
}