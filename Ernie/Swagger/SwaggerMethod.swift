//
//  SwaggerMethod.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerMethod
{
    enum SwaggerMethodType
    {
        case GET, POST, PUT, EVENT
    }
    
    class SwaggerMethodArgument
    {
        var argumentName: String
        var argumentType: SwaggerDataTypeEnum
        var argumentTypeObjectName: String?
        var argumentFormat: SwaggerDataTypeFormatEnum?
        var isArgumentRequired = false
        var argumentDescription: String?
        init(name: String, type: SwaggerDataTypeEnum)
        {
            self.argumentName = name
            self.argumentType = type
        }
        
        func generateSwaggerJson() -> [String : Any]
        {
            var argumentJson: [String : Any] = [:]
            argumentJson["name"] = self.argumentName
            argumentJson["description"] = self.argumentDescription
            argumentJson["in"] = ""
            argumentJson["schema"] = self.generateSwaggerSchemaSection()
            argumentJson["format"] = self.argumentFormat?.stringValue()
            return argumentJson
        }
        
        private func generateSwaggerSchemaSection() -> [String : Any]
        {
            var schemaJson: [String : Any] = [:]
            switch self.argumentType
            {
            case .Array:
                schemaJson["type"] = self.argumentType.stringValue()
                if let objectName = self.argumentTypeObjectName
                {
                    schemaJson["items"] = ["$ref" : "#/definitions/\(objectName)"]
                }
            case .Object:
                if let objectName = self.argumentTypeObjectName
                {
                    schemaJson["$ref"] = "#/definitions/\(objectName)"
                }
            default:
                schemaJson["type"] = self.argumentType.stringValue()
            }
            return schemaJson
        }
    }
    
    class SwaggerResponse
    {
        var responseHttpCode: Int = 200
        var responseDataType = SwaggerDataTypeEnum.Boolean
        var responseDescription: String?
    }
    
    /// The name of the method.
    var methodName: String
    
    /// Indicates what kind of method this is in the HTTP world.
    var methodType = SwaggerMethodType.GET
    
    /// An array of descriptive tags for the method.
    var methodTags: [String] = []
    
    /// A description of this method.
    var methodDescription: String?
    
    /// By default, this will match |methodName|.
    var methodOperationId: String
    
    /// The parameters that need to be passed to the method.
    var methodArguments: [SwaggerMethodArgument] = []
    
    /// The HTTP responses that can be generated by the method.
    var methodResponses: [SwaggerResponse] = []
    
    init(name: String)
    {
        self.methodName = name
        self.methodOperationId = name
    }
    
    func generateSwaggerSection() -> [String : Any]
    {
        return [:]
    }
}
