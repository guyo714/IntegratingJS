import Foundation
import SwiftUI

private let jsFunc = """
function reduce(model, action) {
  if (action._name === "load_initial_values") {
    return {
      "firstName": "Bob",
      "lastName": "Appleton",
      "fullName": model.fullName
    }
  } else if (action._name === "clear_button_tapped") {
    return {
      "firstName": "",
      "lastName": "",
      "fullName": model.fullName
    }
  } else if (action._name === "first_name_field_committed") {
    return {
      "firstName": model.firstName,
      "lastName": model.lastName,
      "fullName": model.lastName + ", " + model.firstName // or more complex logic
    }
  } else {
    return model;
  }
}
"""

protocol Action: Encodable {
    var _name: String { get }
}

// MARK: - Actions
private struct LoadInitialValues: Action {
    let _name = toSnakeCase(String(describing: Self.self))
}

private struct ClearButtonTapped: Action {
    let _name = toSnakeCase(String(describing: Self.self))
}

private struct FirstNameFieldCommitted: Action {
    let _name = toSnakeCase(String(describing: Self.self))
}

struct DiscountsView: View {
    struct Model: Codable {
        var firstName = ""
        var lastName = ""
        var fullName = ""
    }

    @State var model = Model()

    var body: some View {
        Form {
            Text(model.firstName)
            Text(model.lastName)
            Text(model.fullName)
            TextField("First Name", text: $model.firstName, onCommit: {
                // defer most state manipulations to the reducer
                Current.apply(FirstNameFieldCommitted(), to: &model, using: jsFunc)
            })

            Button("Clear") {
                // defer most state manipulations to the reducer
                Current.apply(ClearButtonTapped(), to: &model, using: jsFunc)
            }
            Button("Load") {
                // defer most state manipulations to the reducer
                Current.apply(LoadInitialValues(), to: &model, using: jsFunc)
            }
        }
        .onAppear {
            Current.apply(LoadInitialValues(), to: &model, using: jsFunc)
        }
    }
}

#Preview {
    DiscountsView()
}
