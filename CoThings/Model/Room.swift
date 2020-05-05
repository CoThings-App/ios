import Foundation

struct Room: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case count
        case limit
        case group
        case altBeaconUUID = "altbeacon_uuid"
        case iBeaconUUID = "ibeacon_uuid"
        case major
        case minor
        case percentage
        case cssClass = "css_class"
        case lastUpdated = "last_updated"
    }
    
    let id: Int64
    let name: String
    let count: Int64
    let limit: Int64
    let group: String
    let iBeaconUUID: String?
    let altBeaconUUID: String?
    let major: Int?
    let minor: Int?
    let percentage: Int64
    let cssClass: String
    let lastUpdated: String
}
