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
    favRestaurant.latitude = Double(restaurant.data.location.latitude) ?? 0.0
    favRestaurant.longitude = Double(restaurant.data.location.longitude) ?? 0.0

    do {
      try dataController.viewContext.save()
    }catch {
      showAllert(title: "Failed", message: error.localizedDescription)
    }

    showAllert(title: "Success", message: "Added to favourite")
  }

  var dataController: DataController!
  var restaurant: Restaurant!
  var isFav: Bool!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
    restaurantName.text = restaurant.data.name
    if isFav{
      favButton.image = UIImage(systemName: "heart.fill")
    } else {
      favButton.image = UIImage(systemName: "heart")
    }
  }

  private func showAllert(title: String, message: String) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default){ action in
      self.navigationController?.popViewController(animated: true)
    })
    present(alertVC, animated: true){
      self.performSegue(withIdentifier: "fromDetails", sender: self)
    }
  }

}
