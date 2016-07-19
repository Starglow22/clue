//
//  Position.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class Position: NSObject {
    var isRoom : Bool
    var room: Card?
    
    init(isRoom: Bool, room: Card?)
    {
        self.isRoom = isRoom;
        self.room = room;
    }

}
