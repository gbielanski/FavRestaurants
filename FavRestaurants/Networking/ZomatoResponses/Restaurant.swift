//
//  Restaurant.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation

class Restaurant: Codable{
  let restaurant: RestaurantData
}

class RestaurantData: Codable{
  let name: String
  let location: Location
}

class Location: Codable {
  let address: String
  let latitude: String
  let longitude: String
}
