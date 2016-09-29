//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import UIKit
import AtlasSDK

public typealias AtlasCheckoutConfigurationCompletion = AtlasResult<AtlasCheckout> -> Void

typealias CreateCheckoutViewModelCompletion = AtlasResult<CheckoutViewModel> -> Void

public class AtlasCheckout: LocalizerProviderType {

    public let client: APIClient

    private init(client: APIClient) {
        self.client = client
    }

    lazy private(set) var localizer: Localizer = Localizer(localizationProvider: self)

    /**
     Configure AtlasCheckout.

     - Parameters:
        - options `Options`: provide an `Options` instance with at least 2 mandatory parameters **clientId** and **salesChannel**
            options could be nil, then Info.plist configuration would be used:
             - ATLASSDK_CLIENT_ID: String - Client Id (required)
             - ATLASSDK_SALES_CHANNEL: String - Sales Channel (required)
             - ATLASSDK_USE_SANDBOX: Bool - Indicates whether sandbox environment should be used
             - ATLASSDK_INTERFACE_LANGUAGE: String - Checkout interface language
        - completion `AtlasCheckoutConfigurationCompletion`: `AtlasResult` with success result as `AtlasCheckout` initialized
    */
    public static func configure(options: Options? = nil, completion: AtlasCheckoutConfigurationCompletion) {
        Atlas.configure(options) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let client):
                Injector.register { OAuth2AuthorizationHandler(loginURL: client.config.loginURL) as AuthorizationHandler }
                completion(.success(AtlasCheckout(client: client)))
            }
        }
    }

    public func presentCheckout(onViewController viewController: UIViewController, forProductSKU sku: String) {
        let atlasUIViewController = AtlasUIViewController(atlasCheckout: self, forProductSKU: sku)

        let checkoutTransitioning = CheckoutTransitioningDelegate()
        atlasUIViewController.transitioningDelegate = checkoutTransitioning
        atlasUIViewController.modalPresentationStyle = .Custom

        Injector.deregister(AtlasUIViewController.self)
        Injector.register { atlasUIViewController }

        viewController.presentViewController(atlasUIViewController, animated: true, completion: nil)
    }

    func createCheckoutViewModel(from checkoutViewModel: CheckoutViewModel,
        completion: CreateCheckoutViewModelCompletion) {
            createCheckoutViewModel(for: checkoutViewModel.selectedArticleUnit,
                addresses: checkoutViewModel.selectedAddresses, completion: completion)
    }

    func createCheckoutViewModel(for selectedArticleUnit: SelectedArticleUnit, addresses: CheckoutAddresses? = nil,
        completion: CreateCheckoutViewModelCompletion) {
            client.createCheckout(for: selectedArticleUnit, addresses: addresses) { checkoutResult in
                switch checkoutResult {
                case .failure(let error):
                    if case let AtlasAPIError.checkoutFailed(_, cartId, _) = error {
                        let checkoutModel = CheckoutViewModel(selectedArticleUnit: selectedArticleUnit, cartId: cartId)
                        completion(.success(checkoutModel))
                    } else {
                        completion(.failure(error))
                    }

                case .success(let checkout):
                    let checkoutModel = CheckoutViewModel(selectedArticleUnit: selectedArticleUnit, checkout: checkout)
                    completion(.success(checkoutModel))
                }
            }
    }

}

extension AtlasCheckout: Localizable {

    var localizedStringsBundle: NSBundle {
        return NSBundle(forClass: AtlasCheckout.self)
    }

    var localeIdentifier: String {
        return client.config.interfaceLocale.localeIdentifier
    }

}
