import SwiftUI

public struct SearchBar: View {
  @Binding private var searchText: String
  private let placeholder: String

  public init(searchText: Binding<String>, placeholder: String) {
    self._searchText = searchText
    self.placeholder = placeholder
  }

  public var body: some View {
    ZStack {
      Rectangle()
        .foregroundColor(Color(.lightGray).opacity(0.25))

      HStack(alignment: .center) {
        Image(systemName: "magnifyingglass")
          .imageScale(.medium)
        TextField(placeholder, text: $searchText)
      }
      .foregroundColor(.gray)
      .padding(.horizontal, 15)
    }
    .frame(height: 40)
    .cornerRadius(10)
    .padding(.horizontal, 16)
  }
}
