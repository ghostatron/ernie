//
//  SwaggerContainer.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class SwaggerContainer
{
    var containerDescription: String?
    var containerTitle: String?
    var containerOwner: String?
    var containerMethods: [SwaggerMethod] = []
    var containerModels: [SwaggerObjectModel] = []

    /// A list of the type of files that can be created with by the methods in this container.
    var containerProducts: [SwaggerProductEnum] = []

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
    
    private func generateSwaggerPathsSection() -> [String : Any]
    {
        // The "paths" section defines all the methods.
        var methodsForSection: [String : Any] = [:]
        for method in self.containerMethods
        {
            methodsForSection[method.methodName] = method.generateSwaggerSection()
        }
        return methodsForSection
    }
    
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
}
