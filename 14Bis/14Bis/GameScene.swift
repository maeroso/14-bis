//
//  GameScene.swift
//  14Bis
//
//  Created by Murilo Erhardt on 19/05/15.
//  Copyright (c) 2015 Murilo Erhardt. All rights reserved.
//

import SpriteKit;
import CoreMotion;
import AVFoundation;

// Para colisão
enum PhysicsCategories: UInt32 {
    case enemyCategory = 0b1   //1
    case playerCategory = 0b10   //2
    case bulletCategory = 0b100 //4
    case edgeCategory = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bg_0, bg_1 : SKSpriteNode!;
    var player : Player!;
    var pontosLabel: SKLabelNode!;
    var vidasLabel: SKLabelNode!;
    var bulletsCountLabel: SKLabelNode!;
    
    var motionManager = CMMotionManager();
    var accelNewX: CGFloat! = 187.5;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.bounds);
        self.physicsBody?.categoryBitMask = PhysicsCategories.edgeCategory.rawValue;
        
        self.bg_0 = self.childNodeWithName("bg_0") as! SKSpriteNode;
        self.bg_1 = self.childNodeWithName("bg_1") as! SKSpriteNode;
        self.player = Player(spriteNode: self.childNodeWithName("player") as! SKSpriteNode);
        self.pontosLabel = self.childNodeWithName("pontosLabel") as! SKLabelNode;
        self.vidasLabel = self.childNodeWithName("vidasLabel") as! SKLabelNode;
        self.bulletsCountLabel = self.childNodeWithName("bulletsCountLabel") as! SKLabelNode;
        
        if motionManager.accelerometerAvailable == true {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                data, error in
                self.accelNewX = self.player.sprite.position.x + CGFloat(data.acceleration.x * 750);
                
                if self.accelNewX > self.size.width {
                    self.accelNewX = self.size.width;
                }
                if self.accelNewX < 0 {
                    self.accelNewX = 0;
                }
            })
        }
        
        let timer: NSTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("callEnemy"), userInfo: nil, repeats: true)
    }
    
    func callEnemy() {
        self.addChild(EnemiesFactory.sharedInstance.generateEnemy())
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        var backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        self.player.shootUpwards(self.size.height)
    }
    
    //ALVARO DESCOMENTAR
    /*
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let touchLocation = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            var newX = player.sprite.position.x + (touchLocation.x - previousLocation.x);
            
            if newX > self.size.width {
                newX = self.size.width
            }
            if newX < 0 {
                newX = 0
            }
            
            self.player.sprite.position.x = newX;
        }
    }*/
    
    func scrollBackground() {
        bg_0.position.y -= 5;
        bg_1.position.y -= 5;
        
        if(bg_0.position.y < -bg_0.size.height) {
            bg_0.position.y = bg_1.position.y + bg_1.size.height;
        }
        if(bg_1.position.y < -bg_1.size.height) {
            bg_1.position.y = bg_0.position.y + bg_0.size.height;
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        scrollBackground();
        
        self.bulletsCountLabel.text = "\(self.player.bulletsCount)";
        self.player.sprite.runAction(SKAction.moveToX(self.accelNewX, duration: 0.5));
    }
    
    func showGameOverScene() {
        let reveal = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 0.5)
        let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene;
        gameOverScene.pontos = self.player.pontos;
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var possibleEnemy: SKPhysicsBody;
        var notEnemy: SKPhysicsBody;
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            possibleEnemy = contact.bodyA;
            notEnemy = contact.bodyB;
        } else {
            possibleEnemy = contact.bodyB;
            notEnemy = contact.bodyA;
        }
        
        
        if possibleEnemy.categoryBitMask == PhysicsCategories.enemyCategory.rawValue {
            if notEnemy.categoryBitMask == PhysicsCategories.bulletCategory.rawValue {
                if possibleEnemy.node?.name == "enemy" {
                    possibleEnemy.node?.name = "deadEnemy";
                    (possibleEnemy.node! as! Enemy).explode();
                    (notEnemy.node! as! Bullet).explode();
                    self.player.pontos++;
                    self.pontosLabel.text = "\(self.player.pontos)";
                }
            } else if notEnemy.categoryBitMask == PhysicsCategories.playerCategory.rawValue {
                if possibleEnemy.node?.name == "enemy" {
                    possibleEnemy.node?.name = "deadEnemy";
                    (possibleEnemy.node! as! Enemy).explode();
                    self.player.vidas--;
                    self.vidasLabel.text = "\(self.player.vidas)";
                    self.player.explode();
                    
                    if self.player.vidas == 0 {
                        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.runBlock({self.showGameOverScene()})]));
                    }
                }
            } else if notEnemy.categoryBitMask == PhysicsCategories.edgeCategory.rawValue {
                possibleEnemy.node?.runAction(SKAction.moveToY(-20, duration: 1), completion: {possibleEnemy.node?.removeFromParent()})
            }
        }
    }
}
