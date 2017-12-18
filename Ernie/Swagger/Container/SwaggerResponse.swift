//
//  SwaggerResponse.swift
//  Ernie
//
//  Created by Randy Haid on 12/8/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class SwaggerResponse: CoreDataAvatarDelegate
{
    var responseHttpCode: String
    var responseDataType: SwaggerDataType
    var responseDescription: String?
    private(set) var avatarOf: SWResponse?

    // MARK:- Initializers
    
    /**
     Creates a SwaggerResponse with the given |name| and |type|.
     */
    init(code: String, type: SwaggerDataType)
    {
        self.responseHttpCode = code
        self.responseDataType = type
    }
    
    /**
     Creates a SwaggerResponse that populates itself based on the data in the
     given SWResponse object.
     */
    convenience init?(avatarOf: SWResponse)
    {
        // Create the object using the standard init.
        guard
            let code = avatarOf.responseCode,
            let swDataType = avatarOf.responseType,
            let dataType = SwaggerDataType(avatarOf: swDataType) else
        {
            return nil
        }
        self.init(code: code, type: dataType)
       self.avatarOf = avatarOf
        
        // Copy the properties over.
        self.responseDescription = avatarOf.responseDescription
    }
    
    // MARK:- Swagger Generation
    
    /**
     Generates a dictionary that represents this object in a format appropriate for Electrode
     Native's swagger/json implementation.
     */
    func generateSwaggerJson() -> [String : Any]
    {
        var swaggerBody: [String : Any] = [:]
        swaggerBody["schema"] = self.responseDataType.generateSwaggerSchemaSection()
        if let description = self.responseDescription
        {
            swaggerBody["description"] = description
        }
        return swaggerBody
    }
    
    func refreshCoreDataObject() -> SWResponse?
    {
        let moc = AppDelegate.mainManagedObjectContext()
        moc.performAndWait {
            
            // Figure out if we already have an object, or need to create a new one now.
            if self.avatarOf == nil
            {
                self.avatarOf = NSEntityDescription.insertNewObject(forEntityName: "SWResponse", into: moc) as? SWResponse
            }
            guard let responseToReturn = self.avatarOf else
            {
                return
            }
            
            // Copy over the properties.
            responseToReturn.responseCode = self.responseHttpCode
            responseToReturn.responseDescription = self.responseDescription
            responseToReturn.responseType = self.responseDataType.refreshCoreDataObject()
        }
        
        return self.avatarOf
    }
    
    // MARK:- CoreDataAvatarDelegate
    
    func saveToCoreData()
    {
        
    }
}
