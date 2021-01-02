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

  @IBOutlet weak var enterLocationLabel: UILabel!
  @IBOutlet weak var enterLocation: UITextField!
  @IBOutlet weak var findButton: UIButton!
  @IBAction func findButtonTapped(_ sender: Any) {
    let locationDescription = enterLocation.text
    showEnterLocation(show: false)
    showNetworkCall(inProgress: true)
    CLGeocoder().geocodeAddressString(locationDescription ?? "", completionHandler: handleGeocodeAddressString)
  }
  var dataController: DataController!
  
  var restaurants: [Restaurant]?
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    mapView.delegate = self
    showEnterLocation(show: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailsFromFind" {
      let findDetailsVC = segue.destination as! RestaurantDetailsViewController
      findDetailsVC.dataController = dataController
      let restaurant = sender as! Restaurant
      findDetailsVC.restaurant = restaurant
      findDetailsVC.isFav = false
    }
  }

  private func handleGeocodeAddressString(marker: [CLPlacemark]?, error: Error?) -> Void{
    if let error = error {
      self.showFailure(message: error.localizedDescription)
    } else {
      var location: CLLocation?

      if let marker = marker, marker.count > 0 {
        location = marker.first?.location
      }

      if let location = location {
        ZomatoClient.getRestaurantsInLocation(lat: location.coordinate.latitude , lon: location.coordinate.longitude , completion: handleGetRestaurantsInLocation)
      } else {
        self.showEnterLocation(show: false)
        self.showFailure(message: "Please try again later.")
      }
    }
  }

  private func handleGetRestaurantsInLocation(restaurants: [Restaurant]?, error: Error?) -> Void{
    if let error = error {
      self.showFailure(message: error.localizedDescription)
      return
    }

    restaurants?.forEach { restaurant in
      restaurant.data.highlightsString = restaurant.data.highlights.joined(separator: ", ")
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
  
  private func showNetworkCall(inProgress: Bool){
    tableView.isHidden = inProgress
    lookingForLabel.isHidden = !inProgress
    activityIndicator.isHidden = !inProgress
  }

  private func showEnterLocation(show: Bool){
    enterLocation.isHidden = !show
    enterLocationLabel.isHidden = !show
    findButton.isHidden = !show
    tableView.isHidden = show
    lookingForLabel.isHidden = show
    activityIndicator.isHidden = show
  }
  
  private func showNoResults(){
    tableView.isHidden = true
    couldNotFind.isHidden = false
  }

  private func updateMap(){
    guard let foundRestaurants = restaurants else {
      return
    }

    var annotations = [FavPointAnnotation]()

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

      let annotation = FavPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(restaurant.data.name)"
      annotation.restaurant = restaurant

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
    let restaurant = restaurants![(indexPath as NSIndexPath).row]
    
    cell.textLabel?.text = restaurant.data.name
    cell.detailTextLabel?.text = restaurant.data.location.address
    cell.imageView?.image = UIImage(named: "placeholder")
    
    let path = restaurant.data.thumb
    
    if !path.isEmpty {
      ZomatoClient.downloadImage(path: path){ data, error in
        if let error = error {
          self.showFailure(message: error.localizedDescription)
          return
        }

        if let data = data {
          restaurant.data.imageData = data

          if let image = UIImage(data: data){
            cell.imageView?.image = image
            cell.setNeedsLayout()
          }
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

  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let favPointAnnotation = view.annotation as? FavPointAnnotation {
      self.performSegue(withIdentifier: "showDetailsFromFind", sender: favPointAnnotation.restaurant)
    }
  }
}
