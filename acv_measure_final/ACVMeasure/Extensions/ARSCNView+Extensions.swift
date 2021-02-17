//
//  ARSCNView+Extensions.swift
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import Foundation
import ARKit

extension ARSCNView{
    
    
    /// Adds A Ripple Effect To An ARSCNView
    func rippleView(){
        
        let animation = CATransition()
        animation.duration = 1.75
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = "rippleEffect"
        self.layer.add(animation, forKey: nil)
       
    }
}
