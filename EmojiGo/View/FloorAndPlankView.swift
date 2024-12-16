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
    private var hasAddedInitialFloors = false // // Flag to prevent duplicate addition of floors
    private var plankTimer: Timer?
    var isGameRunning = true

    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }

    // Start the plank refresh timer, triggered every 3 seconds
        func startPlankRefreshTimer() {
            plankTimer?.invalidate() // Ensure the previous timer is cleared
            plankTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
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

    // Add a plank
    func addPlank() {
        guard !isPlankOnScreen else { return }

        // Create a plank
        let plank = SCNBox(width: 0.5, height: 0.3, length: 0.02, chamferRadius: 0.0)
        plank.firstMaterial?.diffuse.contents = UIImage(named: "woodTexture")

        let plankNode = SCNNode(geometry: plank)
        plankNode.position = SCNVector3(0, -0.35, -3.0) // Set plank position
        plankNode.name = "plank"

        // Add emoji synchronously
        let emojiTextures = ["fear", "happy", "surprise"] // Emoji list
        if let randomEmoji = emojiTextures.randomElement(), let emojiImage = UIImage(named: randomEmoji) {
            let emojiPlane = SCNPlane(width: 0.3, height: 0.2)
            emojiPlane.firstMaterial?.diffuse.contents = emojiImage

            let emojiNode = SCNNode(geometry: emojiPlane)
            emojiNode.position = SCNVector3(0, 0, 0.03) // Set emoji node position
            plankNode.addChildNode(emojiNode)

            // Update the current emoji in GameModel
            GameModel.shared.currentPlankEmoji = randomEmoji
            GameModel.shared.hasScoredOnCurrentPlank = false
        } else {
            print("Failed to load emoji image.") // Prevent image not found
        }

        // Add the plank to the scene
        sceneView.scene.rootNode.addChildNode(plankNode)
        isPlankOnScreen = true
    }


    
    func stopPlankRefreshTimer() {
           plankTimer?.invalidate()
           plankTimer = nil
       }
    
    func stopGame() {
           // Stop the plank refresh timer
           stopPlankRefreshTimer()
           
           // Remove all floor and plank nodes
           for node in sceneView.scene.rootNode.childNodes {
               if node.name == "floor" || node.name == "plank" {
                   node.removeFromParentNode()
               }
           }

           // Reset state
           isPlankOnScreen = false
           hasAddedInitialFloors = false
           isGameRunning = false
       }

    func slideFloorsAndPlanks() {
        // Iterate through all nodes
        for node in sceneView.scene.rootNode.childNodes {
            // Check if the node is "floor" or "plank"
            if node.name == "floor" || node.name == "plank" {
                // Slide the node
                node.position.z += 0.036

                // Check if the node slides out of view
                if node.position.z > 1.0 {
                    
                    // Handle when the plank slides out of view
                    if node.name == "plank" {
                        if !GameModel.shared.hasScoredOnCurrentPlank {
                            print("Plank missed without scoring.")
                            GameModel.shared.playFailureSound() // Play failure sound
                        }
                        // Reset state
                        isPlankOnScreen = false
                        GameModel.shared.currentPlankEmoji = nil
                        GameModel.shared.hasScoredOnCurrentPlank = false
                    }

                    // Remove the node that slid out
                    node.removeFromParentNode()

                    // Regenerate a new floor for the removed floor
                    if node.name == "floor" {
                        let newFloor = createFloor(at: SCNVector3(0, -0.5, -4.5)) // New floor position
                        sceneView.scene.rootNode.addChildNode(newFloor)
                    }
                }
            }
        }
    }



}

