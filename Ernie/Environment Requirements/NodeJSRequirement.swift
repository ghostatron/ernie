//
//  NodeJSRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NodeJSRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    init()
    {
        super.init(delegate: self)
    }
    
    override private init(delegate: EnvironmentRequirementDelegate)
    {
            super.init(delegate: delegate)
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var fullPathExecutable: String { get { return "/usr/local/bin/node" } }
    
    var argumentsForVersionCheck: [String] { get { return ["-v"] } }

    var minVersionComponents: [Int] { get { return [4, 5] } }
}
