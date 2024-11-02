//
//  TitleScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/28.
//

import SpriteKit
import AVFoundation
import GameKit

class TitleScene: SKScene {
    
    var audioPlayer: AVAudioPlayer?
    var startButton: SKShapeNode!
    var howToPlayButton: SKShapeNode!
    var returnButtonBg: SKShapeNode!
    var title: SKSpriteNode!
    let titleLabel = SKLabelNode(text: "しょうゆ取ってゲーム")
    var howToPlayDialog: SKSpriteNode?
    
    // GameCenterの認証
    func authenticateLocalPlayer() {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Game Center のログイン画面を表示
                if let presentingVC = self.view?.window?.rootViewController {
                    presentingVC.present(viewController, animated: true, completion: nil)
                }
            } else if player.isAuthenticated {
                print("GameCenter認証OK: \(player.displayName)")
            } else {
                print("GameCenter認証NG: \(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    override func didMove(to view: SKView) {
        // GameCenter認証
        print("GameCenter認証START")
        authenticateLocalPlayer()
        print("GameCenter認証END")
        
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
        let startButtonSize = CGSize(width: 250, height: 90)
        startButton = SKShapeNode(rectOf: startButtonSize, cornerRadius: 10)
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
        
        // 遊び方ボタン
        let howToPlayButtonSize = CGSize(width: 250, height: 90)
        howToPlayButton = SKShapeNode(rectOf: howToPlayButtonSize, cornerRadius: 10)
        howToPlayButton.fillColor = SKColor.white
        howToPlayButton.strokeColor = SKColor.black
        howToPlayButton.lineWidth = 1
        howToPlayButton.zPosition = 1
        howToPlayButton.position = CGPoint(x: frame.midX, y: frame.midY - 300)
        addChild(howToPlayButton)
        let howToPlayButtonLabel = SKLabelNode(text: "遊び方")
        howToPlayButtonLabel.position = CGPoint(x: frame.midX, y: frame.midY - 320)
        howToPlayButtonLabel.fontSize = 60
        howToPlayButtonLabel.fontColor = SKColor.black
        howToPlayButtonLabel.zPosition = 1
        addChild(howToPlayButtonLabel)
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
        
        if (!isPaused) {
            // ゲーム画面に遷移
            if startButton.contains(location) {
                let gameScene = GameScene(size: self.size)
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(gameScene, transition: transition)
            }
            // 遊び方を表示
            if howToPlayButton.contains(location) {
                showHowToPlayDialog()
            }
        }
        
        // 遊び方サブウインドウの戻るボタン
        if let dialog = howToPlayDialog, dialog.contains(location) {
            let nodesAtPoint = nodes(at: location)
            for node in nodesAtPoint {
                if node.name == "returnButton" {
                    closeHowToPlayDialog()
                    break
                }
            }
        }
    }
    
    // 遊び方ダイアログ
    func showHowToPlayDialog() {
        isPaused = true
        
        let howToPlayDialogObject = createObject(textureName: "board", size: CGSize(width: 600, height: 1100), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: 100, isAddChild: false)
        
        let titleLabel = SKLabelNode(text: "遊び方")
        titleLabel.position = CGPoint(x: 0, y: 415)
        titleLabel.zPosition = 101
        titleLabel.fontColor = SKColor.black
        titleLabel.fontSize = 50
        howToPlayDialogObject.addChild(titleLabel)
        
        let howToPlayObject = createObject(textureName: "howToPlayImage", size: CGSize(width: 500, height: 750), position: CGPoint(x: 0, y: 0), zPosition: 101, isAddChild: false)
        howToPlayDialogObject.addChild(howToPlayObject)
        
        let buttonSize = CGSize(width: 160, height: 70)
        returnButtonBg = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        returnButtonBg.fillColor = SKColor.white
        returnButtonBg.strokeColor = SKColor.black
        returnButtonBg.lineWidth = 1
        returnButtonBg.zPosition = 101
        returnButtonBg.position = CGPoint(x: 0, y: -440)
        howToPlayDialogObject.addChild(returnButtonBg)
        let returnButton = SKLabelNode(text: "戻る")
        returnButton.position = CGPoint(x: 0, y: -460)
        returnButton.zPosition = 101
        returnButton.fontColor = SKColor.black
        returnButton.fontSize = 50
        returnButton.name = "returnButton"
        howToPlayDialogObject.addChild(returnButton)
        
        addChild(howToPlayDialogObject)
        howToPlayDialog = howToPlayDialogObject
    }
    
    func closeHowToPlayDialog() {
        // ダイアログを削除
        howToPlayDialog?.removeFromParent()
        howToPlayDialog = nil
        
        // ゲームの挙動を再開
        isPaused = false
    }
    
    func createObject(textureName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, isAddChild: Bool = true) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName)
        let spriteNode = SKSpriteNode(texture: texture, size: size)
        spriteNode.position = position
        spriteNode.zPosition = zPosition
        if isAddChild { addChild(spriteNode) }
        return spriteNode
    }
}
