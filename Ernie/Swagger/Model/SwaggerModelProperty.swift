//
//  SwaggerModelProperty.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerModelProperty: CoreDataAvatarDelegate
{
    var propertyName: String
    var propertyDataType: SwaggerDataType
    var propertyIsRequired = false
    var propertyDescription: String?
    var propertyFormat: SwaggerDataTypeFormatEnum?
    
    init(name: String, dataType: SwaggerDataType)
    {
        self.propertyName = name
        self.propertyDataType = dataType
    }
    
    func generateSwaggerSection() -> [String : Any]
    {
        var swaggerBody: [String : Any] = [:]
        swaggerBody["schema"] = self.propertyDataType.generateSwaggerSchemaSection()
        swaggerBody["format"] = self.propertyFormat?.stringValue()
        swaggerBody["description"] = self.propertyDescription
        return swaggerBody
    }
    
    // MARK:- CoreDataAvatarDelegate
    
    var avatarOf: SWModelProperty?
    
    convenience required init?(avatarOf: NSManagedObject)
    {
        guard
            let avatarOf = avatarOf as? SWModelProperty,
            let propertyName = avatarOf.propertyName,
            let swPropertyType = avatarOf.propertyDataType,
            let propertyType = SwaggerDataType(avatarOf: swPropertyType) else
        {
            return nil
        }
        
        self.init(name: propertyName, dataType: propertyType)
        self.avatarOf = avatarOf
        self.propertyDescription = avatarOf.propertyDesciption
        self.propertyIsRequired = avatarOf.propertyIsRequired
        if let format = avatarOf.propertyFormat
        {
            self.propertyFormat = SwaggerDataTypeFormatEnum(rawValue: format)
        }
    }
    
    func saveToCoreData()
    {
        
    }
}
