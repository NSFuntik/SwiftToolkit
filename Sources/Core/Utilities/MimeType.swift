//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
//

import Foundation
import UniformTypeIdentifiers

// MARK: - MIMEType

// public func MimeType(ext: String?) throws -> String {
//    if let ext = ext?.lowercased(),
//       let mimeType = try? MIMEType.type(for: ext) {
//        return mimeType.id
//    } else {
//        return "image/jpeg"
//    }
// }

/// This enum represents a set of different MIME and file types.
///
/// Note that some types may be expected to be a different type,
/// but are instead an `.application` type. For instance, `json`
/// is a text format, but the mime type is `application/json`.
public enum MIMEType: Identifiable, CaseIterable, RawRepresentable {
  case
    application(Application)
  case audio(Audio)
  case image(Image)
  case text(Text)
  case video(Video)

  // // Nested Types

  public typealias RawValue = String

  public enum Application: String, CaseIterable, Identifiable {
    case
      ai, atom, bin, crt, cco, deb, der, dll, dmg, doc,
      docx, ear, eot, eps, exe, hqx, img, iso, jar,
      jardiff, jnlp, js, json, kml, kmz, m3u8, msi, msm,
      msp, pdb, pdf, pem, pl, pm, ppt, pptx, prc, ps,
      rar, rpm, rss, rtf, run, sea, sit, swf, war, tcl,
      wmlc, woff, x7z, xhtml, xls, xlsx, xpi, xspf, zip

    // // Computed Properties

    public var id: String {
      switch self {
      case .ear,
           .jar,
           .war: "java-archive"
      case .bin,
           .deb,
           .dll,
           .dmg,
           .exe,
           .img,
           .iso,
           .msi,
           .msm,
           .msp: "octet-stream"
      case .pl,
           .pm: "x-perl"
      case .pdb,
           .prc: "x-pilot"
      case .crt,
           .der,
           .pem: "x-x509-ca-cert"
      case .ai: "postscript"
      case .atom: "atom+xml"
      case .cco: "x-cocoa"
      case .doc: "msword"
      case .docx: "vnd.openxmlformats-officedocument.wordprocessingml.document"
      case .eot: "vnd.ms-fontobject"
      case .eps: "postscript"
      case .hqx: "mac-binhex40"
      case .jardiff: "x-java-archive-diff"
      case .jnlp: "x-java-jnlp-file"
      case .js: "javascript"
      case .json: "json"
      case .kml: "vnd.google-earth.kml+xml"
      case .kmz: "vnd.google-earth.kmz"
      case .m3u8: "vnd.apple.mpegurl"
      case .pdf: "pdf"
      case .ppt: "vnd.ms-powerpoint"
      case .pptx: "vnd.openxmlformats-officedocument.presentationml.presentation"
      case .ps: "postscript"
      case .rar: "x-rar-compressed"
      case .rpm: "x-redhat-package-manager"
      case .rss: "rss+xml"
      case .rtf: "rtf"
      case .run: "x-makeself"
      case .sea: "x-sea"
      case .sit: "x-stuffit"
      case .swf: "x-shockwave-flash"
      case .tcl: "x-tcl"
      case .woff: "font-woff"
      case .wmlc: "vnd.wap.wmlc"
      case .x7z: "x-7z-compressed"
      case .xhtml: "xhtml+xml"
      case .xls: "vnd.ms-excel"
      case .xlsx: "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      case .xpi: "x-xpinstall"
      case .xspf: "xspf+xml"
      case .zip: "zip"
      }
    }
  }

  public enum Audio: String, CaseIterable, Identifiable {
    case kar, m4a, midi, mp3, ogg, ra, wav

    // // Computed Properties

    public var id: String {
      switch self {
      case .midi,
           .ogg: rawValue
      case .kar: "midi"
      case .m4a: "x-m4a"
      case .mp3: "mpeg"
      case .ra: "x-realaudio"
      case .wav: "wav"
      }
    }
  }

  public enum Image: String, CaseIterable, Identifiable {
    case bmp, gif, ico, jpeg, jng, png, svg, tiff, wbmp, webp

    // // Computed Properties

    public var id: String {
      switch self {
      case .gif,
           .jpeg,
           .png,
           .tiff,
           .webp: rawValue
      case .bmp: "x-ms-bmp"
      case .ico: "x-icon"
      case .jng: "x-jng"
      case .svg: "svg+xml"
      case .wbmp: "vnd.wap.wbmp"
      }
    }
  }

  public enum Text: String, CaseIterable, Identifiable {
    case plain, css, csv, htc, html, jad, mathml, xml, wml

    // // Computed Properties

    public var id: String {
      switch self {
      case .css,
           .csv,
           .html,
           .mathml,
           .plain,
           .xml: rawValue
      case .jad: "vnd.sun.j2me.app-descriptor"
      case .wml: "vnd.wap.wml"
      case .htc: "x-component"
      }
    }
  }

  public enum Video: String, CaseIterable, Identifiable {
    case asf, asx, avi, flv, m4v, mng, mp4, mpeg, mov, ts, video3gpp, webm, wmv

    // // Computed Properties

    public var id: String {
      switch self {
      case .mp4,
           .mpeg: rawValue
      case .asf: "x-ms-asf"
      case .asx: "x-ms-asf"
      case .avi: "x-msvideo"
      case .flv: "x-flv"
      case .m4v: "x-m4v"
      case .mng: "x-mng"
      case .mov: "quicktime"
      case .ts: "mp2t"
      case .video3gpp: "3gpp"
      case .webm: "webm"
      case .wmv: "x-ms-wmv"
      }
    }
  }

  public enum Archive: String, CaseIterable, Identifiable {
    case gzip, zip

    // // Computed Properties

    public var id: String {
      switch self {
      case .gzip: "x-gzip"
      case .zip: "zip"
      }
    }
  }

  // // Static Properties

  public static var allCases: [MIMEType] = Application.allCases.compactMap {
    MIMEType.application($0)
  }
  .appending(contentsOf: Audio.allCases.compactMap {
    MIMEType.audio($0)
  })
  .appending(contentsOf: Image.allCases.compactMap {
    MIMEType.image($0)
  })
  .appending(contentsOf: Text.allCases.compactMap {
    MIMEType.text($0)
  })
  .appending(contentsOf: Video.allCases.compactMap {
    MIMEType.video($0)
  })

  // // Computed Properties

  public var rawValue: String {
    switch self {
    case let .audio(type): type.rawValue
    case let .application(type): type.rawValue
    case let .image(type): type.rawValue
    case let .text(type): type.rawValue
    case let .video(type): type.rawValue
    }
  }

  public var id: String {
    switch self {
    case let .audio(type): "audio/\(type.id)"
    case let .application(type): "application/\(type.id)"
    case let .image(type): "image/\(type.id)"
    case let .text(type): "text/\(type.id)"
    case let .video(type): "video/\(type.id)"
    }
  }

  // // Lifecycle

  public init?(rawValue: String) {
    guard let this = (try? MIMEType.from(pathExtension: rawValue)) else { return nil }
    self = this
  }

  // // Static Functions

  public static func from(pathExtension: String) throws -> MIMEType {
    let pathExtension = pathExtension.lowercased()
    let type = MIMEType.allCases.first(where: { $0.rawValue == pathExtension || $0.id == pathExtension })

    return try unwrapOrThrow(type, TypeError.invalidMimeType(type: pathExtension))
  }
}

// MARK: - TypeError

enum TypeError: Error, ErrorAlertConvertible {
  case invalidMimeType(type: String)

  // // Computed Properties

  var errorTitle: String {
    switch self {
    case .invalidMimeType: "Invalid MIME type"
    }
  }

  var errorMessage: String {
    switch self {
    case let .invalidMimeType(type: type): "The provided MIME type: \(type) is invalid."
    }
  }

  var errorButtonText: String {
    "OK"
  }
}
