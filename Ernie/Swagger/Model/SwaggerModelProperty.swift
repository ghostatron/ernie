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
    
    // MARK:- CoreDataAvatarDelegate

    func saveToCoreData()
    {
        
    }
}
