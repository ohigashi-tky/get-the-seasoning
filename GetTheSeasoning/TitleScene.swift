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
    var title: SKSpriteNode!
    let titleLabel = SKLabelNode(text: "しょうゆ取ってゲーム")
    
    override func didMove(to view: SKView) {
        playBackgroundMusic()
        
        self.scaleMode = .aspectFill
        
        setupTitleLabel()
        
        // 背景
        let titleTexture = SKTexture(imageNamed: "title")
        title = SKSpriteNode(texture: titleTexture, size: CGSize(width: 750, height: 1334))
        title.position = CGPoint(x: frame.midX, y: frame.midY)
        title.zPosition = -2
        addChild(title)
        
        // スタートボタン
        let buttonSize = CGSize(width: 250, height: 90)
        startButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        startButton.fillColor = SKColor.white
        startButton.strokeColor = SKColor.black
        startButton.lineWidth = 1
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
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.1
            audioPlayer?.play()
        } catch {
            print("error Playing BGM: \(error.localizedDescription)")
        }
    }
    
    func setupTitleLabel() {
        titleLabel.fontName = "HiraMinProN-W6"
        titleLabel.fontSize = 60
        titleLabel.fontColor = SKColor.black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        titleLabel.zPosition = 1
        addChild(titleLabel)
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
