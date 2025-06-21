//
//  ProductFeature.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/24/22.
//

import Foundation

struct ProductFeature: Codable, Identifiable {
    var id: Int
    var slug: String
    var name: String
    var description: String
    var options: [ProductOption]?
}


struct ProductOption: Codable, Identifiable {
    var id: Int
    var slug: String
    var name: String
    var description: String
    var feature: ProductFeature?
    var isDefault: Bool
}
/*"features": [
 {
     "id": 11,
     "name": "Đá",
     "slug": "ice",
     "description": "",
     "options": [
         {
             "id": 27,
             "slug": "less-ice",
             "name": "Đá ít",
             "isDefault": false,
             "description": ""
         },
         {
             "id": 28,
             "slug": "normal-ice",
             "name": "Đá vừa",
             "isDefault": true,
             "description": ""
         },
         {
             "id": 29,
             "slug": "takeaway-ice",
             "name": "Đá riêng",
             "isDefault": false,
             "description": ""
         }
     ]
 },
 ...
 */
