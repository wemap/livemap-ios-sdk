public class JSON: NSObject {
    internal func toDictionary() -> [String?: Any] {
        let mirror = Mirror(reflecting: self);
        return Dictionary(uniqueKeysWithValues: mirror.children.map { ($0.label, $0.value) })
    }
    
    internal func toJson() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self.toDictionary(), options: [])
        } catch {
            return nil
        }
    }

    public func toJsonString() -> String {
        return String(data: self.toJson()!, encoding: String.Encoding.ascii) ?? "undefined"
    }
}

public class Coordinates: JSON {
    public let latitude: Double?;
    public let longitude: Double?;
    public let altitude: Double?;

    /// - Parameters:
    ///   - latitude: Double
    ///   - longitude: Double
    ///   - altitude: Double
    public init(latitude: Double? = nil,
                longitude: Double? = nil,
                altitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
    
    static func fromJson(_ json: NSDictionary? = nil) -> Coordinates {
        let latitude = json?["latitude"] as? Double;
        let longitude = json?["longitude"] as? Double;
        let altitude = json?["altitude"] as? Double;
        
        return Coordinates(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

public class BoundingBox: JSON {
    public let northEast: Coordinates?;
    public let southWest: Coordinates?;
    
    /// - Parameters:
    ///   - northEast: Coordinates
    ///   - southWest: Coordinates
    public init(northEast: Coordinates? = nil, southWest: Coordinates? = nil) {
        self.northEast = northEast!
        self.southWest = southWest!
    }
    
    static func fromJson(_ json: NSDictionary? = nil) -> BoundingBox {
        let northEast = Coordinates.fromJson(json?["northEast"] as? NSDictionary);
        let southWest = Coordinates.fromJson(json?["southWest"] as? NSDictionary);
        
        return BoundingBox(northEast: northEast, southWest: southWest)
    }
}

public class MapMoved: JSON {
    public let zoom: Double?;
    public let bounds: BoundingBox?;
    public let latitude: Double?;
    public let longitude: Double?;

    /// - Parameters:
    ///   - zoom: Double
    ///   - bounds: BoundingBox
    ///   - latitude: Double
    ///   - longitude: Double
    public init(zoom: Double? = nil,
                bounds: BoundingBox? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil) {
        self.zoom = zoom
        self.bounds = bounds
        self.latitude = latitude
        self.longitude = longitude
    }
}

public class ContentUpdatedQuery: JSON {
    public let query: String?;
    public let tags: [String]?;
    public let bounds: BoundingBox?;
    public let minAltitude: Int?;
    public let maxAltitude: Int?;
    
    init(query: String? = nil,
         tags: [String]? = nil,
         bounds: BoundingBox? = nil,
         minAltitude: Int? = nil,
         maxAltitude: Int? = nil) {
        self.query = query
        self.tags = tags
        self.bounds = bounds
        self.minAltitude = minAltitude
        self.maxAltitude = maxAltitude
    }
}

public struct MaxBoundsSnippet: Codable {
    let _northEast: MaxBoundsSnippetCoords?;
    let _southWest: MaxBoundsSnippetCoords?;
}

public struct MaxBoundsSnippetCoords: Codable {
    let lat: Double?;
    let lng: Double?;
}

public struct IntroCardParameter: Codable {
    let active: Bool?;

    /// - Parameters:
    ///   - active: Bool
    public init(active: Bool? = nil) {
        self.active = active
    }
}

public class PolylineOptions: JSON {
    public let color: String?;
    public let opacity: Float?;
    public let width: Float?;
    public let useNetwork: Bool?;
    
    init(color: String? = "2F7DE1",
         opacity: Float = 0.8,
         width: Float = 4,
         useNetwork: Bool = false) {
        self.color = color
        self.opacity = opacity
        self.width = width
        self.useNetwork = useNetwork
    }
}
