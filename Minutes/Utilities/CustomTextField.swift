//
//  CustomTextField.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/5/21.
//

import Foundation
import SwiftUI
import UIKit





extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String, saveAction: @escaping () -> Void) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title, saveAction: saveAction)
    }

}

struct TextFieldAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let saveAction: () -> Void

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                VStack {
                    Text(self.title).foregroundColor(.black).bold().font(.system(size: 20)).padding(.top, 12)
                    CustomTextField(text: self.$text, isFirstResponder: self.isShowing)                .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .id(self.isShowing).padding().padding(.top, 5)
                    Divider()
                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                            }
                        }) {
                            Text("Dismiss").font(.system(size: 20)).bold().foregroundColor(.red).padding()
                        }.frame(width: 110, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
                        
                        Divider()

                        Button(action: {
                            withAnimation {
                                //add save action
                            
                                    self.saveAction()
                                    self.isShowing.toggle()
     

                            }
                        }) {
                            Text("Save").font(.system(size: 20)).foregroundColor(.blue).padding()
                        }.frame(width: 110, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
                    }.padding(.horizontal, 4)
                }.background(Color(UIColor.lightGray)).cornerRadius(15)
                .padding()
                .frame(
                    width: 280,
                    height: 220
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}




struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

    }

    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        
        let placeholder = NSAttributedString(string: "Minutes", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        textField.attributedPlaceholder = placeholder
        textField.textColor = UIColor.black
        textField.backgroundColor = UIColor.white
        textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}




