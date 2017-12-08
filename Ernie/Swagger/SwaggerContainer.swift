//
//  SwaggerContainer.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

enum SwaggerDataTypeEnum
{
    case Integer, String, Boolean, Array, Object
    
    func stringValue() -> String
    {
        switch self
        {
        case .Integer:
            return "integer"
        case .String:
            return "string"
        case .Boolean:
            return "boolean"
        case .Array:
            return "array"
        case .Object:
            return "#/definitions/???"
        }
    }
    
    /**
     Generates a schema swagger section for this data type.
     
     - note: If this is anything other than an Object or Array, then both parameters are ignored.
     
     - parameters:
     - objectName: Has dual meaning: If this is an Object, then this method needs to know the name of the object.
     If this is an Array, and its contents are Objects, then this method needs to know the name of that object type.
     - arrayType: If this is an Array, then this method needs to know what types are in the array.
     */
    // TODO: instead of object name, pass an optional model
    func generateSwaggerSchemaSection(objectName: String?, arrayType: SwaggerDataTypeEnum?) -> [String : Any]
    {
        var schemaJson: [String : Any] = [:]
        
        switch self
        {
        case .Array:
            schemaJson["type"] = "array"
            if let arrayType = arrayType
            {
                schemaJson["items"] = arrayType.generateSwaggerSchemaSection(objectName: objectName, arrayType: nil)
            }
        case .Object:
            if let objectName = objectName
            {
                schemaJson["$ref"] = "#/definitions/\(objectName)"
            }
        default:
            schemaJson["type"] = self.stringValue()
        }

        return schemaJson
    }
}

enum SwaggerDataTypeFormatEnum
{
    case Float, Double, Int32, Int64, DateTime, Date, Password
    
    func stringValue() -> String
    {
        switch self
        {
        case .Float:
            return "float"
        case .Double:
            return "double"
        case .Int32:
            return "int32"
        case .Int64:
            return "int64"
        case .DateTime:
            return "date-time"
        case .Date:
            return "date"
        case .Password:
            return "password"
        }
    }
}

enum SwaggerProductEnum
{
    case JSON, PNG, GIF, JPG, PDF
    
    func stringValue() -> String
    {
        switch self
        {
        case .JSON:
            return "application/json"
        case .PNG:
            return "image/png"
        case .GIF:
            return "image/gif"
        case .JPG:
            return "image/jpeg"
        case .PDF:
            return "image/pdf"
        }
    }
}

class SwaggerContainer
{
    var containerDescription: String?
    var containerTitle: String?
    var containerOwner: String?
    var containerMethods: [SwaggerMethod] = []
    var containerModels: [SwaggerObjectModel] = []
    
    func generateSwaggerJson() -> [String : Any]
    {
        // The top level has a swagger version, plus sections for "info", "paths", and "definitions".
        var swaggerJson: [String : Any] = [:]
        swaggerJson["swagger"] = "2.0"
        swaggerJson["info"] = self.generateSwaggerInfoSection()
        swaggerJson["paths"] = self.generateSwaggerPathsSection()
        swaggerJson["definitions"] = self.generateSwaggerDefinitionsSection()
        return swaggerJson
    }
    
    private func generateSwaggerInfoSection() -> [String : Any]
    {
        // The "info" section has a title, description, and contact/owner.
        var infoJson: [String : Any] = [:]
        infoJson["title"] = self.containerTitle ?? ""
        infoJson["description"] = self.containerDescription ?? ""
        if let owner = self.containerOwner
        {
            infoJson["contact"] = ["name" : owner]
        }
        return infoJson
    }
    
    private func generateSwaggerPathsSection() -> [String : Any]
    {
        // The "paths" section defines all the methods.
        var methodsForSection: [String : Any] = [:]
        for method in self.containerMethods
        {
            methodsForSection[method.methodName] = method.generateSwaggerSection()
        }
        return methodsForSection
    }
    
    private func generateSwaggerDefinitionsSection() -> [String : Any]
    {
        // The "definitions" section defines all the complex objects.
        var definitionsForSection: [String : Any] = [:]
        for definition in self.containerModels
        {
            definitionsForSection[definition.objectName] = definition.generateSwaggerSection()
        }
        return definitionsForSection
    }
}
