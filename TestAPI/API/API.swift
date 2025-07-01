//
//  API.swift
//  ptm
//
//  Created by Đăng Nguyễn on 10/24/22.
//

import Foundation
import OSLog

enum APIError: Error {
    case StatusError
    case NotAuth
    case InvalidURL
    case DecodeError
    case RequestError
}

enum APIMethod: String {
    case GET, POST, PUT, DELETE
}

struct APIErrorResponse: Codable {
    var error: String
}

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        self.description
    }
}

class API {
    var logger = Logger()
    
    static var ptmAdmin = API(
        base: ProcessInfo.processInfo.environment["ADMIN_API_URL"] ?? "https://ptm.phatthanhcafe.com",
        key: "admin-token"
    )
    
    static var ptmAdminDirectory = API(
        base: ProcessInfo.processInfo.environment["ADMIN_API_URL"] ?? "https://ptm.phatthanhcafe.com",
        key: "admin-directory-token",
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDYxOTYwODksImlhdCI6MTcxNDY2MDA4OSwic3ViIjoiMjA5In0.jkgJss655hRx900t-mWX36RN-txcRwVe9PxUzp9x9NI"
    )

    static var shared = API(
        base: ProcessInfo.processInfo.environment["API_URL"] ?? "https://api.phatthanhcafe.com",
        key: "token"
    )
    
    static var apiAdmin = API(
        base: ProcessInfo.processInfo.environment["API_URL"] ?? "https://api.phatthanhcafe.com",
        key: "admin-api-token"
    )
    
    var token: String?
    var base: String
    var key: String
    
    init(base: String, key: String, token: String? = nil) {
        self.base = base
        self.key = key
        self.token = token
    }
    
    func request<T: Decodable>(path: String, method: APIMethod, token: String? = nil, body: Encodable? = nil) async throws -> T? {
        guard let url = URL(string: self.base + path) else {
            print("error", "APIError.InvalidURL")

            throw APIError.InvalidURL
        }
        
        self.logger.info("API request: \(method.rawValue) \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue.uppercased()
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            throw APIError.RequestError
        }
        
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 403 {
                deleteLogin(api: self)
                self.token = nil
                throw APIError.NotAuth
            }
            
            print(method, url)
            print("STATUS", httpResponse.statusCode)
            
            var decodeData: APIErrorResponse
            do {
                decodeData = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                print(decodeData.error)
            } catch {
                print(error)
                print(String(decoding: data, as: UTF8.self))
                throw RuntimeError(String(decoding: data, as: UTF8.self))
            }
            
            if decodeData.error == "voucher not applicable" {
                throw RuntimeError("Đơn hàng không đủ điều kiện áp dụng voucher")
            }
            
            throw RuntimeError(decodeData.error)
        }
        
        if data.count > 0 {
            do {
                let decodeData = try JSONDecoder().decode(T.self, from: data)
                return decodeData
            } catch {
                print(error)
                print(error.localizedDescription)
                throw APIError.DecodeError
            }
        }
        
        return nil
    }
    
    func authRequest<T: Decodable>(method: APIMethod, path: String, body: Encodable? = nil) async throws -> T? {
        if self.token == nil {
            self.token = loadLogin(key: self.key)
        }
        
        if self.token != nil {
            return try await self.request(path: path, method: method, token: self.token, body: body)
        } else {
            throw APIError.NotAuth
        }
    }
    
    func getPublic<T: Decodable>(path: String) async throws -> T {
        return try await self.request(path: path, method: .GET)!
    }
    
    func get<T: Decodable>(path: String) async throws -> T {
        let data: T? = try await self.authRequest(method: .GET, path: path)
        if data == nil {
            throw APIError.RequestError
        }
        return data!
    }
    
    func post(path: String, body: Encodable? = nil) async throws {
        let _: String? = try await self.authRequest(method: .POST, path: path, body: body)
    }
    
    func postWithType<T: Decodable>(path: String, body: Encodable? = nil) async throws -> T {
        let data: T? = try await self.authRequest(method: .POST, path: path, body: body)
        if data == nil {
            throw APIError.RequestError
        }
        return data!
    }
    
    func put(path: String) async throws {
        let _: String? = try await self.authRequest(method: .PUT, path: path)
    }
    
    func delete(path: String) async throws {
        let _: String? = try await self.authRequest(method: .DELETE, path: path)
    }
}
