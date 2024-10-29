import SwiftUI
import CoreAudio

public extension AnyFeedback {
  /// Specifies feedback that plays an audio file
  /// - Parameter audio: The audio to play when this feedback is triggered
  static func audio(_ audio: Audio) -> Self {
    .init(AudioFeedback(audio: audio))
  }
}

public extension View {
  /// Specifies feedback that plays an audio file
  /// - Parameter audio: The audio to play when this feedback is triggered
  func audio(_ audio: Audio) -> some View {
    self.modifier(AudioFeedback(audio: audio))
  }
}

public extension Audio {
  /// Plays the audio file
  @MainActor
  func play() async throws {
    try await AudioPlayer.shared.play(audio: self)
  }
}

// MARK: - AudioPlayerEnvironmentKey

public struct AudioPlayerEnvironmentKey: @preconcurrency EnvironmentKey {
  @MainActor
  public static let defaultValue = AudioPlayer.shared
}

public extension EnvironmentValues {
  var audioPlayer: AudioPlayer {
    get { self[AudioPlayerEnvironmentKey.self] }
    set { self[AudioPlayerEnvironmentKey.self] = newValue }
  }
}

// MARK: - AudioFeedback

public struct AudioFeedback: Feedback, ViewModifier {
  @State var audio: Audio

  @Environment(\.audioPlayer) private var player

  public init(audio: Audio) {
    self._audio = State(wrappedValue: audio)
  }

  public func body(content: Content) -> some View {
    content
      .environment(\.audioPlayer, self.player)
      .task(id: self.audio.hashValue) {
        try? await self.player.play(audio: self.audio)
      }
  }

  // Functions

  @MainActor
  public func perform() async {
    do {
      try await self.player.play(audio: self.audio)
    } catch {
      debugPrint("Error playing audio", error)
    }
  }
}
