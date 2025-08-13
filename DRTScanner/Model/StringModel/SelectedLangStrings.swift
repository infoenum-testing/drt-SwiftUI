//
//  AppStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SelectedLangStrings: Codable {
    var lang: String
    let stats: StatsStrings
    let settings: Settings
    let offline: OfflineStrings
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
    let errorMassage: ErrorMessages
    let errorDescriptionMessages: ErrorDescriptionMessages
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
    let scanner: String
    let lookupName: String
    
    private enum CodingKeys: String, CodingKey {
        case lang
        case stats
        case settings
        case offline
        case dialogLogout = "dialog-logout"
        case mission
        case seat
        case dialogGoOnline = "dialog-go-online"
        case goldenTicket = "golden-ticket"
        case login
        case dialogOpenBrowser = "dialog-open-browser"
        case menu
        case incorrectMode = "incorrect-mode"
        case serviceHref = "service-href"
        case noInternet = "no-internet"
        case switchMode = "switch-mode"
        case orderDetail = "order-detail"
        case dialogGoOffline = "dialog-go-offline"
        case errorMassage = "error"
        case errorDescriptionMessages = "error-description"
        case attached
        case copyright
        case searchResults = "search-results"
        case unsoldScanResults = "unsold-scan-results"
        case serviceName = "service-name"
        case home
        case backImageSvg = "background-href-svg"
        case backImagePng = "background-href-png"
        case appLogoSvg = "logo-href-svg"
        case appLogoPng = "logo-href-png"
        case scanner
        case lookupName = "lookup-name"
    }
}
