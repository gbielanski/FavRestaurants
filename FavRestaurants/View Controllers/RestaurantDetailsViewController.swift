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
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var timing: UILabel!
  @IBOutlet weak var cuisines: UILabel!
  @IBOutlet weak var highlights: UILabel!
  
  @IBAction func favButtonTapped(_ sender: Any) {
    if isFav {
      favButtonTappedForFav()
    }else {
      favButtonTappedForNew()
    }
  }

  private func favButtonTappedForFav(){
    dataController.viewContext.delete(favRestaurant!)

    do {
      try dataController.viewContext.save()
    }catch {
      showAllert(title: "Failed", message: error.localizedDescription)
    }

    favButton.image = UIImage(systemName: "heart")
    showAllert(title: "Success", message: "Removed from favourites")
  }

  private func favButtonTappedForNew(){

    let favRestaurant = FavRestaurant(context: dataController.viewContext)
    favRestaurant.address = restaurant.data.location.address
    favRestaurant.name = restaurant.data.name
    favRestaurant.thumb = restaurant.data.imageData
    favRestaurant.latitude = Double(restaurant.data.location.latitude) ?? 0.0
    favRestaurant.longitude = Double(restaurant.data.location.longitude) ?? 0.0
    favRestaurant.cuisines = restaurant.data.cuisines
    favRestaurant.timings = restaurant.data.timings
    favRestaurant.highlights = restaurant.data.highlights.joined(separator: ", ")

    do {
      try dataController.viewContext.save()
    }catch {
      showAllert(title: "Failed", message: error.localizedDescription)
    }
    favButton.image = UIImage(systemName: "heart.fill")
    showAllert(title: "Success", message: "Added to favourites")
  }

  var dataController: DataController!
  var restaurant: Restaurant!
  var favRestaurant: FavRestaurant? = nil
  var isFav: Bool!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
    fillRestaurantDetails()
  }

  private func fillRestaurantDetails(){
    restaurantName.text = restaurant.data.name
    if isFav{
      favButton.image = UIImage(systemName: "heart.fill")
    } else {
      favButton.image = UIImage(systemName: "heart")
    }

    if let data = restaurant.data.imageData {
      image.image = UIImage(data: data)
    }

    if restaurant.data.location.address.isEmpty {
      address.text = "Unknown"
    } else {
      address.text = restaurant.data.location.address
    }

    if restaurant.data.timings.isEmpty {
      timing.text = "Unknown"
    } else {
      timing.text = restaurant.data.timings
    }

    if restaurant.data.cuisines.isEmpty {
      cuisines.text = "Unknown"
    } else {
      cuisines.text = restaurant.data.cuisines
    }

    if restaurant.data.highlightsString?.isEmpty ?? true {
      highlights.text = " "
    } else {
      highlights.text = restaurant.data.highlightsString
    }
    
  }

  private func showAllert(title: String, message: String) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)


    let backAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
      if self?.navigationController?.children[0] is FavRestaurantsListViewController {
        self?.performSegue(withIdentifier: "fromDetails", sender: self)
      } else {
        self?.performSegue(withIdentifier: "fromDetailsToMap", sender: self)
      }
    }

    alertVC.addAction(backAction)

    present(alertVC, animated: true, completion: nil)

  }

}
