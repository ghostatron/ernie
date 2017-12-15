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
    
    init(primitiveType: SwaggerDataTypeEnum)
    {
        self.primitiveDataType = primitiveType
    }
    
    init(withObject objectModel: SwaggerObjectModel)
    {
        self.primitiveDataType = .Object
        self.objectModel = objectModel
    }
    
    init(asArrayOf arrayType: SwaggerDataType)
    {
        self.primitiveDataType = .Array
        self.arrayDataType = arrayType
    }
    
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
    
    var avatarOf: SWDataType?
    
    required convenience init?(avatarOf: NSManagedObject)
    {
        guard let avatarOf = avatarOf as? SWDataType else
        {
            return nil
        }

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
    
    func saveToCoreData()
    {
        
    }
}
