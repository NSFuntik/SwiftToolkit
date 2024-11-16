import SwiftUI

// MARK: - MaterialStyle

/// Defines the style of material effect to be applied.
public enum MaterialStyle {
  case ultraThinLight
  case thinLight
  case light
  case regular
  case thick
  case ultraThick
  case ultraThinDark
  case thinDark
  case dark

  #if canImport(UIKit)
  var uiStyle: UIBlurEffect.Style {
    switch self {
    case .ultraThinLight: return .systemUltraThinMaterialLight
    case .thinLight: return .systemThinMaterialLight
    case .light: return .systemMaterialLight
    case .regular: return .systemMaterial
    case .thick: return .systemThickMaterial
    case .ultraThick: return .systemUltraThinMaterial
    case .ultraThinDark: return .systemUltraThinMaterialDark
    case .thinDark: return .systemThinMaterialDark
    case .dark: return .systemMaterialDark
    }
  }

  #elseif canImport(AppKit)
  var nsStyle: NSVisualEffectView.Material {
    switch self {
    case .ultraThinLight, .thinLight, .light:
      return .light
    case .regular:
      return .popover
    case .thick, .ultraThick:
      return .titlebar
    case .ultraThinDark, .thinDark, .dark:
      return .dark
    }
  }

  var nsBlendingMode: NSVisualEffectView.BlendingMode {
    switch self {
    case .ultraThinLight, .ultraThinDark:
      return .withinWindow
    default:
      return .behindWindow
    }
  }
  #endif
}

// MARK: - MaterialBackgroundModifier

/// A view modifier that applies a material background effect to any SwiftUI view.
public struct MaterialBackgroundModifier<S: Shape>: ViewModifier {
  let style: MaterialStyle
  let radius: CGFloat
  let shape: S
  let tint: Color
  let stroke: Color
  let width: CGFloat
  let onTap: () -> Void

  /// Initializes a new MaterialBackgroundModifier with the specified parameters.
  public init(
    style: MaterialStyle = .regular,
    blur radius: CGFloat = 6,
    shape: S = RoundedRectangle(cornerRadius: 0, style: .continuous) as! S,
    filled tint: Color = .clear,
    borderStroke: Color = .clear,
    borderWidth: CGFloat = 0,
    onTap: @escaping () -> Void
  ) {
    self.style = style
    self.radius = radius
    self.shape = shape
    self.tint = tint
    self.stroke = borderStroke
    self.width = borderWidth
    self.onTap = onTap
  }

  public func body(content: Content) -> some View {
    content
      .background(backgroundShape)
  }

  @ViewBuilder
  private var backgroundShape: some View {
    shape.fill(tint)
      .background(
        MaterialEffectView(style: style)
          .blur(radius: radius)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      )
      .background(
        shape.stroke(lineWidth: width / 2)
          .fill(stroke)
          .blur(radius: radius)
      )
      .overlay(
        shape
          .stroke(lineWidth: width)
          .fill(stroke)
      )
      .padding(width)
      .clipShape(shape)
      .onTapGesture(perform: onTap)
  }
}

// MARK: - MaterialEffectView

public typealias BackdropBlurView = MaterialEffectView

// MARK: - MaterialEffectView

/// A view that creates a platform-specific material effect.
public struct MaterialEffectView: View {
  let style: MaterialStyle
  let onTap: () -> Void
  public init(
    style: MaterialStyle = .thinDark,
    onTap: @escaping () -> Void = {}
  ) {
    self.style = style
    self.onTap = onTap
  }

  public var body: some View {
    Group {
      #if canImport(UIKit)
      UIKitMaterialView(style: style.uiStyle)
      #elseif canImport(AppKit)
      AppKitMaterialView(style: style)
      #endif
    }
    .highPriorityGesture(TapGesture().onEnded(onTap))
  }
}

#if canImport(UIKit)
/// UIKit-specific implementation of the material effect view.
private struct UIKitMaterialView: UIViewRepresentable {
  let style: UIBlurEffect.Style

  func makeUIView(context: Context) -> UIVisualEffectView {
    let view = UIVisualEffectView()
    let blur = UIBlurEffect(style: style)
    view.effect = blur
    return view
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

#elseif canImport(AppKit)
/// AppKit-specific implementation of the material effect view.
private struct AppKitMaterialView: NSViewRepresentable {
  let style: MaterialStyle

  func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = style.nsStyle
    view.blendingMode = style.nsBlendingMode
    view.state = .active
    return view
  }

  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = style.nsStyle
    nsView.blendingMode = style.nsBlendingMode
  }
}
#endif

// MARK: - View Extension

extension View {
  /// Applies a material background with blur effect to the view.
  ///
  /// - Parameters:
  ///   - style: The style of the material effect
  ///   - radius: The blur radius
  ///   - shape: The shape to clip the background
  ///   - tint: The fill color of the shape
  ///   - stroke: The border color of the shape
  ///   - width: The width of the border
  ///   - onTap: The action to perform when tapped
  @ViewBuilder
  public func materialBackground<S: Shape>(
    style: MaterialStyle = .regular,
    blur radius: CGFloat = 6,
    shape: S = RoundedRectangle(cornerRadius: 0, style: .continuous) as! S,
    filled tint: Color = .clear,
    borderStroke: Color = .clear,
    borderWidth: CGFloat = 0,
    onTap: @escaping () -> Void = {}
  ) -> some View {
    modifier(
      MaterialBackgroundModifier(
        style: style,
        blur: radius,
        shape: shape,
        filled: tint,
        borderStroke: borderStroke,
        borderWidth: borderWidth,
        onTap: onTap
      )
    )
  }
}

// MARK: - Preview

#if DEBUG
struct MaterialBackground_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.blue
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Light Material")
          .padding()
          .materialBackground(
            style: .light,
            blur: 10,
            shape: RoundedRectangle(cornerRadius: 15),
            filled: Color.white.opacity(0.2)
          )

        Text("Dark Material")
          .padding()
          .materialBackground(
            style: .dark,
            blur: 10,
            shape: RoundedRectangle(cornerRadius: 15),
            filled: Color.black.opacity(0.2)
          )

        Text("Custom Material")
          .padding()
          .materialBackground(
            style: .regular,
            blur: 5,
            shape: RoundedRectangle(cornerRadius: 15),
            filled: Color.blue.opacity(0.1),
            borderStroke: .white,
            borderWidth: 1
          )
      }
      .padding()
    }
  }
}
#endif
