//
//  Constant.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-07-16.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import Foundation

struct Constant{
    static let HELP = "Help"
    static let HAND = "Hand"
    static let UICONTROLS = "UICONTROLS"
    static let NOTECARD = "NoteCard"
    static let QUESTION_PANEL = "QuestionPanel"
    
    static let SCARLETT_NAME = "Miss Scarlett"
    static let PLUM_NAME = "Prof. Plum"
    static let PEACOCK_NAME = "Mrs Peacock"
    static let GREEN_NAME = "Mr Green"
    static let MUSTARD_NAME = "Col. Mustard"
    static let WHITE_NAME = "Mrs White"
    
    static let SCARLETT_START = "scarlett start"
    static let PLUM_START = "plum start"
    static let PEACOCK_START = "peacock start"
    static let GREEN_START = "green start"
    static let MUSTARD_START = "mustard start"
    static let WHITE_START = "white start"
    
    static let SCARLETT_CARD = Card(n: Constant.SCARLETT_NAME, t: Type.character, file: "scarlett")
    static let PLUM_CARD = Card(n: Constant.PLUM_NAME, t: Type.character, file: "plum")
    static let PEACOCK_CARD = Card(n: Constant.PEACOCK_NAME, t: Type.character, file: "peacock")
    static let GREEN_CARD = Card(n: Constant.GREEN_NAME, t: Type.character, file: "green")
    static let MUSTARD_CARD = Card(n: Constant.MUSTARD_NAME, t: Type.character, file: "mustard")
    static let WHITE_CARD = Card(n: Constant.WHITE_NAME, t: Type.character, file: "white")
    
    
    static let CANDLESTICK_CARD = Card(n: "Candlestick", t: Type.weapon, file: "candlestick")
    static let KNIFE_CARD = Card(n: "Knife", t: Type.weapon, file: "knife")
    static let LEAD_PIPE_CARD = Card(n: "Lead Pipe", t: Type.weapon, file: "leadpipe")
    static let REVOLVER_CARD = Card(n: "Revolver", t: Type.weapon, file: "revolver")
    static let ROPE_CARD = Card(n: "Rope", t: Type.weapon, file: "rope")
    static let WRENCH_CARD = Card(n: "Wrench", t: Type.weapon, file: "wrench")
    
    static let KITCHEN_TILE_NAME = "kitchen"
    static let BALLROOM_TILE_NAME = "ballroom"
    static let CONSERVATORY_TILE_NAME = "conservatory"
    static let DINING_ROOM_TILE_NAME = "dining"
    static let BILLARD_ROOM_TILE_NAME = "billard"
    static let LIBRARY_TILE_NAME = "library"
    static let LOUNGE_TILE_NAME = "lounge"
    static let HALL_TILE_NAME = "hall"
    static let STUDY_TILE_NAME = "study"
    
    
    static let KITCHEN_CARD = Card(n: "Kitchen", t: Type.location, file: Constant.KITCHEN_TILE_NAME)
    static let BALLROOM_CARD = Card(n: "Ballroom", t: Type.location, file: Constant.BALLROOM_TILE_NAME)
    static let CONSERVATORY_CARD = Card(n: "Conservatory", t: Type.location, file: Constant.CONSERVATORY_TILE_NAME)
    static let DINING_ROOM_CARD = Card(n: "Dining room", t: Type.location, file: Constant.DINING_ROOM_TILE_NAME)
    static let BILLARD_ROOM_CARD = Card(n: "Billard Room", t: Type.location, file: Constant.BILLARD_ROOM_TILE_NAME)
    static let LIBRARY_CARD = Card(n: "Library", t: Type.location, file: Constant.LIBRARY_TILE_NAME)
    static let LOUNGE_CARD = Card(n: "Lounge", t: Type.location, file: Constant.LOUNGE_TILE_NAME)
    static let HALL_CARD = Card(n: "Hall", t: Type.location, file: Constant.HALL_TILE_NAME)
    static let STUDY_CARD = Card(n: "Study", t: Type.location, file: Constant.STUDY_TILE_NAME)
}
