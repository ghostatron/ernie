//
//  SwaggerModelProperty.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerModelProperty
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
}
