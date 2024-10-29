import SwiftUI
import Combine

public struct LogFilterView: View {
  // Properties

  @ObservedObject private var logger: SwiftUILogger
  @State private var searchText = ""
  @State private var contentSize: CGSize = .zero
  @State private var displayedTags: [String] = []
  @State private var selectedTags: Set<String>

  private var isPresented: Binding<Bool>

  private var tags: [String]

  // Lifecycle

  public init(
    logger: SwiftUILogger = .default,
    tags: [String],
    isPresented: Binding<Bool>) {
    self.logger = logger
    self.tags = tags
    self.isPresented = isPresented

    self.selectedTags = logger.filteredTags
  }

  // Content

  public var body: some View {
    self.navigation {
      VStack {
        self.searchBar

        Divider()
          .padding(.vertical, 5)

        self.tagListView

        Spacer()
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          self.cancelToolbarItem
        }

        ToolbarItem(placement: .cancellationAction) {
          HStack(spacing: 5) {
            if self.selectedTags.isEmpty == false {
              self.clearToolbarItem
            }

            self.saveToolbarItem
          }
        }
      }
    }
  }

  @ViewBuilder
  private func navigation(content: () -> some View) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
      NavigationStack {
        content()
      }
    } else {
      NavigationView {
        content()
      }
    }
  }

  private var searchBar: some View {
    SearchBar(
      searchText: self.$searchText,
      placeholder: "Search for tags")
      .onReceive(Just(self.searchText)) { keyword in
        self.displayedTags = self.onSearchKeyword(keyword)
      }
  }

  private var tagListView: some View {
    ScrollView(.vertical) {
      GeometryReader { _ in
        LazyVGrid(
          columns: [GridItem(.flexible())],
          spacing: 8) {
            Group {
              ForEach(self.displayedTags, id: \.self) { tagName in
                LogTagView(
                  name: tagName,
                  selectedTags: self.$selectedTags)
              }
            }
            .navigationTitle("Filter")
          }
          .background(Color.clear)
      }
      .padding(.horizontal, 16)
    }
  }

  private var cancelToolbarItem: some View {
    Button("Cancel") {
      self.isPresented.wrappedValue = false
    }
  }

  private var clearToolbarItem: some View {
    Button("Clear") {
      self.selectedTags = []
    }
  }

  private var saveToolbarItem: some View {
    Button("Apply") {
      self.logger.filteredTags = self.selectedTags
      self.isPresented.wrappedValue = false
    }
  }

  // Functions

  // MARK: Helpers

  private func onSearchKeyword(_ keyword: String) -> [String] {
    let filtered: [String] = self.tags.filter {
      $0
        .lowercased()
        .range(
          of: keyword.lowercased(),
          options: .caseInsensitive) != nil
    }

    return filtered.isEmpty ? self.tags : filtered
  }
}
