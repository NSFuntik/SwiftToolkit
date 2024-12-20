import Photos
import PhotosUI
import SwiftUI

#if canImport(UIKit)
import Core
import UIKit
import Foundation
import UniformTypeIdentifiers

public struct PhotoPicker<Label>: View where Label: View {
  @State private var isPresented = false
  @Binding var selection: [PHPickerResult]

  let filter: PHPickerFilter?
  let maxSelection: Int?
  let preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode
  let library: PHPhotoLibrary
  let label: Label
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - maxSelection: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - library: The photo library to choose from. The selection behavior of the Photos picker. Default is `.default`.
  ///    - preferredAssetRepresentationMode:  The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  public init(
    selection: Binding<[PHPickerResult]>,
    filter: PHPickerFilter?,
    maxSelection: Int?,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode,
    library: PHPhotoLibrary,
    label: Label
  ) {
    self._selection = selection
    self.filter = filter
    self.maxSelection = maxSelection
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = library
    self.label = label
  }

  public var body: some View {
    Button {
      self.isPresented = true
    } label: {
      self.label
    }
    ._photoPicker(
      isPresented: self.$isPresented,
      selection: self.$selection,
      filter: self.filter,
      maxSelectionCount: self.maxSelection,
      preferredAssetRepresentationMode: self.preferredAssetRepresentationMode,
      library: self.library
    )
  }
}

extension PhotoPicker {
  /// Creates a Photos picker that selects a `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - label: The view that describes the action of choosing an item from the photo library.
  public init(
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    @ViewBuilder label: () -> Label
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = label()
  }
}

extension PhotoPicker {
  /// Creates a Photos picker that selects a `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  ///    - label: The view that describes the action of choosing an item from the photo library.
  public init(
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary,
    @ViewBuilder label: () -> Label
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = label()
  }
}

extension PhotoPicker<Text> {
  /// Creates a Photos picker with its label generated from a localized string key that selects a `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - titleKey: A localized string key that describes the purpose of showing the picker.
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = Text(titleKey)
  }

  /// Creates a Photos picker with its label generated from a string that selects a `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - title: A string that describes the purpose of showing the picker.
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  public init(
    _ title: some StringProtocol,
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = Text(title)
  }

  /// Creates a Photos picker with its label generated from a localized string key that selects a `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - titleKey: A localized string key that describes the purpose of showing the picker.
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = Text(titleKey)
  }

  /// Creates a Photos picker with its label generated from a string that selects a `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - title: A string that describes the purpose of showing the picker.
  ///    - selection: The item being shown and selected in the Photos picker.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of the selected item. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  public init(
    _ title: some StringProtocol,
    selection: Binding<PHPickerResult?>,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary
  ) {
    _selection = .init(
      get: {
        [selection.wrappedValue].compactMap { $0 }
      },
      set: { newValue in
        selection.wrappedValue = newValue.first
      }
    )
    self.filter = filter
    self.maxSelection = 1
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = Text(title)
  }
}

extension PhotoPicker {
  /// Creates a Photos picker that selects a collection of `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - label: The view that describes the action of choosing items from the photo library.
  public init(
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    @ViewBuilder label: () -> Label
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = label()
  }

  /// Creates a Photos picker that selects a collection of `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  ///    - label: The view that describes the action of choosing items from the photo library.
  public init(
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary,
    @ViewBuilder label: () -> Label
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = label()
  }
}

extension PhotoPicker<Text> {
  /// Creates a Photos picker with its label generated from a localized string key that selects a collection of `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - titleKey: A localized string key that describes the purpose of showing the picker.
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount
    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = Text(titleKey)
  }

  /// Creates a Photos picker with its label generated from a string that selects a collection of `PHPickerResult`.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - title: A string that describes the purpose of showing the picker.
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  public init(
    _ title: some StringProtocol,
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount

    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = .shared()
    self.label = Text(title)
  }

  /// Creates a Photos picker with its label generated from a localized string key that selects a collection of `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - titleKey: A localized string key that describes the purpose of showing the picker.
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount

    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = Text(titleKey)
  }

  /// Creates a Photos picker with its label generated from a string that selects a collection of `PHPickerResult` from a given photo library.
  ///
  /// The user explicitly grants access only to items they choose, so photo library access authorization is not needed.
  ///
  /// - Parameters:
  ///    - title: A string that describes the purpose of showing the picker.
  ///    - selection: All items being shown and selected in the Photos picker.
  ///    - maxSelectionCount: The maximum number of items that can be selected. Default is `nil`. Setting it to `nil` means maximum supported by the system.
  ///    - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
  ///    - preferredAssetRepresentationMode: The encoding disambiguation policy of selected items. Default is `.automatic`. Setting it to `.automatic` means the best encoding determined by the system will be used.
  ///    - photoLibrary: The photo library to choose from.
  public init(
    _ title: some StringProtocol,
    selection: Binding<[PHPickerResult]>,
    maxSelectionCount: Int? = nil,
    matching filter: PHPickerFilter? = nil,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    photoLibrary: PHPhotoLibrary
  ) {
    _selection = selection
    self.filter = filter
    self.maxSelection = maxSelectionCount

    self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    self.library = photoLibrary
    self.label = Text(title)
  }
}

extension PHPickerResult {
  public func loadTransfer<T>(_type: T.Type) async throws -> T? {
    do {
      let data = try await itemProvider.loadData()

      switch _type {
      case is UIImage.Type:
        guard let image = UIImage(data: data) else { throw PhotoError<T>() }
        return image as? T

      case is Data.Type:
        return data as? T

      default:
        throw PhotoError<T>()
      }
    } catch {
      throw PhotoError<T>()
    }
  }

  public func loadTransfer<T>(_type: T.Type, completion: @escaping (Result<T?, Error>) -> Void) {
    Task {
      let data = try? await itemProvider.loadData()
      switch _type {
      case is UIImage.Type:
        if let data,
          let image = UIImage(data: data)
        {
          completion(.success(image as? T))
        } else {
          completion(.failure(PhotoError<T>()))
        }

      case is Data.Type:
        completion(.success(data as? T))

      default:
        completion(.failure(PhotoError<T>()))
      }
    }
  }

  private struct PhotoError<T>: LocalizedError {
    var errorDescription: String? {
      "Could not load photo as \(T.self)"
    }
  }
}

extension NSItemProvider {
  public func loadData() async throws -> Data {
    let supportedRepresentations = [
      UTType.rawImage.identifier,
      UTType.webP.identifier,
      UTType.gif.identifier,
      UTType.tiff.identifier,
      UTType.bmp.identifier,
      UTType.heif.identifier,
      UTType.heic.identifier,
      UTType.livePhoto.identifier,
      UTType.jpeg.identifier,
      UTType.png.identifier,
      UTType.rawImage.identifier,
      UTType.svg.identifier,
      UTType.movie.identifier,
      UTType.video.identifier,
      UTType.quickTimeMovie.identifier,
      UTType.mpeg.identifier,
      UTType.mpeg2Video.identifier,
      UTType.mpeg4Movie.identifier,
      UTType.appleProtectedMPEG4Video.identifier,
      UTType.avi.identifier,
    ]

    for representation in supportedRepresentations {
      if self.hasItemConformingToTypeIdentifier(representation) {
        return try await self.loadDataRepresentation(forTypeIdentifier: representation)
      }
    }

    return try await self.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier)
  }

  public func loadDataRepresentation(forTypeIdentifier typeIdentifier: String) async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
      self.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, error in
        if let error {
          return continuation.resume(throwing: error)
        }

        guard let data else {
          return continuation.resume(throwing: NSError())
        }

        continuation.resume(returning: data)
      }.resume()
    }
  }
}

#endif
