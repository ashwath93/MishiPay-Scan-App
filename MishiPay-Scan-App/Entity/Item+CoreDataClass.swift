//
//  Item+CoreDataClass.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 30/11/20.
//
//

import UIKit
import CoreData

public class Item: NSManagedObject, NSSecureCoding {
    
    public static var supportsSecureCoding: Bool = true
    
    class var entityDescription: NSEntityDescription {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return NSEntityDescription.entity(forEntityName: "Item", in: context)!
    }
    
    init(context: NSManagedObjectContext) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(entity: Item.entityDescription, insertInto: context)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(price, forKey: "price")
        coder.encode(image, forKey: "image")
    }
    
    public required init?(coder: NSCoder) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(entity: Item.entityDescription, insertInto: context)
        name = coder.decodeObject(forKey: "name") as? String
        price = coder.decodeFloat(forKey: "price")
        image = coder.decodeObject(forKey: "image") as? Data
    }
}
