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
    @FocusState private var focusedField: Field?

    private enum Field {
        case username, password
    }

    var body: some View {
        VStack {
            Spacer()

            headerSection

            Spacer()

            inputSection
        }
        .background(backgroundView)
        .onAppear {
            focusedField = .username
        }
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
        .padding(20)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            TextField(
                "Username",
                text: $username,
                prompt: Text("Username").foregroundColor(.white)
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focusedField, equals: .username)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }
            .inputStyle()

            SecureField(
                "Password",
                text: $password,
                prompt: Text("Password").foregroundColor(.white)
            )
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit { completion(true) }
            .inputStyle()

            Button("Get started") {
                completion(true)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .font(.headline)
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20))
    }

    private var backgroundView: some View {
        GeometryReader { proxy in
            Image("payment")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .brightness(-0.2)
                .blur(radius: 13.0)
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Modifiers

private extension View {
    /// Applies a consistent style to text input fields within the sign-in form.
    func inputStyle() -> some View {
        padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 44)
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
