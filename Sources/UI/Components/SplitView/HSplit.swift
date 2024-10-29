//
//  HSplit.swift
//  SplitView
//
//  Created by Steven Harris on 3/1/23.
//

import SwiftUI

// MARK: - HSplit

/// A view that splits its contents into two parts, allowing for adjustable sizing and hiding capabilities.
@MainActor
public struct HSplit<P: View, D: SplitDivider, S: View>: View {
  private let fraction: FractionHolder
  private let hide: SideHolder
  private let constraints: SplitConstraints
  private let onDrag: ((CGFloat) -> Void)?
  private let primary: P
  private let splitter: D
  private let secondary: S
  /// The body of the view, which defines the layout of the primary and secondary views along with the splitter.
  public var body: some View {
    Split(primary: { primary }, secondary: { secondary })
      .layout(LayoutHolder(.horizontal))
      .constraints(constraints)
      .onDrag(onDrag)
      .splitter { splitter }
      .fraction(fraction)
      .hide(hide)
  }

  /// Initializes a new `HSplit` with primary and secondary views, using default settings for fraction, hiding, and constraints.
  /// - Parameters:
  ///   - left: A closure returning the primary view.
  ///   - right: A closure returning the secondary view.
  public init(
    @ViewBuilder left: @escaping () -> P,
    @ViewBuilder right: @escaping () -> S) where D == Splitter {
    let fraction = FractionHolder()
    let hide = SideHolder()
    let constraints = SplitConstraints()
    self.init(fraction: fraction, hide: hide, constraints: constraints, onDrag: nil, primary: { left() }, splitter: { D() }, secondary: { right() })
  }

  /// Initializes a new `HSplit` with custom settings for fraction, hide, constraints, and behavior during dragging.
  /// - Parameters:
  ///   - fraction: The current fraction of the split view.
  ///   - hide: The side that is currently hidden.
  ///   - constraints: The constraints governing the split view's resizing behavior.
  ///   - onDrag: A closure executed during drag operations.
  ///   - primary: A closure returning the primary view.
  ///   - splitter: A closure returning the splitter view.
  ///   - secondary: A closure returning the secondary view.
  private init(
    fraction: FractionHolder,
    hide: SideHolder,
    constraints: SplitConstraints,
    onDrag: ((CGFloat) -> Void)?,
    @ViewBuilder primary: @escaping () -> P,
    @ViewBuilder splitter: @escaping () -> D,
    @ViewBuilder secondary: @escaping () -> S) {
    self.fraction = fraction
    self.hide = hide
    self.constraints = constraints
    self.onDrag = onDrag
    self.primary = primary()
    self.splitter = splitter()
    self.secondary = secondary()
  }

  // MARK: Modifiers

  /// Note: Modifiers return a new HSplit instance with the same state except for what is
  /// being modified.
  /// Return a new HSplit with the `splitter` set to the `splitter` passed-in.
  public func splitter<T>(
    @ViewBuilder _ splitter: @escaping () -> T
  ) -> HSplit<P, T, S> where T: View {
    return HSplit<P, T, S>(fraction: fraction, hide: hide, constraints: constraints, onDrag: onDrag, primary: { primary }, splitter: splitter, secondary: { secondary })
  }

  /// Return a new instance of HSplit with `constraints` set to these values.
  /// - Parameters:
  ///   - minPFraction: Minimum fraction for the primary view.
  ///   - minSFraction: Minimum fraction for the secondary view.
  ///   - priority: The side that should take priority during resizing.
  ///   - dragToHideP: A Boolean indicating if dragging the splitter should hide the primary view.
  ///   - dragToHideS: A Boolean indicating if dragging the splitter should hide the secondary view.
  public func constraints(
    minPFraction: CGFloat? = nil,
    minSFraction: CGFloat? = nil,
    priority: SplitSide? = nil,
    dragToHideP: Bool = false,
    dragToHideS: Bool = false) -> HSplit {
    let constraints = SplitConstraints(minPFraction: minPFraction, minSFraction: minSFraction, priority: priority, dragToHideP: dragToHideP, dragToHideS: dragToHideS)
    return HSplit(fraction: fraction, hide: hide, constraints: constraints, onDrag: onDrag, primary: { primary }, splitter: { splitter }, secondary: { secondary })
  }

  /// Return a new instance of HSplit with `onDrag` set to `callback`.
  ///
  /// The `callback` will be executed as `splitter` is dragged, with the current value of `privateFraction`.
  /// Note that `fraction` is different. It is only set when drag ends, and it is used to determine the initial fraction at open.
  /// - Parameter callback: A closure executed during the split view dragging.
  public func onDrag(
    _ callback: ((CGFloat) -> Void)?
  ) -> HSplit {
    return HSplit(
      fraction: fraction,
      hide: hide,
      constraints: constraints,
      onDrag: callback,
      primary: { primary },
      splitter: { splitter },
      secondary: { secondary })
  }

  /// Return a new instance of HSplit with its `splitter.styling` set to these values.
  /// - Parameters:
  ///   - color: The color of the splitter.
  ///   - inset: The inset value for the splitter styling.
  ///   - visibleThickness: The thickness of the visible splitter.
  ///   - invisibleThickness: The thickness of the invisible splitter.
  ///   - hideSplitter: A Boolean indicating if the splitter should be hidden.
  public func styling(
    color: Color? = nil,
    inset: CGFloat? = nil,
    visibleThickness: CGFloat? = nil,
    invisibleThickness: CGFloat? = nil,
    hideSplitter: Bool = false) -> HSplit {
    let styling = SplitStyling(color: color, inset: inset, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness, hideSplitter: hideSplitter)
    splitter.styling.reset(from: styling)
    return HSplit(fraction: fraction, hide: hide, constraints: constraints, onDrag: onDrag, primary: { primary }, splitter: { splitter }, secondary: { secondary })
  }

  /// Return a new instance of HSplit with `fraction` set to this FractionHolder
  /// - Parameter fraction: The FractionHolder to set.
  public func fraction(_ fraction: FractionHolder) -> HSplit<P, D, S> {
    HSplit(fraction: fraction, hide: hide, constraints: constraints, onDrag: onDrag, primary: { primary }, splitter: { splitter }, secondary: { secondary })
  }

  /// Return a new instance of HSplit with `fraction` set to a FractionHolder holding onto this CGFloat
  /// - Parameter fraction: The CGFloat to set as the fraction.
  public func fraction(_ fraction: CGFloat) -> HSplit<P, D, S> {
    self.fraction(FractionHolder(fraction))
  }

  /// Return a new instance of HSplit with `hide` set to this SideHolder
  /// - Parameter side: The SideHolder to hide.
  public func hide(_ side: SideHolder) -> HSplit<P, D, S> {
    HSplit(fraction: fraction, hide: side, constraints: constraints, onDrag: onDrag, primary: { primary }, splitter: { splitter }, secondary: { secondary })
  }

  /// Return a new instance of HSplit with `hide` set to a SideHolder holding onto this SplitSide
  /// - Parameter side: The SplitSide to hide.
  public func hide(_ side: SplitSide) -> HSplit<P, D, S> {
    self.hide(SideHolder(side))
  }
}

// MARK: - HSplit_Previews

struct HSplit_Previews: PreviewProvider {
  static var previews: some View {
    HSplit(
      left: { Color.green },
      right: {
        VSplit(
          top: { Color.red },
          bottom: {
            HSplit(
              left: { Color.blue },
              right: { Color.yellow })
          })
      })
    HSplit(
      left: {
        VSplit(top: { Color.red }, bottom: { Color.green })
      },
      right: {
        VSplit(top: { Color.yellow }, bottom: { Color.blue })
      })
  }
}
