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
        static let merchandise = "Merchandise"
        static let seat = "Seat"
    }
    
    // MARK: - Common -
    struct Common {
        static let token = "accessToken"
        static let row = "Row"
        static let section = "Section"
        static let confirm = "Confirm"
        static let logout = "Logout"
        static let Email = "Email"
        static let continueText = "CONTINUE"
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
        static let noOrderFound = "NO ORDER FOUND"
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
        static let noOrdersAvailable = "No orders available."
        
        static let unknown = "Unknown"
        static let oID = "OID :"
        static let cc = "CC :"
        static let phone = "Phone :"
        static let deleteOrder = "Delete Order"
        static let editOrder = "Edit Order"
        static let addOrder = "Add Order"
        static let orderDetails = "Order Details"
        static let buyerName = "Buyer Name"
        static let createOrder = "Create Order"
        static let editOrderDetails = "Edit Order Details"
        static let unknownDevice = "UnknownDevice"
        static let Order = "ORDER"
        static let loadingSeatInformation = "Loading seat information..."
        static let totalResults = "Total Results:"
        static let loadingOrderInformation = "Loading Order information..."
        static let phoneNumber = "PHONE NUMBER"
        static let scannedQrCode = "Scanned QR Code:"
        static let inputCode = "289-6385"
        static let ordersNotFound = "Orders not found."
        static let showCode = "Show Code"
    }
    
    struct httpMethod {
        static let get = "GET"
    }
    
    
    struct Attributes {
        static let oid = "oid"
        static let buyerName = "buyer_name"
        static let cc = "cc"
        static let phone = "phone"
        static let barcode = "barcode"
        static let row = "row"
        static let seat = "seat"
        static let seats = "seats"
        static let section = "section"
        static let qrCode = "qrCode"
        static let handicapped = "handicapped"
        static let datesScanned = "date_scanned"
        static let showId = "show_id"
        static let message = "message"
        static let showDt = "show_dt"
        static let studioId = "studio_id"
        static let valid = "valid"
        static let logoHref = "logo_href"
        static let backgroundHref = "background_href"
        static let color_1_bg = "color_1_bg"
        static let color_1_text = "color_1_text"
        static let color_2_bg = "color_2_bg"
        static let color_2_text = "color_2_text"
        static let href = "href"
        static let height = "height"
        static let width = "width"
        static let isScannedOut = "is_scanned_out"
        static let timeStamp = "timeStamp"
        static let orders = "orders"
        static let sold = "sold"
    }
    
    struct NSPredicate {
        static let oid = "(oid == %@)"
        static let cc = "(cc == %@)"
        static let showidBarcodeQrCode = "(show.show_id == %@) AND ((barcode == %@) OR (qrCode == %@))"
        static let showShowId = "(show.show_id == %@)"
        static let showIdSection = "(show.show_id == %@) AND (section == %@)"
        static let showIdSectionRow = "(show.show_id == %@) AND (section == %@) AND (row == %@)"
        static let sectionRowSeatShowId = "(section == %@) AND (row == %@) AND (seat == %@) AND (show.show_id == %@)"
        static let oidShowId = "(oid == %@) AND (show.show_id == %@)"
    }
    
    struct Formate {
        static let oid = "oid == %@"
        static let showId = "show_id == %@"
        static let barcode = "barcode == %@"
        static let totalSeats = "total_seats == %@"
        static let logoHref = "logo_href == %@"
        static let href = "href == %@"
        static let cc = "cc"
        static let phone = "phone"
        static let phoneContains = "phone CONTAINS [cd] %@"
        static let buyerName = "buyer_name CONTAINS [cd] %@"
    }
    
    struct SeatHomeView {
        static let orderNumberIcon = "order_number_icon"
        static let lookUpBy = "Look UP By"
        static let orderNumber = "ORDER NUMBER"
        static let rightSideArrow = "right_side_arrow"
        static let lastNameIcon = "last_name_icon"
        static let name = "NAME"
        static let phoneNumberIcon = "phone_number_icon"
        static let phoneNumber = "PHONE NUMBER"
        static let creditCardIcon = "credit_card_icon"
        static let creditCard = "CREDIT CARD"
        static let seatIcon = "seat_icon"
        static let seat = "SEAT"
        static let danceRecitalTicketing = "Dance Recital Ticketing"
        static let danceNationals = "2016 DANCE NATIONALS"
        static let areYouSureYouWantToLogout = "Are you sure you want to logout?"
    }
    
    struct SideMenuView {
        static let goOffline = "GO OFFLINE"
        static let scaningStats = "SCANNING STATS"
        static let about = "ABOUT"
        static let stopScanning = "STOP SCANNING"
        static let drtWebsite = "DRT WEBSITE"
        static let setting = "SETTINGS"
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
