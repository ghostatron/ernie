//
//  CoreDataAvatarDelegate.swift
//  Ernie
//
//  Created by Randy Haid on 12/14/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataAvatarDelegate
{
    init?(avatarOf: NSManagedObject)
    func saveToCoreData()
}
