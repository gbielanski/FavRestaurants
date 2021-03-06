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
  let timings: String
  let cuisines: String
  let highlights: [String]
  var imageData: Data?
  var highlightsString: String?
  
  init(name: String, location: Location, thumb: String = "", timings: String, cuisines: String, highlights: [String]) {
    self.name = name
    self.location = location
    self.thumb = thumb
    self.timings = timings
    self.cuisines = cuisines
    self.highlights = highlights
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
