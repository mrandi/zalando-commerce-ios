//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import UIKit
import AtlasSDK

final public class AtlasUI {

    /**
     Configure AtlasUI.

     - Parameters:
        - options `Options`: provide an `Options` instance with at least 2 mandatory parameters **clientId** and **salesChannel**
            options could be nil, then Info.plist configuration would be used:
             - ATLASSDK_CLIENT_ID: String - Client Id (required)
             - ATLASSDK_SALES_CHANNEL: String - Sales Channel (required)
             - ATLASSDK_USE_SANDBOX: Bool - Indicates whether sandbox environment should be used
             - ATLASSDK_INTERFACE_LANGUAGE: String - Checkout interface language
        - completion `AtlasClientCompletion`: `AtlasResult` with success result as `AtlasAPIClient` initialized
    */
    public static func configure(options: Options? = nil, completion: AtlasClientCompletion) {
        Atlas.configure(options) { result in
            switch result {
            case .failure(let error):
                AtlasLogger.logError(error)
                completion(.failure(error))

            case .success(let client):
                do {
                    let localizer = try Localizer(localeIdentifier: client.config.interfaceLocale.localeIdentifier)
                    AtlasUI.register { localizer }
                    AtlasUI.register { client }
                    completion(.success(client))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }

    public static func presentCheckout(onViewController viewController: UIViewController, forProductSKU sku: String) {
        guard let _ = AtlasAPIClient.instance else { AtlasLogger.logError("AtlasUI is not initialized"); return }

        let atlasUIViewController = AtlasUIViewController(forProductSKU: sku)

        let checkoutTransitioning = CheckoutTransitioningDelegate()
        atlasUIViewController.transitioningDelegate = checkoutTransitioning
        atlasUIViewController.modalPresentationStyle = .Custom

        AtlasUI.register { atlasUIViewController }

        viewController.presentViewController(atlasUIViewController, animated: true, completion: nil)
    }

}

extension AtlasUI {

    private static let injector = Injector()

    static func register<T>(factory: Void -> T) {
        injector.register(factory)
    }

    static func provide<T>() throws -> T {
        return try injector.provide()
    }

}

extension AtlasAPIClient {

    static var instance: AtlasAPIClient? {
        return try? AtlasUI.provide()
    }

    static var countryCode: String? {
        return AtlasAPIClient.instance?.config.salesChannel.countryCode
    }

}