//
//  Businesses.swift
//  Fast Foodz
//
//  Created by Jae Young Choi on 2/19/22.
//

/// Data Model for the Yelp Fusion API JSON response
struct Businesses: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let name: String
    let id: String
    let price: String?
    let categories: [Categories]
    let coordinates: Coordinates
    let distance: Double
    let image_url: String
    let phone: String
    let url: String?
}

struct Categories: Codable {
    let alias: String
    let title: String
}

struct Coordinates: Codable, Equatable {
    let longitude: Double
    let latitude: Double
}
