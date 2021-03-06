//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

// TODO: document it, please...

public struct Customer {

    public let customerNumber: CustomerNumber
    public let gender: Gender
    public let firstName: String
    public let lastName: String
    public let email: String

}

extension Customer: JSONInitializable {

    init?(json: JSON) {
        guard let customerNumber = json["customer_number"].string,
            let gender = json["gender"].string,
            let firstName = json["first_name"].string,
            let lastName = json["last_name"].string,
            let email = json["email"].string
            else { return nil }

        self.customerNumber = customerNumber
        self.gender = Gender(rawValue: gender) ?? Gender.female // default value in Zalando registration
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }

}

extension Customer: CustomStringConvertible {

    public var description: String {
        return "Customer: { customer_numer: \(self.customerNumber)"
            + ", gender: \(self.gender)"
            + ", first_name: \(self.firstName)"
            + ", last_name: \(self.lastName)"
            + ", email: \(self.email)"
            + " }"
    }

}
