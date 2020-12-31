//
//  FavRestaurant+Extension.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 31/12/2020.
//

import Foundation

import Foundation
import CoreData

extension FavRestaurant{
  public override func awakeFromInsert() {
    super.awakeFromInsert()
  }
}

extension FavRestaurant{
  func toRestaurnt() -> Restaurant{
    let location = Location(address: self.address ?? "", latitude: "\(self.latitude)", longitude: "\(self.longitude)")

    let data = RestaurantData(name: self.name ?? "", location: location)
    data.imageData = self.thumb

    let restaurant = Restaurant(data: data)
    return restaurant
  }
}
