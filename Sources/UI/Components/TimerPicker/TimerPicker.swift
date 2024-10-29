//
//  ContentView.swift
//  TimerDemo
//
//  Created by Aryaman Sharda on 2/20/23.
//

import SwiftUI

// MARK: - TimerView

public struct TimerView: View {
  public init(
    hours: Binding<Int>,
    minutes: Binding<Int>,
    seconds: Binding<Int>) {
    self._selectedHoursAmount = hours
    self._selectedMinutesAmount = minutes
    self._selectedSecondsAmount = seconds
  }

  private var totalTimeForCurrentSelection: Int {
    (selectedHoursAmount * 3600) + (selectedMinutesAmount * 60) + selectedSecondsAmount
  }

  // MARK: Public Properties

  @Binding var selectedHoursAmount: Int
  @Binding var selectedMinutesAmount: Int
  @Binding var selectedSecondsAmount: Int
  var timerControls: some View {
    HStack {
      Button("Cancel") {
        state = .cancelled
      }
      .buttonStyle(CircleButtonStyle()).foregroundStyle(.primary, .secondary)

      Spacer()

      switch state {
      case .cancelled:
        Button("Start") {
          state = .active
        }
        .buttonStyle(CircleButtonStyle()).foregroundStyle(.secondary, .green)
      case .paused:
        Button("Resume") {
          state = .resumed
        }
        .buttonStyle(CircleButtonStyle()).foregroundStyle(.orange, .orange.opacity(0.66))
      case .active,
           .resumed:
        Button("Pause") {
          state = .paused
        }
        .buttonStyle(CircleButtonStyle()).foregroundStyle(.primary, .orange)
      }
    }.font(.body.weight(.medium).monospaced())
      .padding(.horizontal, 32)
  }

  var timePickerControl: some View {
    HStack {
      TimePickerView(title: "hours", range: hoursRange, binding: $selectedHoursAmount)
      TimePickerView(title: "min", range: minutesRange, binding: $selectedMinutesAmount)
      TimePickerView(title: "sec", range: secondsRange, binding: $selectedSecondsAmount)
    }
    .frame(width: .infinity)
    .padding(.all, 32)
  }

  var progressView: some View {
    ZStack {
      withAnimation {
        CircularProgressView(progress: $progress)
      }

      VStack {
        Text(secondsToCompletion.asTimestamp)
          .font(.largeTitle)
        HStack {
          Image(systemName: "bell.fill")
          Text(completionDate, format: .dateTime.hour().minute())
        }
      }
    }
    .frame(
      minWidth: 250,
      idealWidth: 360,
      maxWidth: 440,
      minHeight: 200,
      idealHeight: 255,
      maxHeight: 300,
      alignment: .center)
    .padding(.all, 32)
  }

  public var body: some View {
    VStack {
      Group {
        if state == .cancelled {
          timePickerControl
        } else {
          progressView
        }
      }
      .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
      .padding(16)
      timerControls
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.bar)
    .foregroundStyle(.foreground)
  }

  struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .frame(width: 66, height: 66)
        .foregroundStyle(.primary)
        .background(.secondary.opacity(0.44), in: Circle())
        .padding(3)
        .overlay(
          Circle()
            .stroke(.secondary, lineWidth: 1.3)
            .foregroundStyle(.primary)
        )
    }
  }

  // MARK: - TimerViewModel

  //	final class TimerViewModel: ObservableObject {
  //		public init(
  //			hours: Int = 0,
  //			minutes: Int = 5,
  //			seconds: Int = 10
  //		) {
  //			self.selectedHoursAmount = hours
  //			self.selectedMinutesAmount = minutes
  //			self.selectedSecondsAmount = seconds
  //		}

  /// Represents the different states the timer can be in
  enum TimerState {
    case active
    case paused
    case resumed
    case cancelled
  }

  // MARK: Private Properties

  @State private var timer: Timer? = nil

  // Powers the ProgressView
  @State var secondsToCompletion = 0
  @State var progress: Float = 0.0
  @State var completionDate = Date.now

  let hoursRange = 0 ... 23
  let minutesRange = 0 ... 59
  let secondsRange = 0 ... 59

  private func startTimer(total: Int) {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak timer] _ in
      guard let timer else {
        return
      }

      debugPrint(
        timer.tolerance.timeString,
        terminator: " Remaining...")

      secondsToCompletion -= 1
      progress = Float(secondsToCompletion) / Float(total)

      // We can't do <= here because we need the time from T-1 seconds to
      // T-0 seconds to animate through first
      if secondsToCompletion < 0 {
        state = .cancelled
      }
    }
  }

  private func updateCompletionDate() {
    completionDate = Date.now.addingTimeInterval(Double(secondsToCompletion))
  }

  //	}

  @State var state: TimerState = .cancelled {
    didSet {
      switch state {
      case .cancelled:
        timer?.invalidate()
        secondsToCompletion = 0
        progress = 0

      case .active:
        startTimer(total: totalTimeForCurrentSelection)

        secondsToCompletion = totalTimeForCurrentSelection
        progress = 1.0

        updateCompletionDate()

      case .paused:
        timer?.invalidate()

      case .resumed:
        startTimer(total: totalTimeForCurrentSelection)
        updateCompletionDate()
      }
    }
  }

  struct TimePickerView: View {
    /// This is used to tighten up the spacing between the Picker and its
    /// respective label
    ///
    /// This allows us to avoid having to use custom
    private let pickerViewTitlePadding: CGFloat = 4.0

    let title: String
    let range: ClosedRange<Int>
    let binding: Binding<Int>

    var body: some View {
      HStack(spacing: -pickerViewTitlePadding) {
        Picker(title, selection: binding) {
          ForEach(range, id: \.self) { timeIncrement in
            HStack {
              // Forces the text in the Picker to be right-aligned
              Spacer()
              Text("\(timeIncrement)")
                .foregroundStyle(.foreground)
                .multilineTextAlignment(.trailing)
            }
          }
        }
        .pickerStyle(InlinePickerStyle())
        .labelsHidden()

        Text(title)
          .fontWeight(.bold)
          .foregroundStyle(.foreground)
      }
    }
  }
}

// MARK: - CircularProgressView

struct CircularProgressView: View {
  @Binding var progress: Float

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 8.0)
        .opacity(0.3)
        .foregroundStyle(.secondary)
      Circle()
        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
        .foregroundStyle(.orange)
        // Ensures the animation starts from 12 o'clock
        .rotationEffect(Angle(degrees: 270))
    }
    // The progress animation will animate over 1 second which
    // allows for a continuous smooth update of the ProgressView
    .animation(.linear(duration: 1.0), value: progress)
  }
}

extension Int {
  var asTimestamp: String {
    let hour = self / 3600
    let minute = self / 60 % 60
    let second = self % 60

    return String(format: "%02i:%02i:%02i", hour, minute, second)
  }
}

// MARK: - TimerView_Previews

#if swift(>=6.0)
  @available(iOS 18.0, *)
  #Preview {
    @Previewable @State var triggerTimestamp: (h: Int, m: Int, s: Int) = (1, 0, 0)
    TimerView(hours: $triggerTimestamp.h, minutes: $triggerTimestamp.m, seconds: $triggerTimestamp.s)
  }
#endif
