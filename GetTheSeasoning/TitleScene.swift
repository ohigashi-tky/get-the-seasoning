//
//  TitleScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/28.
//

import SpriteKit
import AVFoundation

class TitleScene: SKScene {
    
    var audioPlayer: AVAudioPlayer?
    var startButton: SKShapeNode!
    
    override func didMove(to view: SKView) {
        playBackgroundMusic()
        
        self.scaleMode = .aspectFill
        
        // スタートボタン TODO:外部関数化
        let buttonSize = CGSize(width: 250, height: 90)
        startButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 5)
        startButton.fillColor = SKColor.white
        startButton.strokeColor = SKColor.black
        startButton.lineWidth = 2
        startButton.zPosition = 1
        startButton.position = CGPoint(x: frame.midX, y: frame.midY - 180)
        addChild(startButton)
        let startButtonLabel = SKLabelNode(text: "スタート")
        startButtonLabel.position = CGPoint(x: frame.midX, y: frame.midY - 200)
        startButtonLabel.fontSize = 60
        startButtonLabel.fontColor = SKColor.black
        startButtonLabel.zPosition = 1
        addChild(startButtonLabel)
    }
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else {
            print("BGM file not exist")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // -1:無限ループ
            audioPlayer?.volume = 0.1
            audioPlayer?.play()
        } catch {
            print("error Playing BGM: \(error.localizedDescription)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // スタートボタン押下時、ゲーム画面に遷移
        if startButton.contains(location) {
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
