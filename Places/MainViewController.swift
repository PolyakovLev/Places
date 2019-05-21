//
//  MainViewController.swift
//  Places
//
//  Created by Lev polyakov on 14/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    private var places:             Results<Place>! // autoupload container (realtime)
    private var filtredPlaces:      Results<Place>!
    private var ascendingSorted     = true
    private let searchController    = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty:   Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        searchController.obscuresBackgroundDuringPresentation   = false // to interact as main
        searchController.searchResultsUpdater                   = self // получатель сам класс
        searchController.searchBar.placeholder                  = "Search"
        navigationItem.searchController                         = searchController
        definesPresentationContext                              = true // TODO: - Whats that
    }
    
    // MARK: - Table View Datasourse
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 
        if isFiltering {
            return filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count 
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place                               =  isFiltering == true ? filtredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLable.textColor                = UIColor.red
        cell.nameLable.text                     = place.name
        cell.locationLable.text                 = place.location
        cell.typeLable.text                     = place.type
        cell.imageOfPlace.image                 = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius    = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds         = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.white

    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { // delete row 
        let place           =  isFiltering == true ? filtredPlaces[indexPath.row] : places[indexPath.row]
        
        let deleteAction    = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (_, _) in
            let storyboard          = UIStoryboard(name: "Main", bundle: nil)
            let newPlaceVC          = storyboard.instantiateViewController(withIdentifier: "showDetail") as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            self.navigationController?.pushViewController(newPlaceVC, animated: true) // TODO: read about push     
        }
        editAction.backgroundColor = .cyan
        return [deleteAction, editAction]
    }
    
    
    
//      MARK: - Navigation
     
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            guard let indexPath     = tableView.indexPathForSelectedRow else { return }
//            let place               = places[indexPath.row]
//            let newPlaceVC          = segue.destination as! NewPlaceViewController
//            newPlaceVC.currentPlace = place
//            
//        }
//     }
     
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return } // return data from priveus VC
        newPlaceVC.savePlace()
        tableView.reloadData() 
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
       sorting()
    }
    @IBAction func reverseSorting(_ sender: Any) {
        ascendingSorted.toggle()
        reversedSortingButton.image = ascendingSorted == true ? #imageLiteral(resourceName: "AZ") : #imageLiteral(resourceName: "ZA")
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "data", ascending: ascendingSorted)
        } else {
            places = places.sorted(byKeyPath: "name", ascending:  ascendingSorted)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
            filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
