import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 12, *)
public protocol TextSliderStyle {
  associatedtype Body: View
  typealias Configuration = TextSliderConfiguration
  @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

@available(iOS 15, macOS 12, *)
public struct TextSliderConfiguration {
  public struct Label: View {
    let configuration: TextSliderConfiguration

    public init(configuration: TextSliderConfiguration) {
      self.configuration = configuration
    }

    public var body: some View {
      TextSliderField(
        value: configuration._value,
        bounds: configuration.bounds,
        step: configuration.step,
        format: configuration.format,
        phase: configuration._phase
      )
    }
  }

  let _value: Binding<Double>
  let _phase: Binding<TextSlider.Phase>

  public var value: Double { _value.wrappedValue }
  public let bounds: ClosedRange<Double>
  public let step: Double.Stride
  public let format: FloatingPointFormatStyle<Double>
  public var phase: TextSlider.Phase { _phase.wrappedValue }

  public var label: some View {
    Label(configuration: self)
  }
}

@available(iOS 15, macOS 12, *)
private struct TextSliderStyleEnvironmentKey: EnvironmentKey {
  public static var defaultValue: any TextSliderStyle { PlainTextSliderStyle() }
}

@available(iOS 15, macOS 12, *)
extension EnvironmentValues {
  public var textSliderStyle: any TextSliderStyle {
    get { self[TextSliderStyleEnvironmentKey.self] }
    set { self[TextSliderStyleEnvironmentKey.self] = newValue }
  }
}

@available(iOS 15, macOS 12, *)
extension View {
  public func textSliderStyle<S>(_ style: S) -> some View where S: TextSliderStyle {
    environment(\.textSliderStyle, style)
  }
}
#endif
