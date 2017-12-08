//
//  SwaggerResponse.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerResponse
{
    var responseHttpCode: String
    var responseDataType: SwaggerDataType
    var responseDescription: String?
    
    init(code: String, type: SwaggerDataType)
    {
        self.responseHttpCode = code
        self.responseDataType = type
    }
    
    func generateSwaggerJson() -> [String : Any]
    {
        var swaggerBody: [String : Any] = [:]
        swaggerBody["schema"] = self.responseDataType.generateSwaggerSchemaSection()
        if let description = self.responseDescription
        {
            swaggerBody["description"] = description
        }
        return swaggerBody
    }
}
