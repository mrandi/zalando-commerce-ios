//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

extension NSData {

    public convenience init?(json: [String: AnyObject]?) throws {
        guard let json = json else { return nil }
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
            self.init(data: data)
        } catch let e {
            logError(e)
            throw e
        }
    }

}
