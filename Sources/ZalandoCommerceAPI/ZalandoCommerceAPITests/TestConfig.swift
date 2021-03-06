//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation
import MockAPI

@testable import ZalandoCommerceAPI

extension Config {

    static func jsonForTests(options: Options = Options.forTests(), guestCheckoutEnabled: Bool = true) -> JSON {
        return JSON([
            "sales-channels": [
                ["locale": "es_ES", "sales-channel": "SPAIN", "toc_url": "https://www.zalando.es/cgc/"],
                ["locale": TestConsts.configLocale,
                 "sales-channel": options.salesChannel,
                 "toc_url": TestConsts.tocURL],
            ],
            "atlas-guest-checkout-api": ["enabled": guestCheckoutEnabled],
            "atlas-catalog-api": ["url": TestConsts.catalogURL.absoluteString],
            "atlas-checkout-gateway": ["url": TestConsts.gateway],
            "atlas-checkout-api": [
                "url": TestConsts.checkoutURL.absoluteString,
                "payment": [
                    "selection-callback": TestConsts.callback,
                    "third-party-callback": TestConsts.callback
                ]
            ],
            "oauth2-provider": ["url": TestConsts.loginURL.absoluteString]
            ])
    }

    static func forTests(options: Options = Options.forTests(), guestCheckoutEnabled: Bool = true) -> Config {
        let json = jsonForTests(options: options, guestCheckoutEnabled: guestCheckoutEnabled)
        return Config(json: json, options: options)!
    }

}
