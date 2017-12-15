//
//  SwaggerObjectModel.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerObjectModel: CoreDataAvatarDelegate
{
    var objectName: String
    var properties: [SwaggerModelProperty] = []
    
    init(name: String)
    {
        self.objectName = name
    }
    
    func generateSwaggerSection() -> [String : Any]
    {
        // Start off with a body that has the object's type in it.
        var swaggerBody: [String : Any] = [:]
        swaggerBody["type"] = "object"
        
        // Build an array to hold swagger sections for each property and also keep
        // track of which ones are required.
        var requiredProperties: [String] = []
        var propertySections: [String : Any] = [:]
        for property in self.properties
        {
            propertySections[property.propertyName] = property.generateSwaggerSection()
            if property.propertyIsRequired
            {
                requiredProperties.append(property.propertyName)
            }
        }

        // Add the "required" and "properties" sections to swaggerBody and we're done.
        swaggerBody["required"] = requiredProperties
        swaggerBody["properties"] = propertySections
        return swaggerBody
    }
    
    // MARK:- CoreDataAvatarDelegate
    
    var avatarOf: SWObjectModel?
    
    required convenience init?(avatarOf: NSManagedObject)
    {
        guard let avatarOf = avatarOf as? SWObjectModel, let modelName = avatarOf.modelName else
        {
            return nil
        }
        
        self.init(name: modelName)
        for swProperty in avatarOf.modelProperties?.allObjects as? [SWModelProperty] ?? []
        {
            if let property = SwaggerModelProperty(avatarOf: swProperty)
            {
                self.properties.append(property)
            }
        }
    }
    
    func saveToCoreData()
    {
        
    }
}
