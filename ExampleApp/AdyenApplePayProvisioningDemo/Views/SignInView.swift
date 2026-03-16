//
//  SignInView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import SwiftUI

/// A view that handles user authentication for the Apple Pay provisioning flow.
struct SignInView: View {
    /// Closure executed when the sign-in process completes.
    let completion: (Bool) -> Void

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Spacer()

            headerSection

            Spacer()

            inputSection
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20))
        .background(backgroundView)
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack {
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
        }
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username, prompt: Text("Username").foregroundColor(.white))
                .inputStyle()

            SecureField("Password", text: $password, prompt: Text("Password").foregroundColor(.white))
                .inputStyle()

            Button("Get started") {
                completion(true)
            }
            .frame(maxWidth: .infinity, maxHeight: 44)
            .font(.headline)
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var backgroundView: some View {
        Image("payment")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity)
            .brightness(-0.2)
            .blur(radius: 13.0)
    }
}

// MARK: - View Modifiers

private extension View {
    /// Applies a consistent style to text input fields within the sign-in form.
    func inputStyle() -> some View {
        frame(maxWidth: .infinity, maxHeight: 44)
            .tint(.green)
            .multilineTextAlignment(.center)
            .font(.headline)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green)
            )
            .foregroundColor(.white)
    }
}

#Preview {
    SignInView { _ in }
}
