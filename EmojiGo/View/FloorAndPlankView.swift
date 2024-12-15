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
    private var isPlankOnScreen = false
    private var hasAddedInitialFloors = false // 标志位，防止重复添加地板

    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
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

    func addPlank() {
        guard !isPlankOnScreen else { return }

        let plank = SCNBox(width: 0.5, height: 0.3, length: 0.02, chamferRadius: 0.0)
        plank.firstMaterial?.diffuse.contents = UIImage(named: "woodTexture")

        let plankNode = SCNNode(geometry: plank)
        plankNode.position = SCNVector3(0, -0.35, -3.0)
        plankNode.name = "plank"

        let emojiTextures = ["anger", "contempt", "fear", "happy", "surprise"]
        if let randomEmoji = emojiTextures.randomElement(), let emojiImage = UIImage(named: randomEmoji) {
            let emojiPlane = SCNPlane(width: 0.3, height: 0.2)
            emojiPlane.firstMaterial?.diffuse.contents = emojiImage

            let emojiNode = SCNNode(geometry: emojiPlane)
            emojiNode.position = SCNVector3(0, 0, 0.03)
            plankNode.addChildNode(emojiNode)

            // 设置当前木板表情到 GameModel
            GameModel.shared.currentPlankEmoji = randomEmoji
        }

        sceneView.scene.rootNode.addChildNode(plankNode)
        isPlankOnScreen = true
    }

    func slideFloorsAndPlanks() {
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "floor" || node.name == "plank" {
                node.position.z += 0.036

                // 如果地板滑出视野，则移除并添加新地板
                if node.position.z > 1.0 {
                    node.removeFromParentNode()
                    if node.name == "plank" {
                        isPlankOnScreen = false
                    } else if node.name == "floor" {
                        let newFloor = createFloor(at: SCNVector3(0, -0.5, -4.5)) // 新地板位置在前方
                        sceneView.scene.rootNode.addChildNode(newFloor)
                    }
                }
            }
        }
    }

}

