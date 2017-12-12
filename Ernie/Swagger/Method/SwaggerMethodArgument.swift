//
//  SwaggerMethodArgument.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerMethodArgument
{
    var argumentName: String
    var argumentType: SwaggerDataType
    var argumentFormat: SwaggerDataTypeFormatEnum?
    var isArgumentRequired = false
    var argumentDescription: String?
    init(name: String, type: SwaggerDataType)
    {
        self.argumentName = name
        self.argumentType = type
    }
    
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
}
