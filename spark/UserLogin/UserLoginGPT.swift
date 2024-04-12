import SwiftUI

struct LogIn2: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var shouldNavigate: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    Text("Log In")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Group {
                        TextField("Email", text: $email)
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            .background(.gray)
                            .cornerRadius(15)
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            .background(.gray)
                            .cornerRadius(15)
                    }
                    
                    Spacer()

                    Button(action: {
                        if allFieldsAreValid() {
                            self.shouldNavigate = true
                        }
                    }) {
                        Text("Confirm")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                    }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(.white)
                            .cornerRadius(40)
                            .padding(.top, 25)

                    Button(action: {
                        print("Navigate to login screen")
                    }) {
                        Text("Don't have an account?")
                            .font(.system(size: 17))
                            .underline()
                            .foregroundColor(.white)                    }
                }
            }
            .padding(.vertical, 160)
            .padding(.horizontal, 48)
            .frame(width: 430, height: 932)
            .background(.black)
        }
    }

    private func allFieldsAreValid() -> Bool {
        return !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
}

struct LogInV2iew_Previews: PreviewProvider {
    static var previews: some View {
        LogIn2()
    }
}
