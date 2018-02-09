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
        XCTAssertTrue(primitiveType?.primitiveDataType == .Boolean)
        
        // TODO: I think this works, but the model logic tries to hit core data which isn't available in unit tests.
//        let modelType = SwaggerDataType.generateDataTypeFromDictionary(self.modelDataTypeDictionary)
//        XCTAssertNotNil(modelType)
        
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
        
    }
    
    func testSwaggerMethod()
    {
        
    }
    
    func testSwaggerContainer()
    {
        
    }
}
