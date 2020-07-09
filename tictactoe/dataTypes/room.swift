import Foundation

/// Stores a room with its information for the table view data source
struct room: Codable,Hashable,Identifiable {
    var id:    Int
    var title: String
    var host:  String
    var occupancy:  Int
    
}
