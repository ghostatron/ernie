//
//  SwaggerDataTypeFormatEnum.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

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
