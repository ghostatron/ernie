//
//  SwaggerImportTests.swift
//  ErnieTests
//
//  Created by Randy Haid on 2/7/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import XCTest
@testable import Ernie

class SwaggerImportTests: XCTestCase
{
    // MARK:- Test Dictionaries
    
    private let primitiveDataTypeDictionary = ["type" : "string", "format" : "password"]
    private let modelDataTypeDictionary = ["$ref" : "#/definitions/someModel"]
    private let arrayDataTypeDictionary: [String : Any] = ["type" : "array", "items" : ["type" : "string"]]
    
    private func primitiveModelPropertyDictionary() -> [String : Any]
    {
        var propertyDictionary = self.primitiveDataTypeDictionary
        propertyDictionary["description"] = "somePropertyDescription"
        return propertyDictionary
    }
    
    private func simpleModelDictionary() -> [String : Any]
    {
        let properties: [String : Any] = ["someProperty" : self.primitiveModelPropertyDictionary()]
        let required = ["someProperty"]
        return ["type" : "object", "properties" : properties, "required" : required]
    }
    
    private func response200Dictionary() -> [String : Any]
    {
        return ["description" : "A 200 response is good", "schema" : self.primitiveDataTypeDictionary]
    }
    
    private func primitiveMethodArgumentDictionary(required: Bool = false) -> [String : Any]
    {
        var argDictionary: [String : Any] = [:]
        argDictionary["name"] = "SomePrimitiveArgument"
        argDictionary["description"] = "The name kinda says it all"
        argDictionary["required"] = required
        argDictionary["schema"] = self.primitiveDataTypeDictionary
        return argDictionary
    }
    
    private func simpleGetMethodDictionary() -> [String : [String : Any]]
    {
        var getBody: [String : Any] = [:]
        getBody["tags"] = ["tag1", "tag2"]
        getBody["summary"] = "My awesome method summary"
        getBody["description"] = "My even more awesome description"
        getBody["produces"] = ["application/json"]
        getBody["responses"] = ["200" : self.response200Dictionary()]
        return ["get" : getBody]
    }
    
    private func simplePostMethodDictionary() -> [String : [String : Any]]
    {
        var postBody: [String : Any] = [:]
        postBody["tags"] = ["tag1", "tag2"]
        postBody["summary"] = "My awesome method summary"
        postBody["description"] = "My even more awesome description"
        postBody["produces"] = ["application/json"]
        postBody["responses"] = ["200" : self.response200Dictionary()]
        postBody["parameters"] = [self.primitiveMethodArgumentDictionary()]
        return ["post" : postBody]
    }
    
    private func containerDictionary() -> [String : Any]
    {
        var containerBody: [String : Any] = [:]
        containerBody["paths"] = ["AwesomeMethod" : self.simpleGetMethodDictionary()]
        containerBody["definitions"] = ["someModel" : self.simpleModelDictionary()]
        containerBody["produces"] =  ["application/json"]
        var infoBody: [String : Any] = [:]
        infoBody["description"] = "myDescription"
        infoBody["title"] = "myTitle"
        infoBody["contact"] = ["name" : "Randy"]
        containerBody["info"] = infoBody
        return containerBody
    }
    
    // MARK:- Alpha and Omega
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK:- Test Methods
    
    func testSwaggerDataType()
    {
        let primitiveType = SwaggerDataType.generateDataTypeFromDictionary(self.primitiveDataTypeDictionary)
        XCTAssertNotNil(primitiveType)
        XCTAssertTrue(primitiveType?.primitiveDataType == .String)
        
        let modelType = SwaggerDataType.generateDataTypeFromDictionary(self.modelDataTypeDictionary)
        XCTAssertNotNil(modelType)
        
        let arrayType = SwaggerDataType.generateDataTypeFromDictionary(self.arrayDataTypeDictionary)
        XCTAssertNotNil(arrayType)
        XCTAssertTrue(arrayType?.primitiveDataType == .Array)
        XCTAssertNotNil(arrayType?.arrayDataType)
        XCTAssertTrue(arrayType?.arrayDataType?.primitiveDataType == .String)
    }
    
    func testSwaggerModelProperty()
    {
        let primitiveProperty = SwaggerModelProperty.generatePropertyNamed("someProperty", fromDictionary: self.primitiveModelPropertyDictionary())
        XCTAssertNotNil(primitiveProperty)
        XCTAssertTrue(primitiveProperty?.propertyName == "someProperty")
        XCTAssertTrue(primitiveProperty?.propertyFormat == .Password)
        XCTAssertFalse(primitiveProperty?.propertyIsRequired ?? false)
        XCTAssertTrue(primitiveProperty?.propertyDescription == "somePropertyDescription")
        XCTAssertTrue(primitiveProperty?.propertyDataType.primitiveDataType == .String)
    }
    
    func testSwaggerModel()
    {
        let simpleModel = SwaggerObjectModel.generateModelNamed("someModel", fromDictionary: self.simpleModelDictionary())
        XCTAssertNotNil(simpleModel)
        XCTAssertTrue(simpleModel?.modelName == "someModel")
        XCTAssertTrue(simpleModel?.modelProperties.count == 1)
        XCTAssertTrue(simpleModel?.modelProperties.first?.propertyIsRequired ?? false)
    }
    
    func testSwaggerResponse()
    {
        let response = SwaggerResponse.generateResponseForCode("200", fromDictionary: self.response200Dictionary())
        XCTAssertNotNil(response)
        XCTAssertTrue(response?.responseHttpCode == "200")
        XCTAssertTrue(response?.responseDescription == "A 200 response is good")
        XCTAssertNotNil(response?.responseDataType)
        XCTAssertTrue(response?.responseDataType.primitiveDataType == .String)
    }
    
    func testSwaggerMethodArgument()
    {
        let argument = SwaggerMethodArgument.generateArgumentFromDictionary(self.primitiveMethodArgumentDictionary(required: true))
        XCTAssertNotNil(argument)
        XCTAssertTrue(argument?.argumentName == "SomePrimitiveArgument")
        XCTAssertTrue(argument?.argumentDescription == "The name kinda says it all")
        XCTAssertTrue(argument?.isArgumentRequired ?? false)
        XCTAssertNotNil(argument?.argumentType)
        XCTAssertTrue(argument?.argumentType.primitiveDataType == .String)
    }
    
    func testSwaggerMethod()
    {
        let methodArray = SwaggerMethod.generateMethodNamed("AwesomeMethod", fromDictionary: self.simpleGetMethodDictionary())
        XCTAssertNotNil(methodArray)
        XCTAssertTrue(methodArray?.count == 1)
        let method = methodArray?.first!
        XCTAssertTrue(method?.methodSummary == "My awesome method summary")
        XCTAssertTrue(method?.methodDescription == "My even more awesome description")
        XCTAssertTrue(method?.methodName == "AwesomeMethod")
        XCTAssertTrue(method?.methodTags.count == 2)
        XCTAssertTrue(method?.methodProducts.count == 1)
        XCTAssertTrue(method?.methodArguments.count == 0)
        XCTAssertTrue(method?.methodResponses.count == 1)
    }
    
    func testSwaggerContainer()
    {
        let container = SwaggerContainer.generateContainerFromDictionary(self.containerDictionary())
        XCTAssertNotNil(container)
        XCTAssertTrue(container?.containerTitle == "myTitle")
        XCTAssertTrue(container?.containerDescription == "myDescription")
        XCTAssertTrue(container?.containerOwner == "Randy")
        XCTAssertTrue(container?.containerMethods.count == 1)
        XCTAssertTrue(container?.containerModels.count == 1)
        XCTAssertTrue(container?.containerProducts.count == 1)
    }
}
