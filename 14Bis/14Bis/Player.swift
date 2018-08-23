//
//  Player.swift
//  14Bis
//
//  Created by Alvaro Rechetelo on 27/05/15.
//  Copyright (c) 2015 Murilo Erhardt. All rights reserved.
//

import SpriteKit;

public class Player {
    var sprite: SKSpriteNode;
    var explosionAnimation : SKAction!;
    var reloadAnimation : SKAction!;
    
    let maxBullets: Int = 5;
    
    var bulletsCount: Int;
    var pontos: Int;
    var vidas: Int;
    
    init(spriteNode: SKSpriteNode) {
        self.sprite = spriteNode;
        
        self.sprite.physicsBody = SKPhysicsBody(texture: self.sprite.texture, size: self.sprite.size);
        self.sprite.physicsBody?.dynamic = false;
        self.sprite.physicsBody?.categoryBitMask = PhysicsCategories.playerCategory.rawValue;
        self.sprite.physicsBody?.collisionBitMask = PhysicsCategories.enemyCategory.rawValue;
        self.sprite.physicsBody?.contactTestBitMask = PhysicsCategories.enemyCategory.rawValue;
        
        var tempSpritesArray = [SKTexture]();
        let textureAtlas = SKTextureAtlas(named: "explosion");
        
        for textureName in textureAtlas.textureNames {
            tempSpritesArray.append(textureAtlas.textureNamed(textureName as! String))
        }
        
        self.explosionAnimation = SKAction.group([
            SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false),
            SKAction.animateWithTextures(tempSpritesArray, timePerFrame: 0.1)
        ]);
        
        self.bulletsCount = self.maxBullets;
        self.pontos = 0;
        self.vidas = 3;
        
        let block = SKAction.runBlock({if self.bulletsCount+1 <= self.maxBullets {self.bulletsCount++}});
        let reloadBlock = SKAction.sequence([SKAction.waitForDuration(0.2), block])
        
        self.reloadAnimation = SKAction.sequence([SKAction.waitForDuration(0.6), SKAction.repeatAction(reloadBlock, count: 5)]);
    }
    
    func shootUpwards(screenHeight: CGFloat) {
        if self.bulletsCount > 0 {
            self.bulletsCount--;
            
            var bullet = Bullet(imageNamed: "rocket");
            bullet.position = CGPoint(x: self.sprite.position.x, y: self.sprite.position.y);
            bullet.hidden = false;
            
            self.sprite.parent?.addChild(bullet);
            
            bullet.runAction(SKAction.group([SKAction.moveToY(screenHeight, duration: 0.8), SKAction.playSoundFileNamed("gunshot.caf", waitForCompletion: false)]),
                completion: {
                    bullet.explode();
            });
            
            if self.bulletsCount == 0 {
                self.reload();
            }
        }
    }
    
    func reload() {
        self.sprite.runAction(self.reloadAnimation);
    }
    
    func explode() {
        let idleTexture = self.sprite.texture;
        self.sprite.colorBlendFactor = 1;
        self.sprite.runAction(self.explosionAnimation, completion: {
            self.sprite.colorBlendFactor = 0;
            self.sprite.texture = idleTexture;
        })
    }
}

internal class Bullet : SKSpriteNode {
    private var emitter: SKEmitterNode!;
    
    convenience init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed);
        self.init(texture: texture, color: nil, size: texture.size())
        
        self.hidden = true;
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size);
        self.physicsBody?.dynamic = false;
        self.physicsBody?.categoryBitMask = PhysicsCategories.bulletCategory.rawValue;
        self.physicsBody?.collisionBitMask = PhysicsCategories.enemyCategory.rawValue;
        self.physicsBody?.contactTestBitMask = PhysicsCategories.enemyCategory.rawValue;
        self.zPosition = -1;
        
        self.emitter = SKEmitterNode(fileNamed: "SmokeParticle");
        self.addChild(emitter);
        
        self.setScale(0.1);
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size);
    }
    
    func explode() {
        self.removeFromParent();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


