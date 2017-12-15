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
    private(set) var avatarOf: SWObjectModel?

    // MARK:- Initializers
    
    /**
     Creates a SwaggerObjectModel with the given |name|.
     */
    init(name: String)
    {
        self.objectName = name
    }
    
    /**
     Creates a SwaggerObjectModel that populates itself based on the data in the
     given SWObjectModel object.
     */
    convenience init?(avatarOf: SWObjectModel)
    {
        // Create the object using the standard init.
        guard let modelName = avatarOf.modelName else
        {
            return nil
        }
        self.init(name: modelName)
        self.avatarOf = avatarOf

        // Copy each property over.
        for swProperty in avatarOf.modelProperties?.allObjects as? [SWModelProperty] ?? []
        {
            if let property = SwaggerModelProperty(avatarOf: swProperty)
            {
                self.properties.append(property)
            }
        }
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
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
    
    func saveToCoreData()
    {
        
    }
}
