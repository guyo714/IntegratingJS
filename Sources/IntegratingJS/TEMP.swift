import Foundation


struct Name: Codable {
    var first = "Bob"
    var last = "Smith"
}

private struct ClearButtonTapped: Action {
    let _name = toSnakeCase(String(describing: Self.self))
}

private struct SetLastName: Action {
    let _name = toSnakeCase(String(describing: Self.self))
    let value: String
}

private let jsFunction = """
function reduce(model, action) {
    if (action._name === "clear_button_tapped") {
        return {
            "first": "",
            "last": ""
        };
    } else if (action._name === "set_last_name") {
        return {
            "first": model.first,
            "last": action.value
        };
    } else {
        return model;
    }
}
"""

//var name = Name()
//Current.log(name.last)
//
//private let action = ClearButtonTapped()
//Current.apply(action, to: &name, using: jsFunction)
//
//Current.log(name.last)
//
//Current.apply(SetLastName(value: "Bobberson"), to: &name, using: jsFunction)
//
//Current.log(name.last)


//print(Current.execute(Name(), action: ButtonTapped("Bobberson"), using: jsFunction))
