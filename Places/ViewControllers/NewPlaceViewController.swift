//
//  NewPlaceViewController.swift
//  Places
//
//  Created by Lev polyakov on 16/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    var currentPlace: Place!
    var imageIsChaneged  = false
    
    @IBOutlet weak var placeImage:      UIImageView!
    @IBOutlet weak var placeName:       UITextField!
    @IBOutlet weak var placeLocation:   UITextField!
    @IBOutlet weak var placeType:       UITextField!
    @IBOutlet weak var saveButtom:      UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl!
    
    let cameraIcon  = #imageLiteral(resourceName: "camera") 
    let photoIcon   = #imageLiteral(resourceName: "photo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async { // TODO: read about DispatchQueue
//            self.newPlace.savePlaces()
//        }
        
        tableView.tableFooterView   = UIView() // enable horizontal lines under static rows
        saveButtom.isEnabled        = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged) // check content in Name field
        setupEditScreen()
    }
    
    // MARK: - Table View Deligate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { 
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera      = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(sourse: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image") // set camera icon image
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") // align text left 
            
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        var image: UIImage?
        
        if imageIsChaneged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "lounch")
        }
        let imageData   = image?.pngData()
        let newPlace    = Place(name: placeName.text!,
                                location: placeLocation.text,
                                type: placeType.text,
                                imageData: imageData,
                                rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name      = newPlace.name
                currentPlace?.location  = newPlace.location
                currentPlace?.type      = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating    = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChaneged             = true
            guard let data              = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeName.text              = currentPlace?.name
            placeType.text              = currentPlace?.type
            placeLocation.text          = currentPlace?.location
            placeImage.image            = image
            placeImage.contentMode      = .scaleAspectFill
            ratingControl.rating        = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem    = nil
        title                               = currentPlace?.name
        saveButtom.isEnabled                = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        guard let mapVC = segue.destination as? MapViewController else { return }
        mapVC.mapVCDelegate = self
        mapVC.identyfire = identifier        
    }
}

// MARK: - Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide keyboard when tap out field
        return true 
    }
    
    @objc private func textFieldChanged() {
        saveButtom.isEnabled = placeName.text?.isEmpty == false ? true : false
        //QUESTION: why "!placeName.text?.isEmpty" need unwrapped but "== false" is worked?
    }
}

// MARK: - Work with images

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            let imagePicker             = UIImagePickerController()
            imagePicker.delegate        = self
            imagePicker.allowsEditing   = true
            imagePicker.sourceType      = sourse
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image            = info[.editedImage] as? UIImage // put image to imageView 
        placeImage.contentMode      = .scaleAspectFill
        placeImage.clipsToBounds    = true
        imageIsChaneged             = true
        dismiss(animated: true, completion: nil)
    }
}

extension NewPlaceViewController: mapViewControllerDelegate {
    
    func getAddress(_ addres: String?) {
        placeLocation.text = addres
    }
    
    
}
