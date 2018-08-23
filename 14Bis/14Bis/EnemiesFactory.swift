//
//  EnemiesFactory.swift
//  14Bis
//
//  Created by Matheus Aeroso on 31/05/15.
//  
//

import Foundation;
import SpriteKit;

public class EnemiesFactory {
    static let sharedInstance = EnemiesFactory()
    private var possiblePositions: [CGFloat];
    private var possibleColors: [String];
    private let fallingPoint: CGFloat = 720;
    
    init() {
        self.possiblePositions = [84, 158, 232, 316]
        self.possibleColors = ["blue", "green", "white", "yellow"]
    }
    
    func generateEnemy() -> Enemy {
        let positionDrawn = Int(arc4random() % 4);
        let colorDrawn = Int(arc4random() % 4);
        
        let enemy: Enemy = Enemy(imageNamed: self.possibleColors[colorDrawn], position: CGPoint(x: self.possiblePositions[positionDrawn], y: fallingPoint));
        
        return enemy;
    }
    
}
