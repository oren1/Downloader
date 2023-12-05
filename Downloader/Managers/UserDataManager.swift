//
//  UserDataManager.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import Foundation
import StoreKit

class UserDataManager {
    
    static let main: UserDataManager = UserDataManager()
    var products: [SKProduct]!

    static var amountOfDownloads: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "amountOfDownloads")
        }
        get {
            UserDefaults.standard.integer(forKey: "amountOfDownloads")
        }
    }
    
    
    func productforIdentifier(productIndentifier: ProductIdentifier) -> SKProduct? {
        if let product =  products.first(where: { $0.productIdentifier ==  productIndentifier}) {
            return product
        }
        
        return nil
    }
    
}
