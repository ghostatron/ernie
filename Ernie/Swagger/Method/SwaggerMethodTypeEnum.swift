//
//  SwaggerMethodTypeEnum.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

enum SwaggerMethodTypeEnum: String
{
    case GET, POST, PUT, DELETE, EVENT
    
    func toString() -> String
    {
        switch self
        {
        case .GET:
            return "get"
        case .POST:
            return "post"
        case .PUT:
            return "put"
        case .DELETE:
            return "delete"
        case .EVENT:
            return "event"
        }
    }
    
    static func typeFromString(_ type: String) -> SwaggerMethodTypeEnum?
    {
        switch type.lowercased()
        {
        case "get":
            return .GET
        case "post":
            return .POST
        case "put":
            return .PUT
        case "delete":
            return .DELETE
        case "event":
            return .EVENT
        default:
            return nil
        }
    }
}
