//
//  RestaurantDetailsViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import UIKit
import CoreData


class RestaurantDetailsViewController: UIViewController{

  @IBOutlet weak var favButton: UIBarButtonItem!
  @IBOutlet weak var restaurantName: UILabel!

  @IBAction func favButtonTapped(_ sender: Any) {
    let favRestaurant = FavRestaurant(context: dataController.viewContext)
    favRestaurant.address = restaurant.data.location.address
    favRestaurant.name = restaurant.data.name
    favRestaurant.thumb = restaurant.data.imageData
    try? dataController.viewContext.save()
  }

  var dataController: DataController!
  var restaurant: Restaurant!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    restaurantName.text = restaurant.data.name
  }

}
