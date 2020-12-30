//
//  FindRestaurantViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation
import UIKit

class FindRestaurantViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    ZomatoClient.getRestaurantsInLocation(lat: 52.231003, lon: 21.011682){ restaurants, error in

    }
  }
}
