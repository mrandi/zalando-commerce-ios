//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

protocol SalesChannelEndpoint: Endpoint {

    var salesChannel: String { get }

}

extension SalesChannelEndpoint {

    var headers: [String: Any]? {
        return ["X-Sales-Channel": salesChannel]
    }

}
