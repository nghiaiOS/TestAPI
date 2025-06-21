//
//  Product.swift
//  ptm
//
//  Created by Đăng Nguyễn on 5/22/23.
//

import Foundation

struct Product: Codable, Identifiable {
    var id: Int
    var slug: String
    var code: String
    var name: String
    var fullName: String
    var description: String
    var isAvailable: Bool
    var isFeature: Bool
    var notionPageID: String?
    var categoryID: Int
    var images: [String]
    var sharingImage: String?
    var category: Category?
    var variations: [ProductVariation]?
    var features: [ProductFeature]?
    var modifiers: [ProductModifier]?
    var unit: InventoryUnit?
    var barcode: String

   /* func isCoffee() -> Bool {
        return self.categoryID == 1
    }*/
}

/*func loadProducts() async throws -> [Product] {
    return try await API.ptmAdmin.get(path: "/products")
}*/
