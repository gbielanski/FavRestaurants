//
//  SearchResponse.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation

class SearchResponse: Codable{
//  let resultsFound, resultsStart, resultsShown: Int
  let restaurants: [Restaurant]

  enum CodingKeys: String, CodingKey{
//    case resultsFound = "results_found"
//    case resultsStart = "results_start"
//    case resultsShown = "results_shown"
    case restaurants

  }
}
