//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

enum AnimationDuration: TimeInterval {

    case noAnimation = 0
    case fast = 0.35
    case normal = 0.5
    case slow = 1

    static let `default` = AnimationDuration.fast

}
