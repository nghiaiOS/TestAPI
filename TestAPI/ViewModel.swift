//
//  TestAPI1ViewModel.swift
//  TestAPI
//
//  Created by ABC on 20/6/25.
//

import Foundation

import Foundation
class ViewModel: ObservableObject {
    @Published var collections: [ProductCollection] = []

    func fetch() {
        guard let url = URL(string: "https://api.phatthanhcafe.com/product/collection?ids=101") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error:", error)
                return
            }

            guard let data = data else {
                print("❌ No data")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ProductCollection].self, from: data)
                DispatchQueue.main.async {
                    self.collections = decoded
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }
}
