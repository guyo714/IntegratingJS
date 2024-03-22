import Foundation
import JavaScriptCore
import Operators


var Current = Dependency.live

struct Dependency {
    var _apply: (Codable, Codable.Type, Encodable, String) -> Any
    var _log: (String, StaticString, UInt) -> Void

    func apply<C: Codable, A: Encodable>(_ action: A, to value: inout C, using script: String) {
        value = _apply(value, C.self, action, script) as! C
    }

    func log(_ message: String, file: StaticString = #file, line: UInt = #line) {
        _log(message, file, line)
    }
}

private func encode<T: Encodable>(_ value: T) -> Any {
    let encoder = JSONEncoder()
    let inputData = try! encoder.encode(value)
    return try! JSONSerialization.jsonObject(with: inputData)
}

private func decode<T: Decodable>(_ type: T.Type, from dict: [AnyHashable: Any]) throws -> T {
    let decoder = JSONDecoder()
    let data = try JSONSerialization.data(withJSONObject: dict)
    return try decoder.decode(type, from: data)
}

extension Dependency {
    static let live = Dependency(
        _apply: { input, cType, action, script in
            let jsInput = encode(input)
            let jsAction = encode(action)

            let context = JSContext()!
            context.evaluateScript(script)

            guard let function = context.objectForKeyedSubscript("reduce") else {
                fatalError("missing function 'reduce'!")
            }
            guard let result = function.call(withArguments: [jsInput, jsAction]) else {
                fatalError("failed to call function!")
            }

            do {
                return try decode(cType, from: result.toDictionary())
            } catch {
                print(error)
                fatalError(error.localizedDescription)
            }
        },
        _log: { str, file, line in
            let lineNumber = line 
            |> { "\($0)" }
            >>> slice
            >>> fixedWidth(3)

            let prefix = file.description
            |> slice
            >>> dropExtension
            >>> removeDir
            >>> fixedWidth(10)

            print("\(prefix): \(line) - '\(str)'")
        }
    )
}

private func slice<C: Collection>(_ value: C) -> C.SubSequence {
    value[...]
}

private func dropExtension(_ str: Substring) -> Substring {
    guard let extIndex = str.lastIndex(of: ".") else {
        return str
    }

    return str[..<extIndex]
}

private func removeDir(_ str: Substring) -> Substring {
    guard let slashIndex = str.lastIndex(of: "/") else {
        return str
    }

    return str[slashIndex...].dropFirst()
}

private func fixedWidth(_ length: Int) -> (Substring) -> String {
    { str in
        String(str) + String(repeating: " ", count: length - str.count)
    }
}
