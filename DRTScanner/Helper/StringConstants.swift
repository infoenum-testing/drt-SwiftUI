//
//  StringConstraint.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

struct StringConstants {
    enum LandingView {
        static let showCode = "ENTER SHOW CODE"
        static let copyRight = "Copyright(c) 2013-2025. DRT Performance Tix. All Rights Reserved"
        static let invalidShowCode = "Invalid show code."
        static let validShowCode = "Do you want to scan merchandise or seat?"
    }
    // MARK: - Common -
       struct Common {
           static let token = "accessToken"
           static let Email = "Email"
           static let Password = "Password"
           static let submit = "Submit"
           static let enterEmailAddress = "Enter email address"
           static let SignUp = "Sign up"
           static let enterPassword = "Enter Password"
           static let skip = "Skip"
           static let accessTokenExpiresAt = "access_token_expires_at"
           static let refreshTokenExpiresAt = "refresh_token_expires_at"
           static let userName = "userName"
           static let refreshToken = "refreshToken"
           static let oneTimeOtp = "One-time code"
           static let logIn = "Log in"
           static let forgotPassword = "Forgot password?"
           static let guest = "Guest"
           static let save = "Save"

           static let error = "Error"
           static let ok = "OK"
           static let emailCannotEmpty = "Email cannot be empty"
           static let invalidEmail = "Invalid email address"
           static let success = "Success"
           static let nameCannotEmpty = "Name cannot be empty"
           static let invalidName = "Invalid Name"
           static let done = "Done"
           static let alert = "Alert"
           static let cancel = "Cancel"
           static let music = "music"
           static let DontCry = "Don't cry"
           static let someTimeLittle = "some time a little.."

       }
    
    // MARK: - API Error -
    
    struct APIError {
        static let serverError = "Server Error"
        static let tokenHasExpired = "Token has expired"
        static let clientError = "Client Error"
        static let invalidCredential = "Invalid credentials provided."
        static let emailNotVerified = "User email address does not veirfied. Please verify email address through the OTP to continue access to the app."
        
    }
}
