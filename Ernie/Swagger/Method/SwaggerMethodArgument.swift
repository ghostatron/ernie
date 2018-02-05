//
//  SwaggerMethodArgument.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerMethodArgument
{
    var argumentName: String
    var argumentType: SwaggerDataType
    var argumentFormat: SwaggerDataTypeFormatEnum?
    var isArgumentRequired = false
    var argumentDescription: String?
    private(set) var avatarOf: SWMethodArgument?
    
    // MARK:- Initializers
    
    /**
     Creates a SwaggerMethodArgument with the given |name| and |type|.
     */
    init(name: String, type: SwaggerDataType)
    {
        self.argumentName = name
        self.argumentType = type
    }
    
    /**
     Creates a SwaggerMethodArgument that populates itself based on the data in the
     given SwaggerMethodArgument object.
     */
    convenience init?(avatarOf: SWMethodArgument)
    {
        // Create the object using the standard init.
        guard
            let argName = avatarOf.argName,
            let swArgType = avatarOf.argType,
            let argType = SwaggerDataType(avatarOf: swArgType) else
        {
            return nil
        }
       self.init(name: argName, type: argType)
        self.avatarOf = avatarOf
        
        // Copy each property over.
        if let format = avatarOf.argFormat
        {
            self.argumentFormat = SwaggerDataTypeFormatEnum(rawValue: format)
        }
        self.isArgumentRequired = avatarOf.argIsRequired
        self.argumentDescription = avatarOf.argDescription
    }
    
    class func generateArgumentFromJSON(_ json: String) -> SwaggerMethodArgument?
    {
        return nil
    }
    
    // MARK:- Misc.
    
    func swiftSignature() -> String
    {
        var swiftArgument = "\(self.argumentName): \(self.argumentType.stringValue())"
        if !self.isArgumentRequired
        {
            swiftArgument += "?"
        }
        return swiftArgument
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerJson() -> [String : Any]
    {
        var argumentJson: [String : Any] = [:]
        argumentJson["name"] = self.argumentName
        argumentJson["description"] = self.argumentDescription
        argumentJson["required"] = self.isArgumentRequired
        argumentJson["in"] = "body"
        argumentJson["schema"] = self.argumentType.generateSwaggerSchemaSection()
        argumentJson["format"] = self.argumentFormat?.stringValue()
        return argumentJson
    }
    
    @discardableResult func refreshCoreDataObject(autoSave: Bool = false) -> SWMethodArgument?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWMethodArgument", into: moc) as? SWMethodArgument
            }
            guard let argumentToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the properties.
            argumentToReturn.argName = self.argumentName
            argumentToReturn.argDescription = self.argumentDescription
            argumentToReturn.argIsRequired = self.isArgumentRequired
            argumentToReturn.argType = self.argumentType.refreshCoreDataObject()
            argumentToReturn.argFormat = self.argumentFormat?.rawValue
            
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
