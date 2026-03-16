//
//  AccountView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

/// A view that displays the account balance and a list of recent transactions.
struct AccountView: View {
    var body: some View {
        VStack(spacing: 20) {
            balanceHeader

            transactionList

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Subviews

    /// Displays the current account balance.
    private var balanceHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.headline)

            HStack {
                Text("$42.78")
                    .font(.largeTitle)
                Spacer()
            }
        }
        .frame(height: 80)
    }

    /// Displays a scrollable list of mock transactions.
    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Transactions")
                .font(.headline)

            ScrollView {
                // Generates a mock list of transactions for demo purposes.
                ForEach((1...30).reversed(), id: \.self) { day in
                    transactionRow(forDay: day)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    /// A single row representing a transaction entry.
    private func transactionRow(forDay day: Int) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(day) - 01 - 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("-$\(String(format: "%.2f", Double.random(in: 2...120)))")
                    .font(.headline)
            }
            .frame(height: 44)

            Divider()
        }
    }
}

#Preview {
    AccountView()
}
