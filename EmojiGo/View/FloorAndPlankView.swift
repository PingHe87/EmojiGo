//
//  FloorAndPlankView.swift
//  EmojiGo
//
//  Created by p h on 12/15/24.
//

import SceneKit
import ARKit

class FloorAndPlankView {
    private let sceneView: ARSCNView
    var isPlankOnScreen = false
    private var hasAddedInitialFloors = false // 标志位，防止重复添加地板
    private var plankTimer: Timer? // 定时器属性

    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }

    // 启动木板刷新定时器，每3秒触发一次
        func startPlankRefreshTimer() {
            plankTimer?.invalidate() // 确保之前的定时器被清理
            plankTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.addPlank()
            }
        }
    
    func createFloor(at position: SCNVector3) -> SCNNode {
        let floor = SCNPlane(width: 1.0, height: 1.0)
        floor.firstMaterial?.diffuse.contents = UIImage(named: "floorTexture") ?? UIColor.gray
        floor.firstMaterial?.isDoubleSided = true

        let floorNode = SCNNode(geometry: floor)
        floorNode.eulerAngles.x = -.pi / 2
        floorNode.position = position
        floorNode.name = "floor"
        return floorNode
    }

    func addInitialFloors() {
        guard !hasAddedInitialFloors else { return }
        for i in 0..<5 {
            let floorNode = createFloor(at: SCNVector3(0, -0.5, Float(i) * -1.0))
            sceneView.scene.rootNode.addChildNode(floorNode)
        }
        hasAddedInitialFloors = true
    }

    // 添加木板
    func addPlank() {
        guard !isPlankOnScreen else { return }

        // 创建木板
        let plank = SCNBox(width: 0.5, height: 0.3, length: 0.02, chamferRadius: 0.0)
        plank.firstMaterial?.diffuse.contents = UIImage(named: "woodTexture")

        let plankNode = SCNNode(geometry: plank)
        plankNode.position = SCNVector3(0, -0.35, -3.0) // 确定木板位置
        plankNode.name = "plank"

        // 同步添加表情
        let emojiTextures = ["fear", "happy", "surprise"] // 表情列表
        if let randomEmoji = emojiTextures.randomElement(), let emojiImage = UIImage(named: randomEmoji) {
            let emojiPlane = SCNPlane(width: 0.3, height: 0.2)
            emojiPlane.firstMaterial?.diffuse.contents = emojiImage

            let emojiNode = SCNNode(geometry: emojiPlane)
            emojiNode.position = SCNVector3(0, 0, 0.03) // 表情节点位置
            plankNode.addChildNode(emojiNode)

            // 更新 GameModel 中的当前表情
            GameModel.shared.currentPlankEmoji = randomEmoji
            GameModel.shared.hasScoredOnCurrentPlank = false
        } else {
            print("Failed to load emoji image.") // 防止图片未找到
        }

        // 将木板添加到场景中
        sceneView.scene.rootNode.addChildNode(plankNode)
        isPlankOnScreen = true
    }


    
    func stopPlankRefreshTimer() {
           plankTimer?.invalidate()
           plankTimer = nil
       }

    func slideFloorsAndPlanks() {
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "floor" || node.name == "plank" {
                node.position.z += 0.036

                // 如果地板或木板滑出视野
                if node.position.z > 1.0 {
                    // 对木板进行判定
                    if node.name == "plank" {
                        if !GameModel.shared.hasScoredOnCurrentPlank {
                            print("Plank missed without scoring.")
                            GameModel.shared.playFailureSound() // 播放失败音效
                        }
                        isPlankOnScreen = false // 标记木板移除
                    }
                    node.removeFromParentNode()

                    // 为滑出的地板添加新的地板
                    if node.name == "floor" {
                        let newFloor = createFloor(at: SCNVector3(0, -0.5, -4.5)) // 新地板位置
                        sceneView.scene.rootNode.addChildNode(newFloor)
                    }
                }
            }
        }
    }


}

