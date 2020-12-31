//
//  Restaurant.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation
import UIKit

class Restaurant: Codable{
  let data: RestaurantData
  enum CodingKeys: String, CodingKey{
    case data = "restaurant"
  }
}

class RestaurantData: Codable{
  let name: String
  let location: Location
  let thumb: String
  var imageData: Data?
}

class Location: Codable {
  let address: String
  let latitude: String
  let longitude: String
}
