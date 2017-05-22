//
//  HumanPlayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class HumanPlayer: Player {
    
    override func reply(_ t: Trio, p:Player) -> Card?
    {
        Game.getGame().state = State.waitingForAnswer
        Game.getGame().roomScene!.question = t
        Game.getGame().roomScene!.updateState();
        return nil
    }

}
