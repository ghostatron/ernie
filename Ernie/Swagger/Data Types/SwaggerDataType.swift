//
//  SwaggerDataType.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerDataType: CoreDataAvatarDelegate
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
    
    /**
     Creates a SwaggerDataType that populates itself based on the data in the
     given SWDataType object.
     */
    convenience init?(avatarOf: SWDataType)
    {
        // Figure out which basic init to call and create the object.
        if let primitiveType = avatarOf.primitiveDataType, let primitiveTypeEnum = SwaggerDataTypeEnum(rawValue: primitiveType)
        {
            self.init(primitiveType: primitiveTypeEnum)
            self.avatarOf = avatarOf
        }
        else if let swArrayType = avatarOf.dataTypeArrayDataType, let arrayType = SwaggerDataType(avatarOf: swArrayType)
        {
            self.init(asArrayOf: arrayType)
            self.avatarOf = avatarOf
        }
        else if let swModel = avatarOf.parentModel, let model = SwaggerObjectModel(avatarOf: swModel)
        {
            self.init(withObject: model)
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
            schemaJson["$ref"] = "#/definitions/\(model.objectName)"
        }
        else if let primitiveType = self.primitiveDataType
        {
            schemaJson["type"] = primitiveType.stringValue()
        }
        
        return schemaJson
    }
    
    // MARK:- CoreDataAvatarDelegate
    
    func saveToCoreData()
    {
        
    }
}
