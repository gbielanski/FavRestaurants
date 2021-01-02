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
  
  init(data: RestaurantData){
    self.data = data
  }
}

class RestaurantData: Codable{
  let name: String
  let location: Location
  let thumb: String
  var imageData: Data?
  
  init(name: String, location: Location, thumb: String = "") {
    self.name = name
    self.location = location
    self.thumb = thumb
  }
}

class Location: Codable {
  let address: String
  let latitude: String
  let longitude: String
  
  init(address: String, latitude: String, longitude: String){
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
  }
}
