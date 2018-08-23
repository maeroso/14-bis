//
//  Enemy.swift
//  14Bis
//
//  Created by Matheus Aeroso on 27/05/15.
//  
//

import SpriteKit;

class Enemy : SKSpriteNode {
    var explosionAnimation : SKAction!;
    
    convenience init(imageNamed: String, position: CGPoint) {
        let texture = SKTexture(imageNamed: imageNamed);
        self.init(texture: texture, color: nil, size: texture.size())
        
        self.name = "enemy"
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.enemyCategory.rawValue;
        self.physicsBody?.collisionBitMask = PhysicsCategories.bulletCategory.rawValue | PhysicsCategories.playerCategory.rawValue;
        self.physicsBody?.contactTestBitMask = PhysicsCategories.bulletCategory.rawValue | PhysicsCategories.playerCategory.rawValue;
        
        self.zPosition = 0;
        self.position = position;
        self.setScale(0.5);
        
        var tempSpritesArray = [SKTexture]();
        let textureAtlas = SKTextureAtlas(named: "explosion");
        
        for textureName in textureAtlas.textureNames {
            tempSpritesArray.append(textureAtlas.textureNamed(textureName as! String))
        }
        
        self.explosionAnimation = SKAction.group([
            SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false),
            SKAction.animateWithTextures(tempSpritesArray, timePerFrame: 0.1)]);
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func explode() {
        self.runAction(self.explosionAnimation, completion: {
            self.removeFromParent();
        })
    }
}
