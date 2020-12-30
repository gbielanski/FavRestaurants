//
//  ZomatoErrorResponse.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation
// Example
//{
//  "code": 403,
//  "status": "Forbidden",
//  "message": "Invalid API Key"
//}

class ZomatoErrorResponse: Codable {
  let code: Int
  let status: String
  let message: String
}

extension ZomatoErrorResponse : LocalizedError{
  var errorDescription: String? {
    return "\(status) \(message)"
  }
}
