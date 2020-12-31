//
//  FavRestaurantsListViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import UIKit

class FavRestaurantsListViewController: UIViewController{
  var dataController: DataController!

  @IBAction func addButtonTapped(_ sender: Any) {
    self.performSegue(withIdentifier: "findRestaurantFromList", sender: nil)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "findRestaurantFromList" {
      let findRestaurantVC = segue.destination as! FindRestaurantViewController
      findRestaurantVC.dataController = dataController
    }
  }
}
