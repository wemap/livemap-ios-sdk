
// https://stackoverflow.com/questions/53367491/decode-json-string-to-class-object-swift
extension Decodable { // Codable + Decodable = Codable
    static func map(dict: NSDictionary) -> Self? {
        do {
            let decoder = JSONDecoder()
            let bodyStruct = try JSONSerialization.data(withJSONObject: dict)
            let parsedStruct = try decoder.decode(Self.self, from: bodyStruct)
            return parsedStruct
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func map(string: String) -> Self? {
        do {
            let decoder = JSONDecoder()
            let parsedStruct = try decoder.decode(Self.self, from: Data(string.utf8))
            return parsedStruct
        } catch let error {
            print(error)
            return nil
        }
    }
}

extension Encodable { // Codable + Decodable = Codable

    static func toJsonString(parsedStruct: Self) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(parsedStruct)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        } catch { print(error) }
        return nil
    }
}
