import Foundation

func toSnakeCase(_ str: String) -> String {
    guard !str.isEmpty else {
        return ""
    }

    var result = "\(str.first!.lowercased())"

    for char in str.dropFirst() {
        if char.isUppercase {
            result.append("_")
            result.append(char.lowercased())
        } else {
            result.append(char)
        }
    }

    return result
}
