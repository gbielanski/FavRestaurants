//
//  ZomatoClient.swift
//  FavRestaurants
//
//  Created by Grzegorz Bielanski on 30/12/2020.
//

import Foundation

class ZomatoClient {
  static var apiKey: String {
    get {
      guard let filePath = Bundle.main.path(forResource: "Zomato-Info", ofType: "plist") else {
        fatalError("Couldn't find file 'Zomato-Info.plist'.")
      }
      let plist = NSDictionary(contentsOfFile: filePath)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'Zomato-Info.plist'.")
      }
      return value
    }
  }

  enum Endpoints {
    static let base = "https://developers.zomato.com/api/v2.1/search"
    static let count = 10
    static let radius = 100
    static let sort = "real_distance"
    static let order = "desc"
    static let start = "0"

    case getRestaurantsInLocation(String, String)
    case downloadImage(String)

    var stringValue: String {
      switch self {
      case .getRestaurantsInLocation(let latitude, let longitude): return Endpoints.base +
        "?start=\(Endpoints.start)" +
        "&count=\(Endpoints.count)" +
        "&lat=\(latitude)" +
        "&lon=\(longitude)" +
        "&radius=\(Endpoints.radius)" +
        "&sort=\(Endpoints.sort)" +
        "&order=\(Endpoints.order)"
      case .downloadImage(let path): return path
      }
    }

    var url: URL {
      return URL(string: stringValue)!
    }
  }

  class func downloadImage(path: String, completionHandler: @escaping (Data?, Error?) -> Void){
    let download = URLSession.shared.dataTask(with: Endpoints.downloadImage(path).url){ (data, _, error) in
      DispatchQueue.main.async {
        completionHandler(data, error)
      }
    }

    download.resume()
  }

  class func getRestaurantsInLocation(lat: Double, lon: Double, completion: @escaping ([Restaurant]?, Error?) -> Void) {
    let url = Endpoints.getRestaurantsInLocation("\(lat)", "\(lon)").url
    taskForGETRequest(url: url, responseType: SearchResponse.self){ (response, error)
      in
      if let response = response {
        completion(response.restaurants, nil)
      }else{
        completion(nil, error)
      }
    }
  }

  class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("\(ZomatoClient.apiKey)", forHTTPHeaderField: "user-key")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }

      print(String(data: data, encoding: .utf8)!)

      let decoder = JSONDecoder()
      do {
        let responseObject = try decoder.decode(ResponseType.self, from: data)
        DispatchQueue.main.async {
          completion(responseObject, nil)
        }
      } catch {
        do {
          print(error.localizedDescription)
          let errorResponse = try decoder.decode(ZomatoErrorResponse.self, from: data)
          DispatchQueue.main.async {
            completion(nil, errorResponse)
          }
        }catch{
          DispatchQueue.main.async {
            completion(nil, error)
          }
        }
      }
    }
    task.resume()
  }
}
