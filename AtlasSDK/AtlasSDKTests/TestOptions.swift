//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

import AtlasSDK
import AtlasMockAPI

extension Options {

    static func forTests(interfaceLanguage: String = "en") -> Options {
        return Options(clientId: "partner_YCg9dRq",
                       salesChannel: "82fe2e7f-8c4f-4aa1-9019-b6bde5594456",
                       useSandbox: true,
                       interfaceLanguage: interfaceLanguage,
                       configurationURL: AtlasMockAPI.endpointURL(forPath: "/config"))
    }

}