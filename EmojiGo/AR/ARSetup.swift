//
//  ARSetup.swift
//  EmojiGo
//
//  Created by p h on 12/15/24.
//

import ARKit

class ARSetup {
    private var sceneView: ARSCNView

    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        setupARSession()
    }

    func setupARSession() {
        print("AR session started successfully")

        guard ARFaceTrackingConfiguration.isSupported else {
            print("AR Face Tracking is not supported.")
            return
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
    }


    func restartSession() {
        sceneView.session.pause()
        setupARSession()
    }

    func stopSession() {
        sceneView.session.pause()
    }
}
