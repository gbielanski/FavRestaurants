//
//  FindRestaurantViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation
import UIKit
import MapKit

class FindRestaurantViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var mapView: MKMapView!

  @IBOutlet weak var couldNotFind: UILabel!
  @IBOutlet weak var lookingForLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var dataController: DataController!
  
  var restaurants: [Restaurant]?
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    mapView.delegate = self
    // Warsaw Centrum
    ZomatoClient.getRestaurantsInLocation(lat: 52.231003, lon: 21.011682){ restaurants, error in
    // Zielonka
    // ZomatoClient.getRestaurantsInLocation(lat: 52.313758, lon: 21.170652){ restaurants, error in
      if let error = error {
        self.showFailure(message: error.localizedDescription)
        return
      }
      
      self.restaurants = restaurants
      self.showNetworkCall(inProgress: false)
      
      if restaurants?.count == 0 {
        self.showNoResults()
      }else{
        self.tableView.reloadData()
        self.updateMap()
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
    showNetworkCall(inProgress: true)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailsFromFind" {
      let findDetailsVC = segue.destination as! RestaurantDetailsViewController
      findDetailsVC.dataController = dataController
      let restaurant = sender as! Restaurant
      findDetailsVC.restaurant = restaurant
    }
  }
  
  private func showNetworkCall(inProgress: Bool){
    tableView.isHidden = inProgress
    lookingForLabel.isHidden = !inProgress
    activityIndicator.isHidden = !inProgress
  }
  
  private func showNoResults(){
    tableView.isHidden = true
    couldNotFind.isHidden = false
  }

  private func updateMap(){
    guard let foundRestaurants = restaurants else {
      return
    }

    var annotations = [MKPointAnnotation]()

    if foundRestaurants.count > 0 {
      let centerLocation = CLLocation(
        latitude: CLLocationDegrees(foundRestaurants[0].data.location.latitude)!,
        longitude: CLLocationDegrees(foundRestaurants[0].data.location.longitude)!)
      let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
      let region = MKCoordinateRegion(center: centerLocation.coordinate, span: span)
      mapView.setRegion(region, animated: false)
    }

    for restaurant in foundRestaurants {

      let lat = CLLocationDegrees(restaurant.data.location.latitude)!
      let long = CLLocationDegrees(restaurant.data.location.longitude)!

      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(restaurant.data.name)"

      annotations.append(annotation)
    }

    self.mapView.addAnnotations(annotations)
  }
  
  private func showFailure(message: String) {
    let alertVC = UIAlertController(title: "Search failed", message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default){ action in
      self.navigationController?.popViewController(animated: true)
    })
    present(alertVC, animated: true, completion: nil)
  }
}

extension FindRestaurantViewController: UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurants?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "FoundRestaurantTableCell")!
    var restaurant = restaurants![(indexPath as NSIndexPath).row]
    
    cell.textLabel?.text = restaurant.data.name
    cell.detailTextLabel?.text = restaurant.data.location.address
    cell.imageView?.image = UIImage(named: "launch")
    
    let path = restaurant.data.thumb
    
    if !path.isEmpty {
      ZomatoClient.downloadImage(path: path){ data, error in
        guard let data = data else {
          return
        }

        restaurant.data.imageData = data
        
        if let image = UIImage(data: data){
          cell.imageView?.image = image
          cell.setNeedsLayout()
        }
      }
    }
    
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let restaurants = self.restaurants {
      let restaurant = restaurants[(indexPath as NSIndexPath).row]

      self.performSegue(withIdentifier: "showDetailsFromFind", sender: restaurant)
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 128
  }
}

extension FindRestaurantViewController: MKMapViewDelegate{
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let reuseId = "pin"

    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }

    return pinView
  }
}
