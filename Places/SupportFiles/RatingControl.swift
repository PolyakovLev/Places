//
//  RatingControl.swift
//  Places
//
//  Created by Lev polyakov on 21/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { // IBDesignable - to show in storyboard

    // MARK: properties
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    private var ratingButtons: [UIButton] = []
    
    
    @IBInspectable var starSize: CGSize = CGSize(width: 40.0, height: 40.0) {
        didSet { // TODO: - Read about observers 
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
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
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private methods
    
    private func setupButtons() {
        
        for button in ratingButtons { // wtf?
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // load button image
        let bundle = Bundle(for: type(of: self)) // for path to images, needed for IB
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection) // TODO: traitCollection?
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 1...starCount {
            // create button
            let button = UIButton()

            // set button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // add constraints
            
            button.translatesAutoresizingMaskIntoConstraints = false // no autoconstreints
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            // setup button action 
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside) // QUESTION: Why button field is empty??
            // add button to stack
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating ? true : false
        }
    }
}
