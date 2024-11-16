import AVKit
import SwiftUI

// MARK: - PlayerError

private enum PlayerError: LocalizedError {
  case badUrl(Audio)
  var errorDescription: String? {
    switch self {
    case let .badUrl(audio):
      return "Couldn't play sound: \(audio.url.lastPathComponent), the URL was invalid."
    }
  }
}

// MARK: - AudioPlayer

@MainActor
public final class AudioPlayer: NSObject, Observable, AVAudioPlayerDelegate {
  @MainActor private var player: AVAudioPlayer?

  @MainActor public static let shared = AudioPlayer()

  @MainActor
  public func play(audio: Audio) async throws {
    #if os(iOS)
    await stop()

    try AVAudioSession.sharedInstance().setCategory(.ambient)
    try AVAudioSession.sharedInstance().setActive(true)
    #endif
    try await MainActor.run {
      player = try AVAudioPlayer(contentsOf: audio.url)
      player?.delegate = self
      player?.prepareToPlay()

      DispatchQueue.main.async { [weak self] in
        self?.player?.play()
      }
    }
    await stop()
  }

  @MainActor
  func stop() async {
    player?.stop()
    player = nil
  }

  public nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    Task { await stop() }
  }
}
