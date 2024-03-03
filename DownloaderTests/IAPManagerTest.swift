//
//  IAPManagerTest.swift
//  DownloaderTests
//
//  Created by oren shalev on 15/02/2024.
//

import XCTest
@testable import Downloader

final class IAPManagerTest: XCTestCase {

    let iapManagerUserDefaults = UserDefaults(suiteName: "IAPManager")!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        iapManagerUserDefaults.removePersistentDomain(forName: "IAPManager")
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func test_isProductPurchased_NotPurchased() {
        MockDownloaderProducts.store = IAPManager(productIds: MockDownloaderProducts.productIdentifiers, userDefaults: iapManagerUserDefaults)
        let isPurchased = MockDownloaderProducts.store.isProductPurchased(MockDownloaderProducts.proVersion)
        XCTAssertFalse(isPurchased)
    }
    
    func test_isProductPurchased_Purchased() {
        iapManagerUserDefaults.set(true, forKey: MockDownloaderProducts.proVersion)
        MockDownloaderProducts.store = IAPManager(productIds: MockDownloaderProducts.productIdentifiers, userDefaults: iapManagerUserDefaults)
        let isPurchased = MockDownloaderProducts.store.isProductPurchased(MockDownloaderProducts.proVersion)
        XCTAssertTrue(isPurchased)
    }
}


class MockDownloaderProducts {
    
    static let proVersion = "ProVersion.1234"
    static let ProVersionOnlyAds = "ProVersion.OnlyAds.24"

    static let ProConsumable = "ProConsumable"

    static let productIdentifiers: Set<ProductIdentifier> = [proVersion, ProVersionOnlyAds, ProConsumable]
    
    static var store = IAPManager(productIds: productIdentifiers, userDefaults: UserDefaults.standard)

}

