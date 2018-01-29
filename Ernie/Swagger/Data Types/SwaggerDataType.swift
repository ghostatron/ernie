//
//  SwaggerDataType.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerDataType
{
    private(set) var primitiveDataType: SwaggerDataTypeEnum?
    private(set) var objectModel: SwaggerObjectModel?
    private(set) var arrayDataType: SwaggerDataType?
    private(set) var avatarOf: SWDataType?

    // MARK:- Initializers
    
    /**
     Creates a SwaggerDataType that encapsulates a primitive data type.  (i.e. Anything other
     than Object or Array.)
     */
    init(primitiveType: SwaggerDataTypeEnum)
    {
        self.primitiveDataType = primitiveType
    }
    
    /**
     Creates a SwaggerDataType that encapsulates an object model data type.
     */
    init(withObject objectModel: SwaggerObjectModel)
    {
        self.primitiveDataType = .Object
        self.objectModel = objectModel
    }
    
    /**
     Creates a SwaggerDataType that encapsulates an array containing elements of
     the given data type.
     */
    init(asArrayOf arrayType: SwaggerDataType)
    {
        self.primitiveDataType = .Array
        self.arrayDataType = arrayType
    }
    
    class func dataTypeFromString(_ dataTypeString: String) -> SwaggerDataType?
    {
        // Check for the primitive data types first.
        switch dataTypeString.lowercased()
        {
        case "bool":
            return SwaggerDataType(primitiveType: .Boolean)
        case "int":
            return SwaggerDataType(primitiveType: .Integer)
        case "string":
            return SwaggerDataType(primitiveType: .String)
        default:
            break
        }
        
        // It's either an array, an object model, or trash...
        
        // Check if it's an array.
        if dataTypeString.first == "[" && dataTypeString.last == "]"
        {
            let arrayDataTypeString = dataTypeString.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            guard let arrayDataType = SwaggerDataType.dataTypeFromString(arrayDataTypeString) else
            {
                return nil
            }
            return SwaggerDataType(asArrayOf: arrayDataType)
        }
        
        // Check if it's an object model.
        if let model = SwaggerObjectModel.getModelNamed(dataTypeString)
        {
            return SwaggerDataType(withObject: model)
        }
        
        // It's trash.
        return nil
    }
    
    /**
     Creates a SwaggerDataType that populates itself based on the data in the
     given SWDataType object.
     */
    convenience init?(avatarOf: SWDataType)
    {
        // Figure out which basic init to call and create the object.
        if let swArrayType = avatarOf.dataTypeArrayDataType, let arrayType = SwaggerDataType(avatarOf: swArrayType)
        {
            self.init(asArrayOf: arrayType)
            self.avatarOf = avatarOf
        }
        else if let swModel = avatarOf.dataTypeModel, let model = SwaggerObjectModel(avatarOf: swModel)
        {
            self.init(withObject: model)
            self.avatarOf = avatarOf
        }
        else if let primitiveType = avatarOf.simpleDataType, let primitiveTypeEnum = SwaggerDataTypeEnum(rawValue: primitiveType)
        {
            self.init(primitiveType: primitiveTypeEnum)
            self.avatarOf = avatarOf
        }
        else
        {
            return nil
        }
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerSchemaSection() -> [String : Any]
    {
        var schemaJson: [String : Any] = [:]
        
        if let arrayType = self.arrayDataType
        {
            schemaJson["type"] = "array"
            schemaJson["items"] = arrayType.generateSwaggerSchemaSection()
        }
        else if let model = self.objectModel
        {
            schemaJson["$ref"] = "#/definitions/\(model.modelName)"
        }
        else if let primitiveType = self.primitiveDataType
        {
            schemaJson["type"] = primitiveType.stringValue()
        }
        
        return schemaJson
    }
    
    @discardableResult func refreshCoreDataObject(autoSave: Bool = false) -> SWDataType?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWDataType", into: moc) as? SWDataType
            }
            guard let dataTypeToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the properties.
            dataTypeToReturn.simpleDataType = self.primitiveDataType?.rawValue
            dataTypeToReturn.dataTypeArrayDataType = self.arrayDataType?.refreshCoreDataObject()
            dataTypeToReturn.dataTypeModel = self.objectModel?.refreshCoreDataObject()
            
            // Save if requested.
            if autoSave
            {
                try? moc.save()
            }
        }
        
        return self.avatarOf
    }
    
    /**
     Provides a relatively human readable string for this data type.
     (This is intended for UI display, and isn't used in swagger generation.)
     */
    func stringValue() -> String
    {
        if let arrayType = self.arrayDataType
        {
            return "array of \(arrayType.stringValue())"
        }
        else if let model = self.objectModel
        {
            return model.modelName
        }
        else if let primitiveType = self.primitiveDataType
        {
            return primitiveType.rawValue
        }
        
        return ""
    }
}
