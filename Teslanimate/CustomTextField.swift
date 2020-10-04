//
//  CustomTextField.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-03-04.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import TextFieldEffects
import IBAnimatable

class CustomTextField: KaedeTextField, CornerDesignable, FillDesignable, BorderDesignable, RotationDesignable, ShadowDesignable, BlurDesignable, TintDesignable, GradientDesignable, MaskDesignable, Animatable {

    // MARK: - CornerDesignable
    @IBInspectable internal var cornerRadius: CGFloat = CGFloat.NaN {
        didSet {
            configCornerRadius()
        }
    }
    
    // MARK: - FillDesignable
    @IBInspectable internal var fillColor: UIColor? {
        didSet {
            configFillColor()
        }
    }
    
    @IBInspectable internal var predefinedColor: String? {
        didSet {
            configFillColor()
        }
    }
    
    @IBInspectable internal var opacity: CGFloat = CGFloat.NaN {
        didSet {
            configOpacity()
        }
    }
    
    // MARK: - BorderDesignable
    @IBInspectable internal var borderColor: UIColor? {
        didSet {
            configBorder()
        }
    }
    
    @IBInspectable internal var borderWidth: CGFloat = CGFloat.NaN {
        didSet {
            configBorder()
        }
    }
    
    @IBInspectable internal var borderSide: String? {
        didSet {
            configBorder()
        }
    }
    
    // MARK: - RotationDesignable
    @IBInspectable internal var rotate: CGFloat = CGFloat.NaN {
        didSet {
            configRotate()
        }
    }
    
    // MARK: - ShadowDesignable
    @IBInspectable internal var shadowColor: UIColor? {
        didSet {
            configShadowColor()
        }
    }
    
    @IBInspectable internal var shadowRadius: CGFloat = CGFloat.NaN {
        didSet {
            configShadowRadius()
        }
    }
    
    @IBInspectable internal var shadowOpacity: CGFloat = CGFloat.NaN {
        didSet {
            configShadowOpacity()
        }
    }
    
    @IBInspectable internal var shadowOffset: CGPoint = CGPoint(x: CGFloat.NaN, y: CGFloat.NaN) {
        didSet {
            configShadowOffset()
        }
    }
    
    // MARK: - BlurDesignable
    @IBInspectable internal var blurEffectStyle: String?
    @IBInspectable internal var blurOpacity: CGFloat = CGFloat.NaN
    
    // MARK: - TintDesignable
    @IBInspectable internal var tintOpacity: CGFloat = CGFloat.NaN
    @IBInspectable internal var shadeOpacity: CGFloat = CGFloat.NaN
    @IBInspectable internal var toneColor: UIColor?
    @IBInspectable internal var toneOpacity: CGFloat = CGFloat.NaN
    
    // MARK: - GradientDesignable
    @IBInspectable internal var startColor: UIColor?
    @IBInspectable internal var endColor: UIColor?
    @IBInspectable internal var predefinedGradient: String?
    @IBInspectable internal var startPoint: String?
    
    // MARK: - MaskDesignable
    @IBInspectable internal var maskType: String? {
        didSet {
            configMask()
            configBorder()
        }
    }
    
    // MARK: - Animatable
    @IBInspectable internal var animationType: String?
    @IBInspectable internal var autoRun: Bool = true
    @IBInspectable internal var duration: Double = Double.NaN
    @IBInspectable internal var delay: Double = Double.NaN
    @IBInspectable internal var damping: CGFloat = CGFloat.NaN
    @IBInspectable internal var velocity: CGFloat = CGFloat.NaN
    @IBInspectable internal var force: CGFloat = CGFloat.NaN
    @IBInspectable internal var repeatCount: Float = Float.NaN
    @IBInspectable internal var x: CGFloat = CGFloat.NaN
    @IBInspectable internal var y: CGFloat = CGFloat.NaN
    
    // MARK: - Lifecycle
    internal override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configInspectableProperties()
    }
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        configInspectableProperties()
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        configAfterLayoutSubviews()
        autoRunAnimation()
    }
    
    // MARK: - Private
    private func configInspectableProperties() {
        configAnimatableProperties()
        configTintedColor()
        configBlurEffectStyle()
    }
    
    private func configAfterLayoutSubviews() {
        configGradient()
        configBorder()
    }
   

}
