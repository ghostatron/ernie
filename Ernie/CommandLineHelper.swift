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
    class func executeCommandLineAndWait(command: String, arguments: [String]?) -> CommandLineResponse
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
}
