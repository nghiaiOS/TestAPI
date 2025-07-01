//
//  Auth.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/31/22.
//

import Foundation
import SwiftUI


struct Certificate: Codable {
    var id: Int
    var email: String?
    var token: String
    var name: String
    var phone: String
}

func loadLogin(key: String) -> String? {
    return UserDefaults.standard.string(forKey: key)
}

func saveLogin(_ response: Certificate, key: String) -> Void {
    UserDefaults.standard.set(response.token, forKey: key)
}

func deleteLogin(api: API) -> Void {
    api.token = nil
    UserDefaults.standard.set(nil, forKey: api.key)
}

func loginAdmin(phone: String) async throws -> Certificate {
    let response: Certificate = try await API.ptmAdmin.getPublic(path: "/login?phone=\(phone)")
    return response
}

func login(phone: String) async throws -> Certificate {
    let response: Certificate = try await API.shared.getPublic(path: "/login?phone=\(phone)")
    return response
}

func loginAdminAPI(phone: String) async throws -> Certificate {
    let response: Certificate = try await API.apiAdmin.getPublic(path: "/login?phone=\(phone)")
    return response
}
