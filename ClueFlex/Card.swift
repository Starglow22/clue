//
//  Card.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class Card: NSObject {
    var type: Type
    var imageName: String
    var name: String
    
    init(n: String, t: Type, file:String) {
        name = n;
        type = t;
        imageName = file;
    }
}

enum Type{
    case CHARACTER
    case WEAPON
    case LOCATION
}
