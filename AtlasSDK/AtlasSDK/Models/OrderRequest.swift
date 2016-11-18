//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public struct OrderRequest: JSONRepresentable {

    public let checkoutId: String

    public init(checkoutId: String) {
        self.checkoutId = checkoutId
    }

    public func toJSON() -> Dictionary<String, AnyObject> {
        return [
            "checkout_id": self.checkoutId as AnyObject
        ]
    }

}
