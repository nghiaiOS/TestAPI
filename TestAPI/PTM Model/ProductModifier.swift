//
//  ProductModifier.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/24/22.
//

import Foundation

struct ProductModifier: Codable {
    var id: Int
    var slug: String
    var name: String
    var description: String
    var options: [ProductModifierOption]
}

struct ProductModifierOption: Codable {
    var id: Int
    var slug: String
    var name: String
    var price: Int
    var description: String
}
