//
//  FeedbackForm.swift
//  wallet
//
//  Created by Francisco Gindre on 7/14/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct FeedbackForm: View {
    @State var details: String = ""
    @State var balance: String = ""
    @State var otherSuggestions: String = ""
    @State var selectedRating = 3
    @State var showFeedbackSentAlert = false
    @Binding var isActive: Bool
    
    var validForm: Bool {
        details.count > 0
    }
    var body: some View {
        ScrollView {
       
                
                VStack(alignment: .center, spacing: 30) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Please Rank Your Experience")
                                .foregroundColor(.white)
                                .font(.title)
                            Text("We improve and iterate with YOUR feedback")
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                        .padding(0)
                        Spacer()
                    }.padding(0)
                    RateComponent(selectedIndex: $selectedRating)
                    
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Any details to share?")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        TextField("My Experience was...", text: $details)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Was your Balance Clear?")
                            .font(.body)
                            .foregroundColor(.white)
                        TextField("My balance was...", text: $balance)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What feature would you like to see next?")
                            .font(.body)
                            .foregroundColor(.white)
                        TextField("I'd like...", text: $otherSuggestions)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    Button(action: {
                        tracker.track(.feedback, properties: [
                            "rating" : String(self.selectedRating),
                            "question1" : self.details,
                            "question2" : self.balance,
                            "question3" : self.otherSuggestions
                        ])
                        self.showFeedbackSentAlert = true
                    }) {
                        Text("button_send")
                            .foregroundColor(.black)
                            .zcashButtonBackground(
                                shape: .roundedCorners(
                                    fillStyle: .solid(
                                        color: Color.zYellow)))
                            .frame(height: 48)
                    }
                .disabled(!validForm)
                }
                .padding(.bottom, 20)
                .padding([.horizontal],30)
       
            
        }
        .background(ZcashBackground())
        .keyboardAdaptive()
        .animation(.easeInOut)
        .navigationBarTitle("",displayMode: .inline)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            tracker.track(.screen(screen: .feedback), properties: [:])
        }
        .alert(isPresented: $showFeedbackSentAlert) {
            Alert(title: Text("Feedback Sent!".localized()),
                  message: Text("Thanks for your feedback!".localized()),
                  dismissButton: .default(Text("OK".localized()),action: {
                    self.isActive = false
                  }))
        }
       
        
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(10)
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.zDarkGray2))
            
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.zLightGray, lineWidth: 1))
    }
    
}

struct FeedbackForm_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackForm(isActive: .constant(true))
    }
}
