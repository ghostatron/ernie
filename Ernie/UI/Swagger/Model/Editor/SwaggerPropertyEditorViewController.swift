//
//  SwaggerPropertyEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 12/20/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerPropertyEditorViewController: NSViewController, NSComboBoxDataSource
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var requiredCheckBox: NSButton!
    @IBOutlet weak var arrayCheckBox: NSButton!
    @IBOutlet weak var dataTypeComboBox: NSComboBox!
    @IBOutlet weak var formatComboBox: NSComboBox!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    var property: SwaggerModelProperty?
    var modalDelegate: ModalDialogDelegate?
    
    var sortedPrimitiveTypes: [String] = []
    var sortedModels: [SwaggerObjectModel] = []
    var orderedDataTypeNames: [String] = []
    var sortedFormats: [String] = []
    var comboBoxesInitialized = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildDataTypeDataSource()
        self.buildFormatDataSource()
        self.comboBoxesInitialized = true
        self.configureForProperty()
    }
    
    private func configureForProperty()
    {
        if let property = self.property
        {
            self.nameTextField.stringValue = property.propertyName
            self.descriptionTextField.stringValue = property.propertyDescription ?? ""
            self.requiredCheckBox.state = property.propertyIsRequired ? NSControl.StateValue.on : NSControl.StateValue.off
            self.arrayCheckBox.state = property.propertyDataType.arrayDataType == nil ? NSControl.StateValue.off : NSControl.StateValue.on
            
            // Special case for array, we want to select the type of the array rather than use the "Array"
            // primitive type directly.
            if let arrayDataType = property.propertyDataType.arrayDataType
            {
                self.dataTypeComboBox.stringValue = arrayDataType.primitiveDataType?.rawValue ?? ""
            }
            else
            {
                self.dataTypeComboBox.stringValue = property.propertyDataType.primitiveDataType?.rawValue ?? ""
            }
            
            self.formatComboBox.stringValue = self.property?.propertyFormat?.rawValue ?? ""
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
        // Must have a property name and property data type.
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
            baseDataType = SwaggerDataType(withObject: self.sortedModels[dataTypeIndex])
        }
        else
        {
            // Index out of bounds.
            return
        }
        
        // Embed that data type in an array if necessary.
        var dataTypeForProperty: SwaggerDataType = baseDataType
        if self.arrayCheckBox.state == NSControl.StateValue.on
        {
            dataTypeForProperty = SwaggerDataType(asArrayOf: baseDataType)
        }
        
        // Create a new property if one was not supplied to us.
        if self.property == nil
        {
            self.property = SwaggerModelProperty(name: "", dataType: dataTypeForProperty)
        }
        
        // Copy the user's data into the property.
        self.property?.propertyName = self.nameTextField.stringValue
        self.property?.propertyDescription = self.descriptionTextField.stringValue
        self.property?.propertyIsRequired = self.requiredCheckBox.state == NSControl.StateValue.on
        self.property?.propertyDataType = dataTypeForProperty

        if self.formatComboBox.stringValue.count == 0
        {
            self.property?.propertyFormat = SwaggerDataTypeFormatEnum.None
        }
        else
        {
            self.property?.propertyFormat = SwaggerDataTypeFormatEnum(rawValue: self.formatComboBox.stringValue)
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
