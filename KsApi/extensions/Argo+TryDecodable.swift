import Argo
import Foundation

extension Argo.JSON {
  func toPrimitive() -> Any? {
    switch self {
    case .array(let json):
      return json.map { $0.toPrimitive() }
    case .bool(let bool):
      return bool
    case .null:
      return nil
    case .number(let number):
      return number
    case .object(let dict):
      return dict.mapValues { $0.toPrimitive() }
    case .string(let string):
      return string
    }
  }
}

public func tryDecodable<T: Swift.Decodable>(_ json: Argo.JSON?) -> Argo.Decoded<T?> {
  guard
    let primitive = json?.toPrimitive(),
    let data = try? JSONSerialization.data(withJSONObject: primitive, options: [])
    else { return .success(nil) }

  do {
    let value = try JSONDecoder().decode(T?.self, from: data)
    return .success(value)
  } catch let error {
    return .failure(.custom("\(error)"))
  }
}

public func tryDecodable<T: Swift.Decodable>(_ json: JSON) -> Decoded<T> {
  guard
    let primitive = json.toPrimitive(),
    let data = try? JSONSerialization.data(withJSONObject: primitive, options: [])
    else { return .failure(.custom("Invalid JSON data")) }

  do {
    let value = try JSONDecoder().decode(T.self, from: data)
    return .success(value)
  } catch let error {
    return .failure(.custom(error.localizedDescription))
  }
}
