//
//  MeasuringLineNode.swift
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import Foundation
import ARKit

class MeasuringLineNode: SCNNode{
    
    init(startingVector vectorA: GLKVector3, endingVector vectorB: GLKVector3) {
        super.init()
        
        let height = CGFloat(GLKVector3Distance(vectorA, vectorB))
        
        self.position = SCNVector3(vectorA.x, vectorA.y, vectorA.z)
        
        let nodeVectorTwo = SCNNode()
        nodeVectorTwo.position = SCNVector3(vectorB.x, vectorB.y, vectorB.z)
        
        let nodeZAlign = SCNNode()
        nodeZAlign.eulerAngles.x = Float.pi/2
        
        let box = SCNBox(width: 0.002, height: height, length: 0.001, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.orange
        box.materials = [material]
        
        let nodeLine = SCNNode(geometry: box)
        nodeLine.position.y = Float(-height/2)
        nodeZAlign.addChildNode(nodeLine)
        
        self.addChildNode(nodeZAlign)
        
        self.constraints = [SCNLookAtConstraint(target: nodeVectorTwo)]
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
