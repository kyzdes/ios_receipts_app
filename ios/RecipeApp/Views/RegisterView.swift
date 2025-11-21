import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }

                Section {
                    Button(action: register) {
                        if authViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(authViewModel.isLoading || !isFormValid)
                }

                if let errorMessage = authViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Register")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !username.isEmpty &&
        password == confirmPassword && password.count >= 8
    }

    func register() {
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }

        Task {
            await authViewModel.register(email: email, password: password, username: username)
            if authViewModel.isAuthenticated {
                dismiss()
            }
        }
    }
}
