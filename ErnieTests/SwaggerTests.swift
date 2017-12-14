//
//  SwaggerTests.swift
//  ErnieTests
//
//  Created by Randy Haid on 12/11/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import XCTest
@testable import Ernie

class SwaggerTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testDataType()
    {
        let primitiveType = SwaggerDataType(primitiveType: .String)
        let primitiveJson = primitiveType.generateSwaggerSchemaSection()
        XCTAssert(primitiveJson.count == 1)
        XCTAssert(primitiveJson["type"] as? String == "string")
        
        let arrayType = SwaggerDataType(asArrayOf: primitiveType)
        let arrayJson = arrayType.generateSwaggerSchemaSection()
        XCTAssert(arrayJson.count == 2)
        XCTAssert(arrayJson["type"] as? String == "array")
        XCTAssertNotNil(arrayJson["items"] as? [String : Any])
        
        let object = SwaggerObjectModel(name: "swaggerTest")
        let objectType = SwaggerDataType(withObject: object)
        let objectJson = objectType.generateSwaggerSchemaSection()
        XCTAssert(objectJson.count == 1)
        XCTAssert(objectJson["$ref"] as? String == "#/definitions/swaggerTest")
    }
    
    func testSwaggerModel()
    {
        let stringType = SwaggerDataType(primitiveType: .String)
        let passwordProperty = SwaggerModelProperty(name: "UserPassword", dataType: stringType)
        passwordProperty.propertyDescription = "Just a simple string property formatted for a password"
        passwordProperty.propertyFormat = SwaggerDataTypeFormatEnum.Password
        let propertyJson = passwordProperty.generateSwaggerSection()
        XCTAssert(propertyJson.count == 3)
        XCTAssert(propertyJson["description"] as? String == passwordProperty.propertyDescription)
        XCTAssert(propertyJson["format"] as? String == passwordProperty.propertyFormat?.stringValue())
        XCTAssertNotNil(propertyJson["schema"] as? [String : Any])
        
        let boolType = SwaggerDataType(primitiveType: .Boolean)
        let boolProperty = SwaggerModelProperty(name: "AmICool", dataType: boolType)
        boolProperty.propertyDescription = "Please be yes, please be yes"
        boolProperty.propertyIsRequired = true
        let model = SwaggerObjectModel(name: "TestModel")
        model.properties = [passwordProperty, boolProperty]
        let modelJson = model.generateSwaggerSection()
        XCTAssert(modelJson.count == 3)
        XCTAssert(modelJson["type"] as? String == "object")
        XCTAssertNotNil(modelJson["required"] as? [String])
        XCTAssertNotNil(modelJson["properties"] as? [String : Any])
    }
    
    func testSwaggerMethodArgument()
    {
        let stringType = SwaggerDataType(primitiveType: .String)
        let argument = SwaggerMethodArgument(name: "arg1", type: stringType)
        argument.argumentDescription = "The first argument for the method"
        argument.argumentFormat = SwaggerDataTypeFormatEnum.DateTime
        let argumentJson = argument.generateSwaggerJson()
        XCTAssert(argumentJson.count == 6)
        XCTAssert(argumentJson["description"] as? String == argument.argumentDescription)
        XCTAssert(argumentJson["name"] as? String == argument.argumentName)
        XCTAssert(argumentJson["format"] as? String == argument.argumentFormat?.stringValue())
        XCTAssert(argumentJson["required"] as? Bool == false)
        XCTAssert(argumentJson["in"] as? String == "body")
    }
    
    func testSwaggerResponse()
    {
        let boolType = SwaggerDataType(primitiveType: .Boolean)
        let response = SwaggerResponse(code: "200", type: boolType)
        response.responseDescription = "It's all good"
        let responseJson = response.generateSwaggerJson()
        XCTAssert(responseJson.count == 2)
        XCTAssert(responseJson["description"] as? String == response.responseDescription)
        XCTAssertNotNil(responseJson["schema"] as? [String : Any])
    }
    
    func testSwaggerMethod()
    {
        let method = SwaggerMethod(name: "MyGetMethod", type: .GET)
        method.methodTags = ["awesome", "cool", "getonmylevel"]
        method.methodDescription = "Simple method for unit testing"
        method.methodSummary = "Yeah, so, like the description pretty much says it all...but the summary can be more detailed. You're welcome."
        let stringType = SwaggerDataType(primitiveType: .String)
        let argument = SwaggerMethodArgument(name: "arg1", type: stringType)
        method.methodArguments = [argument]
        
        let methodJson = method.generateSwaggerSection()
        guard let getSection = methodJson["get"] as? [String : Any] else
        {
            return
        }
        
        XCTAssert(getSection.count == 7)
        XCTAssert(getSection["operationId"] as? String == method.methodOperationId)
        XCTAssert(getSection["description"] as? String == method.methodDescription)
        XCTAssert(getSection["summary"] as? String == method.methodSummary)
        XCTAssertNotNil(getSection["produces"] as? [String])
        XCTAssertNotNil(getSection["responses"] as? [String : Any])
        XCTAssertNotNil(getSection["parameters"] as? [[String : Any]])
    }
    
    func testSwaggerContainer()
    {
        let container = SwaggerContainer()
        container.containerTitle = "THE Container"
        container.containerDescription = "This is my mega awesome unit test container"
        container.containerOwner = "Me. Duh."
        
        let method = SwaggerMethod(name: "MyGetMethod", type: .GET)
        method.methodTags = ["awesome", "cool", "getonmylevel"]
        method.methodDescription = "Simple method for unit testing"
        method.methodSummary = "Yeah, so, like the description pretty much says it all...but the summary can be more detailed. You're welcome."
        let stringType = SwaggerDataType(primitiveType: .String)
        let argument = SwaggerMethodArgument(name: "arg1", type: stringType)
        method.methodArguments = [argument]
        container.containerMethods = [method]
        
        let boolType = SwaggerDataType(primitiveType: .Boolean)
        let boolProperty = SwaggerModelProperty(name: "AmICool", dataType: boolType)
        boolProperty.propertyDescription = "Please be yes, please be yes"
        boolProperty.propertyIsRequired = true
        let model = SwaggerObjectModel(name: "TestModel")
        model.properties = [boolProperty]
        container.containerModels = [model]
        
        let containerJson = container.generateSwaggerJson()
        XCTAssert(containerJson.count == 5)
        XCTAssert(containerJson["swagger"] as? String == "2.0")
        XCTAssertNotNil(containerJson["info"] as? [String : Any])
        XCTAssertNotNil(containerJson["paths"] as? [String : Any])
        XCTAssertNotNil(containerJson["produces"] as? [String])
        XCTAssertNotNil(containerJson["definitions"] as? [String : Any])
    }
}
