//
//  SwaggerModelProperty.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerModelProperty
{
    var propertyName: String
    var propertyDataType: SwaggerDataType
    var propertyIsRequired = false
    var propertyDescription: String?
    var propertyFormat: SwaggerDataTypeFormatEnum?
    var model: SwaggerObjectModel?
    private(set) var avatarOf: SWModelProperty?

    // MARK:- Initializers

    /**
     Creates a SwaggerModelProperty with the given |name| and |dataType|.
     */
    init(name: String, dataType: SwaggerDataType)
    {
        self.propertyName = name
        self.propertyDataType = dataType
    }
    
    /**
     Creates a SwaggerModelProperty that populates itself based on the data in the
     given SWModelProperty object.
     */
    convenience init?(avatarOf: SWModelProperty)
    {
        // Create the object using the standard init.
        guard
            let propertyName = avatarOf.propertyName,
            let swPropertyType = avatarOf.propertyDataType,
            let propertyType = SwaggerDataType(avatarOf: swPropertyType) else
        {
            return nil
        }
        self.init(name: propertyName, dataType: propertyType)
        self.avatarOf = avatarOf

        // Copy the properties over.
        self.propertyDescription = avatarOf.propertyDesciption
        self.propertyIsRequired = avatarOf.propertyIsRequired
        if let format = avatarOf.propertyFormat
        {
            self.propertyFormat = SwaggerDataTypeFormatEnum(rawValue: format)
        }
    }
    
    class func generatePropertyNamed(_ name: String, fromDictionary jsonDictionary: [String : Any]) -> SwaggerModelProperty?
    {
        // Must have a type for the property.  This could be provided via "schema" or "type".
        let schemaBody =  jsonDictionary["schema"] as? [String : Any]
        let typeString = jsonDictionary["type"] as? String
        let propertyType: SwaggerDataType?
        if let schemaBody = schemaBody
        {
            propertyType = SwaggerDataType.generateDataTypeFromDictionary(schemaBody)
            guard propertyType != nil else
            {
                return nil
            }
        }
        else if let typeString = typeString
        {
            propertyType = SwaggerDataType.dataTypeFromString(typeString)
            guard propertyType != nil else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
        
        // Create the property object and copy the info into it.
        let property = SwaggerModelProperty(name: name, dataType: propertyType!)
        property.propertyDescription = jsonDictionary["description"] as? String
        if let formatString = jsonDictionary["format"] as? String
        {
            property.propertyFormat = SwaggerDataTypeFormatEnum.enumFromString(formatString)
        }
        
        return property
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerSection() -> [String : Any]
    {
        var swaggerBody: [String : Any] = [:]
        swaggerBody["schema"] = self.propertyDataType.generateSwaggerSchemaSection()
        swaggerBody["format"] = self.propertyFormat?.stringValue()
        swaggerBody["description"] = self.propertyDescription
        return swaggerBody
    }
    
    @discardableResult func refreshCoreDataObject(autoSave: Bool = false) -> SWModelProperty?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWModelProperty", into: moc) as? SWModelProperty
            }
            guard let propertyToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the property properties properly (probably).
            propertyToReturn.propertyName = self.propertyName
            propertyToReturn.propertyDesciption = self.propertyDescription
            propertyToReturn.propertyIsRequired = self.propertyIsRequired
            propertyToReturn.propertyFormat = self.propertyFormat?.rawValue
            propertyToReturn.propertyDataType = self.propertyDataType.refreshCoreDataObject()
            
            // Save if requested.
            if autoSave
            {
                try? moc.save()
            }
        }
        
        return self.avatarOf
    }
    
    func removeFromCoreData(save: Bool = true)
    {
        // Make sure we have something to delete.
        guard let coreDataObject = self.avatarOf else
        {
            return
        }
        
        // Delete it.
        let moc = AppDelegate.mainManagedObjectContext()
        moc.delete(coreDataObject)
        
        // Save if asked too.
        if save
        {
            try? moc.save()
        }
        
        // Clean up any reference to the object.
        self.avatarOf = nil
    }
}
