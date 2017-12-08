//
//  SwaggerObjectModel.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerObjectModel
{
    class SwaggerModelProperty
    {
        var propertyName: String
        var propertyDataType: SwaggerDataTypeEnum
        var propertyIsRequired = false
        var propertyDescription: String?
        var propertyFormat: SwaggerDataTypeFormatEnum?

        init(name: String, dataType: SwaggerDataTypeEnum)
        {
            self.propertyName = name
            self.propertyDataType = dataType
        }
        
        func generateSwaggerSection() -> [String : Any]
        {
            var swaggerBody: [String : Any] = [:]
            swaggerBody["schema"] = self.propertyDataType.generateSwaggerSchemaSection(objectName: nil, arrayType: nil) // TODO
            swaggerBody["format"] = self.propertyFormat?.stringValue()
            swaggerBody["description"] = self.propertyDescription
            return swaggerBody
        }
    }
    
    var objectName: String
    var properties: [SwaggerModelProperty] = []
    
    init(name: String)
    {
        self.objectName = name
    }
    
    func generateSwaggerSection() -> [String : Any]
    {
        // Start off with a body that has the object's type in it.
        var swaggerBody: [String : Any] = [:]
        swaggerBody["type"] = "object"
        
        // Build an array to hold swagger sections for each property and also keep
        // track of which ones are required.
        var requiredProperties: [String] = []
        var propertySections: [String : Any] = [:]
        for property in self.properties
        {
            propertySections[property.propertyName] = property.generateSwaggerSection()
            if property.propertyIsRequired
            {
                requiredProperties.append(property.propertyName)
            }
        }

        // Add the "required" and "properties" sections to swaggerBody and we're done.
        swaggerBody["required"] = requiredProperties
        swaggerBody["properties"] = propertySections
        return swaggerBody
    }
}
