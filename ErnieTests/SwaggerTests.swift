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
        XCTAssert(propertyJson["description"] as? String == "Just a simple string property formatted for a password")
        XCTAssert(propertyJson["format"] as? String == "password")
        XCTAssertNotNil(propertyJson["schema"] as? [String : Any])
    }
}
