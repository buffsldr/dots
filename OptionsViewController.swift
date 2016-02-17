//
//  OptionsViewController.swift
//  DotMatrix
//
//  Created by Mark Vader on 2/15/16.
//  Copyright © 2016 vaderapps.com. All rights reserved.
//

import UIKit
import CoreData

let rowsColumnsChangedNotification = "rowsColumnsChangedNotification"
let optionsViewControllerSegueIdentifier = "OptionsViewControllerSegueIdentifier"
let resetPressedNotification = "resetPressedNotification"
let photoNotification = "photoNotification"


class OptionsViewController: UIViewController, UITextFieldDelegate {
    
    let notUsed = "Not Used"
    let resetInProgress: [UInt] = [1]
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var columnsTextField: UITextField!
    var selectedColors = Set<UInt>()
    var selectedColorArray = [UInt]()
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var photoButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func photoPressed(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(photoNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        rowsTextField.resignFirstResponder()
        columnsTextField.resignFirstResponder()
        
        return true
    }

    
    @IBAction func colorButtonPressed(sender: UIButton) {
        switch sender {
        case redButton:
            selectedColorArray.append(CircleColor.Red.rawValue)
        case greenButton:
            selectedColorArray.append(CircleColor.Green.rawValue)
        case blueButton:
            selectedColorArray.append(CircleColor.Blue.rawValue)
        case yellowButton:
            selectedColorArray.append(CircleColor.Yellow.rawValue)
        default:
            break
        }
        sender.enabled = false
        sender.titleLabel?.font
        sender.titleLabel?.text = selectedColorArray.count.description
        sender.setTitle(selectedColorArray.count.description, forState: .Normal)
    }
    
    @IBAction func resetPressed(sender: UIButton) {
        selectedColorArray = []
        rowsTextField.text = ""
        columnsTextField.text = ""
        redButton.setTitle(notUsed, forState: .Normal)
        greenButton.setTitle(notUsed, forState: .Normal)
        blueButton.setTitle(notUsed, forState: .Normal)
        yellowButton.setTitle(notUsed, forState: .Normal)
        redButton.enabled = true
        greenButton.enabled = true
        blueButton.enabled = true
        yellowButton.enabled = true
        selectedColors = Set<UInt>()
        var userInfo: [String: [UInt]] = ["rows": [0], "columns": [0]]
        let colorsChosen = [UInt]()
        userInfo.updateValue(colorsChosen, forKey: "colors")
        userInfo.updateValue(resetInProgress, forKey: "reset")
        NSNotificationCenter.defaultCenter().postNotificationName(rowsColumnsChangedNotification, object: nil, userInfo: userInfo)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPressed(sender: UIButton) {
        rowsTextField.resignFirstResponder()
        columnsTextField.resignFirstResponder()
        selectedColors = Set<UInt>()
        if let rowText = rowsTextField.text, rows = UInt(rowText), columnText = columnsTextField.text, columns = UInt(columnText) {
            var userInfo: [String: [UInt]] = ["rows": [rows], "columns": [columns]]
            let colorsChosen = selectedColorArray
            userInfo.updateValue(colorsChosen, forKey: "colors")
            NSNotificationCenter.defaultCenter().postNotificationName(rowsColumnsChangedNotification, object: nil, userInfo: userInfo)
        }
    }
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
