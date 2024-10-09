//
//  RecipesViewModel.swift
//  Recipes
//
//  Created by Amey Kanunje on 10/8/24.
//

import Foundation
import UIKit

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var recipe: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiManager: APIManagerProtocol
    let imageCache = NSCache<NSString, UIImage>()
    
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
        print("RecipesViewModel Initialized")
    }
    
    func fetchRecipeData() async {
        print("fetchRecipeData called")
        isLoading = true
        errorMessage = nil
        
        do {
            let recipeData = try await apiManager.request(modelType: Recipes.self, type: EndpointItems.Recipes)
            //print("Fetched \(recipeData.recipes.count) recipes from API")
            self.recipe = recipeData.recipes
            self.errorMessage = nil
        } catch {
            //print("API Fetch failed: \(error.localizedDescription)")
            self.recipe = []
            self.errorMessage = "No recipes available"
        }
        
        isLoading = false
    }
    
    func getImage(for url: URL) async -> UIImage? {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                return image
            }
        } catch {
            print("Failed to load image: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func cleanData() {
        recipe.removeAll()
        imageCache.removeAllObjects()
        print("Data and Cache Image Cleared")
    }
}
