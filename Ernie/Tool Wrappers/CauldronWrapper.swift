//
//  CauldronWrapper.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import CoreData

class CauldronWrapper
{
    // MARK:- Cauldron Analysis Methods
    
    class func analyzeAndUpdateCache(completion: @escaping (Bool) -> ())
    {
        // First wipe out all cauldron data in order to make our lives infinitely simpler.
        self.deleteExistingCauldronCache()
        
        // Each repository is basically a cauldron in this case.
        let waitGroup = DispatchGroup()
        self.listOfRepositories { (repositoryList) in
            for repositoryEntry in repositoryList ?? []
            {
                waitGroup.enter()
                // Create the core data objects appropriate for this cauldron based on its JSON body.
                self.cauldronJSONForRepositoryAt(repositoryEntry.location, completion: { (repoJSON) in
                    self.buildCacheForCauldron(alias: repositoryEntry.alias, location: repositoryEntry.location, cauldronJSON: repoJSON)
                    waitGroup.leave()
                })
            }
        }
        
        // Wait for all the cache objects to be build before signaling the handler.
        waitGroup.wait()
        completion(true)
    }
    
    private class func buildCacheForCauldron(alias: String, location: String, cauldronJSON: [String : Any])
    {
        // Create the parent Cauldron object.
        let moc = AppDelegate.mainManagedObjectContext()
        let cauldron = NSEntityDescription.insertNewObject(forEntityName: "Cauldron", into: moc) as! Cauldron
        cauldron.alias = alias
        cauldron.location = location
        if let jsonData = try? JSONSerialization.data(withJSONObject: cauldronJSON)
        {
            cauldron.jsonBody = String(data: jsonData, encoding: String.Encoding.utf8)
        }

        // Build the native apps objects.
        // The JSON has a nativeApps array, which has a platforms array, which has a versions array.
        // In our core data data model, we are more focused on the versions themselves.
        guard let nativeAppsArray = cauldronJSON["nativeApps"] as? [[String : Any]] else
        {
            return
        }
        for nativeAppJSON in nativeAppsArray
        {
            // Track the top level name as it will be assigned as the native app name for all
            // version objects we create below.
            let nativeAppName = nativeAppJSON["name"] as? String
            
            // The platforms array breaks the data into android and ios buckets.
            let platforms = nativeAppJSON["platforms"] as? [[String : Any]]
            for platform in platforms ?? []
            {
                // Track the name as it will be assigned as the platform name for all version
                // objects we create below.
                let nativeAppPlatform = platform["name"] as? String
                
                // The versions array has entries for each release of the native app.  We need
                // to dig through there and get the miniapps, dependencies, and codepush history
                // for each version.
                let versions = platform["versions"] as? [[String : Any]]
                for version in versions ?? []
                {
                    // Create the native app version object for this version entry.
                    let nativeAppVersion = NSEntityDescription.insertNewObject(forEntityName: "CauldronNativeAppVersion", into: moc) as! CauldronNativeAppVersion
                    nativeAppVersion.cauldron = cauldron
                    nativeAppVersion.nativeAppName = nativeAppName
                    nativeAppVersion.platform = nativeAppPlatform
                    nativeAppVersion.nativeAppVersion = version["name"] as? String
                    nativeAppVersion.ernVersion = version["ernPlatformVersion"] as? String
                    nativeAppVersion.isReleased = (version["isReleased"] as? Bool) ?? false
                    
                    // Dig through the miniApps/container section and generate mini app
                    // objects for this version object.
                    if let miniApps = version["miniApps"] as?  [String : Any]
                    {
                        let container = miniApps["container"] as? [String]
                        for miniAppEntry in container ?? []
                        {
                            let miniApp = NSEntityDescription.insertNewObject(forEntityName: "CauldronMiniApp", into: moc) as! CauldronMiniApp
                            miniApp.nativeAppVersion = nativeAppVersion
                            let trimmedMiniAppEntry = miniAppEntry.trimmingCharacters(in: CharacterSet.init(charactersIn: "@"))
                            let nameAndVersion = trimmedMiniAppEntry.components(separatedBy: "@")
                            if nameAndVersion.count == 2
                            {
                                miniApp.name = nameAndVersion[0]
                                miniApp.version = nameAndVersion[1]
                            }
                            else
                            {
                                miniApp.name = miniAppEntry
                            }
                        }
                        
                        // Dig through the nativeDeps section and generate mini app objects for this version object.
                        let dependencies = version["nativeDeps"] as?  [String]
                        for dependencyEntry in dependencies ?? []
                        {
                            let dependency = NSEntityDescription.insertNewObject(forEntityName: "CauldronDependency", into: moc) as! CauldronDependency
                            dependency.nativeAppVersion = nativeAppVersion
                            let trimmedDependencyEntry = dependencyEntry.trimmingCharacters(in: CharacterSet.init(charactersIn: "@"))
                            let nameAndVersion = trimmedDependencyEntry.components(separatedBy: "@")
                            if nameAndVersion.count == 2
                            {
                                dependency.name = nameAndVersion[0]
                                dependency.version = nameAndVersion[1]
                            }
                            else
                            {
                                dependency.name = dependencyEntry
                            }
                        }
                        
                        // Dig through the codePush section and generate mini app objects for this version object.
                        let codePushes = miniApps["codePush"] as? [[String]]
                        for codePushArray in codePushes ?? []
                        {
                            let codePush = NSEntityDescription.insertNewObject(forEntityName: "CauldronCodePush", into: moc) as! CauldronCodePush
                            codePush.nativeAppVersion = nativeAppVersion
                            
                            for codePushEntry in codePushArray
                            {
                                let codePushMiniApp = NSEntityDescription.insertNewObject(forEntityName: "CauldronMiniApp", into: moc) as! CauldronMiniApp
                                codePushMiniApp.nativeAppVersion = nativeAppVersion
                                codePushMiniApp.codePush = codePush
                                let trimmedCodePushEntry = codePushEntry.trimmingCharacters(in: CharacterSet.init(charactersIn: "@"))
                                let nameAndVersion = trimmedCodePushEntry.components(separatedBy: "@")
                                if nameAndVersion.count == 2
                                {
                                    codePushMiniApp.name = nameAndVersion[0]
                                    codePushMiniApp.version = nameAndVersion[1]
                                }
                                else
                                {
                                    codePushMiniApp.name = codePushEntry
                                }
                            }
                        }
                    }
                }
            }
        }
        
        try? moc.save()
    }
    
    private class func cauldronJSONForRepositoryAt(_ location: String, completion: @escaping ([String : Any]) -> ())
    {
        // TODO: use the location variable instead of the hard coded URL I'm using for testing...
        //https://gecgithub01.walmart.com/react-native/walmart-cauldron/blob/master/cauldron.json
        let repoUrl = URL(string: "https://raw.githubusercontent.com/ghostatron/whatev-cauldron/master/cauldron2.json")
//        let repoUrl = URL(string: "https://raw.githubusercontent.com/ghostatron/whatev-cauldron/master/cauldron.json")
        var repoRequest = URLRequest(url: repoUrl!)
        repoRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: repoRequest) { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            print("response status: \(statusCode ?? 999)")
//            let dataString = String(data: data!, encoding: String.Encoding.utf8)
//            print(dataString!)
            if let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            {
                completion(json as! [String : Any])
            }
            completion([:])
        }
        task.resume()
    }
    //ernie-playground -> git@github.com:ghostatron/whatev-cauldron.git
    //https://raw.githubusercontent.com/ghostatron/whatev-cauldron/master/cauldron.json
    
    @discardableResult private class func deleteExistingCauldronCache() -> Int
    {
        //
        // We could use batch delete here, but it's not going to work well because of the cascade
        // delete rules on the Cauldron relationships.  Batch delete would go directly to the store
        // and ignore the cascade rules.
        //
        
        // Create a request to get all Cauldron objects, but just their NSManagedObjectIDs.
        let request: NSFetchRequest<Cauldron> = Cauldron.fetchRequest()
        request.includesPropertyValues = false
        
        // Execute the request and bail if it fails.
        var numberOfCauldronsDeleted = 0
        let moc = AppDelegate.mainManagedObjectContext()
        guard let cauldronsToDelete = try? moc.fetch(request) else
        {
            return numberOfCauldronsDeleted
        }
        numberOfCauldronsDeleted = cauldronsToDelete.count
        
        // Loop through and delete each cauldron.
        for cauldron in cauldronsToDelete
        {
            moc.delete(cauldron)
        }
        try? moc.save()
        return numberOfCauldronsDeleted
    }
    
    // MARK:- Repository Methods
    
    /**
     Adds a new repository with the given |alias| located at |location|.  The |completion| block
     will be called with TRUE if the process succeeds.
     */
    class func addRepository(_ alias: String, location: String, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "add", alias, location, "--current", "false"]) { (response) in
            let successText = "Added Cauldron repository \(location) with alias \(alias)"
            completion(response.output?.contains(successText) ?? false)
        }
    }
    
    /**
     Removes the rrepository with the given |alias|.  The |completion| block
     will be called with TRUE if the process succeeds.
     */
    class func removeRepository(_ alias: String, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "remove", alias]) { (response) in
            let successText = "Removed Cauldron repository exists with alias \(alias)"
            completion(response.output?.contains(successText) ?? false)
        }
    }
    
    /**
     Returns a list of all local repositories via |completion|.
     */
    class func listOfRepositories(completion: @escaping ([(alias: String, location: String)]?) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "list"]) { (response) in
            
            // The output starts out with some electrode header info and ends with the
            // actual listing of repositories.  We can find where that list begins by locating
            // the key phrase "[Cauldron Repositories]"
            guard let twoHalves = response.output?.components(separatedBy: "[Cauldron Repositories]"), twoHalves.count == 2 else
            {
                completion(nil)
                return
            }
            
            // Our return value, initially empty.
            var repositoryList: [(alias: String, location: String)] = []
            
            // We're only interested in the second half of that output, which has 1 repository
            // listing per line.  So break that up by newline characters.
            let repositoryLines = twoHalves[1].components(separatedBy: .newlines)
            for line in repositoryLines
            {
                // Each line is something like "alias -> url".
                let aliasAndLocation = line.components(separatedBy: " -> ")
                if aliasAndLocation.count == 2
                {
                    repositoryList.append((alias: aliasAndLocation[0], location: aliasAndLocation[1]))
                }
            }

            // Send the results back to the listener.
            completion(repositoryList)
        }
    }
    
    /**
     Returns the |alias| and |location| of the currently active repository via |completion|.
     */
    class func currentRepository(completion: @escaping ((alias: String, location: String)?) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "current"]) { (response) in
            
            // The output has the electrode header and then the current repository as the last line.
            // So start by splitting that into lines and grabbing the last one.
            guard let outputLines = response.output?.components(separatedBy: .newlines), outputLines.count > 0 else
            {
                completion(nil)
                return
            }
            let currentRepositoryLine = outputLines.last!

            // The last line should look like "alias location".
            var currentRepository: (alias: String, location: String)?
            let aliasAndLocation = currentRepositoryLine.components(separatedBy: " ")
            if aliasAndLocation.count == 2
            {
                // The location comes out surrounded by square brackets that need to be removed.
                let trimmedLocation = aliasAndLocation[1].trimmingCharacters(in: CharacterSet.init(charactersIn: "[]"))
                currentRepository = (alias: aliasAndLocation[0], location: trimmedLocation)
            }
            completion(currentRepository)
        }
    }
    
    /**
     Changes the currently active repository to be |alias|.  Returns TRUE if the process succeeds via |completion|.
     */
    class func switchToRepository(_ alias: String, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "use", alias]) { (response) in
            let successText = "\(alias) Cauldron is now in use"
            completion(response.output?.contains(successText) ?? false)
        }
    }
}
