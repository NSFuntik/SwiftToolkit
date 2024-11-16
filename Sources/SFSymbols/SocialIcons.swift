//
//  SocialIcons.swift
//  FlomniChatCore
//
//  Created by Dmitry Mikhaylov on 30.05.2024.
//

import SwiftUI

// MARK: - SocialIcons

public enum SocialIcons: RawRepresentable, CaseIterable {
  public static let allCases: [SocialIcons] = [
    .etsy, .facebook, .facebookMessenger, .github, .google, .imo, .instagram, .apple, .discord, .linkedin, .medium,
    .notion, .paypal, .pinterest, .reddit, .signal, .skype, .snapchat, .telegram, .tikTok, .twitch, .twitter, .venmo,
    .wechat, .whatsApp, .youTube, .viber, .vk, .odnoklassniki, .email, .voicer,
  ]
  case unknown(String)

  case etsy
  case facebook
  case facebookMessenger
  case github
  case google
  case imo
  case instagram
  case apple
  case discord
  case linkedin
  case medium
  case notion
  case paypal
  case pinterest
  case reddit
  case signal
  case skype
  case snapchat
  case telegram
  case tikTok
  case twitch
  case twitter
  case venmo
  case wechat
  case whatsApp
  case youTube
  case viber
  case vk
  case odnoklassniki
  case email
  case voicer

  public var rawValue: String {
    switch self {
    case .etsy: "etsy"
    case .facebook: "facebook"
    case .facebookMessenger: "facebookMessenger"
    case .github: "github"
    case .google: "google"
    case .imo: "imo"
    case .instagram: "instagram"
    case .apple: "apple"
    case .discord: "discord"
    case .linkedin: "linkedin"
    case .medium: "medium"
    case .notion: "notion"
    case .paypal: "paypal"
    case .pinterest: "pinterest"
    case .reddit: "reddit"
    case .signal: "signal"
    case .skype: "skype"
    case .snapchat: "snapchat"
    case .telegram: "telegram"
    case .tikTok: "tikTok"
    case .twitch: "twitch"
    case .twitter: "twitter"
    case .venmo: "venmo"
    case .wechat: "wechat"
    case .whatsApp: "whatsApp"
    case .youTube: "youTube"
    case .viber: "viber"
    case .vk: "vk"
    case .odnoklassniki: "odnoklassniki"
    case .email: "email"
    case .voicer: "voicer"
    case let .unknown(id): id
    }
  }

  public var description: String {
    switch self {
    case .etsy: "Etsy"
    case .facebook: "Facebook"
    case .facebookMessenger: "Facebook Messenger"
    case .github: "Github"
    case .google: "Google"
    case .imo: "Imo"
    case .instagram: "Instagram"
    case .apple: "Apple"
    case .discord: "Discord"
    case .linkedin: "Linkedin"
    case .medium: "Medium"
    case .notion: "Notion"
    case .paypal: "Paypal"
    case .pinterest: "Pinterest"
    case .reddit: "Reddit"
    case .signal: "Signal"
    case .skype: "Skype"
    case .snapchat: "Snapchat"
    case .telegram: "Telegram"
    case .tikTok: "TikTok"
    case .twitch: "Twitch"
    case .twitter: "Twitter"
    case .venmo: "Venmo"
    case .wechat: "WeChat"
    case .whatsApp: "WhatsApp"
    case .youTube: "YouTube"
    case .viber: "Viber"
    case .vk: "Vk"
    case .odnoklassniki: "Odnoklassniki"
    case .email: "Email"
    case .voicer: "Voicer"
    case let .unknown(id): id
    }
  }

  public init(rawValue: String) {
    self =
      Self.allCases.sorted(by: {
        Self.levenshteinDistanceScore(from: $0.rawValue, to: rawValue)
          > Self.levenshteinDistanceScore(from: $1.rawValue, to: rawValue)
      }).first ?? .unknown(rawValue)
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let typeStr = try container.decode(String.self)
    self = SocialIcons(
      rawValue: typeStr
    ) /* .allCases.first(where: { $0.rawValue.contains(typeStr, caseSensitive: true) }) */
    // , ChatClientError.failedToLoadAppSettings(url: typeStr))
  }

  public static func == (lhs: SocialIcons, rhs: SocialIcons) -> Bool {
    lhs.rawValue == rhs.rawValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }

  public var image: Image? {
    Image(description)
  }

  static func levenshteinDistanceScore(
    from: String,
    to string: String,
    caseSensitive: Bool = false,
    trimWhiteSpacesAndNewLines: Bool = true
  ) -> Double {
    var firstString = from
    var secondString = string

    if !caseSensitive {
      firstString = firstString.lowercased()
      secondString = secondString.lowercased()
    }
    if trimWhiteSpacesAndNewLines {
      firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
      secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    let empty = [Int](repeating: 0, count: secondString.count)
    var last = [Int](0...secondString.count)

    for (i, tLett) in firstString.enumerated() {
      var cur = [i + 1] + empty
      for (j, sLett) in secondString.enumerated() {
        cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
      }
      last = cur
    }

    // maximum string length between the two
    let lowestScore = max(firstString.count, secondString.count)

    if let validDistance = last.last {
      return 1 - (Double(validDistance) / Double(lowestScore))
    }

    return 0.0
  }
}

struct Ve: View {
  var body: some View {
    ZStack {
      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)

      Path { path in
        path.move(to: CGPoint(x: 7, y: 14))
        path.addLine(to: CGPoint(x: 5, y: 14))
        path.addLine(to: CGPoint(x: 5, y: 19))
        path.addLine(to: CGPoint(x: 10, y: 19))
        path.addLine(to: CGPoint(x: 10, y: 17))
        path.addLine(to: CGPoint(x: 7, y: 17))
        path.addLine(to: CGPoint(x: 7, y: 14))

        path.move(to: CGPoint(x: 5, y: 10))
        path.addLine(to: CGPoint(x: 7, y: 10))
        path.addLine(to: CGPoint(x: 7, y: 7))
        path.addLine(to: CGPoint(x: 10, y: 7))
        path.addLine(to: CGPoint(x: 10, y: 5))
        path.addLine(to: CGPoint(x: 5, y: 5))
        path.addLine(to: CGPoint(x: 5, y: 10))

        path.move(to: CGPoint(x: 14, y: 16))
        path.addLine(to: CGPoint(x: 14, y: 18))
        path.addLine(to: CGPoint(x: 19, y: 18))
        path.addLine(to: CGPoint(x: 19, y: 13))
        path.addLine(to: CGPoint(x: 17, y: 13))
        path.addLine(to: CGPoint(x: 17, y: 16))
        path.addLine(to: CGPoint(x: 14, y: 16))

        path.move(to: CGPoint(x: 14, y: 5))
        path.addLine(to: CGPoint(x: 14, y: 7))
        path.addLine(to: CGPoint(x: 17, y: 7))
        path.addLine(to: CGPoint(x: 17, y: 10))
        path.addLine(to: CGPoint(x: 19, y: 10))
        path.addLine(to: CGPoint(x: 19, y: 5))
        path.addLine(to: CGPoint(x: 14, y: 5))
      }
      .fill(Color.white)
    }
    .frame(width: 24, height: 24)
  }
}

// MARK: - Ue

struct Ue: View {
  var body: some View {
    ZStack {
      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)

      Path { path in
        path.move(to: CGPoint(x: 5, y: 16))
        path.addLine(to: CGPoint(x: 8, y: 16))
        path.addLine(to: CGPoint(x: 8, y: 19))
        path.addLine(to: CGPoint(x: 10, y: 19))
        path.addLine(to: CGPoint(x: 10, y: 14))
        path.addLine(to: CGPoint(x: 5, y: 14))
        path.addLine(to: CGPoint(x: 5, y: 16))

        path.move(to: CGPoint(x: 8, y: 8))
        path.addLine(to: CGPoint(x: 5, y: 8))
        path.addLine(to: CGPoint(x: 5, y: 10))
        path.addLine(to: CGPoint(x: 10, y: 10))
        path.addLine(to: CGPoint(x: 10, y: 5))
        path.addLine(to: CGPoint(x: 8, y: 5))
        path.addLine(to: CGPoint(x: 8, y: 8))

        path.move(to: CGPoint(x: 14, y: 19))
        path.addLine(to: CGPoint(x: 16, y: 19))
        path.addLine(to: CGPoint(x: 16, y: 16))
        path.addLine(to: CGPoint(x: 19, y: 16))
        path.addLine(to: CGPoint(x: 19, y: 14))
        path.addLine(to: CGPoint(x: 14, y: 14))
        path.addLine(to: CGPoint(x: 14, y: 19))

        path.move(to: CGPoint(x: 18, y: 5))
        path.addLine(to: CGPoint(x: 18, y: 8))
        path.addLine(to: CGPoint(x: 16, y: 8))
        path.addLine(to: CGPoint(x: 16, y: 10))
        path.addLine(to: CGPoint(x: 21, y: 10))
        path.addLine(to: CGPoint(x: 21, y: 5))
        path.addLine(to: CGPoint(x: 18, y: 5))
      }
      .fill(Color.white)
    }
    .frame(width: 24, height: 24)
  }
}

struct Se: View {
  var body: some View {
    ZStack {
      Path { path in
        path.move(to: CGPoint(x: 19, y: 9))
        path.addLine(to: CGPoint(x: 15, y: 9))
        path.addLine(to: CGPoint(x: 15, y: 3))
        path.addLine(to: CGPoint(x: 9, y: 3))
        path.addLine(to: CGPoint(x: 9, y: 9))
        path.addLine(to: CGPoint(x: 5, y: 9))
        path.addLine(to: CGPoint(x: 12, y: 16))
        path.addLine(to: CGPoint(x: 19, y: 9))

        path.move(to: CGPoint(x: 5, y: 18))
        path.addLine(to: CGPoint(x: 5, y: 20))
        path.addLine(to: CGPoint(x: 19, y: 20))
        path.addLine(to: CGPoint(x: 19, y: 18))
        path.addLine(to: CGPoint(x: 5, y: 18))
      }
      .fill(Color.white)

      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)
    }
    .frame(width: 24, height: 24)
  }
}

struct qe: View {
  var body: some View {
    ZStack {
      Path { path in
        path.move(to: CGPoint(x: 19, y: 6.41))
        path.addLine(to: CGPoint(x: 17.59, y: 5))
        path.addLine(to: CGPoint(x: 12, y: 10.59))
        path.addLine(to: CGPoint(x: 6.41, y: 5))
        path.addLine(to: CGPoint(x: 5, y: 6.41))
        path.addLine(to: CGPoint(x: 10.59, y: 12))
        path.addLine(to: CGPoint(x: 5, y: 17.59))
        path.addLine(to: CGPoint(x: 6.41, y: 19))
        path.addLine(to: CGPoint(x: 12, y: 13.41))
        path.addLine(to: CGPoint(x: 17.59, y: 19))
        path.addLine(to: CGPoint(x: 19, y: 17.59))
        path.addLine(to: CGPoint(x: 13.41, y: 12))
        path.addLine(to: CGPoint(x: 19, y: 6.41))
      }
      .fill(Color.white)

      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)
    }
    .frame(width: 24, height: 24)
  }
}

struct Ye: View {
  var body: some View {
    ZStack {
      Path { path in
        path.move(to: CGPoint(x: 6, y: 2))
        path.addLine(to: CGPoint(x: 6, y: 8))
        path.addLine(to: CGPoint(x: 6.01, y: 8.01))
        path.addLine(to: CGPoint(x: 10, y: 12))
        path.addLine(to: CGPoint(x: 6, y: 16))
        path.addLine(to: CGPoint(x: 6.01, y: 16.01))
        path.addLine(to: CGPoint(x: 6, y: 22))
        path.addLine(to: CGPoint(x: 18, y: 22))
        path.addLine(to: CGPoint(x: 18, y: 16.01))
        path.addLine(to: CGPoint(x: 18.01, y: 16))
        path.addLine(to: CGPoint(x: 14, y: 12))
        path.addLine(to: CGPoint(x: 18, y: 8.01))
        path.addLine(to: CGPoint(x: 18.01, y: 8))
        path.addLine(to: CGPoint(x: 18, y: 2))
        path.addLine(to: CGPoint(x: 6, y: 2))

        path.move(to: CGPoint(x: 16, y: 14.5))
        path.addLine(to: CGPoint(x: 16, y: 20))
        path.addLine(to: CGPoint(x: 8, y: 20))
        path.addLine(to: CGPoint(x: 8, y: 16.5))
        path.addLine(to: CGPoint(x: 12, y: 12.5))
        path.addLine(to: CGPoint(x: 16, y: 16.5))

        path.move(to: CGPoint(x: 12, y: 9.5))
        path.addLine(to: CGPoint(x: 8, y: 5.5))
        path.addLine(to: CGPoint(x: 8, y: 4))
        path.addLine(to: CGPoint(x: 16, y: 4))
        path.addLine(to: CGPoint(x: 16, y: 7.5))
        path.addLine(to: CGPoint(x: 12, y: 9.5))
      }
      .fill(Color.white)

      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)
    }
    .frame(width: 48, height: 48)
  }
}

struct Ge: View {
  var body: some View {
    ZStack {
      Path { path in
        path.addRect(CGRect(x: 0, y: 0, width: 24, height: 24))
      }
      .fill(Color.clear)

      Path { path in
        path.move(to: CGPoint(x: 7.47, y: 21.49))
        path.addCurve(
          to: CGPoint(x: 1.86, y: 13),
          control1: CGPoint(x: 4.2, y: 19.93),
          control2: CGPoint(x: 1.86, y: 16.76)
        )
        path.addLine(to: CGPoint(x: 0, y: 13))
        path.addCurve(
          to: CGPoint(x: 11.95, y: 24),
          control1: CGPoint(x: 5.66, y: 13),
          control2: CGPoint(x: 11.95, y: 24)
        )
        path.addLine(to: CGPoint(x: 12.61, y: 23.97))
        path.addLine(to: CGPoint(x: 8.8, y: 20.15))
        path.addLine(to: CGPoint(x: 7.47, y: 21.49))

        path.move(to: CGPoint(x: 12.05, y: 0))
        path.addLine(to: CGPoint(x: 11.39, y: 0.04))
        path.addLine(to: CGPoint(x: 15.2, y: 3.85))
        path.addLine(to: CGPoint(x: 16.53, y: 2.52))
        path.addCurve(
          to: CGPoint(x: 22.5, y: 11),
          control1: CGPoint(x: 19.8, y: 4.07),
          control2: CGPoint(x: 22.14, y: 7.24)
        )
        path.addLine(to: CGPoint(x: 24, y: 11))
        path.addCurve(
          to: CGPoint(x: 11.95, y: 0),
          control1: CGPoint(x: 18.34, y: 11),
          control2: CGPoint(x: 11.95, y: 0)
        )

        path.move(to: CGPoint(x: 16, y: 14))
        path.addLine(to: CGPoint(x: 18, y: 14))
        path.addLine(to: CGPoint(x: 18, y: 8))
        path.addCurve(to: CGPoint(x: 16, y: 6), control1: CGPoint(x: 18, y: 6.9), control2: CGPoint(x: 17.11, y: 6))
        path.addLine(to: CGPoint(x: 10, y: 6))
        path.addLine(to: CGPoint(x: 10, y: 8))
        path.addLine(to: CGPoint(x: 16, y: 8))
        path.addLine(to: CGPoint(x: 16, y: 14))

        path.move(to: CGPoint(x: 8, y: 16))
        path.addLine(to: CGPoint(x: 8, y: 4))
        path.addLine(to: CGPoint(x: 6, y: 4))
        path.addLine(to: CGPoint(x: 6, y: 6))
        path.addLine(to: CGPoint(x: 4, y: 6))
        path.addLine(to: CGPoint(x: 4, y: 8))
        path.addLine(to: CGPoint(x: 6, y: 8))
        path.addLine(to: CGPoint(x: 6, y: 16))
        path.addCurve(to: CGPoint(x: 8, y: 18), control1: CGPoint(x: 6.9, y: 18), control2: CGPoint(x: 8, y: 17.11))
        path.addLine(to: CGPoint(x: 16, y: 18))
        path.addLine(to: CGPoint(x: 16, y: 20))
        path.addLine(to: CGPoint(x: 18, y: 20))
        path.addLine(to: CGPoint(x: 18, y: 18))
        path.addLine(to: CGPoint(x: 20, y: 18))
        path.addLine(to: CGPoint(x: 20, y: 16))
        path.addLine(to: CGPoint(x: 8, y: 16))
      }
      .fill(Color.white)
    }
    .frame(width: 24, height: 24)
  }
}

#Preview {
  VStack {
    qe()
    Ye()
    Ge()
    Se()
    Ve()
    Ue()
  }
}
