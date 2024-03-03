//
//  AppOpenAdTest.swift
//  DownloaderTests
//
//  Created by oren shalev on 15/02/2024.
//

import XCTest
@testable import Downloader

final class AppOpenAdTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MockAppOpenAd.manager.userDefaults = UserDefaults(suiteName: "MockAppOpenAdd")!
        MockAppOpenAd.manager.userDefaults.removePersistentDomain(forName: "MockAppOpenAdd")
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

    func test_addOpenAppCount_increasesValueByOne() {
        MockAppOpenAd.manager.amountOfAppOpens = 1
        MockAppOpenAd.manager.addOpenAppCount()
        XCTAssert(MockAppOpenAd.manager.amountOfAppOpens == 2)
    }
    
}



class MockAppOpenAd: AppOpenAd {
    
    override init() {
        super.init()
        userDefaults = UserDefaults(suiteName: "MockAppOpenAdd")!
    }
}
