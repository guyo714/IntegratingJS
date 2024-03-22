import Foundation
import JavaScriptCore

struct Dependency {
    var _execute: (Codable, Codable.Type, Encodable, String) -> Any

    func execute<C: Codable, A: Encodable>(_ value: C, action: A, using script: String) -> C {
        _execute(value, C.self, action, script) as! C
    }
}

func encode<T: Encodable>(_ value: T) -> Any {
    let encoder = JSONEncoder()
    let inputData = try! encoder.encode(value)
    return try! JSONSerialization.jsonObject(with: inputData)
}

func decode<T: Decodable>(_ type: T.Type, from dict: [AnyHashable: Any]) throws -> T {
    let decoder = JSONDecoder()
    let data = try JSONSerialization.data(withJSONObject: dict)
    return try decoder.decode(type, from: data)
}

extension Dependency {
    static let live = Dependency(
        _execute: { input, cType, action, script in
            let jsInput = encode(input)
            let jsAction = encode(action)

            let context = JSContext()!
            context.evaluateScript(script)

            guard let function = context.objectForKeyedSubscript("sayHello") else {
                fatalError("missing function 'sayHello'!")
            }
            guard let result = function.call(withArguments: [jsInput, jsAction]) else {
                fatalError("failed to call function!")
            }

            do {
                print(result.isUndefined)
                let output = try decode(cType, from: result.toDictionary())

                print("type is: \(type(of: output))")

                return output
            } catch {
                print(error)
                fatalError(error.localizedDescription)
            }
        }
    )
}

var Current = Dependency.live

struct Name: Codable {
    var first = "Bob"
    var last = "Smith"
}

protocol NameAction: Encodable {
    var name: String { get }
}

struct ButtonTapped: NameAction {
    let name = "set_name"
    let value: String

    init(_ value: String) {
        self.value = value
    }
}


let jsFunction = """
function sayHello(model, action) {
    if (action.name === "set_name") {
        return {
            "first": model.first,
            "last": action.value
        };
    } else {
        return model;
    }
}
"""

print(Current.execute(Name(), action: ButtonTapped("Bobberson"), using: jsFunction))
