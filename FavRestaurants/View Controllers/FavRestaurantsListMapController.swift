//
//  FavRestaurantsListMapController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import UIKit

class FavRestaurantsMapViewController: UIViewController{

  @IBAction func addButtonTapped(_ sender: Any) {
    self.performSegue(withIdentifier: "findRestaurantFromMap", sender: nil)
  }
  
  var dataController: DataController!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "findRestaurantFromMap" {
      let findRestaurantVC = segue.destination as! FindRestaurantViewController
      findRestaurantVC.dataController = dataController
    }
  }

}
