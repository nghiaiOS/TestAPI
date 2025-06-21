//
//  Product.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/24/22.
//

import Foundation

struct ProductVariation: Codable, Identifiable {
    var id: Int
    var sku: String
    var unit: String
    var originalPrice: Int
    var price: Int
    var gram: Int
    var images: [String]
    var isAvailable: Bool
    var isDefault: Bool
    var options: [ProductOption]
    var product: Product?
}
