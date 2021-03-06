//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

public struct GuestCheckoutAddress: EquatableAddress {

    public let id: AddressId
    public let gender: Gender
    public let firstName: String
    public let lastName: String
    public let street: String?
    public let additional: String?
    public let zip: String
    public let city: String
    public let countryCode: String
    public let pickupPoint: PickupPoint?

}
