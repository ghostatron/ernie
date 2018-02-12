//
//  SwaggerProductEnum.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

enum SwaggerProductEnum: String
{
    case JSON, PNG, GIF, JPG, PDF, XML
    
    func stringValue() -> String
    {
        switch self
        {
        case .JSON:
            return "application/json"
        case .PNG:
            return "image/png"
        case .GIF:
            return "image/gif"
        case .JPG:
            return "image/jpeg"
        case .PDF:
            return "image/pdf"
        case .XML:
            return "application/xml"
        }
    }
    
    static func enumFromString(_ enumString: String) -> SwaggerProductEnum?
    {
        switch enumString.lowercased()
        {
        case "application/json":
            return .JSON
        case "image/png":
            return .PNG
        case "image/gif":
            return .GIF
        case "image/jpeg":
            return .JPG
        case "image/pdf":
            return .PDF
        case "application/xml":
            return .XML
        default:
            return nil
        }
    }
}
