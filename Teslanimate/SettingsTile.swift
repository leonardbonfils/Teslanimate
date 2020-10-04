//
//  SettingsTile.swift
//  Teslanimate
//
//  Created by Léonard Bonfils on 2016-04-19.
//  Copyright © 2016 Léonard Bonfils. All rights reserved.
//

import UIKit
import IBAnimatable

class SettingsTile: AnimatableLabel {
    
    var previousColor: UIColor?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.textColor = UIColor.whiteColor()
        self.textAlignment = .Center
        self.adjustsFontSizeToFitWidth = true
        self.font = UIFont(name: UIVariables.helveticaNeueBaseFontName + "Light", size: 16.0)
        self.userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        previousColor = self.backgroundColor
        self.backgroundColor = UIColor.whiteColor()
        self.textColor = UIColor.blackColor()
        self.layer.borderColor = UIVariables.settingTileBorderColor
        self.layer.borderWidth = UIVariables.settingsTileBorderWidth
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(1.0, animations: {
            self.backgroundColor = self.previousColor
            self.textColor = UIColor.whiteColor()
        })
    }
}