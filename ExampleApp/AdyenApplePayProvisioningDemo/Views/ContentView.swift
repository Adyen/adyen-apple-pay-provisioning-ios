//
//  ContentView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import SwiftUI

/// The root view that manages the top-level navigation state of the application.
/// It switches between authentication, loading, promotional banners, and the main dashboard.
@MainActor
struct ContentView: View {
    @State var viewModel: ViewModel

    var body: some View {
        ZStack {
            switch viewModel.appState {
            case .signedOut:
                SignInView { _ in
                    // Authentication succeeded. The signed-in flow decides when to fetch data.
                    viewModel.setAppState(.signedIn(.home))
                }

            case .loading:
                ProgressView("Loading your card…")

            case let .signedIn(subState):
                switch subState {
                case .banner:
                    BannerView { action in
                        handleBannerAction(action)
                    }
                    .alert(item: Bindable(viewModel).provisioningError) { error in
                        Alert(
                            title: Text("Wallet Error"),
                            message: Text(error.localizedDescription),
                            dismissButton: .default(Text("OK")) {
                                viewModel.clearProvisioningError()
                            }
                        )
                    }

                case .home:
                    mainTabView(viewModel)
                        .task {
                            await viewModel.fetchStateIfNeeded()
                        }
                }
            }
        }
        .animation(.default, value: viewModel.appState)
    }

    // MARK: - Helper Methods

    private func handleBannerAction(_ action: BannerView.Selection) {
        switch action {
        case .add:
            do {
                // Triggers the system sheet; success, error, and cancellation are handled via delegate callbacks.
                try viewModel.addCardToWallet()
            } catch {
                // Handle immediate initialization errors.
                viewModel.provisioningError = AppError(
                    code: .provisioningUnavailable,
                    description: error.localizedDescription,
                    underlyingError: error
                )
            }

        case .skip:
            // Explicit dismissal moves the user to the dashboard.
            viewModel.setSignedInState(.home)
        }
    }

    private func mainTabView(_ viewModel: ViewModel) -> some View {
        TabView {
            NavigationStack {
                AccountView()
                    .navigationTitle("Your Account")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out") {
                                viewModel.signOut()
                            }
                        }
                    }
            }
            .tabItem {
                Label("Account", systemImage: "list.bullet")
            }

            NavigationStack {
                CardView(viewModel: viewModel)
                    .navigationTitle("Your Card")
            }
            .tabItem {
                Label("Card", systemImage: "creditcard")
            }
        }
    }
}

#Preview {
    ContentView(
        viewModel: ViewModel(
            paymentInstrumentId: "PREVIEW_ID",
            apiEnvironment: .test,
            networkManager: NetworkManager(
                session: URLSession(configuration: .mock),
                headerProvider: EmptyHeaderProvider()
            ),
            activationDataCacheFactory: ActivationDataCacheFactory()
        )
    )
}
