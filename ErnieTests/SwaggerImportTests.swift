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
    private let primitiveDataTypeDictionary = ["type" : "string", "format" : "password"]
    private let modelDataTypeDictionary = ["$ref" : "#/definitions/someModel"]
    private let arrayDataTypeDictionary: [String : Any] = ["type" : "array", "items" : ["type" : "string"]]
    
    private func primitiveModelPropertyDictionary() -> [String : Any]
    {
        var propertyDictionary = self.primitiveDataTypeDictionary
        propertyDictionary["description"] = "somePropertyDescription"
        return propertyDictionary
    }
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
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
        
    }
    
    func testSwaggerResponse()
    {
        
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
