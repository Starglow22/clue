//
//  BoardScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class BoardScene: SKScene {
    var game : Game?
    
    var board = [String: Position]()
    
    var playerNameDisplay :SKNode?
    
    var dieRoll: Int?
    var possibleDestinations: [Position]?
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        game = Game.getGame()
        playerNameDisplay = self.childNodeWithName("PlayersList")!
        
        (playerNameDisplay?.childNodeWithName("P1") as! SKLabelNode).text = game?.currentPlayer.character.name
        
        let i = game!.players.indexOf(game!.currentPlayer)!
        
        for x in 2...game!.players.count
        {
            (playerNameDisplay?.childNodeWithName("P\(x)") as! SKLabelNode).text = game?.players[(i+x)%game!.players.count].character.name
        }
        
        for x in game!.players.count...6
        {
            (playerNameDisplay?.childNodeWithName("P\(x)") as! SKLabelNode).text = ""
        }
        highlightCurrentPlayer()
        
        for node in (self.childNodeWithName("UICONTROLS")?.children)!
        {
            node.runAction(SKAction.hide())
        }
        
        (self.childNodeWithName("UICONTROLS")?.childNodeWithName("TextDisplay") as! SKLabelNode).text = "Your turn!"
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let textDisplay = self.childNodeWithName("UICONTROLS")?.childNodeWithName("TextDisplay") as! SKLabelNode
        
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        switch game!.state
        {
        case State.waitingForTurn:
            //allow notecard to be opened
            break;
            
        case State.startOfTurn:
            //any click moves to next stage
            textDisplay.text = "Please roll the die"
            game?.state = State.waitingForDieRoll
            
        case State.waitingForDieRoll:
            if(node.name == "Die")
            {
                dieRoll = rollDie();
                game?.state = State.waitingForMoveDestination
                possibleDestinations = game?.currentPlayer.position?.reachablePositions(dieRoll!)
                textDisplay.text = "Select your destination"
            }
            
        case State.waitingForMoveDestination:
            let selection = board[node.name!.lowercaseString]
            //nil if not a position
            
            if (selection != nil && possibleDestinations!.contains(selection!))
            {
                moveToPosition(selection!)
                textDisplay.runAction(SKAction.hide())
                if (selection!.isRoom)
                {
                    switchToRoomView()
                    game?.state = State.waitingForSuspectOrAccuse
                }else{
                    game?.currentPlayer.passTurn()
                    //pass turn
                }
            }else{
                textDisplay.text = "Thats is not a valid move, sorry"
            }
            
            
        default:
            //do nothing
            break;
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //animation - move sprite node in 2 moves x and y, largest first, set new position
    func moveToPosition(newPos: Position)
    {
        // move to new position
        let newX = newPos.sprite.position.x
        let newY = newPos.sprite.position.y
        
        let oldX = game!.currentPlayer.sprite!.position.x
        let oldY = game!.currentPlayer.sprite!.position.y
        
        if (abs(oldX-newX) > abs(oldY - newY))
        {
            game?.currentPlayer.sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: oldY), duration: 0.5))
            game?.currentPlayer.sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: newY), duration: 0.5))
        }else{
            game?.currentPlayer.sprite?.runAction(SKAction.moveTo(CGPoint(x: oldX, y: newY), duration: 0.5))
            game?.currentPlayer.sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: newY), duration: 0.5))
        }
        
        
        
        game?.currentPlayer.position = newPos
    }
    
    //including animation
    func rollDie() -> Int
    {
        let roll = arc4random_uniform(6) + 1
        let node  = self.childNodeWithName("UICONTROLS")?.childNodeWithName("Die") as! SKSpriteNode
        node.runAction(SKAction.rotateByAngle(CGFloat(M_PI * 16), duration: 1.5))
        node.runAction(SKAction.setTexture(SKTexture(imageNamed: "Die\(roll)")))
        return Int(roll);
        
    }
    
    func highlightCurrentPlayer()
    {
        for x in 1...game!.players.count
        {
            if((playerNameDisplay?.childNodeWithName("P\(x)") as! SKLabelNode).text == game?.currentPlayer.character.name)
            {
                (playerNameDisplay?.childNodeWithName("P\(x)") as! SKLabelNode).fontSize = 36
            }else{
                (playerNameDisplay?.childNodeWithName("P\(x)") as! SKLabelNode).fontSize = 24
            }
        }
    }
    
    func switchToRoomView()
    {
        //reset
        dieRoll = 0
        possibleDestinations = []
        
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5)
        var nextScene = game?.roomScene
        if(nextScene == nil){
            nextScene = RoomScene(fileNamed: "RoomScene")
            game?.roomScene = nextScene
        }
        nextScene?.size = self.size
        nextScene?.scaleMode = .AspectFill
        self.view?.presentScene(nextScene!, transition: reveal)
    }
    
    func setUpTiles()
    {
        let root = self.childNodeWithName("BoardBackground")
        for i in 1...182
        {
            board["tile\(i)"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("Tile\(i)") as! SKSpriteNode)
        }
        
        board["study"] = Position(isRoom: true, room: game?.roomCards![8], node: root?.childNodeWithName("Study") as! SKSpriteNode)
        board["hall"] = Position(isRoom: true, room: game?.roomCards![7], node: root?.childNodeWithName("Hall") as! SKSpriteNode)
        board["lounge"] = Position(isRoom: true, room: game?.roomCards![6], node: root?.childNodeWithName("Lounge") as! SKSpriteNode)
        board["library"] = Position(isRoom: true, room: game?.roomCards![5], node: root?.childNodeWithName("Library") as! SKSpriteNode)
        board["billard"] = Position(isRoom: true, room: game?.roomCards![4], node: root?.childNodeWithName("Billard") as! SKSpriteNode)
        board["dining"] = Position(isRoom: true, room: game?.roomCards![3], node: root?.childNodeWithName("Dining Room") as! SKSpriteNode)
        board["conservatory"] = Position(isRoom: true, room: game?.roomCards![2], node: root?.childNodeWithName("Conservatory") as! SKSpriteNode)
        board["ballroom"] = Position(isRoom: true, room: game?.roomCards![1], node: root?.childNodeWithName("Ballroom") as! SKSpriteNode)
        board["kitchen"] = Position(isRoom: true, room: game?.roomCards![0], node: root?.childNodeWithName("Kitchen") as! SKSpriteNode)
        
        board["scarlett start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("Scarlett start") as! SKSpriteNode)
        board["green start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("Green start") as! SKSpriteNode)
        board["peacock start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("Peacock start") as! SKSpriteNode)
        board["white start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("White start") as! SKSpriteNode)
        board["mustard start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("mustard start") as! SKSpriteNode)
        board["plum start"] = Position(isRoom: false, room: nil, node: root?.childNodeWithName("Plum start") as! SKSpriteNode)
        connectTiles()
    }
    
    func connectTiles()
    {
        board["study"]?.adjacent = [board["tile19"]!, board["kitchen"]!]
        board["hall"]?.adjacent = [board["tile21"]!, board["tile49"]!, board["tile50"]!]
        board["lounge"]?.adjacent = [board["tile39"]!, board["conservatory"]!]
        board["library"]?.adjacent = [board["tile61"]!, board["tile83"]!]
        board["billard"]?.adjacent = [board["tile81"]!, board["tile106"]!]
        board["dining"]?.adjacent = [board["tile66"]!, board["tile95"]!]
        board["conservatory"]?.adjacent = [board["tile160"]!, board["lounge"]!]
        board["ballroom"]?.adjacent = [board["tile162"]!, board["tile122"]!, board["tile127"]!, board["tile163"]!]
        board["kitchen"]?.adjacent = [board["tile146"]!, board["study"]!]
        
        
        board["scarlett start"]?.adjacent = [board["tile5"]!]
        board["green start"]?.adjacent = [board["tile179"]!]
        board["peacock start"]?.adjacent = [board["tile151"]!]
        board["white start"]?.adjacent = [board["tile180"]!]
        board["mustard start"]?.adjacent = [board["tile60"]!]
        board["plum start"]?.adjacent = [board["tile24"]!]
        
        board["tile1"]?.adjacent = [board["tile2"]!]
        board["tile2"]?.adjacent = [board["tile3"]!, board["tile6"]!]
        board["tile3"]?.adjacent = [board["tile2"]!, board["tile7"]!]
        board["tile4"]?.adjacent = [board["tile5"]!, board["tile8"]!]
        board["tile5"]?.adjacent = [board["tile4"]!, board["tile9"]!, board["Scarlett start"]!]
        board["tile6"]?.adjacent = [board["tile7"]!, board["tile10"]!, board["tile2"]!]
        board["tile7"]?.adjacent = [board["tile3"]!, board["tile6"]!, board["tile11"]!]
        board["tile8"]?.adjacent = [board["tile4"]!, board["tile9"]!, board["tile12"]!]
        board["tile9"]?.adjacent = [board["tile5"]!, board["tile8"]!, board["tile13"]!]
        board["tile10"]?.adjacent = [board["tile6"]!, board["tile11"]!, board["tile20"]!]
        
        board["tile11"]?.adjacent = [board["tile7"]!, board["til10"]!, board["tile21"]!]
        board["tile12"]?.adjacent = [board["tile8"]!, board["tile13"]!, board["tile22"]!]
        board["tile13"]?.adjacent = [board["tile9"]!, board["tile12"]!, board["tile23"]!]
        board["tile14"]?.adjacent = [board["tile15"]!, board["tile24"]!]
        board["tile15"]?.adjacent = [board["tile14"]!, board["tile16"]!, board["tile25"]!]
        board["tile16"]?.adjacent = [board["tile15"]!, board["tile17"]!, board["tile26"]!]
        board["tile17"]?.adjacent = [board["tile16"]!, board["tile18"]!, board["tile27"]!]
        board["tile18"]?.adjacent = [board["tile17"]!, board["tile19"]!, board["tile28"]!]
        board["tile19"]?.adjacent = [board["tile18"]!, board["tile20"]!, board["tile29"]!]
        board["tile20"]?.adjacent = [board["tile19"]!, board["tile21"]!, board["tile30"]!, board["tile10"]!]
        
        board["tile21"]?.adjacent = [board["tile20"]!, board["tile31"]!, board["tile11"]!]
        board["tile22"]?.adjacent = [board["tile32"]!, board["tile12"]!, board["tile23"]!]
        board["tile23"]?.adjacent = [board["tile22"]!, board["tile13"]!, board["tile33"]!]
        board["tile24"]?.adjacent = [board["tile14"]!, board["tile25"]!, board["Plum start"]!]
        board["tile25"]?.adjacent = [board["tile15"]!, board["tile24"]!, board["tile26"]!]
        board["tile26"]?.adjacent = [board["tile16"]!, board["tile25"]!, board["tile27"]!]
        board["tile27"]?.adjacent = [board["tile17"]!, board["tile26"]!, board["tile28"]!]
        board["tile28"]?.adjacent = [board["tile18"]!, board["tile27"]!, board["tile29"]!]
        board["tile29"]?.adjacent = [board["tile28"]!, board["tile30"]!, board["tile19"]!, board["tile34"]!]
        board["tile30"]?.adjacent = [board["tile29"]!, board["tile31"]!, board["tile20"]!, board["tile35"]!]
        
        board["tile31"]?.adjacent = [board["tile30"]!, board["tile36"]!, board["tile21"]!]
        board["tile32"]?.adjacent = [board["tile33"]!, board["tile37"]!, board["tile22"]!]
        board["tile33"]?.adjacent = [board["tile32"]!, board["tile38"]!, board["tile23"]!]
        board["tile34"]?.adjacent = [board["tile29"]!, board["tile35"]!]
        board["tile35"]?.adjacent = [board["tile34"]!, board["tile36"]!, board["tile30"]!, board["tile45"]!]
        board["tile36"]?.adjacent = [board["tile35"]!, board["tile31"]!, board["tile45"]!]
        board["tile37"]?.adjacent = [board["tile38"]!, board["tile53"]!, board["tile32"]!]
        board["tile38"]?.adjacent = [board["tile37"]!, board["tile39"]!, board["tile54"]!, board["tile33"]!]
        board["tile39"]?.adjacent = [board["tile38"]!, board["tile40"]!, board["tile55"]!]
        board["tile40"]?.adjacent = [board["tile39"]!, board["tile41"]!, board["tile56"]!]
        
        board["tile41"]?.adjacent = [board["tile40"]!, board["tile42"]!, board["tile57"]!]
        board["tile42"]?.adjacent = [board["tile41"]!, board["tile43"]!, board["tile58"]!]
        board["tile43"]?.adjacent = [board["tile42"]!, board["tile44"]!, board["tile59"]!]
        board["tile44"]?.adjacent = [board["tile43"]!, board["tile60"]!]
        board["tile45"]?.adjacent = [board["tile46"]!, board["tile61"]!, board["tile35"]!]
        board["tile46"]?.adjacent = [board["tile45"]!, board["tile47"]!, board["tile62"]!, board["tile36"]!]
        board["tile47"]?.adjacent = [board["tile46"]!, board["tile48"]!]
        board["tile48"]?.adjacent = [board["tile47"]!, board["tile49"]!]
        board["tile49"]?.adjacent = [board["tile48"]!, board["tile50"]!]
        board["tile50"]?.adjacent = [board["tile49"]!, board["tile51"]!]
        
        board["tile51"]?.adjacent = [board["tile50"]!, board["tile52"]!]
        board["tile52"]?.adjacent = [board["tile51"]!, board["tile53"]!, board["tile63"]!]
        board["tile53"]?.adjacent = [board["tile52"]!, board["tile54"]!, board["tile64"]!, board["tile37"]!]
        board["tile54"]?.adjacent = [board["tile54"]!, board["tile55"]!, board["tile65"]!, board["tile38"]!]
        board["tile55"]?.adjacent = [board["tile54"]!, board["tile56"]!, board["tile66"]!, board["tile39"]!]
        board["tile56"]?.adjacent = [board["tile55"]!, board["tile57"]!, board["tile67"]!, board["tile40"]!]
        board["tile57"]?.adjacent = [board["tile56"]!, board["tile58"]!, board["tile68"]!, board["tile41"]!]
        board["tile58"]?.adjacent = [board["tile57"]!, board["tile59"]!, board["tile69"]!, board["tile42"]!]
        board["tile59"]?.adjacent = [board["tile49"]!, board["tile51"]!]
        board["tile60"]?.adjacent = [board["tile59"]!, board["tile70"]!, board["tile43"]!, board["mustard start"]!]
        
        board["tile61"]?.adjacent = [board["tile72"]!, board["tile62"]!, board["tile45"]!]
        board["tile62"]?.adjacent = [board["tile61"]!, board["tile73"]!, board["tile46"]!]
        board["tile63"]?.adjacent = [board["tile64"]!, board["tile74"]!, board["tile52"]!]
        board["tile64"]?.adjacent = [board["tile63"]!, board["tile65"]!, board["tile53"]!, board["tile75"]!]
        board["tile65"]?.adjacent = [board["tile64"]!, board["tile66"]!, board["tile54"]!]
        board["tile66"]?.adjacent = [board["tile65"]!, board["tile67"]!, board["tile55"]!]
        board["tile67"]?.adjacent = [board["tile66"]!, board["tile68"]!, board["tile56"]!]
        board["tile68"]?.adjacent = [board["tile67"]!, board["tile69"]!, board["tile57"]!]
        board["tile69"]?.adjacent = [board["tile68"]!, board["tile70"]!, board["tile58"]!]
        board["tile70"]?.adjacent = [board["tile69"]!, board["tile71"]!, board["tile59"]!]
        
        board["tile71"]?.adjacent = [board["tile70"]!, board["tile60"]!]
        board["tile72"]?.adjacent = [board["tile73"]!, board["tile77"]!, board["tile61"]!]
        board["tile73"]?.adjacent = [board["tile72"]!, board["tile78"]!, board["tile62"]!]
        board["tile74"]?.adjacent = [board["tile63"]!, board["tile79"]!, board["tile75"]!]
        board["tile75"]?.adjacent = [board["tile74"]!, board["tile80"]!, board["tile64"]!]
        board["tile76"]?.adjacent = [board["tile86"]!, board["tile76"]!]
        board["tile77"]?.adjacent = [board["tile76"]!, board["tile78"]!, board["tile87"]!, board["tile72"]!]
        board["tile78"]?.adjacent = [board["tile77"]!, board["tile88"]!, board["tile73"]!]
        board["tile79"]?.adjacent = [board["tile80"]!, board["tile89"]!, board["tile74"]!]
        board["tile80"]?.adjacent = [board["tile79"]!, board["tile90"]!, board["tile75"]!]
        
        board["tile81"]?.adjacent = [board["tile82"]!]
        board["tile82"]?.adjacent = [board["tile81"]!, board["tile83"]!]
        board["tile83"]?.adjacent = [board["tile82"]!, board["tile84"]!]
        board["tile84"]?.adjacent = [board["tile83"]!, board["tile85"]!]
        board["tile85"]?.adjacent = [board["tile84"]!, board["tile86"]!]
        board["tile86"]?.adjacent = [board["tile85"]!, board["tile87"]!, board["tile76"]!, board["tile91"]!]
        board["tile87"]?.adjacent = [board["tile86"]!, board["tile88"]!, board["tile77"]!, board["tile92"]!]
        board["tile88"]?.adjacent = [board["tile87"]!, board["tile78"]!, board["tile93"]!]
        board["tile89"]?.adjacent = [board["tile90"]!, board["tile79"]!, board["tile94"]!]
        board["tile90"]?.adjacent = [board["tile89"]!, board["tile80"]!, board["tile95"]!]
        
        board["tile91"]?.adjacent = [board["tile86"]!, board["tile96"]!, board["tile92"]!]
        board["tile92"]?.adjacent = [board["tile87"]!, board["tile97"]!, board["tile91"]!, board["tile93"]!]
        board["tile93"]?.adjacent = [board["tile88"]!, board["tile98"]!, board["tile92"]!]
        board["tile94"]?.adjacent = [board["tile89"]!, board["tile99"]!, board["tile95"]!]
        board["tile95"]?.adjacent = [board["tile90"]!, board["tile100"]!, board["tile94"]!]
        board["tile96"]?.adjacent = [board["tile97"]!, board["tile101"]!, board["tile91"]!]
        board["tile97"]?.adjacent = [board["tile96"]!, board["tile92"]!, board["tile102"]!, board["tile98"]!]
        board["tile98"]?.adjacent = [board["tile97"]!, board["tile93"]!, board["tile103"]!]
        board["tile99"]?.adjacent = [board["tile100"]!, board["tile104"]!, board["tile94"]!]
        board["tile100"]?.adjacent = [board["tile99"]!, board["tile105"]!, board["tile95"]!]
        
        board["tile101"]?.adjacent = [board["tile96"]!, board["tile106"]!, board["tile102"]!]
        board["tile102"]?.adjacent = [board["tile101"]!, board["tile103"]!, board["tile107"]!, board["tile97"]!]
        board["tile103"]?.adjacent = [board["tile102"]!, board["tile108"]!, board["tile98"]!]
        board["tile104"]?.adjacent = [board["tile105"]!, board["tile114"]!, board["tile99"]!]
        board["tile105"]?.adjacent = [board["tile104"]!, board["tile115"]!, board["tile100"]!]
        board["tile106"]?.adjacent = [board["tile101"]!, board["tile107"]!, board["tile119"]!]
        board["tile107"]?.adjacent = [board["tile106"]!, board["tile102"]!, board["tile120"]!, board["tile108"]!]
        board["tile108"]?.adjacent = [board["tile107"]!, board["tile109"]!, board["tile121"]!, board["tile103"]!]
        board["tile109"]?.adjacent = [board["tile108"]!, board["tile110"]!, board["tile122"]!]
        board["tile110"]?.adjacent = [board["tile109"]!, board["tile111"]!, board["tile123"]!]
        
        board["tile111"]?.adjacent = [board["tile110"]!, board["tile112"]!, board["tile124"]!]
        board["tile112"]?.adjacent = [board["tile113"]!, board["tile111"]!, board["tile125"]!]
        board["tile113"]?.adjacent = [board["tile112"]!, board["tile114"]!, board["tile126"]!]
        board["tile114"]?.adjacent = [board["tile113"]!, board["tile115"]!, board["tile127"]!, board["tile104"]!]
        board["tile115"]?.adjacent = [board["tile114"]!, board["tile116"]!, board["tile128"]!, board["tile105"]!]
        board["tile116"]?.adjacent = [board["tile115"]!, board["tile117"]!, board["tile129"]!]
        board["tile117"]?.adjacent = [board["tile116"]!, board["tile118"]!, board["tile130"]!]
        board["tile118"]?.adjacent = [board["tile117"]!, board["tile131"]!]
        board["tile119"]?.adjacent = [board["tile120"]!, board["tile106"]!, board["tile141"]!]
        board["tile120"]?.adjacent = [board["tile119"]!, board["tile121"]!, board["tile142"]!, board["tile107"]!]
        
        board["tile121"]?.adjacent = [board["tile120"]!, board["tile122"]!, board["tile108"]!]
        board["tile122"]?.adjacent = [board["tile121"]!, board["tile123"]!, board["tile109"]!]
        board["tile123"]?.adjacent = [board["tile122"]!, board["tile124"]!, board["tile110"]!]
        board["tile124"]?.adjacent = [board["tile123"]!, board["tile125"]!, board["tile111"]!]
        board["tile125"]?.adjacent = [board["tile124"]!, board["tile126"]!, board["tile112"]!]
        board["tile126"]?.adjacent = [board["tile125"]!, board["tile127"]!, board["tile113"]!]
        board["tile127"]?.adjacent = [board["tile126"]!, board["tile128"]!, board["tile114"]!]
        board["tile128"]?.adjacent = [board["tile127"]!, board["tile129"]!, board["tile115"]!]
        board["tile129"]?.adjacent = [board["tile128"]!, board["tile130"]!, board["tile116"]!, board["tile143"]!]
        board["tile130"]?.adjacent = [board["tile129"]!, board["tile131"]!, board["tile117"]!, board["tile144"]!]
        
        board["tile131"]?.adjacent = [board["tile130"]!, board["tile132"]!, board["tile118"]!, board["tile145"]!]
        board["tile132"]?.adjacent = [board["tile131"]!, board["tile133"]!, board["tile146"]!]
        board["tile133"]?.adjacent = [board["tile132"]!, board["tile134"]!, board["tile147"]!]
        board["tile134"]?.adjacent = [board["tile133"]!, board["tile135"]!, board["tile148"]!]
        board["tile135"]?.adjacent = [board["tile134"]!, board["tile149"]!]
        board["tile136"]?.adjacent = [board["tile137"]!, board["tile151"]!]
        board["tile137"]?.adjacent = [board["tile136"]!, board["tile138"]!, board["tile152"]!]
        board["tile138"]?.adjacent = [board["tile137"]!, board["tile139"]!, board["tile153"]!]
        board["tile139"]?.adjacent = [board["tile138"]!, board["tile140"]!, board["tile154"]!]
        board["tile140"]?.adjacent = [board["tile139"]!, board["tile141"]!, board["tile155"]!]
        
        board["tile141"]?.adjacent = [board["tile140"]!, board["tile142"]!, board["tile156"]!, board["tile119"]!]
        board["tile142"]?.adjacent = [board["tile141"]!, board["tile157"]!, board["tile120"]!]
        board["tile143"]?.adjacent = [board["tile144"]!, board["tile158"]!, board["tile129"]!]
        board["tile144"]?.adjacent = [board["tile143"]!, board["tile145"]!, board["tile159"]!, board["tile130"]!]
        board["tile145"]?.adjacent = [board["tile144"]!, board["tile146"]!, board["tile131"]!]
        board["tile146"]?.adjacent = [board["tile145"]!, board["tile147"]!, board["tile132"]!]
        board["tile147"]?.adjacent = [board["tile146"]!, board["tile148"]!, board["tile133"]!]
        board["tile148"]?.adjacent = [board["tile147"]!, board["tile149"]!, board["tile134"]!]
        board["tile149"]?.adjacent = [board["tile148"]!, board["tile150"]!, board["tile135"]!]
        board["tile150"]?.adjacent = [board["tile149"]!]
        
        board["tile151"]?.adjacent = [board["tile152"]!, board["tile136"]!, board["tile151"]!]
        board["tile152"]?.adjacent = [board["tile151"]!, board["tile153"]!, board["tile137"]!]
        board["tile153"]?.adjacent = [board["tile152"]!, board["tile154"]!, board["tile138"]!]
        board["tile154"]?.adjacent = [board["tile153"]!, board["tile155"]!, board["tile139"]!]
        board["tile155"]?.adjacent = [board["tile154"]!, board["tile156"]!, board["tile140"]!, board["tile160"]!]
        board["tile156"]?.adjacent = [board["tile155"]!, board["tile157"]!, board["tile141"]!, board["tile161"]!]
        board["tile157"]?.adjacent = [board["tile156"]!, board["tile142"]!, board["tile162"]!]
        board["tile158"]?.adjacent = [board["tile159"]!, board["tile163"]!, board["tile143"]!]
        board["tile159"]?.adjacent = [board["tile158"]!, board["tile164"]!, board["tile144"]!]
        board["tile160"]?.adjacent = [board["tile161"]!, board["tile155"]!]
        
        board["tile161"]?.adjacent = [board["tile160"]!, board["tile162"]!, board["tile156"]!, board["tile165"]!]
        board["tile162"]?.adjacent = [board["tile161"]!, board["tile157"]!, board["tile166"]!]
        board["tile163"]?.adjacent = [board["tile164"]!, board["tile167"]!, board["tile158"]!]
        board["tile164"]?.adjacent = [board["tile163"]!, board["tile168"]!, board["tile159"]!]
        board["tile165"]?.adjacent = [board["tile166"]!, board["tile169"]!, board["tile161"]!]
        board["tile166"]?.adjacent = [board["tile165"]!, board["tile170"]!, board["tile162"]!]
        board["tile167"]?.adjacent = [board["tile168"]!, board["tile171"]!, board["tile163"]!]
        board["tile168"]?.adjacent = [board["tile167"]!, board["tile172"]!, board["tile164"]!]
        board["tile169"]?.adjacent = [board["tile170"]!, board["tile173"]!, board["tile165"]!]
        board["tile170"]?.adjacent = [board["tile169"]!, board["tile174"]!, board["tile166"]!]
        
        board["tile171"]?.adjacent = [board["tile172"]!, board["tile175"]!, board["tile167"]!]
        board["tile172"]?.adjacent = [board["tile171"]!, board["tile176"]!, board["tile168"]!]
        board["tile173"]?.adjacent = [board["tile174"]!, board["tile169"]!]
        board["tile174"]?.adjacent = [board["tile173"]!, board["tile170"]!, board["tile177"]!]
        board["tile175"]?.adjacent = [board["tile176"]!, board["tile171"]!, board["tile182"]!]
        board["tile176"]?.adjacent = [board["tile175"]!, board["tile172"]!]
        board["tile177"]?.adjacent = [board["tile174"]!, board["tile178"]!]
        board["tile178"]?.adjacent = [board["tile177"]!, board["tile179"]!]
        board["tile179"]?.adjacent = [board["tile178"]!, board["Green start"]!]
        board["tile180"]?.adjacent = [board["tile181"]!, board["White start"]!]
        
        board["tile181"]?.adjacent = [board["tile180"]!, board["tile182"]!]
        board["tile182"]?.adjacent = [board["tile181"]!, board["tile175"]!]
        
        board["tile19"]?.adjacent += [board["study"]!]
        board["tile21"]?.adjacent += [board["hall"]!]
        board["tile49"]?.adjacent += [board["hall"]!]
        board["tile50"]?.adjacent += [board["hall"]!]
        board["tile39"]?.adjacent += [board["lounge"]!]
        board["tile61"]?.adjacent += [board["library"]!]
        board["tile83"]?.adjacent += [board["library"]!]
        board["tile81"]?.adjacent += [board["billard"]!]
        board["tile106"]?.adjacent += [board["billard"]!]
        board["tile66"]?.adjacent += [board["dining"]!]
        board["tile95"]?.adjacent += [board["dining"]!]
        board["tile160"]?.adjacent += [board["conservatory"]!]
        board["tile162"]?.adjacent += [board["ballroom"]!]
        board["tile122"]?.adjacent += [board["ballroom"]!]
        board["tile127"]?.adjacent += [board["ballroom"]!]
        board["tile163"]?.adjacent += [board["ballroom"]!]
        board["tile146"]?.adjacent += [board["kitchen"]!]
        
        //116,175
        
    }


}
