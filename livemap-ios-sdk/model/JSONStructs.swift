
public struct Coordinates: Codable {
    let latitude: Double?;
    let longitude: Double?;
    let altitude: Double?;

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
}

public struct BoundingBox: Codable {
    let northEast: Coordinates?;
    let southWest: Coordinates?;

    /// - Parameters:
    ///   - northEast: Coordinates
    ///   - southWest: Coordinates
    public init(northEast: Coordinates? = nil,
                southWest: Coordinates? = nil) {
        self.northEast = northEast
        self.southWest = southWest
    }
}

public struct MapMoved: Codable {
    let zoom: Double?;
    let bounds: BoundingBox?;
    let latitude: Double?;
    let longitude: Double?;

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

