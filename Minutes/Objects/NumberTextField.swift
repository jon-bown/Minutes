//
//  File.swift
//  Minutes
//
//  Created by Jonathan Bown on 2/10/21.
//

import UIKit
import SwiftUI


struct NumberTextField: UIViewRepresentable {
    @Binding var value: Int
    var formatter: Formatter
    var keyType: UIKeyboardType
    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
      textfield.keyboardType = keyType
        textfield.addTarget(self, action: #selector(textfield.textFieldDidChange(textField:)), for: .editingChanged)
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textfield.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textfield.doneButtonTapped(button:)))
        textfield.delegate = context.coordinator
        toolBar.items = [doneButton]
        toolBar.setItems([doneButton], animated: true)
        textfield.inputAccessoryView = toolBar
        return textfield
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = formatter.string(for: value)
        
    }
    
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UITextFieldDelegate {
        var numTextField: NumberTextField
        init(_ numTextField: NumberTextField) {
            self.numTextField = numTextField
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
            //textField.resignFirstResponder()
            numTextField.value = Int(textField.text!) ?? 1
            //numTextField.commit()
            return true
        }
    }
    

}

extension  UITextField{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        _ = textField.delegate?.textFieldShouldReturn?(self)
    }
    

}
