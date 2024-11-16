import Foundation

#if os(iOS)
import SwiftUI
import Core
/// This color picker bar can be used to select colors, using a
/// SwiftUI `ColorPicker` and a list of colors.
///
/// The picker supports both optional and non-optional bindings.
///
/// The picker uses `.colorPickerBarColors` as the default list
/// of colors to list, but you can pass in any colors.
public struct ColorPickerBar: View {

  /// Create a color picker bar with an optional binding.
  ///
  /// - Parameters:
  ///   - value: The value to bind to.
  ///   - colors: The colors to list in the bar, by default `.colorPickerBarColors`.
  public init(
    value: Binding<Color?>,
    colors: [Color] = .colorPickerBarColors
  ) {
    self.value = value
    self.colors = colors
  }

  /// Create a color picker bar with a non-optional binding.
  ///
  /// - Parameters:
  ///   - value: The value to bind to.
  ///   - colors: The colors to list in the bar, by default `.colorPickerBarColors`.
  public init(
    value: Binding<Color>,
    colors: [Color] = .colorPickerBarColors
  ) {
    self.value = .init(
      get: {
        value.wrappedValue
      },
      set: {
        value.wrappedValue = $0 ?? .clear
      }
    )
    self.colors = colors
  }

  private let value: Binding<Color?>
  private let colors: [Color]

  @Environment(\.colorPickerBarConfig)
  private var config: Config

  @Environment(\.colorPickerBarStyle)
  private var style: Style

  @Environment(\.colorScheme)
  private var colorScheme

  public var body: some View {
    HStack(spacing: 0) {
      picker
      if !colors.isEmpty {
        divider
        scrollView
      }
      if shouldShowResetButton {
        divider
        resetButton
      }
    }
    .labelsHidden()
    .frame(maxHeight: style.selectedColorSize)
  }
}

extension ColorPickerBar {

  fileprivate func colorButton(for color: Color) -> some View {
    Button {
      value.wrappedValue = color
    } label: {
      let size = scrollViewCircleSize(for: color)
      colorCircle(for: color)
        .frame(width: size, height: size)
        .padding(.vertical, isSelected(color) ? 0 : 5)
        .animation(style.animation, value: value.wrappedValue)
    }.buttonStyle(.plain)
  }

  @ViewBuilder
  fileprivate func colorCircle(for color: Color) -> some View {
    Circle()
      .stroke(scrollViewCircleStroke(for: color), lineWidth: 1)
      .background(scrollViewCircleBackground(for: color))
  }

  fileprivate var divider: some View {
    Divider()
  }

  fileprivate var picker: some View {
    ColorPicker(
      "",
      selection: value.unwrapped(.accentColor),
      supportsOpacity: config.addOpacityToPicker
    )
    .fixedSize()
    .padding(.trailing, style.spacing)
  }

  fileprivate var resetButton: some View {
    Button {
      value.wrappedValue = config.resetButtonValue
    } label: {
      style.resetButtonImage
        .resizable()
        .frame(width: style.colorSize, height: style.colorSize)
    }
    .padding(.leading, style.spacing)
  }

  fileprivate var scrollView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: style.spacing) {
        ForEach(Array(colors.enumerated()), id: \.offset) {
          colorButton(for: $0.element)
        }
      }
      .padding(.horizontal, style.spacing)
      .padding(.vertical, 2)
    }.frame(maxWidth: .infinity)
  }

  @ViewBuilder
  fileprivate func scrollViewCircleBackground(for color: Color) -> some View {
    if color == .clear {
      Image(systemName: "circle.dotted")
        .resizable()
    } else {
      Circle()
        .fill(color)
        .shadow(.badge)
    }
  }

  fileprivate func scrollViewCircleSize(for color: Color) -> Double {
    isSelected(color) ? style.selectedColorSize : style.colorSize
  }

  fileprivate func scrollViewCircleStroke(for color: Color) -> Color {
    if color == .black && colorScheme == .dark { return .white }
    return .clear
  }
}

extension ColorPickerBar {

  fileprivate var hasChanges: Bool {
    value.wrappedValue != config.resetButtonValue
  }

  fileprivate var shouldShowResetButton: Bool {
    config.addResetButton && hasChanges
  }

  fileprivate func isSelected(_ color: Color) -> Bool {
    value.wrappedValue == color
  }

  fileprivate func select(color: Color) {
    value.wrappedValue = color
  }
}

extension Collection where Element == Color {

  /// Get a standard list of `ColorPickerBar` colors.
  public static var colorPickerBarColors: [Color] {
    [
      .black, .gray, .white,
      .red, .pink, .orange, .yellow,
      .indigo, .purple, .blue, .cyan, .teal, .mint,
      .green, .brown,
    ]
  }

  public static func colorPickerBarColors(withClearColor: Bool) -> [Color] {
    let standard = colorPickerBarColors
    guard withClearColor else { return standard }
    return [.clear] + standard
  }
}

#Preview {

  struct Preview: View {

    @State
    private var color1: Color = .red

    @State
    private var color2: Color = .yellow

    @State
    private var color3: Color = .purple

    @State
    private var optionalColor: Color?

    @State
    var optionalDouble: Double?

    var pickers: some View {
      VStack(alignment: .leading) {
        ColorPickerBar(
          value: $color1,
          colors: [.red, .green, .blue]
        )
        ColorPickerBar(
          value: $color2
        )
        ColorPickerBar(
          value: $color3,
          colors: .colorPickerBarColors(withClearColor: true)
        )
        ColorPickerBar(
          value: $optionalColor,
          colors: .colorPickerBarColors(withClearColor: true)
        )
        .colorPickerBarConfig(
          .init(
            addOpacityToPicker: false,
            addResetButton: true,
            resetButtonValue: nil
          )
        )
      }
      .padding()
    }

    var body: some View {
      VStack {
        pickers
        pickers
          .background(Color.black)
          .colorScheme(.dark)
      }
    }
  }

  return Preview()
}
#endif
