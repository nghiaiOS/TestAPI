//
//  ProductSummary.swift
//  ptm
//
//  Created by Đăng Nguyễn on 07/11/2023.
//

import Foundation

struct ProductSummary: Codable, Identifiable {
    var id: Int {
        return product.id
    }

    var ordersCount: Int
    var totalGram: Int
    var totalSpent: Int
    var product: Product
}

/*func loadProductsWithSummaries(groupIDs: [Int], userIDs: [Int], from: Date, to: Date) async throws -> [ProductSummary] {
    let query = groupIDs.map { String($0) }.joined(separator: ",")
    let userIDsQuery = userIDs.map { String($0) }.joined(separator: ",")
    let path = "/products/summaries?group_ids=\(query)&user_ids=\(userIDsQuery)&from=\(from.ISO8601Format())&to=\(to.ISO8601Format())"
    return try await API.ptmAdmin.get(path: path)
}*/
