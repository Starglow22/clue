//
//  AIPlayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class EasyAIPlayer: Player {
    
    // Simple elimination: never ask a combo you already know. May ask with cards from hand but not all
    
    var charInfo: [String : Player?]
    var weaponInfo: [String : Player?]
    var roomInfo: [String : Player?]
    
    var shown: [String : [Card]]
    
    var charSoln: Card?
    var weaponSoln: Card?
    var roomSoln: Card?
    
    override init(c: Card) {
        charInfo = ["Miss Scarlett": nil, "Prof. Plum": nil, "Mrs Peacock": nil, "Mr Green": nil, "Col. Mustard": nil, "Mrs White": nil]
        
        weaponInfo = ["Candlestick": nil, "Knife": nil, "Lead Pipe": nil, "Revolver": nil, "Rope": nil, "Wrench": nil]
        
        roomInfo = ["Kitchen": nil, "Ballroom": nil, "Conservatory": nil, "Dining room": nil, "Billard Room": nil, "Library": nil, "Lounge": nil, "Hall": nil, "Study": nil]
        
        shown = ["Miss Scarlett": [], "Prof. Plum": [], "Mrs Peacock": [], "Mr Green": [], "Col. Mustard": [], "Mrs White": []]
        
        super.init(c: c)
    }
    
    func markHandCards()
    {
        for x in hand
        {
            if(x.type == Type.character)
            {
                charInfo[x.name] = self
            }else if (x.type == Type.weapon){
                weaponInfo[x.name] = self
            }else{
                roomInfo[x.name] = self
            }
        }
    }
    
    override func reply(_ t: Trio, p:Player) -> Card?
    {
        let numIHave = (hand.contains(t.location) ? 1 : 0) + (hand.contains(t.weapon) ? 1 : 0) + (hand.contains(t.person) ? 1 : 0)
        let response : Card
        
        
        if(numIHave == 0)
        {
            return nil;
        }else if (numIHave == 1)
        {
            if(hand.contains(t.person))
            {
                response = t.person;
            }else if (hand.contains(t.weapon)){
                response = t.weapon
            }else{
                response = t.location
            }
        }else{
            if(shown[p.character.name]!.contains(t.location))
            {
                response = t.location
            }else if(shown[p.character.name]!.contains(t.person)){
                response = t.person
            }else if(shown[p.character.name]!.contains(t.weapon)){
                response = t.weapon
            }else{
                var availableCards = [Card]()
                if(hand.contains(t.person))
                {
                    availableCards += [t.person];
                }else if (hand.contains(t.weapon)){
                    availableCards += [t.weapon];
                }else{
                    availableCards += [t.location];
                }
                
                let i = (Int)(arc4random_uniform(UInt32(availableCards.count)))
                response = availableCards[i];
            }
        }
        
        shown[p.character.name]?.append(response)
        
        let display = (Game.getGame().roomScene?.childNode(withName: "Result"))!
        display.run(SKAction.unhide())
        
        (display.childNode(withName: "Text") as! SKLabelNode).text =  "\(self.character.name) showed something to \(Game.getGame().currentPlayer.character.name)"
        
        return response
    }
    
    
    override func move(num: Int) -> Int
    {
        var target: Position
        if(notReadyToAccuse())
        {
            //handle case where you know culprit and weapon but not room
            if(charSoln != nil && weaponSoln != nil)
            {
                var unknown = [String]();
                for s in roomInfo
                {
                    if(s.1 == nil)
                    {
                        unknown.append(s.0)
                    }
                }
                if(turnsSinceEntered < 2 && lastRoomEntered != nil && unknown.contains((lastRoomEntered?.room?.name)!))
                {
                    unknown.remove(at: unknown.index(of: (lastRoomEntered?.room?.name)!)!)
                }
                
                target = position!.closestRoomFrom(selection: unknown)
                
            }else{
                target = (position!.closestRoom(lastVisited: lastRoomEntered, numTurns: turnsSinceEntered))
            }
        }else{
            target = Game.getGame().boardScene.board[(roomSoln?.name.lowercased())!]!
            var tempPath = position!.shortestPathTo(target, lastVisited: lastRoomEntered, numTurns: turnsSinceEntered)
            if(tempPath == nil){
                return 0; //no possible moves
            }
            if(position?.room == roomSoln || (lastRoomEntered == target && turnsSinceEntered < 2 && tempPath!.count < 2 && tempPath!.last == target))
            {
                //just go somewhere near but don't take secret passages (heuristic)
                target = position!.closestRoomFrom(selection: ["Ballroom", "Dining room", "Billard Room", "Library", "Hall"])
            }else{
                if(roomSoln == lastRoomEntered?.room && turnsSinceEntered < 2 && num >= tempPath!.count){
                    target = tempPath![tempPath!.count - 1 - (2-turnsSinceEntered)]
                }
            }
        }
        
        var pathToDestination = position!.shortestPathTo(target, lastVisited: lastRoomEntered, numTurns: turnsSinceEntered)
        
        if(pathToDestination == nil)
        {
            return 0; // no possible path
        }
        
        if(pathToDestination!.count <= num)
        {
            moveToken(newPos: pathToDestination![pathToDestination!.count-1], p: Array(pathToDestination!));
        }else{
            moveToken(newPos: pathToDestination![num-1], p: Array(pathToDestination!.dropLast(pathToDestination!.count-num)));
            //not using all moves (eg entering room) causes -ve index
        }
        
        return pathToDestination!.count
        
    }
    
    func notReadyToAccuse() -> Bool
    {
        if(charSoln != nil && weaponSoln != nil && roomSoln != nil)
        {
            return false;
        }
        return true
    }
    
    override func chooseToSuspect()
    {
        if(charSoln != nil && weaponSoln != nil && roomSoln != nil && position?.room == roomSoln)
        {
            suspect = false;
        }else{
            suspect = true;
        }
    }
    
    override func selectPersonWeapon() -> Trio
    {
        if(charSoln != nil && weaponSoln != nil && roomSoln != nil && position?.room == roomSoln)
        {
            return Trio(person: charSoln!, weapon: weaponSoln!, location: roomSoln!)
        }
        
        // lists of ones I don't yet know
        var charOptions = [String]()
        var weaponOptions = [String]()
        
        var charGuess : String
        var weaponGuess : String
        
        for s in charInfo
        {
            if(s.value == nil)
            {
                charOptions += [s.key]
            }
        }
        
        for s in weaponInfo
        {
            if(s.value == nil)
            {
                weaponOptions += [s.key]
            }
        }
        
        // 3 cases: knows none, knows 1, knows 2 - separate case for knowing everything but room must be handled in choosing destination
        
        if(charSoln != nil && weaponSoln != nil) // knows answer but is in wrong room or doesn't know room
        {
            var options = [charSoln!];
            for c in hand
            {
                if(c.type == Type.character)
                {
                    options.append(c);
                }
            }
            charGuess = options[(Int)(arc4random_uniform(UInt32(options.count)))].name
            
            options = [weaponSoln!];
            for c in hand
            {
                if(c.type == Type.weapon)
                {
                    options.append(c);
                }
            }
            weaponGuess = options[(Int)(arc4random_uniform(UInt32(options.count)))].name

            return Trio(person: Card.getCardWithName(charGuess)!, weapon: Card.getCardWithName(weaponGuess)!, location: self.position!.room!)
        }else{
            if(charSoln != nil){ // knows character
                // guess something random from what you hold in your hand and the one in the envelope
                var options = [charSoln!];
                for c in hand
                {
                    if(c.type == Type.character)
                    {
                        options.append(c);
                    }
                }
                charGuess = options[(Int)(arc4random_uniform(UInt32(options.count)))].name
                
                weaponGuess = weaponOptions[(Int)(arc4random_uniform(UInt32(weaponOptions.count)))]
                
            }else if (weaponSoln != nil){
                //mirror above
                var options = [weaponSoln!];
                for c in hand
                {
                    if(c.type == Type.weapon)
                    {
                        options.append(c);
                    }
                }
                weaponGuess = options[(Int)(arc4random_uniform(UInt32(options.count)))].name
                
                charGuess = charOptions[(Int)(arc4random_uniform(UInt32(charOptions.count)))]
            }else{
                charGuess = charOptions[(Int)(arc4random_uniform(UInt32(charOptions.count)))]
                
                weaponGuess = weaponOptions[(Int)(arc4random_uniform(UInt32(weaponOptions.count)))]
            }
            
            var guess: Trio?
            let suspect = Card.getCardWithName(charGuess)!
            let weapon = Card.getCardWithName(weaponGuess)!
        
            guess = Trio(person: suspect, weapon: weapon, location: self.position!.room!)
            
            return guess!
        }
    }
    
    
    override func takeNotes(_ answer: Answer, question:Trio)
    {
        //answer needs guess too in case nothing is returned
        if(answer.card == nil){
            // no one had anything
            if(!hand.contains(question.person)){
                charSoln = question.person
            }
            if(!hand.contains(question.weapon)){
                weaponSoln = question.weapon
            }
            
            if(!hand.contains(question.location)){
                roomSoln = question.location
            }
            
        }else if (answer.card?.type == Type.character)
        {
            charInfo[(answer.card?.name)!] = answer.person
        }else if (answer.card?.type == Type.weapon){
            weaponInfo[(answer.card?.name)!] = answer.person
        }else{
            roomInfo[(answer.card?.name)!] = answer.person
        }
        
        //check if answeres are now known
        var char : String? = nil
        var weapon: String? = nil
        var room: String? = nil
        
        // if there is only one unknown in each category, var holds name, else nil
        for s in charInfo
        {
            if(s.value == nil)
            {
                if(char == nil)
                {
                    char = s.key
                }else{
                    char = nil
                    break
                }
                
            }
        }
        
        for s in weaponInfo
        {
            if(s.value == nil)
            {
                if(weapon == nil)
                {
                    weapon = s.key
                }else{
                    weapon = nil
                    break
                }
                
            }
        }
        
        for s in roomInfo
        {
            if(s.value == nil)
            {
                if(room == nil)
                {
                    room = s.key
                }else{
                    room = nil
                    break
                }
                
            }
        }
        
        if(charSoln == nil && char != nil)
        {
            charSoln = Card.getCardWithName(char!)
        }
        
        if(weaponSoln == nil && weapon != nil)
        {
            weaponSoln = Card.getCardWithName(weapon!)
        }
        
        if(roomSoln == nil && room != nil)
        {
            roomSoln = Card.getCardWithName(room!)
        }
    }
    
    
}
