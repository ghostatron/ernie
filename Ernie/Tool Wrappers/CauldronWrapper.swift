//
//  CauldronWrapper.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class CauldronWrapper
{
    class func analyzeAndUpdateCache(completion: @escaping (CommandLineResponse) -> ())
    {
        let response = CommandLineResponse()
        completion(response)
    }
}
