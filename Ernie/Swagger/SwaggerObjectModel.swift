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
    }
    
    var properties: [SwaggerModelProperty] = []
    
    func generateSwaggerSection() -> [String : Any]
    {
        return [:]
    }
}
