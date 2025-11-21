import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo or App Name
                Text("Recipe Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)

                // Email Field
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                // Password Field
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)

                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Login Button
                Button(action: {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

                // Register Button
                Button(action: {
                    showRegister = true
                }) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
