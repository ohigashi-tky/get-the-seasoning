//
//  GameViewController.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/23.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {

    // 広告
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GKScene(fileNamed: "TitleScene") {
            if let sceneNode = scene.rootNode as! TitleScene? {
                sceneNode.scaleMode = .aspectFill
                
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                }
            }
        }
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        
        addBannerViewToView(bannerView)
        
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.adUnitID = "ca-app-pub-2702984873601788/7790379231"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        // バナーを画面の下部に配置
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // 画面の向き
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
