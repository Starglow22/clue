//
//  Trio.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Foundation

struct Trio: Equatable{
    
    var person: Card
    var weapon: Card
    var location: Card
    

}

struct Answer: Equatable{
    var card: Card?
    var person: Player?
}

func ==(lhs: Trio, rhs: Trio) -> Bool {
    return lhs.person == rhs.person && lhs.weapon == rhs.weapon && lhs.location == rhs.location
}


func ==(lhs: Answer, rhs: Answer) -> Bool {
    return lhs.card == rhs.card && lhs.person == rhs.person
}