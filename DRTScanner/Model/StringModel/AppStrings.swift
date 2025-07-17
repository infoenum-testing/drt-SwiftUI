//
//  AppStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct AppStringsClass: Codable {
    
    let enUS: AppStrings
    let frCA: AppStrings
    let esUS: AppStrings
    
    enum CodingKeys: String, CodingKey {
        case enUS = "en_US"
        case frCA = "fr_CA"
        case esUS = "es_US"
    }
}

extension AppStringsClass {
    /// Fetch by exact language code
    subscript(_ code: LangCode) -> AppStrings {
        switch code {
        case .enUS: return enUS
        case .frCA: return frCA
        case .esUS: return esUS
        }
    }
    
    /// Overload that also accepts the raw string ("en_US") and returns nil if unknown
    subscript(_ raw: String) -> AppStrings? {
        LangCode(rawValue: raw).map { self[$0] }
    }
}

/// Languages you know about
enum LangCode: String {
    case enUS = "en_US"
    case frCA = "fr_CA"
    case esUS = "es_US"
    
    static func current() -> LangCode {
            let locale = Locale.current
            guard
                let lang = locale.languageCode,   // "en"
                let region = locale.regionCode    // "US"
        else { return .enUS }
            
        return LangCode(rawValue: "\(lang)_\(region)") ?? .enUS
        }
}

struct AppStrings: Codable {
    let lang: String
    let stats: StatsStrings
    let settings: Settings
    let dialogLogout: DialogLogout
    let mission: String
    let seat: SeatStrings
    let dialogGoOnline: DialogGoOnline
    let goldenTicket: GoldenTicket
    let login: LoginStrings
    let dialogOpenBrowser: DialogOpenBrowser
    let menu: MenuStrings
    let incorrectMode: IncorrectMode
    let serviceHref: String
    let noInternet: NoInternet
    let switchMode: SwitchMode
    let orderDetail: OrderDetail
    let dialogGoOffline: DialogGoOffline
    let attached: String
    let copyright: String
    let searchResults: SearchResults
    let unsoldScanResults: UnsoldScanResults
    let serviceName: String
    let home: HomeStrings
    let backImageSvg: String
    let backImagePng: String
    let appLogoSvg: String
    let appLogoPng: String
    
    private enum CodingKeys: String, CodingKey {
        case lang = "lang"
        case stats = "stats"
        case settings =  "settings"
        case dialogLogout = "dialog-logout"
        case mission = "mission"
        case seat = "seat"
        case dialogGoOnline = "dialog-go-online"
        case goldenTicket = "golden-ticket"
        case login = "login"
        case dialogOpenBrowser = "dialog-open-browser"
        case attached = "attached"
        case menu = "menu"
        case incorrectMode = "incorrect-mode"
        case serviceHref = "service-href"
        case noInternet = "no-internet"
        case switchMode = "switch-mode"
        case orderDetail = "order-detail"
        case dialogGoOffline = "dialog-go-offline"
        case copyright = "copyright"
        case searchResults = "search-results"
        case unsoldScanResults = "unsold-scan-results"
        case serviceName = "service-name"
        case home = "home"
        case backImageSvg = "background-href-svg"
        case backImagePng = "background-href-png"
        case appLogoSvg =  "logo-href-svg"
        case appLogoPng =  "logo-href-png"
    }
}
