//
//  HardAIPlayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-30.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class HardAIPlayer: EasyAIPlayer {
    // makes deductions from other people's plays - my current strategy. Observer to be notified of the results of every play, just like human player
    
    override init(c: Card) {
        super.init(c: c)
    }
    
    override func move(num: Int) -> Int
    {
        // avoid returning to a room that has been shown by the next person in line - do not consider
        // Go to a more distant room if your roll allows you to enter it
        var target: Position?
        if(notReadyToAccuse())
        {
            if(charSoln != nil && weaponSoln != nil)
            {
                target = position!.closestRoomFrom(selection: unknownRooms(), lastVisited: self.lastRoomEntered, numTurns: self.turnsSinceEntered)
            }else{
                let players = Game.getGame().allPlayers
                let nextPlayer = players[(players.index(of: self)!+1) % players.count]
                var options = [String]();
                for s in roomInfo
                {
                    if(s.1 != nextPlayer && s.0 != position?.room?.name)
                    {
                        options.append(s.0)
                    }
                }
                
                target = position!.closestRoomFrom(selection: options, lastVisited: self.lastRoomEntered, numTurns: self.turnsSinceEntered)
                if(target == nil)
                {
                    return 0;
                }
                
                options.remove(at: options.index(of: target!.room!.name)!)
                let nextClosest = position!.closestRoomFrom(selection: options, lastVisited: self.lastRoomEntered, numTurns: self.turnsSinceEntered)
                
                if(nextClosest != nil)
                {
                    let distanceToNext = position!.shortestPathTo(nextClosest!, lastVisited: lastRoomEntered, numTurns: turnsSinceEntered)?.count
                    
                    if(distanceToNext != nil && distanceToNext! <= num)
                    {
                        target = nextClosest
                    }
                }
            }
        }else{
            let optionalTarget = navigateToSolutionRoom(numMoves: num)
            if(optionalTarget != nil)
            {
                target = optionalTarget!
            }
        }
        
        if(target == nil){
            return 0
        }
        
        return plotPath(target: target!, numMoves: num)
    }
    
    
    override func observe(question: Trio, personAsking: Player, personAnswering:Player?, showedCard: Bool) {
        
        let personKnown = charInfo[question.person.name]! != nil || charSoln == question.person
        let knowWeapon = weaponInfo[question.weapon.name]!
        let weaponKnown = knowWeapon != nil || weaponSoln == question.weapon
        let roomKnown = roomInfo[question.location.name]! != nil || roomSoln == question.location
        let knowPersonShowingHasCardAskedFor = (personKnown && charInfo[question.person.name]! == personAnswering) || (weaponKnown && weaponInfo[question.weapon.name]! == personAnswering) || (roomKnown && roomInfo[question.location.name]! == personAnswering)
        
        if(showedCard)
        {
            // but not if you know the person answering to have one of the cards asked for
            if(!knowPersonShowingHasCardAskedFor)
            {
                if(personKnown && weaponKnown && !roomKnown)
                {
                    takeNotes(Answer(card:question.location, person:personAnswering), question: question)
                }else if(personKnown && !weaponKnown && roomKnown)
                {
                    takeNotes(Answer(card:question.weapon, person:personAnswering), question: question)
                }else if(!personKnown && weaponKnown && roomKnown)
                {
                    takeNotes(Answer(card:question.person, person:personAnswering), question: question)
                }
            }
        }else{
            
            //if person asking owns some - 2 of 3 you can make a deduction about the last, otherwise you could take a ? and check later if they pass on a question involving those but too complicated to code
            //can use the boolean because if no one answered then if they are true it must be because they belong to the person asking
            if(personKnown && weaponKnown && !roomKnown)
            {
                roomSoln = question.location
            }else if(personKnown && !weaponKnown && roomKnown)
            {
                weaponSoln = question.weapon
            }else if(!personKnown && weaponKnown && roomKnown)
            {
                charSoln = question.person
            }
            
            //if you know all the cards the player asking owns, you can make a deduction that any others are the solution
            let numKnownCardsOfPlayer = charInfo.filter({ (item: (key: String, value: Player?)) -> Bool in
                return item.value == personAsking
            }).count + weaponInfo.filter({ (item: (key: String, value: Player?)) -> Bool in
                return item.value == personAsking
            }).count + roomInfo.filter({ (item: (key: String, value: Player?)) -> Bool in
                return item.value == personAsking
            }).count
            
            if(numKnownCardsOfPlayer == personAsking.hand.count)
            {
                if(!personKnown)
                {
                    charSoln = question.person
                }
                if(!weaponKnown)
                {
                    weaponSoln = question.weapon
                }
                if(!roomKnown)
                {
                    roomSoln = question.location
                }
            }
            
        }
    }
}
