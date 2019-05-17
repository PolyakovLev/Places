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
    
    
    var places: Results<Place>! // autoupload container realtime
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
        cell.imageOfPlace.layer.cornerRadius    = cell.imageOfPlace.frame.size.height / 2 // TODO: why not circle?
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
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return } // return data from priveus VC
        newPlaceVC.saveNewPlace()
        tableView.reloadData() 
    }
    
}
