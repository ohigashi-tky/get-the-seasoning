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
        authenticateLocalPlayer()
        
        playBackgroundMusic()
        
        self.scaleMode = .aspectFill
        
        setupTitleLabel()
        
        // 背景
        let titleTexture = SKTexture(imageNamed: "title")
        title = SKSpriteNode(texture: titleTexture, size: CGSize(width: 750, height: 1334))
        title.position = CGPoint(x: frame.midX, y: frame.midY)
        title.zPosition = -2
        addChild(title)

        createButton(
            buttonName: "level1Button"
            , buttonLabel: "初級"
            , buttonSize: CGSize(width: 250, height: 90)
            , buttonPosition: CGPoint(x: frame.midX, y: frame.midY - 60)
            , buttonLabelPosition: CGPoint(x: frame.midX, y: frame.midY - 80)
            , fontSize: 60
        )

        createButton(
              buttonName: "level2Button"
            , buttonLabel: "中級"
            , buttonSize: CGSize(width: 250, height: 90)
            , buttonPosition: CGPoint(x: frame.midX, y: frame.midY - 180)
            , buttonLabelPosition: CGPoint(x: frame.midX, y: frame.midY - 200)
            , fontSize: 60
        )

        createButton(
              buttonName: "howToPlayButton"
            , buttonLabel: "遊び方"
            , buttonSize: CGSize(width: 250, height: 90)
            , buttonPosition: CGPoint(x: frame.midX, y: frame.midY - 300)
            , buttonLabelPosition: CGPoint(x: frame.midX, y: frame.midY - 320)
            , fontSize: 60
        )
    }
    
    func createButton (buttonName: String, buttonLabel: String, buttonSize: CGSize, buttonPosition: CGPoint, buttonLabelPosition: CGPoint, fontSize: CGFloat) {
        let button = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        button.fillColor = SKColor.white
        button.strokeColor = SKColor.black
        button.lineWidth = 1
        button.zPosition = 1
        button.position = buttonPosition
        button.name = buttonName
        addChild(button)
        let buttonLabel = SKLabelNode(text: buttonLabel)
        buttonLabel.position = buttonLabelPosition
        buttonLabel.fontSize = fontSize
        buttonLabel.fontColor = SKColor.black
        buttonLabel.zPosition = 1
        addChild(buttonLabel)
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
            let nodesAtPoint = nodes(at: location)
            for node in nodesAtPoint {
                if node.name == "level1Button" {
                    let gameScene = GameScene(size: self.size, level: 1)
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameScene, transition: transition)
                } else if node.name == "level2Button" {
                    let gameScene = GameScene(size: self.size, level: 2)
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameScene, transition: transition)
                } else if node.name == "howToPlayButton" {
                    showHowToPlayDialog()
                }
            }
        }
        
        // 遊び方サブウインドウの戻るボタン
        if let dialog = howToPlayDialog, dialog.contains(location) {
            let nodesAtPointSub = nodes(at: location)
            for node in nodesAtPointSub {
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
        let buttonBg = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        buttonBg.fillColor = SKColor.white
        buttonBg.strokeColor = SKColor.black
        buttonBg.lineWidth = 1
        buttonBg.zPosition = 101
        buttonBg.position = CGPoint(x: 0, y: -440)
        howToPlayDialogObject.addChild(buttonBg)
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
