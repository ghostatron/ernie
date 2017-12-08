//
//  SwaggerDataTypeEnum.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
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
}
