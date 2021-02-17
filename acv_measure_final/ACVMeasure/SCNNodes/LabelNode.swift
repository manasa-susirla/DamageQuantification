//
//  LabelNode.swift
//  ACV
//
//  Created by Sanjay Khan on 10/8/20.
//

import ARKit
import Foundation
import SceneKit
import UIKit

final class LabelNode: SCNNode {
    static let sceneSize = CGSize(width: 300, height: 150)
    // Plane size used real world unit = Meters
    static let planeSize: (width: CGFloat, height: CGFloat) = (width: 0.048, height: 0.020)

//    override init() {
//        super.init()
//    }

    init(_ text: String, textColor _: UIColor) {
        super.init()

        let skScene = SKScene(size: LabelNode.sceneSize)
        skScene.backgroundColor = UIColor.clear

        let rectangle = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: LabelNode.sceneSize), cornerRadius: LabelNode.sceneSize.height / 2)
        rectangle.fillColor = UIColor.orange
        rectangle.lineWidth = 0
        skScene.addChild(rectangle)

        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 52
        labelNode.fontName = "AvenirNext-Bold"
        labelNode.fontColor = .black
        labelNode.position = CGPoint(x: LabelNode.sceneSize.width / 2, y: LabelNode.sceneSize.height / 2 - 8)
        skScene.addChild(labelNode)

        let plane = SCNPlane(width: LabelNode.planeSize.width, height: LabelNode.planeSize.height)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        node.position = position

        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y, .Z]
        node.constraints = [billboardConstraint]

        addChildNode(node)
    }
    
    func placeBetweenNodesLabel(_ nodeA: SCNNode, and nodeB: SCNNode){

        let minPosition = nodeA.position
        let maxPosition = nodeB.position
        let x = ((maxPosition.x + minPosition.x)/2.0)
        let y = (maxPosition.y + minPosition.y)/2.0 + 0.01
        let z = (maxPosition.z + minPosition.z)/2.0
        self.position =  SCNVector3(x, y, z)
        
//        let centerPoint = SCNVector3(x, y, z)
//        let currentCameraPosition = view.pointOfView!
//
//        let distanceBetweenNodeAndCamera = centerPoint.distance(from: currentCameraPosition.worldPosition)
//        let delta = Float(distanceBetweenNodeAndCamera * 3.5)
//
//
//        let distanceBetweenNodeAndCamera = centerPoint.distance(from: currentCameraPosition.worldPosition)
        

        
//        let dx = (startPoint.x + endPoint.x) / 2.0
//        let dy = (startPoint.y + endPoint.y) / 2.0
//        let dz = (startPoint.z + endPoint.z) / 2.0
//
//        let centerPoint = SCNVector3(dx, dy, dz)
        
       // let distanceBetweenNodeAndCamera = centerPoint.distance(from: currPosition.worldPosition)
      //  let delta = Float(distanceBetweenNodeAndCamera * 3.5)
        
//        self.position = SCNVector3(delta, delta, delta)
        
//        let distanceText = updateResultLabel(startPoint.distance(from: endPoint))
//        label = LabelNode(distanceText, position: centerPoint, backgroundColor: shapeColor, textColor: textColor)
        
//        sceneView.scene.rootNode.addChildNode(label)
//        label.childNodes.forEach { (node) in
//            node.simdScale = simd_float3(delta, delta, delta)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   

    //-----------------------
    //MARK: Pivot Positioning
    //-----------------------

    /// Sets The Pivot Of The TextNode
    ///
    /// - Parameter alignment: PivotAlignment
//    func setTextAlignment(_ alignment: PivotAlignment){
//
//        //1. Get The Bounding Box Of The TextNode
//        let min = self.boundingBox.min
//        let max = self.boundingBox.max
//
//        switch alignment {
//
//        case .Left:
//            self.pivot = SCNMatrix4MakeTranslation(
//                min.x,
//                min.y + (max.y - min.y)/2,
//                min.z + (max.z - min.z)/2
//            )
//        case .Right:
//            self.pivot = SCNMatrix4MakeTranslation(
//                max.x,
//                min.y + (max.y - min.y)/2,
//                min.z + (max.z - min.z)/2
//            )
//        case .Center:
//            self.pivot = SCNMatrix4MakeTranslation(
//                min.x + (max.x - min.x)/2,
//                min.y + (max.y - min.y)/2,
//                min.z + (max.z - min.z)/2
//            )
//        }
////
    }
extension SCNVector3: Equatable {
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func distance(from vector: SCNVector3) -> CGFloat {
        let dx = x - vector.x
        let dy = y - vector.y
        let dz = z - vector.z
        
        return CGFloat(sqrt(dx * dx + dy * dy + dz * dz))
    }
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

extension ARSCNView {
    func realWorldVector(screenPos: CGPoint) -> SCNVector3? {
        let planeTestResults = hitTest(screenPos, types: [.featurePoint])
        if let result = planeTestResults.first {
            return SCNVector3.positionFromTransform(result.worldTransform)
        }
        
        return nil
    }
}
