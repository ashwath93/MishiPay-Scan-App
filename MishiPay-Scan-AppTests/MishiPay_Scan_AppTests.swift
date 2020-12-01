//
//  MishiPay_Scan_AppTests.swift
//  MishiPay-Scan-AppTests
//
//  Created by Ashwath R on 29/11/20.
//

import XCTest
@testable import MishiPay_Scan_App

class MishiPay_Scan_AppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCameraStarted() {
        let viewModel = BarCodeVCViewModel()
        viewModel.startCamera()
        XCTAssertTrue(viewModel.captureSession.isRunning)
    }
    
    func testAddItemToCart() {
        let viewModel = BarCodeVCViewModel()
        viewModel.addItemToCart(name: "Coke")
        XCTAssertTrue(viewModel.cartItemsCount > 0)
    }
}
