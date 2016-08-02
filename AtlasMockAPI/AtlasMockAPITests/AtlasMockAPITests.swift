//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON

@testable import AtlasMockAPI

typealias JSONCompletion = JSON -> Void

class AtlasMockAPITests: XCTestCase {

    override static func setUp() {
        super.setUp()
        try! AtlasMockAPI.startServer()
    }

    override static func tearDown() {
        super.tearDown()
        try! AtlasMockAPI.stopServer()
    }

    func testRootEndpoint() {
        assertSuccessfulResponse(forEndpoint: "/")
    }

    func testCatalogEndpoint() {
        assertSuccessfulResponse(forEndpoint: "/articles") { json in
            XCTAssertEqual(json["content", 0, "id"].stringValue, "L2711E002-Q11")
        }
    }

    func testArticleEndpoint() {
        assertSuccessfulResponse(forEndpoint: "/articles/AD541L009-G11") { json in
            XCTAssertEqual(json["activationDate"].stringValue, "2015-07-04T10:25:19+02:00")
        }
    }

    private func assertSuccessfulResponse(method: Alamofire.Method = .GET, forEndpoint endpoint: String, completion: JSONCompletion? = nil) {
        let expectation = expectationWithDescription("assertSuccessfulResponse \(endpoint)")

        let url = AtlasMockAPI.endpointURL(forPath: endpoint)
        Alamofire.request(method, url).responseString { response in

            guard let data = response.data else {
                XCTFail()
                return
            }

            if let completion = completion {
                let json = SwiftyJSON.JSON(data: data)
                completion(json)
            }

            XCTAssertTrue(response.result.isSuccess)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

}
