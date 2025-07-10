//
//  AppStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct AppStrings: Codable {
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

	private enum CodingKeys: String, CodingKey {
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
	}

}
