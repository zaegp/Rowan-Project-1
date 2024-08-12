//
//  Cart+CoreDataProperties.swift
//  
//
import Foundation
import CoreData

extension Cart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart> {
        return NSFetchRequest<Cart>(entityName: "Cart")
    }
    
    @NSManaged public var title: String
    @NSManaged public var mainImage: String
    @NSManaged public var price: String
    @NSManaged public var size: String
    @NSManaged public var color: String
    @NSManaged public var number: String
    @NSManaged public var stock: String
    @NSManaged public var colorName: String
    @NSManaged public var id: String
}
