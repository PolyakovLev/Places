//
//  MainViewController.swift
//  Places
//
//  Created by Lev polyakov on 14/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let restarantArray: [String] = ["bizon", "pinzza", "sirena", "klevo", "italy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table View Datasourse
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return restarantArray.count }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.nameLable.textColor                = UIColor.red
        cell.backgroundColor                    = UIColor.blue
        cell.nameLable.text                     = restarantArray[indexPath.row]
        cell.imageOfPlace.layer.cornerRadius    = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds         = true
        cell.imageOfPlace.image                 = UIImage(named: restarantArray[indexPath.row])
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
    
    // MARK: - Table view deligate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 100.0 }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
