//
//  MarkerNode.swift
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import UIKit
import ARKit

class MarkerNode: SCNNode {

    /// Creates A Spherical Marker Node From A matrix_float4x4
    ///
    /// - Parameter matrix: matrix_float4x4
    init(fromMatrix matrix: matrix_float4x4 ) {
        
        super.init()
        
        //1. Convert The 3rd Column Values To Float
        let x = matrix.columns.3.x
        let y = matrix.columns.3.y
        let z = matrix.columns.3.z
        
        //2. Create A Marker Node At The Detected Matrixes Position
        let markerNodeGeometry = SCNSphere(radius: 0.003)
        markerNodeGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        self.geometry = markerNodeGeometry
        self.position = SCNVector3(x, y, z)
        
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Coder Not Implemented") }

}
