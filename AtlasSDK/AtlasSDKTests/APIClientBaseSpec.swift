//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

import Foundation
import Quick
import Nimble
import AtlasMockAPI

@testable import AtlasSDK

class APIClientBaseSpec: QuickSpec {

    override class func setUp() {
        super.setUp()
        try! AtlasMockAPI.startServer() // swiftlint:disable:this force_try
    }

    override class func tearDown() {
        super.tearDown()
        try! AtlasMockAPI.stopServer() // swiftlint:disable:this force_try
    }

    private let clientOptions = Options(clientId: "atlas_Y2M1MzA",
        salesChannel: "82fe2e7f-8c4f-4aa1-9019-b6bde5594456",
        useSandbox: true, interfaceLanguage: "en_DE",
        configurationURL: AtlasMockAPI.endpointURL(forPath: "/config"))

    func waitUntilAPIClientIsConfigured(actions: (done: () -> Void, client: APIClient) -> Void) {
        waitUntil(timeout: 10) { done in
            Atlas.configure(self.clientOptions) { result in
                switch result {
                case .failure(let error):
                    fail(String(error))
                case .success(let client):
                    actions(done: done, client: client)
                }
            }
        }
    }

    func dataWithJSONObject(object: AnyObject) -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(object, options: []) // swiftlint:disable:this force_try
    }

    func mockedAPIClient(forURL url: NSURL, data: NSData?, statusCode: Int, errorCode: Int? = nil) -> APIClient {
        let apiURL = AtlasMockAPI.endpointURL(forPath: "/")
        let config = Config(catalogAPIURL: apiURL,
            checkoutAPIURL: apiURL,
            loginURL: apiURL, options: clientOptions)
        var client = APIClient(config: config)

        var error: NSError? = nil
        if let errorCode = errorCode {
            error = NSError(domain: "NSURLErrorDomain", code: errorCode, userInfo: nil)
        }

        client.urlSession = URLSessionMock(data: data,
            response: NSHTTPURLResponse(URL: url, statusCode: statusCode),
            error: error)

        return client
    }

}
