import SwiftUI

/// A view that supports displaying and transitioning between a thumbnail and an expanded view, with the ability to copy associated text.
@available(macOS 14.0, *)
public struct DroppableView: View {
  /// Nested Types
  /// A view representing a thumbnail with unique identifier.
  public struct Thumbnail: View, Identifiable {
    // Properties
    /// A unique identifier for this thumbnail.
    public var id = UUID()
    @ViewBuilder public var content: any View
    /// Lifecycle
    /// Initializes a new instance of `Thumbnail` with an optional identifier and a view builder for content.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the thumbnail. Defaults to a new UUID.
    ///   - content: A view builder that provides the content to display within the thumbnail.
    public init(
      id: UUID = UUID(),
      @ViewBuilder content: () -> any View) {
      self.id = id
      self.content = content()
    }

    /// Content
    /// The view content for the thumbnail.
    public var body: some View {
      ZStack {
        AnyView(self.content)
      }
    }
  }

  /// A view representing an expanded view with a unique identifier.
  public struct Expanded: View, Identifiable {
    // Properties
    /// A unique identifier for this expanded view.
    public var id = UUID()
    @ViewBuilder public var content: any View
    /// Lifecycle
    /// Initializes a new instance of `Expanded` with an optional identifier and a view builder for content.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the expanded view. Defaults to a new UUID.
    ///   - content: A view builder that provides the content to display within the expanded view.
    public init(
      id: UUID = UUID(),
      @ViewBuilder content: () -> any View) {
      self.id = id
      self.content = content()
    }

    /// Content
    /// The view content for the expanded view.
    public var body: some View {
      ZStack {
        AnyView(self.content)
      }
    }
  }

  /// Properties
  /// The thumbnail view to be displayed.
  var thumbnail: Thumbnail
  /// The expanded view to be displayed when toggled.
  var expanded: Expanded
  /// The background color for the thumbnail view.
  var thumbnailViewBackgroundColor = Color(.secondarySystemFill).opacity(0.8)
  /// The background color for the expanded view.
  var expandedViewBackgroundColor = Color(.secondarySystemFill)
  /// The corner radius for the thumbnail view.
  var thumbnailViewCornerRadius: CGFloat = 6
  /// The corner radius for the expanded view.
  var expandedViewCornerRadius: CGFloat = 6
  /// The text that can be copied from the view.
  var textToCopy: String
  @Namespace private var namespace
  @State private var show = false
  /// Lifecycle
  /// Initializes a new instance of `DroppableView`.
  ///
  /// - Parameters:
  ///   - thumbnail: The thumbnail view to be displayed.
  ///   - expanded: The expanded view to be displayed when toggled.
  ///   - thumbnailViewBackgroundColor: The background color for the thumbnail view. Defaults to a system fill color.
  ///   - expandedViewBackgroundColor: The background color for the expanded view. Defaults to a system fill color.
  ///   - thumbnailViewCornerRadius: The corner radius for the thumbnail view. Defaults to 6.
  ///   - expandedViewCornerRadius: The corner radius for the expanded view. Defaults to 6.
  ///   - textToCopy: The text that can be copied from the view.
  public init(
    thumbnail: Thumbnail,
    expanded: Expanded,
    thumbnailViewBackgroundColor: Color = Color(.secondarySystemFill),
    expandedViewBackgroundColor: Color = Color(.secondarySystemFill),
    thumbnailViewCornerRadius: CGFloat = 6,
    expandedViewCornerRadius: CGFloat = 6,
    textToCopy: String) {
    self.thumbnail = thumbnail
    self.expanded = expanded
    self.thumbnailViewBackgroundColor = thumbnailViewBackgroundColor
    self.expandedViewBackgroundColor = expandedViewBackgroundColor
    self.thumbnailViewCornerRadius = thumbnailViewCornerRadius
    self.expandedViewCornerRadius = expandedViewCornerRadius
    self.textToCopy = textToCopy
  }

  /// Content
  /// The view content for the droppable view, which toggles between thumbnail and expanded state on button tap.
  public var body: some View {
    Button(action: {
      if self.show {}
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        self.show.toggle()
      }
    }, label: {
      ZStack {
        if !self.show {
          self.thumbnailView()
        } else {
          self.expandedView()
        }
      }
    })
    .contextMenu {
      Button("Copy text", systemImage: "doc.on.doc", role: .destructive) {
        #if os(macOS)
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(self.textToCopy, forType: .string)
        #else
          UIPasteboard.general.string = self.textToCopy
        #endif
      }
    }
    //
    //        .onTapGesture {
    //            if !show {
    //
    //            }
    //        }
  }

  /// Creates the thumbnail view layout.
  ///
  /// - Returns: A view representing the thumbnail.
  @ViewBuilder
  private func thumbnailView() -> some View {
    ZStack {
      self.thumbnail
        .matchedGeometryEffect(id: "view", in: self.namespace)
    }
    .background(
      self.thumbnailViewBackgroundColor.matchedGeometryEffect(id: "background", in: self.namespace)
    )
    .mask(
      RoundedRectangle(cornerRadius: self.thumbnailViewCornerRadius, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: self.namespace)
    )
  }

  /// Creates the expanded view layout.
  ///
  /// - Returns: A view representing the expanded state.
  @ViewBuilder
  private func expandedView() -> some View {
    ZStack {
      self.expanded
        .matchedGeometryEffect(id: "view", in: self.namespace)
        .background(
          self.expandedViewBackgroundColor
            .matchedGeometryEffect(id: "background", in: self.namespace)
        )
        .mask(
          RoundedRectangle(cornerRadius: self.expandedViewCornerRadius, style: .continuous)
            .matchedGeometryEffect(id: "mask", in: self.namespace)
        )
      Button {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
          self.show.toggle()
        }
      } label: {
        Image(systemName: "xmark")
          .foregroundColor(.clear)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      .matchedGeometryEffect(id: "mask", in: self.namespace)
    }
  }
}
