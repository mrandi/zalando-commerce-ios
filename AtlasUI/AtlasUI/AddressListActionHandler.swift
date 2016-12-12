//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

protocol AddressListActionHandlerDelegate: NSObjectProtocol {

    func created(address: EquatableAddress)
    func updated(address: EquatableAddress)
    func deleted(address: EquatableAddress)

}

protocol AddressListActionHandler {

    weak var delegate: AddressListActionHandlerDelegate? { get set }

    init(addressViewModelCreationStrategy: AddressViewModelCreationStrategy?)

    func createAddress()
    func update(address: EquatableAddress)
    func delete(address: EquatableAddress)

}