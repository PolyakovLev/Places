//
//  CustomTableViewCell.swift
//  Places
//
//  Created by Lev polyakov on 15/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace:    UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius    = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds         = true
        }
    }
    @IBOutlet weak var nameLable:       UILabel!
    @IBOutlet weak var locationLable:   UILabel!
    @IBOutlet weak var typeLable:       UILabel!
    @IBOutlet weak var routeButton: UIButton!
    
    var navigationButtonHandler: (()->())?
    
    @IBAction func routeButtonAction(_ sender: UIButton) {
        self.navigationButtonHandler?()
    }
    
    
}
