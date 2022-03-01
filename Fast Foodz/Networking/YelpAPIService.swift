//
//  YelpAPIService.swift
//  Fast Foodz
//
//  Created by Jae Young Choi on 2/19/22.
//

import Foundation

class YelpAPIService {

    static let shared = YelpAPIService()
    
    func fetchBusinesses(latitude: Double, longitude: Double, completion: @escaping (Result<Businesses, Error>) -> Void) {

        /// Hardcoded query parameters
        let radius: Int = 1000
        let sortBy = "distance"
        let category = "pizza,mexican,chinese,burgers"

        /// Configuring the URL
        let baseUrl = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&categories=\(category)&sort_by=\(sortBy)"
        let url = URL(string: baseUrl)

        /// Configuring the HTTP Request
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        /// Performing the dataTask
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(Businesses.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()

    }
}
