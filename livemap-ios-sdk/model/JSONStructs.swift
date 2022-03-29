
public class Coordinates: NSObject {
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

public class BoundingBox: NSObject {
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

public class MapMoved: NSObject {
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

// from snippet.config.json
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

