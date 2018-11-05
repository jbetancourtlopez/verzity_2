//
//  FormValidate.swift
//  verzity
//
//  Created by Jossue Betancourt on 05/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import Foundation
import UIKit

class FormValidate{
    
    // Es vacio
    static func isEmptyTextField(textField: UITextField)->Bool{
        if((textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) == true){
            return true
        }
        return false
    }
    
    // Validar Email
    static func validateEmail(_ email : String) -> Bool {
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // Validar Length y Caracteres
    static func validateLengthAndCharacters(_ textField: UITextField, str : String, range: NSRange, validCharacters: String, maxLength: Int) -> Bool{
        guard let text = textField.text else {
            return true
        }
        
        let newLength = text.count + str.count - range.length
        let numberFiltered = validateCharacteres(str, characters: validCharacters)
        return newLength <= maxLength && str == numberFiltered
    }
    
    // Validar Télefono
    static func validatePhone(textField: UITextField)->Bool{
        if (textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count)! > 9 {
            return false
        }else{
            return true
        }
    }
    
    static func validate_min_length(_ texfield: UITextField, maxLength: Int)->Bool{
        guard let text = texfield.text else { return true }
        return text.count >= maxLength
    }
    
    // Validar Max Length // No entendi como se usa
    static func validateMaxLength(_ textField: UITextField, str: String, range: NSRange, maxLength: Int)->Bool{
        guard let text = textField.text else { return true }
        let newLength = text.count + str.count - range.length
        return newLength <= maxLength
    }
    
    // Validar Caracteres
    static func validateCharacteres(_ string: String, characters: String) -> String{
        let aSet = CharacterSet(charactersIn:characters).inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return numberFiltered
    }
    
    // Validat URL
    static func validateUrl (urlString: NSString) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
}
