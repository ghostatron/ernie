//
//  SwaggerContainer.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerContainer: CoreDataAvatarDelegate
{
    var containerDescription: String?
    var containerTitle: String?
    var containerOwner: String?
    var containerMethods: [SwaggerMethod] = []
    var containerModels: [SwaggerObjectModel] = []

    /// A list of the type of files that can be created with by the methods in this container.
    var containerProducts: [SwaggerProductEnum] = []

    private(set) var avatarOf: SWContainer?
    
    // MARK:- Initializers
    
    /**
     Creates a SwaggerContainer that populates itself based on the data in the
     given SWContainer object.
     */
    convenience init?(avatarOf: SWContainer)
    {
        // Create the object using the standard init.
        self.init()
        self.avatarOf = avatarOf
        
        // Copy the properties over.
        self.containerDescription = avatarOf.containerDescription
        self.containerTitle = avatarOf.containerName
        self.containerOwner = avatarOf.containerOwner
        for swMethod in avatarOf.containerMethods?.allObjects as? [SWMethod] ?? []
        {
            if let method = SwaggerMethod(avatarOf: swMethod)
            {
                self.containerMethods.append(method)
            }
        }
        for swModel in avatarOf.containerModels?.allObjects as? [SWObjectModel] ?? []
        {
            if let model = SwaggerObjectModel(avatarOf: swModel)
            {
                self.containerModels.append(model)
            }
        }
    }

    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerJson() -> [String : Any]
    {
        // The top level has a swagger version, plus sections for "info", "paths", and "definitions".
        var swaggerJson: [String : Any] = [:]
        swaggerJson["swagger"] = "2.0"
        swaggerJson["info"] = self.generateSwaggerInfoSection()
        swaggerJson["produces"] = self.generateSwaggerProducesSection()
        swaggerJson["paths"] = self.generateSwaggerPathsSection()
        swaggerJson["definitions"] = self.generateSwaggerDefinitionsSection()
        return swaggerJson
    }
    
    /**
     Generates a dictionary that represents this object's Info section in a format
     appropriate for Electrode Native's swagger/json implementation.
     */
    private func generateSwaggerInfoSection() -> [String : Any]
    {
        // The "info" section has a title, description, and contact/owner.
        var infoJson: [String : Any] = [:]
        infoJson["title"] = self.containerTitle ?? ""
        infoJson["description"] = self.containerDescription ?? ""
        if let owner = self.containerOwner
        {
            infoJson["contact"] = ["name" : owner]
        }
        return infoJson
    }
    
    /**
     Generates a dictionary that represents this object's Produces section in a format
     appropriate for Electrode Native's swagger/json implementation.
     */
    private func generateSwaggerProducesSection() -> [String]
    {
        // The "produces" section is simply an array of strings where each string is an output type.
        if self.containerProducts.count > 0
        {
            var productStrings: [String] = []
            for product in self.containerProducts
            {
                productStrings.append(product.stringValue())
            }
            return productStrings
        }
        else
        {
            return [SwaggerProductEnum.JSON.stringValue()]
        }
    }
    
    /**
     Generates a dictionary that represents this object's Paths section in a format
     appropriate for Electrode Native's swagger/json implementation.
     */
    private func generateSwaggerPathsSection() -> [String : Any]
    {
        // The "paths" section defines all the methods.
        var methodsForSection: [String : Any] = [:]
        
        // A method could be given multiple times if it has multiple types (GET, POST, DELETE, etc.)
        // We need to first bundle them together by method name if they exist.
        var bundledMethods: [String : [SwaggerMethod]] = [:]
        for method in self.containerMethods
        {
            if var existingArray = bundledMethods[method.methodName]
            {
                existingArray.append(method)
            }
            else
            {
                bundledMethods[method.methodName] = [method]
            }
        }
        
        // Now call the correct swagger generator based on whether each method has 1
        // or more than 1 type.
        for methodArray in bundledMethods.values
        {
            if let method = methodArray.first
            {
                if methodArray.count == 1
                {
                    methodsForSection[method.methodName] = method.generateSwaggerSection()
                }
                else
                {
                    methodsForSection[method.methodName] = SwaggerMethod.generateSwaggerSection(methods: methodArray)
                }
            }
        }

        return methodsForSection
    }
    
    /**
     Generates a dictionary that represents this object's Definitions section in a format
     appropriate for Electrode Native's swagger/json implementation.
     */
    private func generateSwaggerDefinitionsSection() -> [String : Any]
    {
        // The "definitions" section defines all the complex objects.
        var definitionsForSection: [String : Any] = [:]
        for definition in self.containerModels
        {
            definitionsForSection[definition.objectName] = definition.generateSwaggerSection()
        }
        return definitionsForSection
    }
    
    // MARK:- CoreDataAvatarDelegate
    
    func saveToCoreData()
    {
        
    }
}
