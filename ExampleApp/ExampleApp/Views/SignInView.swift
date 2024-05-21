//
//  SignInView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

struct SignInView: View {
    let completion: () -> Void
    @State private var userName = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Spacer()

            Text("Easy Pay")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.largeTitle)
                .shadow(color: .black, radius: 10)
            Text("Make payments a breeze!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.callout)
                .shadow(radius: 5)
            Spacer()

            VStack(spacing: 16) {
                TextField("User name", text: $userName, prompt: Text("User name").foregroundColor(.white))
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .tint(.green)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green)
                    )
                    .foregroundColor(.white)

                SecureField("Password", text: $password, prompt: Text("Password").foregroundColor(.white))
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .tint(.green)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green)
                    )
                    .foregroundColor(.white)

                Button("Get started") {
                    completion()
                }
                .frame(maxWidth: .infinity, maxHeight: 44)
                .multilineTextAlignment(.center)
                .font(.headline)
                .background(.green)
                .border(.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20))
        .background(
            Image("payment")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .brightness(-0.2)
                .blur(radius: 13.0)
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SignInView {}
}
