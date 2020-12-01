//
//  Utilities.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 01/12/20.
//

import UIKit
import CoreData

class Utilities {
    
    class func saveCartItems(_ items: [Item]) {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            let cart = Cart(context: context)
            cart.items = try NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
            try context.save()
        } catch {
            print("Failed")
        }
    }
}
