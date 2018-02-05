//
//  SwaggerMethod.swift
//  Ernie
//
//  Created by Randy Haid on 12/7/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerMethod
{
    /// The name of the method.
    var methodName: String
    
    /// Indicates what kind of method this is in the HTTP world.
    var methodType: SwaggerMethodTypeEnum
    
    /// An array of descriptive tags for the method.
    var methodTags: [String] = []
    
    /// A summary of this method.
    var methodSummary: String?
    
    /// A description of this method.
    var methodDescription: String?
    
    /// By default, this will match |methodName|.
    var methodOperationId: String
    
    /// The parameters that need to be passed to the method.
    var methodArguments: [SwaggerMethodArgument] = []
    
    /// The HTTP responses that can be generated by the method.
    var methodResponses: [SwaggerResponse] = []
    
    /// A list of the type of files that can be accepted/created with this method.
    var methodProducts: [SwaggerProductEnum] = []
    
    private(set) var avatarOf: SWMethod?
    
    private let parsingDelimiter = ";;"
    
    // MARK:- Initializers
    
    /**
     Creates a SwaggerMethod with the given |name| and |type|.
     */
    init(name: String, type: SwaggerMethodTypeEnum)
    {
        self.methodName = name
        self.methodOperationId = name
        self.methodType = type
    }
    
    /**
     Creates a SWMethod that populates itself based on the data in the
     given SWMethodArgument object.
     */
    convenience init?(avatarOf: SWMethod)
    {
        // Create the object using the standard init.
        guard
            let methodName = avatarOf.methodName,
            let swMethodType = avatarOf.methodType,
            let methodType = SwaggerMethodTypeEnum(rawValue: swMethodType) else
        {
            return nil
        }
        self.init(name: methodName, type: methodType)
        self.avatarOf = avatarOf
        
        // Copy each property over.
        self.methodSummary = avatarOf.methodSummary
        self.methodDescription = avatarOf.methodDescription
        self.methodOperationId = avatarOf.methodOperationId ?? self.methodName
        for swArgument in avatarOf.methodArguments?.allObjects as? [SWMethodArgument] ?? []
        {
            if let argument = SwaggerMethodArgument(avatarOf: swArgument)
            {
                self.methodArguments.append(argument)
            }
        }
        for swResponse in avatarOf.methodResponses?.allObjects as? [SWResponse] ?? []
        {
            if let response = SwaggerResponse(avatarOf: swResponse)
            {
                self.methodResponses.append(response)
            }
        }
        self.methodTags = avatarOf.methodTags?.components(separatedBy: self.parsingDelimiter) ?? []
        for productString in avatarOf.methodProducts?.components(separatedBy: self.parsingDelimiter) ?? []
        {
            if let product = SwaggerProductEnum(rawValue: productString)
            {
                self.methodProducts.append(product)
            }
        }
    }
    
    class func generateMethodFromDictionary(_ jsonDictionary: [String : Any]) -> SwaggerMethod?
    {
        return nil
    }
    
    /**
     Parses the given swift method signature and creates a representative SwaggerMethod object.
     e.g. "func myMethod(myFirstArgument: String, mySecondArgument: SomeModel) -> Int"
     Does not support "_" (or other arg labels).
     Does not support class methods.
     Does not support tuples.
     Does not support model objects that haven't been defined yet.
     */
    class func methodFromSwiftMethodSignature(_ swiftString: String) -> SwaggerMethod?
    {
        guard swiftString.hasPrefix("func "), let funcIndex = swiftString.index(of: " ") else
        {
            return nil
        }
        
        // Locate the method name.
        var remainingString = swiftString.suffix(from: funcIndex).trimmingCharacters(in: .whitespaces)
        guard let indexOfOpeningParenthesis = remainingString.index(of: "(") else
        {
            return nil
        }
        let methodNameSubstring = remainingString.prefix(upTo: indexOfOpeningParenthesis)
        let methodName = String(methodNameSubstring)

        // Locate the arguments list.
        remainingString = String(remainingString.suffix(from: indexOfOpeningParenthesis))
        remainingString.remove(at: remainingString.startIndex)
        guard let indexOfClosingParenthesis = remainingString.index(of: ")") else
        {
            return nil
        }
        let argumentString = remainingString.prefix(upTo: indexOfClosingParenthesis)
        
        // Parse the argument list to create SwaggerMethodArgument objects.
        var argumentObjects: [SwaggerMethodArgument] = []
        if argumentString.count > 0
        {
            let argumentArray = argumentString.components(separatedBy: ",")
            for argument in argumentArray
            {
                // Must have exactly 2 parts: the argument name, and the argument type.
                let argNameAndType = argument.components(separatedBy: ":")
                guard argNameAndType.count == 2 else
                {
                    return nil
                }
                
                // Must have non-empty name and type strings.
                let argName = argNameAndType[0].trimmingCharacters(in: .whitespaces)
                let argTypeString = argNameAndType[1].trimmingCharacters(in: .whitespaces)
                guard let argType = SwaggerDataType.dataTypeFromString(argTypeString), argName.count > 0, argName != "_" else
                {
                    return nil
                }
                
                // Create and add an actual argument object.
                let argumentObject = SwaggerMethodArgument(name: argName, type: argType)
                argumentObject.isArgumentRequired = !argTypeString.hasSuffix("?")
                argumentObjects.append(argumentObject)
            }
        }

        // Locate the return type.
        remainingString = String(remainingString.suffix(from: indexOfClosingParenthesis))
        remainingString.remove(at: remainingString.startIndex)
        var result: SwaggerResponse?
        if let indexOfArrow = remainingString.index(of: ">")
        {
            var trimSet = CharacterSet.whitespaces
            trimSet.insert("-")
            trimSet.insert(">")
            let resultString = remainingString.suffix(from: indexOfArrow).trimmingCharacters(in: trimSet)
            guard let resultDataType = SwaggerDataType.dataTypeFromString(resultString) else
            {
                return nil
            }
            result = SwaggerResponse(code: "200", type: resultDataType)
        }
        
        let method = SwaggerMethod(name: methodName, type: result == nil ? .POST : .GET)
        method.methodArguments = argumentObjects
        if let result = result
        {
            method.methodResponses = [result]
        }
        return method
    }
    
    class func getAllMethods() -> [SwaggerMethod]
    {
        var allMethods: [SwaggerMethod] = []
        
        let request: NSFetchRequest<SWMethod> = SWMethod.fetchRequest()
        let swMethods = try? AppDelegate.mainManagedObjectContext().fetch(request)
        for swMethod in swMethods ?? []
        {
            if let method = SwaggerMethod(avatarOf: swMethod)
            {
                allMethods.append(method)
            }
        }
        
        return allMethods
    }
    
    // MARK:- Misc.
    
    /**
     Returns a Swift style function signature for this SwaggerMethod object.
     */
    func swiftSignature() -> String
    {
        // Start things off with the method name.
        var signature = self.methodName
        
        // Add the arguments.
        signature += "("
        for argument in self.methodArguments
        {
            signature += argument.swiftSignature()
        }
        signature += ")"
        
        // Add the return part.  There could be multiple response options, so just
        // insert the first and then add an indicator for how many are not displayed.
        if let firstResponse = self.methodResponses.first
        {
            signature += " -> \(firstResponse.responseDataType.stringValue())"
            if self.methodResponses.count > 1
            {
                signature += " [+ \(self.methodResponses.count - 1)]"
            }
        }
        
        // Swiftitized!
        return signature
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents the given |methods| merged together
     in a format appropriate for Electrode Native's swagger/json implementation.
     */
    class func generateSwaggerSection(methods: [SwaggerMethod]) -> [String : Any]
    {
        var swaggerBody: [String : Any] = [:]
        for method in methods
        {
            swaggerBody[method.methodType.toString()] = method.generateSwaggerSection()
        }
        return swaggerBody
    }

    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerSection() -> [String : Any]
    {
        // Create the return object with the simple properties assigned.
        var swaggerBody: [String : Any] = [:]
        swaggerBody["operationId"] = self.methodOperationId
        
        // Add the products to swaggerBody.
        if self.methodProducts.count > 0
        {
            var productStrings: [String] = []
            for product in self.methodProducts
            {
                productStrings.append(product.stringValue())
            }
            swaggerBody["produces"] = productStrings
        }
        else
        {
            swaggerBody["produces"] = [SwaggerProductEnum.JSON.stringValue()]
        }
        
        // Add the tags to swaggerBody.
        if self.methodTags.count > 0
        {
            swaggerBody["tags"] = self.methodTags
        }
        
        // Add the summary to swaggerBody.
        if let summary = self.methodSummary
        {
            swaggerBody["summary"] = summary
        }
        
        // Add the description to swaggerBody.
        if let description = self.methodDescription
        {
            swaggerBody["description"] = description
        }
        
        // Add the parameters to swaggerBody.
        var parametersSection: [[String : Any]] = [[:]]
        for parameter in self.methodArguments
        {
            parametersSection.append(parameter.generateSwaggerJson())
        }
        swaggerBody["parameters"] = parametersSection
        
        // Add the responses to swaggerBody.
        var responsesSection: [String : Any] = [:]
        for response in self.methodResponses
        {
            responsesSection[response.responseHttpCode] = response.generateSwaggerJson()
        }
        swaggerBody["responses"] = responsesSection

        return [self.methodType.toString() : swaggerBody]
    }
    
    @discardableResult func refreshCoreDataObject(autoSave: Bool = false) -> SWMethod?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWMethod", into: moc) as? SWMethod
            }
            guard let methodToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the properties.
            methodToReturn.methodName = self.methodName
            methodToReturn.methodType = self.methodType.rawValue
            methodToReturn.methodDescription = self.methodDescription
            methodToReturn.methodSummary = self.methodSummary
            methodToReturn.methodOperationId = self.methodOperationId
            
            // The tags are stored as a delimited string.
            if self.methodTags.count > 0
            {
                methodToReturn.methodTags = self.methodTags.joined(separator: self.parsingDelimiter)
            }
            else
            {
                methodToReturn.methodTags = nil
            }
            
            // Wipe out any pre-existing arguments and rebuild that set.
            if let oldArguments = methodToReturn.methodArguments
            {
                methodToReturn.removeFromMethodArguments(oldArguments)
            }
            for argument in self.methodArguments
            {
                if let argumentAvatar = argument.refreshCoreDataObject()
                {
                    methodToReturn.addToMethodArguments(argumentAvatar)
                }
            }
            
            // Wipe out any pre-existing responses and rebuild that set.
            if let oldResponses = methodToReturn.methodResponses
            {
                methodToReturn.removeFromMethodResponses(oldResponses)
            }
            for response in self.methodResponses
            {
                if let responseAvatar = response.refreshCoreDataObject()
                {
                    methodToReturn.addToMethodResponses(responseAvatar)
                }
            }
            
            // The products are stored as a delimited string.
            if self.methodProducts.count > 0
            {
                var productsAsString: [String] = []
                for product in self.methodProducts
                {
                    productsAsString.append(product.rawValue)
                }
                methodToReturn.methodProducts = productsAsString.joined(separator: self.parsingDelimiter)
            }
            else
            {
                methodToReturn.methodProducts = nil
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
