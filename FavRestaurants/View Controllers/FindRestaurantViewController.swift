//
//  FindRestaurantViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation
import UIKit

class FindRestaurantViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet weak var couldNotFind: UILabel!
  @IBOutlet weak var lookingForLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var restaurants: [Restaurant]?
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    ZomatoClient.getRestaurantsInLocation(lat: 52.231003, lon: 21.011682){ restaurants, error in
      self.restaurants = restaurants
      self.showNetworkCall(inProgress: false)

      if restaurants?.count == 0 {
        self.showNoResults()
      }else{
        self.tableView.reloadData()
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    showNetworkCall(inProgress: true)
  }

  func showNetworkCall(inProgress: Bool){
    tableView.isHidden = inProgress
    lookingForLabel.isHidden = !inProgress
    activityIndicator.isHidden = !inProgress
  }

  func showNoResults(){
    tableView.isHidden = true
    couldNotFind.isHidden = false
  }
}

extension FindRestaurantViewController: UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurants?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "FoundRestaurantTableCell")!
    let restaurant = restaurants![(indexPath as NSIndexPath).row]

    cell.textLabel?.text = restaurant.data.name
    cell.detailTextLabel?.text = restaurant.data.location.address
    cell.imageView?.image = UIImage(named: "launch")

    return cell
  }


}
