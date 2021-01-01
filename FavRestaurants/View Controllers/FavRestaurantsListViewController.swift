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

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = false
    setupFetchedResultController()

    if fetchedResultsController.sections?[0].numberOfObjects ?? 0 > 0 {
      tableView.reloadData()
    } else {
//TODO
    }
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
      let findDetailsVC = segue.destination as! RestaurantDetailsViewController
      findDetailsVC.dataController = dataController
      let restaurant = sender as! Restaurant
      findDetailsVC.restaurant = restaurant
    }
  }

  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<FavRestaurant> = FavRestaurant.fetchRequest()

    //TODO Add sort by name
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
    
    self.performSegue(withIdentifier: "showDetailsFromList", sender: fav.toRestaurnt())
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

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    let indexSet = IndexSet(integer: sectionIndex)
     switch type {
     case .insert: tableView.insertSections(indexSet, with: .fade)
     case .delete: tableView.deleteSections(indexSet, with: .fade)
     case .update, .move:
         fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
     }
  }
}
