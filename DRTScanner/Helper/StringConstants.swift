//
//  StringConstraint.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

struct StringConstants {
    
    enum LandingView {
        static let showCode = "ENTER SHOW CODE"
        static let copyRight = "Copyright(c) 2013-2025. DRT Performance Tix.\nAll Rights Reserved"
        static let invalidShowCode = "Invalid show code."
        static let validShowCode = "Do you want to scan merchandise or seat?"
        static let merchandise = "MERCHANDISE"
        static let seat = "SEAT"
        static let seatSection = "Seat"
        static let changeShow = "Change Show"
        static let scanMerchOrSeat = "What would you like to scan?"
        static let isOfflineAlertMessage = "You are currently scanning in OFFLINE MODE and therefore cannot log out. First, find connectivity and go back into online mode. Then you may log out"
        static let logoutConfirm = "Are you sure you want to log out?"
        static let orderLabel = "ORDER"
        static let ccLabel = "CC"
        static let phoneLabel = "PHONE NUMBER"
        static let previouslyScannedAt = "PREVIOUSLY SCANNED AT %@"
        static let notYetScanned = "NOT YET SCANNED"
        static let sectionLabel = "SECT:"
        static let rowLabel = "ROW:"
        static let seatLabel = "SEAT:"
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
        static let yes = "Yes"
        static let no = "No"
        static let emailCannotEmpty = "Email cannot be empty"
        static let invalidEmail = "Invalid email address"
        static let success = "Success"
        static let nameCannotEmpty = "Name cannot be empty"
        static let invalidName = "Invalid Name"
        static let done = "Done"
        static let alert = "ALERT"
        static let cancel = "Cancel"
        static let continueTextAlert = "Continue"
        static let music = "music"
        static let DontCry = "Don't cry"
        static let someTimeLittle = "some time a little.."
        static let noOrdersAvailable = "No orders available."
        static let noOrdersFound = "No orders found."
        
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
        static let ordersNotFound = "Orders not found."
        static let showCode = "Show Code"
        static let selectTime = "Select Time"
        static let seats = "seats"
        static let merch = "merch"
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
        static let showDt = "showDt"
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
        static let unsold = "unsold"
        static let isSold = "issold"
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
    
    struct DRTImages {
        static let backgound = "background"
        static let crossImage = "Popup_cross_btn"
        static let logo = "Logo"
        static let logout = "logout"
        static let scanNow = "scan_now"
        static let greenCheckImage = "Green_circle_check_btn"
        static let leftSideArrow = "left_side_arrow"
        static let arrowWithCrossBtnImage = "arrow_with_cross_btn"
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
        static let lookUpBy = "Look Up By"
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
        static let successDbDownloadAlert = "Database download successfully"
        static let selectSeat = "Select Seat"
    }
    
    struct SideMenuView {
        static let goOffline = "GO OFFLINE"
        static let goOfflineViewText = "Go offline"
        static let goOfflineViewDiscription = "By going offline, the database will be downloaded to this device, and nobody else will be able to scan tickets for this show until I go back online. When I return online, the scanned tickets will be uploaded back to the server.\n\nBy signing my name, I understand and agree to the above:"
        static let goOnline = "GO ONLINE"
        static let goOnlineServer = "Uploading database"
        static let goOnlineSuccess = "Database Uploaded Successfully!"
        static let goOnlineFailed = "Database upload failed! Please try again."
        static let scanTicket = "SCAN TICKETS"
        static let ticket = "tickets?"
        static let merchandise = "merchandise?"
        static let scanMerchandise = "SCAN MERCHANDISE"
        static let scaningStats = "SCANNING STATS"
        static let scaningStatsTitle = "Scanning Stats"
        static let about = "ABOUT"
        static let logout = "LOG OUT"
        static let drtWebsite = "DRT WEBSITE"
        static let setting = "SETTINGS"
        static let settingSmall = "Settings"
        static let goOfflineViewTextFieldText = "Type your name here"
        static let openDrtWebsiteTitle = "Open DRT Website?"
        static let openDrtWebsiteMessage = "Do you want to visit the DRT website?"
        static let drtWebsiteURL = "http://www.dancerecitalticketing.com"
        static let copyRightTitle = "Copyright(c) 2013-2025. DRT Performance Tix."
        static let copyRightTitle2 = "All Rights Reserved"
        static let aboutDescriptionText = "Our purpose and mission is to provide small bussinesses with the advantages to grow and prosper through innovative solution and lifelong relationships."
    }
    
    // MARK: - API Error -
    struct APIError {
        static let serverError = "Server Error"
        static let tokenHasExpired = "Token has expired"
        static let clientError = "Client Error"
        static let invalidCredential = "Invalid credentials provided."
        static let emailNotVerified = "User email address does not veirfied. Please verify email address through the OTP to continue access to the app."
        
    }
    
    struct Offline {
            static let title = "Going Offline"
            static let description = "Are you sure you want to go offline? The database will be downloaded to this device, and nobody else will be able to scan tickets until you go back online."
            static let continueText = "CONTINUE"
            static let cancelText = "CANCEL"
        }
    
    struct DRTFont {
        static let verlagBold = "Verlag-Bold"
        static let verlagBook = "Verlag-Book"
        static let verlagBlack = "Verlag-Black"
    }
    
    struct DRTToastMessages {
        static let inValidMerchandiseVoucher = "You are currently in merchandise scanning mode."
        static let inValidTicketVoucher = "You are currently in seat scanning mode."
        static let inValidShow = "INVALID SHOW"
        static let preScanned = "Previously Scanned"
    }
}
