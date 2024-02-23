//
//  GameView.swift
//  Swift Challenger
//
//  Created by 64005831 on 2/12/24.
//
import ARKit
import SwiftUI
import RealityKit
import Combine

class GameView: ARView, ARSessionDelegate {
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    lazy var carAnchor: AnchorEntity = {
        let anchor = AnchorEntity(world: .zero)
        scene.addAnchor(anchor)
        return anchor
    }()

    var gameState = GameState()

    var arView: ARView { return self }
    var cancellables = [AnyCancellable]()
    
    var placedCar = false
    var loadedGhostCar = false
    
    lazy var ghostAnchor: AnchorEntity = {
        let anchor = AnchorEntity(world: .zero)
        scene.addAnchor(anchor)
        return anchor
    }()
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if gameState.moveForward == true {
            gameState.z = 0.025 * gameState.speed
        }
        
        if gameState.moveBackward == true {
            gameState.z = -0.025 * gameState.speed
        }
        
        if gameState.moveRight == true {
            gameState.r = .pi/(-8)
        }
        
        if gameState.moveLeft == true {
            gameState.r = .pi/8
        }
        
        if gameState.big == true {
            gameState.size += 0.05
        }
        
        if gameState.small == true {
            gameState.size -= 0.05
        }
                
        //moves car every frame
        let transform = Transform(scale: gameState.size, rotation: simd_quatf(angle: gameState.r, axis: [0,1,0]), translation: [0, 0, gameState.z])
        carAnchor.move(to: transform, relativeTo: carAnchor, duration: 0.1, timingFunction: .easeInOut)
        
        gameState.z = 0
        gameState.r = 0
        gameState.size = .one
        
        
        // handle moving ghost entity to center of screen every frame update
        let center = arView.center
        let hitTest = arView.hitTest(center, types: .existingPlaneUsingExtent)
        if placedCar == false && loadedGhostCar == true {
            if !hitTest.isEmpty {
                if let centerPoint = hitTest.first?.worldTransform.translation {
                    ghostAnchor.setPosition(centerPoint, relativeTo: nil)
                }
            }
        }
        
        //print("car anchor position: \(carAnchor.transform.translation)")
    }
    
    func setup() {
        configureWorldTracking()
        loadGhostCar()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(singleTap)
    }
    
    func loadGhostCar() {
        do {
            let entity = try Entity.loadModel(named: "Go_Kart")
            entity.transform.scale = SIMD3<Float>(repeating: 0.0001)
            let bounds = entity.visualBounds(recursive: true, relativeTo: nil, excludeInactive: false)
            let shapes: ShapeResource = ShapeResource.generateCapsule(
                height: bounds.extents.y,
                radius: 33 * bounds.boundingRadius)
                .offsetBy(translation: [0, 5, 0])
            let collision = CollisionComponent(shapes: [shapes], mode: .trigger, filter: .sensor)
            entity.components.set(collision)
            entity.name = "Ghost"
            ghostAnchor.addChild(entity)
            loadedGhostCar = true
        } catch {
            return
        }
    }
    
    @objc
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if placedCar == false {
            if let centerPoint = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any).first {
                let centerAnchorPoint = centerPoint.worldTransform.translation
                
                do {
                    let entity = try Entity.loadModel(named: "Go_Kart")
                    entity.transform.scale = SIMD3<Float>(repeating: 0.0001)
                    
                    
                    // set custom collision box
                    carAnchor.position = centerAnchorPoint
                    let bounds = entity.visualBounds(recursive: true, relativeTo: nil, excludeInactive: false)
                    let shapes: ShapeResource = ShapeResource.generateCapsule(
                        height: bounds.extents.y,
                        radius: 33 * bounds.boundingRadius)
                        .offsetBy(translation: [0, 5, 0])
                    let collision = CollisionComponent(shapes: [shapes], mode: .trigger, filter: .sensor)
                    entity.components.set(collision)
                    carAnchor.addChild(entity)
                    placedCar = true
                    // remove ghost car
                    if let ghostEntity = arView.scene.findEntity(named: "Ghost") {
                        ghostEntity.removeFromParent()
                    }
                } catch {
                    return
                }
            }
        }
    }
    
    private func configureWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection.insert(.horizontal)
        session.run(configuration)
        defer { session.delegate = self }
        
        arView.renderOptions.insert(.disableMotionBlur)
        arView.environment.sceneUnderstanding.options.insert([.collision, .physics, .receivesLighting, .occlusion])
    }
    
}
