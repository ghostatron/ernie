//
//  SwaggerMethodArgumentEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/4/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodArgumentEditorViewController: NSViewController, NSComboBoxDataSource
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var requiredCheckBox: NSButton!
    @IBOutlet weak var arrayCheckBox: NSButton!
    @IBOutlet weak var dataTypeComboBox: NSComboBox!
    @IBOutlet weak var formatComboBox: NSComboBox!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!

    var modalDelegate: ModalDialogDelegate?
    var argument: SwaggerMethodArgument?
    private var sortedPrimitiveTypes: [String] = []
    private var sortedModels: [SwaggerObjectModel] = []
    private var orderedDataTypeNames: [String] = []
    private var sortedFormats: [String] = []
    private var comboBoxesInitialized = false
    
    // View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildDataTypeDataSource()
        self.buildFormatDataSource()
        self.comboBoxesInitialized = true
        self.configureForArgument()
    }
    
    // MARK:- Private Methods
    
    private func configureForArgument()
    {
        if let argument = self.argument
        {
            self.nameTextField.stringValue = argument.argumentName
            self.descriptionTextField.stringValue = argument.argumentDescription ?? ""
            self.requiredCheckBox.state = argument.isArgumentRequired ? NSControl.StateValue.on : NSControl.StateValue.off
            self.arrayCheckBox.state = argument.argumentType.arrayDataType == nil ? NSControl.StateValue.off : NSControl.StateValue.on
            
            // Special case for array, we want to select the type of the array rather than use the "Array"
            // primitive type directly.
            if let arrayDataType = argument.argumentType.arrayDataType
            {
                self.dataTypeComboBox.stringValue = arrayDataType.primitiveDataType?.rawValue ?? ""
            }
            else
            {
                self.dataTypeComboBox.stringValue = argument.argumentType.primitiveDataType?.rawValue ?? ""
            }
            
            self.formatComboBox.stringValue = self.argument?.argumentFormat?.rawValue ?? ""
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
        // Must have an argument name and argument data type.
        guard self.nameTextField.stringValue.count > 0, self.dataTypeComboBox.stringValue.count > 0 else
        {
            return
        }
        
        // Determine the index to use when looking up the data type.
        var dataTypeIndex = self.dataTypeComboBox.indexOfSelectedItem
        if dataTypeIndex < 0
        {
            dataTypeIndex = self.orderedDataTypeNames.index(of: self.dataTypeComboBox.stringValue) ?? -1
        }
        guard dataTypeIndex > -1 else
        {
            return
        }
        
        // Figure out what data type they have selected.
        var baseDataType: SwaggerDataType!
        if dataTypeIndex < self.sortedPrimitiveTypes.count
        {
            // It's a primitive type
            guard let primitiveType = SwaggerDataTypeEnum(rawValue: self.sortedPrimitiveTypes[dataTypeIndex]) else
            {
                return
            }
            baseDataType = SwaggerDataType(primitiveType: primitiveType)
        }
        else if dataTypeIndex < self.sortedPrimitiveTypes.count + self.sortedModels.count
        {
            // It's a model
            let modelIndex = dataTypeIndex - self.sortedPrimitiveTypes.count
            guard modelIndex < self.sortedModels.count else
            {
                return
            }
            baseDataType = SwaggerDataType(withObject: self.sortedModels[modelIndex])
        }
        else
        {
            // Index out of bounds.
            return
        }
        
        // Embed that data type in an array if necessary.
        var dataTypeForArgument: SwaggerDataType = baseDataType
        if self.arrayCheckBox.state == NSControl.StateValue.on
        {
            dataTypeForArgument = SwaggerDataType(asArrayOf: baseDataType)
        }
        
        // Create a new argument if one was not supplied to us.
        if self.argument == nil
        {
            self.argument = SwaggerMethodArgument(name: "", type: dataTypeForArgument)
        }
        
        // Copy the user's data into the argument.
        self.argument?.argumentName = self.nameTextField.stringValue
        self.argument?.argumentDescription = self.descriptionTextField.stringValue
        self.argument?.isArgumentRequired = self.requiredCheckBox.state == NSControl.StateValue.on
        self.argument?.argumentType = dataTypeForArgument
        
        if self.formatComboBox.stringValue.count == 0
        {
            self.argument?.argumentFormat = SwaggerDataTypeFormatEnum.None
        }
        else
        {
            self.argument?.argumentFormat = SwaggerDataTypeFormatEnum(rawValue: self.formatComboBox.stringValue)
        }
        
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- Data Source Builders
    
    private func buildFormatDataSource()
    {
        // The format combo box data source.
        self.sortedFormats = [
            SwaggerDataTypeFormatEnum.None.rawValue,
            SwaggerDataTypeFormatEnum.Date.rawValue,
            SwaggerDataTypeFormatEnum.DateTime.rawValue,
            SwaggerDataTypeFormatEnum.Double.rawValue,
            SwaggerDataTypeFormatEnum.Float.rawValue,
            SwaggerDataTypeFormatEnum.Int32.rawValue,
            SwaggerDataTypeFormatEnum.Int64.rawValue,
            SwaggerDataTypeFormatEnum.Password.rawValue
        ]
    }
    
    private func buildDataTypeDataSource()
    {
        // The data type combo box data source.
        self.orderedDataTypeNames = []
        
        // Add the primitive types first.
        self.sortedPrimitiveTypes = [
            SwaggerDataTypeEnum.Boolean.rawValue,
            SwaggerDataTypeEnum.Integer.rawValue,
            SwaggerDataTypeEnum.Number.rawValue,
            SwaggerDataTypeEnum.String.rawValue
        ]
        for typeName in self.sortedPrimitiveTypes
        {
            self.orderedDataTypeNames.append(typeName)
        }
        
        // Then add the models.
        self.sortedModels = SwaggerObjectModel.getAllModels(sorted: true)
        for model in self.sortedModels
        {
            self.orderedDataTypeNames.append(model.modelName)
        }
    }
    
    // MARK:- NSComboBoxDataSource
    
    func numberOfItems(in comboBox: NSComboBox) -> Int
    {
        guard self.comboBoxesInitialized else
        {
            return 0
        }
        
        switch comboBox
        {
        case self.dataTypeComboBox:
            return self.orderedDataTypeNames.count
            
        case self.formatComboBox:
            return self.sortedFormats.count
            
        default:
            return 0
        }
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any?
    {
        if index < 0
        {
            return nil
        }
        else if comboBox == self.dataTypeComboBox
        {
            guard index < self.orderedDataTypeNames.count else
            {
                return nil
            }
            return self.orderedDataTypeNames[index]
        }
        else if comboBox == self.formatComboBox
        {
            guard index < self.sortedFormats.count else
            {
                return nil
            }
            return self.sortedFormats[index]
        }
        else
        {
            return nil
        }
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int
    {
        switch comboBox
        {
        case self.formatComboBox:
            return self.sortedFormats.index(of: string) ?? -1
            
        case self.dataTypeComboBox:
            return self.orderedDataTypeNames.index(of: string) ?? -1
            
        default:
            return -1
        }
    }
}
