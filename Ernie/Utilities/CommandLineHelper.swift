//
//  CommandLineHelper.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class CommandLineResponse
{
    var output: String?
    var errorMessage: String?
}

class CommandLineHelper
{
    /**
     Executes |command| with |arguments| passed in to it and passes the resulting output back via |completion|.
     */
    class func executeCommandLine(command: String, arguments: [String]?, completion: @escaping (CommandLineResponse) -> ())
    {
        let response = self.executeCommandLineAndWait(command: command, arguments: arguments)
        completion(response)
    }
    
    /**
     Executes |command| with |arguments| passed in to it and returns the resulting output.
     */
    @discardableResult class func executeCommandLineAndWait(command: String, arguments: [String]?) -> CommandLineResponse
    {
        // A non-empty command is actually required...
        let response = CommandLineResponse()
        guard !command.isEmpty else
        {
            response.errorMessage = "No command was given"
            return response
        }
        
        // Set up the process that will run the command.
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
        
        // Attach a pipe to the process so we can read the output.
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Kick off the command and capture the output for the caller.
        task.launch()
        response.output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.trimmingCharacters(in: .newlines)
        return response
    }
    
    /**
     Creates and executes a temporary shell script that only has the content given by |scriptLines|.
     Each element of the array will be on a separate line in the script.
     The script will be deleted after it finishes running.
     */
    class func executeCommandsAsShellScript(scriptLines: [String])
    {
        // Create the temporary shell script in ~/Library/Application Scripts/WalmartLabs.Ernie/TempScripts
        // that has |scriptLines| as the body..
        let tempFileName = "\(UUID().uuidString).sh"
        guard let path = NSSearchPathForDirectoriesInDomains(.applicationScriptsDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent("TempScripts") else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let tempScript = writePath.appendingPathComponent(tempFileName)
        let scriptContent = scriptLines.joined(separator: "\n")
        try? scriptContent.write(to: tempScript, atomically: false, encoding: String.Encoding.utf8)
        
        // Make the script executable.
        CommandLineHelper.executeCommandLineAndWait(command: "/bin/chmod", arguments: ["a+x", tempScript.path])
        
        // Run the script.
        CommandLineHelper.executeCommandLineAndWait(command: "/bin/bash", arguments: [tempScript.path])
        
        // Delete the script.
        CommandLineHelper.executeCommandLineAndWait(command: "/bin/rm", arguments: [tempScript.path])
    }
}
