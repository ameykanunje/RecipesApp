//
//  MockAPIManager.swift
//  RecipesTests
//
//  Created by Amey Kanunje on 10/8/24.
//

import Foundation
import UIKit
@testable import Recipes


class MockAPIManager: APIManagerProtocol {
    var mockResult: Result<Recipes, Error>?
    var mockEndpoint: URL?
    let imageCache = NSCache<NSString, UIImage>()
    
    func request<T: Decodable>(modelType: T.Type, type: any EndpointType) async throws -> T {
        if let mockResult = mockResult {
            switch mockResult {
            case .success(let recipes):
                if let recipes = recipes as? T {
                    return recipes
                } else {
                    throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected type"])
                }
            case .failure(let error):
                throw error
            }
        } else if let url = mockEndpoint {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } else {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock data or endpoint set"])
        }
    }
    
    func getImage(for url: URL) async -> UIImage? {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        
        let mockImage = UIImage(systemName: "photo") ?? UIImage()
        imageCache.setObject(mockImage, forKey: url.absoluteString as NSString)
        return mockImage
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    func setMockResult(_ result: Result<Recipes, Error>) {
        self.mockResult = result
    }
}
