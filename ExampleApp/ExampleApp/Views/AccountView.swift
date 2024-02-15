//
//  AccountView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .font(.headline)
                        HStack {
                            Text("42.78 $")
                                .font(.largeTitle)
                            Spacer()
                        }
                    }

                    Spacer()
                }

                Spacer()
            }
            .frame(height: 80)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Transactions")
                        .font(.headline)
                    Spacer()
                }

                ScrollView {
                    ForEach((1...30).reversed(), id: \.self) { number in
                        VStack {
                            HStack {
                                Text("\(number) - 01 - 2024")
                                    .font(.caption)
                                Spacer()
                                Text("- \(String(format: "%.2f", Double.random(in: 2...120))) $")
                                    .font(.headline)
                            }
                            .frame(height: 44)

                            Color.gray.frame(height: 1)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    AccountView(
        viewModel: ViewModel(
            paymentInstrumentId: "",
            apiClient: AppAPIClient(configuration: URLSessionConfiguration.mock)
        )
    )
}
