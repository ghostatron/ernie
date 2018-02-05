//
//  String+Ernie.swift
//  Ernie
//
//  Created by Randy Haid on 2/5/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation

extension String
{
    func jsonDictionary() -> [String : Any]?
    {
        // Return nil if the string is empty.
        guard self.count > 0 else
        {
            return nil
        }
        
        // First push the string into a data object...
        guard let jsonData = self.data(using: .utf8) else
        {
            return nil
        }
        
        // Then turn that data object into a json object.
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else
        {
            return nil
        }
        
        // Return the json object as a dictionary.
        return jsonObject as? [String : Any]
    }
}
