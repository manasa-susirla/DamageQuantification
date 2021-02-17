//
//  RoundButton.swift
//
//  Created by Vaibhav, Trijala, Manasa, Sanjay - 12/01/2020
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refresh()
    }
    
    override func prepareForInterfaceBuilder() {
        refresh()
    }
    
    func refresh() {
        refreshCorners(value: cornerRadius)
        refreshLineColour(value: lineColour)
        
    }
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    @IBInspectable var lineColour: UIColor = UIColor.black {
        didSet {
            refreshLineColour(value: lineColour)
        }
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    func refreshLineColour(value: UIColor) {
        layer.borderColor = value.cgColor
        layer.borderWidth = 1
    }
    override var intrinsicContentSize: CGSize {
           get {
               let baseSize = super.intrinsicContentSize
               return CGSize(width: baseSize.width + 40,//ex: padding 20
                             height: baseSize.height)
               }
        }
}
