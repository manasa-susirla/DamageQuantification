//
//  TextNode.swift
//  Setup
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import Foundation
import SceneKit
import UIKit
import ARKit

class TextNode: SCNNode{
    

    enum PivotAlignment{

        case Left
        case Right
        case Center
    }
//
    var textGeometry: SCNText!

    /// Creates An SCNText Geometry
    ///
    /// - Parameters:
    ///   - text: String (The Text To Be Displayed)
    ///   - depth: Optional CGFloat (Defaults To 1)
    ///   - font: UIFont
    ///   - textSize: Optional CGFloat (Defaults To 3)
    ///   - colour: UIColor
    init(text: String, depth: CGFloat = 0, font: String = "Helvatica", textSize: CGFloat = 0.1, colour: UIColor) {

        super.init()

        //1. Create A Billboard Constraint So Our Text Always Faces The Camera
        let constraints = SCNBillboardConstraint()


        //2. Create An SCNNode To Hold Out Text
        let node = SCNNode()
        let max, min: SCNVector3
        let tx, ty, tz: Float

        //3. Set Our Free Axes
        constraints.freeAxes = [.X,.Y,.Z]

        //4. Create Our Text Geometry
        textGeometry = SCNText(string: text, extrusionDepth: depth)

        //5. Set The Flatness To Zero (This Makes The Text Look Smoother)
        textGeometry.flatness = 0

        //6. Set The Alignment Mode Of The Text
        textGeometry.alignmentMode = kCAAlignmentCenter

        //7. Set Our Text Colour & Apply The Font
        textGeometry.firstMaterial?.diffuse.contents = colour
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.font = UIFont(name: font, size: textSize)

        //8. Position & Scale Our Node
        max = textGeometry.boundingBox.max
        min = textGeometry.boundingBox.min

        tx = (max.x - min.x) / 2.0
        ty = min.y
        tz = Float(depth) / 2.0

        node.geometry = textGeometry
        node.scale = SCNVector3(0.001, 0.001, 0.001)
        node.pivot = SCNMatrix4MakeTranslation(tx, ty, tz)

        self.addChildNode(node)

        self.constraints = [constraints]

    }


    /// Places The TextNode Between Two SCNNodes
    ///
    /// - Parameters:
    ///   - nodeA: SCNode
    ///   - nodeB: SCNode
    func placeBetweenNodes(_ nodeA: SCNNode, and nodeB: SCNNode){

        let minPosition = nodeA.position
        let maxPosition = nodeB.position
        let x = ((maxPosition.x + minPosition.x)/2.0)
        let y = (maxPosition.y + minPosition.y)/2.0 + 0.01
        let z = (maxPosition.z + minPosition.z)/2.0
        self.position =  SCNVector3(x, y, z)
        
        
//        let centerPoint = SCNVector3(dx, dy, dz)
//        
//        let distanceBetweenNodeAndCamera = centerPoint.distance(from: pointOfView.worldPosition)
//        let delta = Float(distanceBetweenNodeAndCamera * 3.5)
//        
//        let distanceText = updateResultLabel(startPoint.distance(from: endPoint))
//        label = LabelNode(distanceText, position: centerPoint, backgroundColor: shapeColor, textColor: textColor)
//        
//        sceneView.scene.rootNode.addChildNode(label)
//        label.childNodes.forEach { (node) in
//            node.simdScale = simd_float3(delta, delta, delta)
    }

    //-----------------------
    //MARK: Pivot Positioning
    //-----------------------

    /// Sets The Pivot Of The TextNode
    ///
    /// - Parameter alignment: PivotAlignment
    func setTextAlignment(_ alignment: PivotAlignment){

        //1. Get The Bounding Box Of The TextNode
        let min = self.boundingBox.min
        let max = self.boundingBox.max

        switch alignment {

        case .Left:
            self.pivot = SCNMatrix4MakeTranslation(
                min.x,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        case .Right:
            self.pivot = SCNMatrix4MakeTranslation(
                max.x,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        case .Center:
            self.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
        }
//
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}




//import ARKit
//import Foundation
//import SceneKit
//import UIKit
//
//final class LabelNode: SCNNode {
//    static let sceneSize = CGSize(width: 240, height: 100)
//    // Plane size used real world unit = Meters
//    static let planeSize: (width: CGFloat, height: CGFloat) = (width: 0.048, height: 0.020)
//
//    override init() {
//        super.init()
//    }
//
//    init(_ text: String, position: SCNVector3, backgroundColor: UIColor, textColor _: UIColor) {
//        super.init()
//
//        let skScene = SKScene(size: LabelNode.sceneSize)
//        skScene.backgroundColor = UIColor.clear
//
//        let rectangle = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: LabelNode.sceneSize), cornerRadius: LabelNode.sceneSize.height / 2)
//        rectangle.fillColor = backgroundColor
//        rectangle.lineWidth = 0
//        skScene.addChild(rectangle)
//
//        let labelNode = SKLabelNode(text: text)
//        labelNode.fontSize = 32
//        labelNode.fontName = "AvenirNext-Bold"
//        labelNode.fontColor = .black
//        labelNode.position = CGPoint(x: LabelNode.sceneSize.width / 2, y: LabelNode.sceneSize.height / 2 - 8)
//        skScene.addChild(labelNode)
//
//        let plane = SCNPlane(width: LabelNode.planeSize.width, height: LabelNode.planeSize.height)
//        let material = SCNMaterial()
//        material.isDoubleSided = true
//        material.diffuse.contents = skScene
//        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
//        plane.materials = [material]
//
//        let node = SCNNode(geometry: plane)
//        node.position = position
//
//        let billboardConstraint = SCNBillboardConstraint()
//        billboardConstraint.freeAxes = [.X, .Y, .Z]
//        node.constraints = [billboardConstraint]
//
//        addChildNode(node)
//    }
//
//    required init?(coder _: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
