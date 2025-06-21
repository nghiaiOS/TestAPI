//
//  Unit.swift
//  ptm
//
//  Created by Đăng Nguyễn on 30/12/2023.
//

import Foundation

struct InventoryBaseUnit: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let gram: Int
    let ratio: Double
}


struct InventoryUnit: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let gram: Int
    let baseUnit: InventoryBaseUnit?
    let ratio: Double
}
