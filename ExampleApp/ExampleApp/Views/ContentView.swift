//
//  ContentView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var isShowingError = false

    var body: some View {
        ZStack {
            switch viewModel.appState {
            case .signedOut:
                SignInView { authenticated in
                    if authenticated {
                        Task {
                            try await viewModel.fetchState()
                        }
                    } else {
                        // Failed to sign in
                    }
                }
            case .loading:
                ProgressView()
            case .banner:
                BannerView { action in
                    switch action {
                    case .add:
                        do {
                            try viewModel.addCardToWallet()
                        } catch {
                            isShowingError = true
                        }
                    case .skip:
                        viewModel.setAppState(.signedIn(viewModel))
                    }
                }
                .alert(isPresented: $isShowingError) {
                    Alert(title: Text("Could not add a card to the Wallet"))
                }
            case let .signedIn(viewModel):
                TabView {
                    NavigationView {
                        AccountView(viewModel: viewModel)
                            .navigationTitle("Your account")
                            .navigationBarItems(
                                trailing: Button("Sign out",
                                                 action: {
                                                     viewModel.setAppState(.signedOut)
                                                 }))
                    }
                    .tabItem {
                        Label("Account", systemImage: "list.bullet")
                    }

                    NavigationView {
                        CardView(viewModel: viewModel)
                            .navigationTitle("Your card")

                    }
                    .tabItem {
                        Label("Card", systemImage: "creditcard")
                    }
                }
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    ContentView(
        viewModel: ViewModel(
            paymentInstrumentId: "",
            apiClient: AppAPIClient(configuration: URLSessionConfiguration.mock)
        )
    )
}
