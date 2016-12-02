//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import Swifter
import SwiftyJSON

extension HttpServer {

    func addGuestOrder() {
        let path = "/guest-checkout/api/orders"

        self[path] = { request in
            let data = NSData(bytes: &request.body, length: request.body.count)
            let json = JSON(data: data)
            if json["payment"] == nil {
                let url = "https://payment-gateway.kohle-integration.zalan.do/payment-method-selection-session/TOKEN/selection"
                return HttpResponse.RAW(204, "No Content", ["Location": url], nil)
            } else {
                // swiftlint:disable:next line_length
                let json = "{\"order_number\":\"10105083300694\",\"billing_address\":{\"gender\":\"MALE\",\"first_name\":\"John\",\"last_name\":\"Doe\",\"street\":\"Mollstr. 1\",\"zip\":\"10178\",\"city\":\"Berlin\",\"country_code\":\"DE\"},\"shipping_address\":{\"gender\":\"MALE\",\"first_name\":\"John\",\"last_name\":\"Doe\",\"street\":\"Mollstr. 1\",\"zip\":\"10178\",\"city\":\"Berlin\",\"country_code\":\"DE\"},\"gross_total\":{\"amount\":10.45,\"currency\":\"EUR\"},\"tax_total\":{\"amount\":2.34,\"currency\":\"EUR\"},\"created\":\"2016-11-29T14:14:25.126Z\"}"
                return .OK(.Text(json))
            }
        }
    }

}
