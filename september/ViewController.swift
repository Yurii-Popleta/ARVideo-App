//
//  ViewController.swift
//  september
//
//  Created by Admin on 23/09/2022.


import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var videoLooper: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
            
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "September", bundle: Bundle.main) {
            
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            
        }
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
           
           let node = SCNNode()
           
        if let imageAnchor = anchor as? ARImageAnchor {
            
            guard let url = Bundle.main.url(forResource: "september", withExtension: "MP4") else { return nil }
            
            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
                videoLooper = AVPlayerLooper(player: player, templateItem: item)
            
                let videoNode = SKVideoNode(avPlayer: player)
                let videoScene = SKScene(size: CGSize(width: 2160, height: 2160))
                    videoScene.addChild(videoNode)
                    videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                    videoNode.yScale = -1.0
                    videoNode.play()
                            
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                
                plane.firstMaterial?.diffuse.contents = videoScene
                
                let planeNode = SCNNode(geometry: plane)
                
                planeNode.eulerAngles.x = -Float.pi / 2
                
                node.addChildNode(planeNode)
                

        }
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if node.isHidden == true {
            if let imageAnchor = anchor as? ARImageAnchor {
                sceneView.session.remove(anchor: imageAnchor)
            }
        }
    }
}
