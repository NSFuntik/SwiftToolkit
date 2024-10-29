import SwiftUI

public struct LogTagView: View {
  @Binding private var selectedTags: Set<String>

  var isSelected: Bool {
    selectedTags.contains(name)
  }

  private let name: String

  public init(name: String, selectedTags: Binding<Set<String>>) {
    self.name = name
    self._selectedTags = selectedTags
  }

  public var body: some View {
    return Button {
      if isSelected {
        selectedTags.remove(name)
      } else {
        selectedTags.insert(name)
      }
    } label: {
      ZStack {
        HStack {
          Spacer()
          Image(systemName: isSelected ? "checkmark" : "plus")
            .imageScale(.medium)
        }
        HStack {
          Text(name)
            .padding(.trailing, 22)
            .multilineTextAlignment(.leading)
          Spacer()
        }
      }
      .foregroundColor(.white)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 5)
    .background(isSelected ? Color.blue : Color.gray)
    .cornerRadius(8)
  }
}
