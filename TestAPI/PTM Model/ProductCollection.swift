//
//  ProductCollection.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/25/22.
//

import Foundation

struct ProductCollection: Codable, Identifiable {
    var id: Int
    var name: String
    var description: String?
    var products: [Product]
}

func loadCollectionsByIDs(_ ids: [Int]) async throws -> [ProductCollection] {
    let query = ids.map{ String($0) }.joined(separator: ",")
    return try await API.shared.getPublic(path: "/product/collection?ids=\(query)")
}
