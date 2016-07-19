//
//  PLayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Foundation

class Player: NSObject{
    
    var hand = [Card]()
    var position: Position?
    var character: Card
    
    init(c:Card)
    {
        character = c;
    }
    
    func ask()
    {
        
    }
    
    func reply(t: Trio) -> Card?
    {
        return nil
    }
    
    func play()
    {
        
    }
    
    func move()
    {
        
    }
    
    func takeNotes()
    {
        
    }
    
    
    
}