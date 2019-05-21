//
//  RatingControl.swift
//  Places
//
//  Created by Lev polyakov on 21/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {

    // MARK: - initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    // MARK: Button action
    
    // MARK: Private methods
    
    private func setupButtons() {
        
        // create button
        let button = UIButton()
        button.backgroundColor = .red
        
        // add constraints
        
        button.translatesAutoresizingMaskIntoConstraints = false // no autoconstreints
        button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        // add button to stack
        addArrangedSubview(button)
    }

}
