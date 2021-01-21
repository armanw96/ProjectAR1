//
//  ViewController.swift
//  Project 3
//
//  Created by Arman Wirawan on 1/13/21.
//

import UIKit
import RealityKit
import ARKit


class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap (recognizer: ))))
        
    }
    //MARK: - Setting up ARView right here.
    
    func setupARView() {
        
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
        
    }
    
    //MARK: - Tap gesture recognizer
    //ray casting is like a laser pointer a virtual laser to see if its intersecting with any surface that we recognize.
    
    @objc func handleTap(recognizer: UITapGestureRecognizer ) {
        //getting the location in arView
        let location = recognizer.location(in: arView)
        
        
        //using raycast if its intersecting with real life world surfaces.
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        
        // this is to show whether or not you actually hit anything horizontal so that we know the raycast work and can set our model somewhere int he real world.
        
        if let firstResult = results.first {
            //if we have a result that mean we actually fi=ound a horizontal scene
            
            // we have to add ojects to anchors so that we can show it up in the ARView otherwise it won't work you have to attach it to the anchor.
            
            // the world transform includes the location and the way it is laid out.
            
            let anchor = ARAnchor(name: "toy_robot_vintage" , transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            
        } else {
            print("hey we could not found a surface object placement fail")
            
        }
        
    }
    
    func placeObject(named anchorName: String, for anchor: ARAnchor) {
        //we know that there's amodel here or do a do catch block
        
        let entity = try! ModelEntity.loadModel(named: anchorName)
        
        // creating gesture
        
        entity.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.rotation, .translation], for: entity)
        // now that we have our model we want to add it to our anchor entity and then our anchor entity is added to our scene because its anchor type.
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        
        anchorEntity.addChild(entity)
        
        arView.scene.addAnchor(anchorEntity)
        
        
        
        
        
    }
    
    
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "toy_robot_vintage"{
                // this placeObject is a function that you have to create first so that you know if the anchor name is contemporaryFan then it would attach it sel fto the scene through this extentoin delegate so that it would show on the AR.


                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
