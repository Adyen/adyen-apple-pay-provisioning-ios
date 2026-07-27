//
//  MFAView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

/// A fake MFA verification step shown after the user signs in.
struct MFAView: View {
    let completion: () -> Void

    @State private var code = ""
    @State private var isVerifying = false
    @FocusState private var isInputFocused: Bool

    private let codeLength = 6

    var body: some View {
        VStack {
            Spacer()

            headerSection

            Spacer()

            inputSection
        }
        .background(backgroundView)
        .onAppear {
            isInputFocused = true
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .shadow(color: .black, radius: 10)

            Text("Two-Factor Authentication")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.title2)
                .shadow(color: .black, radius: 10)

            Text("Enter the 6-digit code sent to your device.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.callout)
                .shadow(radius: 5)
        }
        .padding(20)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            codeDotsRow

            // Hidden text field to capture input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .focused($isInputFocused)
                .frame(width: 0, height: 0)
                .opacity(0)
                .onChange(of: code) { _, newValue in
                    let filtered = String(newValue.filter(\.isNumber).prefix(codeLength))
                    if filtered != newValue {
                        code = filtered
                    }
                }

            Button {
                isInputFocused = false
                isVerifying = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    completion()
                }
            } label: {
                ZStack {
                    if isVerifying {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Verify")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 44)
                .font(.headline)
            }
            .background(code.count == codeLength ? Color.green : Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(code.count != codeLength || isVerifying)
            .animation(.default, value: code.count == codeLength)
        }
        .onTapGesture {
            if !isVerifying {
                isInputFocused = true
            }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20))
    }

    private var codeDotsRow: some View {
        HStack(spacing: 12) {
            ForEach(0 ..< codeLength, id: \.self) { index in
                let digit = index < code.count ? String(code[code.index(code.startIndex, offsetBy: index)]) : nil

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(index < code.count ? Color.green : Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 44, height: 56)

                    if let digit {
                        Text(digit)
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
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

#Preview {
    MFAView { }
}
