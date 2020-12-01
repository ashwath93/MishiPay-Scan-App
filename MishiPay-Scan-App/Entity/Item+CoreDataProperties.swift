//
//  Item+CoreDataProperties.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 30/11/20.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var price: Float

}

extension Item : Identifiable {

}
