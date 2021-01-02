//
//  FavRestaurantsListViewController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import UIKit
import CoreData

class FavRestaurantsListViewController: UIViewController{
  @IBOutlet weak var tableView: UITableView!

  var dataController: DataController!
  var fetchedResultsController: NSFetchedResultsController<FavRestaurant>!

  @IBAction func addButtonTapped(_ sender: Any) {
    self.performSegue(withIdentifier: "findRestaurantFromList", sender: nil)
  }

  @IBAction func unwindToFirstVC( _ seg: UIStoryboardSegue) {
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = false
    setupFetchedResultController()

    tableView.reloadData()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    fetchedResultsController = nil
  }


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "findRestaurantFromList" {
      let findRestaurantVC = segue.destination as! FindRestaurantViewController
      findRestaurantVC.dataController = dataController
    } else if segue.identifier == "showDetailsFromList" {
      let detailsVC = segue.destination as! RestaurantDetailsViewController
      detailsVC.dataController = dataController
      let fav = sender as! FavRestaurant
      detailsVC.restaurant = fav.toRestaurnt()
      detailsVC.isFav = true
      detailsVC.favRestaurant = fav
    }
  }

  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<FavRestaurant> = FavRestaurant.fetchRequest()
    fetchRequest.sortDescriptors = []

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "fav")
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
    } catch{
      fatalError("The fetch could not be performed \(error.localizedDescription)")
    }
  }
}

extension FavRestaurantsListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "FavRestaurantTableCell")!

    let fav = fetchedResultsController.object(at: indexPath)

    cell.textLabel?.text = fav.name
    cell.detailTextLabel?.text = fav.address

    if let thumb = fav.thumb {
      cell.imageView?.image = UIImage(data: thumb)
    }

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[0].numberOfObjects ?? 0
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fav = fetchedResultsController.object(at: indexPath)
    
    self.performSegue(withIdentifier: "showDetailsFromList", sender: fav)
  }
}

extension FavRestaurantsListViewController: NSFetchedResultsControllerDelegate{

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
     case .insert:
         tableView.insertRows(at: [newIndexPath!], with: .fade)
         break
     case .delete:
         tableView.deleteRows(at: [indexPath!], with: .fade)
         break
     case .update:
         tableView.reloadRows(at: [indexPath!], with: .fade)
     case .move:
         tableView.moveRow(at: indexPath!, to: newIndexPath!)
    @unknown default:
      break
    }
  }
}
