//
//  MainViewController.swift
//  Places
//
//  Created by Lev polyakov on 14/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    
    var places: Results<Place>! // autoupload container (realtime)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }
    
    // MARK: - Table View Datasourse
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 
        return places.isEmpty ? 0 : places.count 
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place                               = places[indexPath.row]
        
        cell.nameLable.textColor                = UIColor.red
        cell.backgroundColor                    = UIColor.blue
        cell.nameLable.text                     = place.name
        cell.locationLable.text                 = place.location
        cell.typeLable.text                     = place.type
        cell.imageOfPlace.image                 = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius    = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds         = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hello")
        self.tableView.backgroundColor = UIColor.red
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (indexPath.row < 5) {
            self.tableView.backgroundColor = UIColor.white
            print("111")
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { // delete row 
        let place           = places[indexPath.row]
        let deleteAction    = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let editAction      = UITableViewRowAction(style: .default, title: "Edit") { (_, _) in
            print("dsf")
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            /*
             // QUESTION: why it not worked
            let newPlaceVC = NewPlaceViewController()
            newPlaceVC.currentPlace = place
            present(newPlaceVC, animated: true, completion: nil)
            */
            
        }
        editAction.backgroundColor = .cyan
        return [deleteAction, editAction]
    }
    
    
//      MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath     = tableView.indexPathForSelectedRow else { return }
            let place               = places[indexPath.row]
            let newPlaceVC          = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            
        }
     }
     
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return } // return data from priveus VC
        newPlaceVC.savePlace()
        tableView.reloadData() 
    }
    
}
