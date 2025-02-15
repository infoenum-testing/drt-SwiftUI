//
//  DRTHTTPServiceConstants.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//

import Foundation

enum DRTHTTPServiceConstants {
    static let serverURL = "https://api.drttix.com/scanner"
    
    struct Show {
        static let path = "/show"
        static let sidKey = "sid"
        
        static func url(forCode code: String, deviceName: String) -> URL? {
            var components = URLComponents(string: serverURL + path)
            components?.queryItems = [
                URLQueryItem(name: "c", value: code),
                URLQueryItem(name: "devicename", value: deviceName)
            ]
            return components?.url
        }
    }
    
    struct Ticket {
        static let getTicket = "/ticket?c=%@&bc=%@&devicename=%@"
        static let getTicketQrCode = "/%@?c=%@&devicename=%@"
        static let showIDKey = "show_id"
    }
    
    struct Database {
        static let getAllData = "/db/dl?c=%@&username=%@&devicename=%@"
        static let uploadOfflineData = "/db/ul/?c=%@&sid=%@&db_code=%@&username=%@&devicename=%@"
        static let listOfSections = "/db/q?c=%@&ds=sections&devicename=%@"
        static let listOfRows = "/db/q?c=%@&ds=rows&s=%@&devicename=%@"
        static let listOfSeats = "/db/q?c=%@&ds=seats&s=%@&r=%@&devicename=%@"
    }
    
    struct Lookup {
        static let seat = "/seat?c=%@&section=%@&row=%@&seat=%@&devicename=%@"
        static let order = "/orders/by-number?c=%@&q=%@&devicename=%@"
        static let byPhoneNumber = "/orders/by-phone?c=%@&q=%@&devicename=%@"
        static let byLastName = "/orders/by-name?c=%@&q=%@&devicename=%@"
        static let byCreditCard = "/orders/by-cc?c=%@&&q=%@&devicename=%@"
    }
    
    struct Order {
        static let seat = "/order/?c=%@&sid=%@&oid=%@&type=%@"
    }
    
    struct StringService {
        static let stringCode = "/strings?lang=en-US"
    }
    
    struct KeyTag {
        static let lookup = "/keytag/?c=%@&code=%@&devicename=%@"
    }
    
    struct TicketOut {
        static let ticketOut = "/ticket-out/?sid=%@&bc=%@&devicename=%@"
    }
}
