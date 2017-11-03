//
//  ErnWrapper.swift
//  Ernie
//
//  Created by Randy Haid on 11/3/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class ErnWrapper
{
    class func createMiniApp(parentFolderFullPath: String, createFolderIfNeeded: Bool, appName: String, completion: @escaping (CommandLineResponse) -> ())
    {
        // Create the parent folder if needed.
        do
        {
            try FileManager.default.createDirectory(atPath: parentFolderFullPath, withIntermediateDirectories: createFolderIfNeeded)
        }
        catch
        {
            let response = CommandLineResponse()
            response.errorMessage = error.localizedDescription
            completion(response)
            return
        }
        
        // We need to cd into the parentFolder and run ern from there.  ern will prompt for an app name,
        // so we pipe in a carriage return in order to accept the default.
        let scriptLines = [
            "cd \(parentFolderFullPath)",
            "printf '\\n' | /usr/local/bin/ern create-miniapp \(appName)"]
        CommandLineHelper.executeCommandsAsShellScript(scriptLines: scriptLines) { (response) in
            print("error = \(response.errorMessage ?? "")")
            print("output = \(response.output ?? "")")
            completion(response)
        }
    }
}
