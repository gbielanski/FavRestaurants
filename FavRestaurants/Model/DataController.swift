//
//  DataController.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation
import CoreData

class DataController {
  let persistanceContainer: NSPersistentContainer

  var viewContext: NSManagedObjectContext {
    return persistanceContainer.viewContext
  }

  var backgroundContext: NSManagedObjectContext!

  init(modelName: String) {
    persistanceContainer = NSPersistentContainer(name: modelName)
  }

  func configureContexts(){
    backgroundContext = persistanceContainer.newBackgroundContext()

    viewContext.automaticallyMergesChangesFromParent = true
    backgroundContext.automaticallyMergesChangesFromParent = true

    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
  }

  func load(completion: (() -> Void)? = nil){
    persistanceContainer.loadPersistentStores{ (storeDescription, error) in
      guard error == nil else {
        fatalError(error!.localizedDescription)
      }

      self.configureContexts()
      completion?()
    }
  }
}
