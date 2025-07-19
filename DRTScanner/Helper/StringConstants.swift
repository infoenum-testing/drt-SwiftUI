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
        static let continueText = "CONTINUE"
        static let search = "Search"
        
        static let refreshToken = "refreshToken"
        
        static let save = "Save"
        static let error = "Error"
        static let ok = "OK"
        static let yes = "Yes"
        static let no = "No"
        static let success = "Success"
        static let cancel = "Cancel"
        static let continueTextAlert = "Continue"
        static let noOrdersFound = "No orders found."
        
        
        static let Order = "ORDER"
        static let totalResults = "TOTAL RESULTS:"
        static let ordersNotFound = "Orders not found."
        static let showCode = "Show Code"
        static let selectTime = "Select Time"
    }
    
    struct httpMethod {
        static let get = "GET"
    }
    
    
    struct Attributes {
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
        
        static let successDbDownloadAlert = "Database download successfully"
        static let selectSeat = "Select Seat"
    }
    
    struct SideMenuView {
        static let goOffline = "GO OFFLINE"
        
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
    
    
    struct DRTFont {
        static let verlagBold = "Verlag-Bold"
        static let verlagBook = "Verlag-Book"
        static let verlagBlack = "Verlag-Black"
    }
    
    struct DRTToastMessages {
        static let inValidMerchandiseVoucher = "You are currently in merchandise scanning mode."
        static let inValidTicketVoucher = "You are currently in seat scanning mode."
    }
}
