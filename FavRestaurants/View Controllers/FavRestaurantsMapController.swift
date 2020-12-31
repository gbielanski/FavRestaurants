//
//  FavRestaurantsListMapController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import UIKit
import CoreData
import MapKit

class FavRestaurantsMapViewController: UIViewController{

  @IBOutlet weak var mapView: MKMapView!

  var dataController: DataController!
  var fetchedResultsController: NSFetchedResultsController<FavRestaurant>!

  @IBAction func addButtonTapped(_ sender: Any) {
    self.performSegue(withIdentifier: "findRestaurantFromMap", sender: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    setupFetchedResultController()

    if fetchedResultsController.sections?[0].numberOfObjects ?? 0 > 0 {
     updateMap()
    } else {
      //TODO
      print("Zero")
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    fetchedResultsController = nil
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "findRestaurantFromMap" {
      let findRestaurantVC = segue.destination as! FindRestaurantViewController
      findRestaurantVC.dataController = dataController
    }
  }

  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<FavRestaurant> = FavRestaurant.fetchRequest()

    //TODO Add sort by name ??
    fetchRequest.sortDescriptors = []

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "fav")
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
    } catch{
      fatalError("The fetch could not be performed \(error.localizedDescription)")
    }
  }

  private func updateMap(){
    fetchedResultsController.fetchedObjects?.forEach{ fav in
      let lat = CLLocationDegrees(fav.latitude)
      let long = CLLocationDegrees(fav.longitude)
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(fav.name)"
      self.mapView.addAnnotation(annotation)
    }
  }
}

extension FavRestaurantsMapViewController: NSFetchedResultsControllerDelegate{

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch type {
    case .insert:
      let fav = fetchedResultsController.object(at: newIndexPath!)
      let lat = CLLocationDegrees(fav.latitude)
      let long = CLLocationDegrees(fav.longitude)
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(fav.name)"
      self.mapView.addAnnotation(annotation)
      break
    case .delete:
      let fav = fetchedResultsController.object(at: indexPath!)
      //TODO
      break
    case .update:
      //TODO
      break
    case .move:
      // TODO
      break
    @unknown default:
      break
    }
  }
}

extension FavRestaurantsMapViewController: MKMapViewDelegate{
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