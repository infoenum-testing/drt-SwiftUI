//
//  MarchedResponse.swift
//  DRTScanner
//
//  Created by DRT on 03/09/25.
//



struct MarchedResponse: Codable {
    let iconSrc: String?
    let tsScanned: Int64
    let valid: Bool
    let dateScanned: String?
    let qtyScanned: Int?
    let message: String
    let name: String?
    let variantName: String?
    let qty: Int?

    enum CodingKeys: String, CodingKey {
        case iconSrc, tsScanned, valid, dateScanned, qtyScanned, message, name, variantName, qty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        iconSrc = try container.decodeIfPresent(String.self, forKey: .iconSrc)
        valid = try container.decode(Bool.self, forKey: .valid)
        dateScanned = try? container.decodeIfPresent(String.self, forKey: .dateScanned)
        qtyScanned = try container.decodeIfPresent(Int.self, forKey: .qtyScanned)
        message = try container.decode(String.self, forKey: .message)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        variantName = try? container.decodeIfPresent(String.self, forKey: .variantName)
        qty = try container.decodeIfPresent(Int.self, forKey: .qty)

        // tsScanned can be Int / Double / String
        if let intValue = try? container.decode(Int64.self, forKey: .tsScanned) {
            tsScanned = intValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .tsScanned) {
            tsScanned = Int64(doubleValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .tsScanned),
                  let intFromString = Int64(stringValue) {
            tsScanned = intFromString
        } else {
            tsScanned = 0
        }
    }
}

extension MarchedResponse {
    var tsScannedString: String { String(tsScanned) }
}
