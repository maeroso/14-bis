//
//  GameOverScene.swift
//  14Bis
//
//  Created by Alvaro Rechetelo on 31/05/15.
//  
//

import SpriteKit

class GameOverScene: SKScene {
    var pontos : Int!;
    
    override func didMoveToView(view: SKView) {
        var bestScore : String!
        
        let file = "pontuacao.txt"
        
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingPathComponent(file);
            let pontosDoArquivo = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
            if(pontosDoArquivo != nil){
                var pontuacao = pontosDoArquivo!.toInt()
                if(pontuacao < pontos ){
                    let text = "\(pontos)"
                    text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
                    bestScore = "\(pontos)"
                }
                else{
                    bestScore = pontosDoArquivo
                }
            }
            else {
                let text = "\(pontos)"
                text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            }
            
            let lastScoreLabel = self.childNodeWithName("lastScoreLabel") as! SKLabelNode;
            lastScoreLabel.text = "\(pontos)"
            
            let bestScoreLabel = self.childNodeWithName("bestScoreLabel") as! SKLabelNode;
            bestScoreLabel.text = "\(bestScore)"
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location: CGPoint = touch.locationInNode(self);
            let node = self.nodeAtPoint(location);
            
            if node.name == "tryAgainButton" {
                let reveal = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 0.5)
                let gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
                self.view?.presentScene(gameScene, transition: reveal)
            }
        }
    }
}
