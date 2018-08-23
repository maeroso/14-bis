//
//  MainMenuScene.swift
//  14Bis
//
//  Created by Matheus Aeroso on 01/06/15.
//  Copyright (c) 2015 Murilo Erhardt. All rights reserved.
//

import SpriteKit;

class MainMenuScene: SKScene {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location: CGPoint = touch.locationInNode(self);
            let node = self.nodeAtPoint(location);
            
            if node.name == "playButton" {
                let reveal = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 0.5)
                let gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
                self.view?.presentScene(gameScene, transition: reveal)
            }
        }
    }
}
