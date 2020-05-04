import Foundation

struct Room: Decodable {
  let id: Int64
  let name: String
  let count: Int64
  let limit: Int64
  let group: String
  let ibeacon_uuid: String?
  let altbeacon_uuid: String?
  let major: Int?
  let minor: Int?
  let percentage: Int64
  let css_class: String
  let last_updated: String
}
