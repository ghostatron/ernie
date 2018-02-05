//
//  SwaggerObjectModel.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerObjectModel
{
    var modelName: String
    var modelProperties: [SwaggerModelProperty] = []
    private(set) var avatarOf: SWObjectModel?

    // MARK:- Initializers
    
    /**
     Creates a SwaggerObjectModel with the given |name|.
     */
    init(name: String)
    {
        self.modelName = name
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
            // This protects against an infinite loop: You can't let a model have a property that
            // has a data type of that model. i.e. don't let a model reference itself in a property.
            if swProperty.propertyDataType?.dataTypeModel === self.avatarOf
            {
                continue
            }
            
            if let property = SwaggerModelProperty(avatarOf: swProperty)
            {
                property.model = self
                self.modelProperties.append(property)
            }
        }
    }
    
    class func generateModelFromDictionary(_ jsonDictionary: [String : Any]) -> SwaggerObjectModel?
    {
        return nil
    }
    
    class func getAllModels(sorted: Bool = false) -> [SwaggerObjectModel]
    {
        var allModels: [SwaggerObjectModel] = []
        
        let request: NSFetchRequest<SWObjectModel> = SWObjectModel.fetchRequest()
        if sorted
        {
            let nameSorter = NSSortDescriptor(key: "modelName", ascending: true)
            request.sortDescriptors = [nameSorter]
        }
        let swModels = try? AppDelegate.mainManagedObjectContext().fetch(request)
        for swModel in swModels ?? []
        {
            if let model = SwaggerObjectModel(avatarOf: swModel)
            {
                allModels.append(model)
            }
        }
        
        return allModels
    }
    
    class func getModelNamed(_ modelName: String) -> SwaggerObjectModel?
    {
        let request: NSFetchRequest<SWObjectModel> = SWObjectModel.fetchRequest()
        request.predicate = NSPredicate(format: "modelName = %k", argumentArray: [modelName])
        let swModels = try? AppDelegate.mainManagedObjectContext().fetch(request)
        guard let swModel = swModels?.first else
        {
            return nil
        }
        return SwaggerObjectModel(avatarOf: swModel)
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
        for property in self.modelProperties
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
        
    @discardableResult func refreshCoreDataObject(autoSave: Bool = false) -> SWObjectModel?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWObjectModel", into: moc) as? SWObjectModel
            }
            guard let modelToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the properties.
            modelToReturn.modelName = self.modelName
            if let oldProperties = modelToReturn.modelProperties, oldProperties.count > 0
            {
                modelToReturn.removeFromModelProperties(oldProperties)
            }
            for property in self.modelProperties
            {
                if let propertyAvatar = property.refreshCoreDataObject()
                {
                    modelToReturn.addToModelProperties(propertyAvatar)
                }
            }
            
            // Save if requested.
            if autoSave
            {
                try? moc.save()
            }
        }
        
        return self.avatarOf
    }
    
    func removeFromCoreData(save: Bool = true)
    {
        // Make sure we have something to delete.
        guard let coreDataObject = self.avatarOf else
        {
            return
        }
        
        // Delete it.
        let moc = AppDelegate.mainManagedObjectContext()
        moc.delete(coreDataObject)
        
        // Save if asked too.
        if save
        {
            try? moc.save()
        }
        
        // Clean up any reference to the object.
        self.avatarOf = nil
    }
}
