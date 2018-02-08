//
//  SwaggerDataTypeFormatEnum.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

enum SwaggerDataTypeFormatEnum: String
{
    case None, Float, Double, Long, Int32, Int64, DateTime, Date, Password
    
    func stringValue() -> String
    {
        switch self
        {
        case .Float:
            return "float"
        case .Long:
            return "long"
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
        case .None:
            return ""
        }
    }
    
    static func enumFromString(_ enumString: String) -> SwaggerDataTypeFormatEnum
    {
        switch enumString.lowercased()
        {
        case "float":
            return .Float
        case "long":
            return .Long
        case "double":
            return .Double
        case "int32":
            return .Int32
        case "int64":
            return .Int64
        case "date-time":
            return .DateTime
        case "date":
            return .Date
        case "password":
            return .Password
        default:
            return .None
        }
    }
}
