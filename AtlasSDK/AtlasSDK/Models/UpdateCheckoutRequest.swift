//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public struct UpdateCheckoutRequest {
    public let billingAddressId: String?
    public let shippingAddressId: String?
}

extension UpdateCheckoutRequest: JSONRepresentable {

    private struct Keys {
        static let billingAddressId = "billing_address_id"
        static let shippingAddressId = "shipping_address_id"
    }

    func toJSON() -> [String: AnyObject] {
        var result = [String: AnyObject]()

        if let billingAddressId = billingAddressId where !billingAddressId.isEmpty {
            result[Keys.billingAddressId] = billingAddressId
        }
        if let shippingAddressId = shippingAddressId where !shippingAddressId.isEmpty {
            result[Keys.shippingAddressId] = shippingAddressId
        }
        return result
    }
}

extension UpdateCheckoutRequest {
    public init(billingAddressId: String, shippingAddressId: String) {
        self.shippingAddressId = shippingAddressId
        self.billingAddressId = billingAddressId
    }
}
