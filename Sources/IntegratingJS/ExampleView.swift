import Foundation
import SwiftUI

private let jsFunc = """
function makeFullName(first, last) {
  if (first !== "") {
    if (last !== "") {
      return last + ", " + first
    } else {
      return first
    }
  }

  return last
}

function reduce(model, action) {
  if (action._name === "load_initial_values") {
    model.firstName = "Bob";
    model.lastName = "Appleton";
  } else if (action._name === "clear_button_tapped") {
    model.firstName = "";
    model.lastName = "";
  } else if (action._name === "first_name_field_committed") {
    // nothing to do here, just wait for formatting
  } else if (action._name === "next_button_tapped") {
    model.isShowingNextScreen = true;
  }

  model.fullName = makeFullName(model.firstName, model.lastName);

  return model;
}
"""

/*
 Helpful improvements to make:
 - Change actions to an Enum with cases
 - create an Executor type, to keep a single instance of JSContext alive and avoid extra overhead
    - should also have a generic for Action type
 */

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

private struct NextButtonTapped: Action {
    let _name = toSnakeCase(String(describing: Self.self))
}

struct DiscountsView: View {
    struct Model: Codable {
        var firstName = ""
        var lastName = ""
        var fullName = ""
        var isShowingNextScreen = false
    }

    @State var model = Model()

    var body: some View {
        Form {
            Section("Read-only") {
                Text(model.firstName)
                Text(model.lastName)
                Text(model.fullName)
            }

            Section("Controls") {
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
                Button("Next Screen") {
                    Current.apply(NextButtonTapped(), to: &model, using: jsFunc)
                }
            }
        }
        .onAppear {
            Current.apply(LoadInitialValues(), to: &model, using: jsFunc)
        }
        .sheet(isPresented: $model.isShowingNextScreen) {
            Text("This is the next screen")
        }
    }
}

#Preview {
    DiscountsView()
}
