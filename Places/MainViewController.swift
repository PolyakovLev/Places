//
//  MainViewController.swift
//  Places
//
//  Created by Lev polyakov on 14/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    
    var places: [Place] = Place.getPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table View Datasourse
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return places.count }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place                               = places[indexPath.row]
        cell.nameLable.textColor                = UIColor.red
        cell.backgroundColor                    = UIColor.blue
        cell.nameLable.text                     = place.name
        cell.imageOfPlace.layer.cornerRadius    = cell.imageOfPlace.frame.size.height / 2 // TODO: why not circle?
        cell.imageOfPlace.clipsToBounds         = true
        cell.locationLable.text                 = place.location
        cell.typeLable.text                     = place.type
        
        if place.image == nil {
            cell.imageOfPlace.image = UIImage(named: place.restarantImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
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
        places.append(newPlaceVC.newPlace!)
        tableView.reloadData() 
    }
    
}
