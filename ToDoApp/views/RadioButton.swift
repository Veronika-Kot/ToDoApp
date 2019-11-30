//
//  RadioButton.swift
//  ToDoApp
//
//  Created by Veronika Kotckovich on 11/1/19.
//  Copyright © 2019 Centennial College. All rights reserved.
//

import UIKit

class RadioButton: UIButton {
    
    let unselectedRadio = UIImage(named: "radio-off-button")
    let selectedRadio = UIImage(named: "radio-on-button")
    
    var isSelectedRadio: Bool = false {
        didSet{
            if isSelectedRadio == true {
                setImage(selectedRadio, for: .normal)
            } else {
                setImage(unselectedRadio, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isSelectedRadio = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isSelectedRadio = !isSelectedRadio
        }
    }
}
