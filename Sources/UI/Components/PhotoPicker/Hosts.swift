import Photos
import SwiftUI
import PhotosUI
@_exported import MDFoundation
#if canImport(UIKit)
import Core
import UIKit
import CoreServices

/// A struct that represents an asset selected from the photo picker.
///
/// This struct conforms to `Identifiable` and `Hashable`, providing properties such as `id`, `image`, `url`, `name`, and `size`
/// to represent the specifics of the asset.
public struct PHPickerAsset: Identifiable, Hashable {
  public var id: String
  var image: UIImage
  var url: URL
  var name: String
  var size: String
}

/// An extension of `NSItemProvider` providing a method to asynchronously load an object of a specified type.
///
/// This method uses a continuation to resume once the object is loaded or an error occurs.
///
/// - Parameter type: The type of object to load.
/// - Returns: An object of the specified type.
/// - Throws: An error if the loading fails.
public extension NSItemProvider {
  func loadObject<T>(of type: T.Type) async throws -> T where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
    try await withCheckedThrowingContinuation { continuation in
      _ = loadObject(ofClass: T.self) { (value: _ObjectiveCBridgeable?, error: Error?) in
        switch (value, error) {
        case let (.some(value as T), nil):
          continuation.resume(returning: value)
        case let (_, .some(error)):
          continuation.resume(throwing: error)
          return
        default:
          return
        }
      }
    }
  }
}

/// An extension of `NSData` to conform to `NSItemProviderReading`.
///
/// This extension provides a readable type identifier and a method to create an object from item provider data.
extension NSData: NSItemProviderReading {
  public static var readableTypeIdentifiersForItemProvider: [String] { [String(UTType.data.identifier)] }
  public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
    try unwrapOrThrow(NSData(data: data) as? Self, CompressionError.initError)
  }
}

/// An extension of `PHPickerResult` that adds `Identifiable` conformance.
///
/// This extension provides an identifier based on the hash value and methods to retrieve images and file attributes associated with the picker result.
extension PHPickerResult: Identifiable {
  public var id: Int {
    hashValue
  }
  
  /// Asynchronously retrieves the image representation of the `PHPickerResult`.
  ///
  /// This method attempts to load the corresponding data, decompresses it, and creates a `UIImage` instance.
  /// If the decompression or image creation fails, it throws an appropriate error.
  ///
  /// - Returns: A `UIImage` representation of the picker result.
  /// - Throws: An error if the image loading or compression fails.
  public func image() async throws -> UIImage {
    if let data = try await loadTransfer(_type: Data.self),
       let imageFull = UIImage(data: data) {
      do {
        let compressedData = try data.compress()
        guard let uiImage = UIImage(data: compressedData)
        else { throw CompressionError.initError }
        debugPrint("Compressed \(imageFull.getSizeString(in: .byte)) to \(uiImage.getSizeString(in: .byte)) bytes")
        return uiImage
      } catch {
        debugPrint("Failed to compress image  error: \(error).")
        throw CompressionError.processError
      }
    } else {
      throw CompressionError.initError
    }
  }
  
  /// Asynchronously retrieves the file attributes associated with the picker result.
  ///
  /// This method loads the file representation and returns a tuple containing the suggested name and file size as a string.
  ///
  /// - Returns: A tuple containing the file name and size.
  /// - Throws: An error if loading the file representation fails.
  public func fileAttributes() async throws -> (String, String) {
    var fileAttributes = ("", "")
    fileAttributes = try await withCheckedThrowingContinuation { continuation in
      self.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.item") { url, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          if let url = url {
            continuation.resume(returning: (itemProvider.suggestedName ?? url.lastPathComponent, url.fileSizeString ?? ""))
          } else {
            continuation.resume(returning: (itemProvider.suggestedName ?? "", ""))
          }
        }
      }
    }
    return fileAttributes
  }
}

/// A view extension that presents a photo picker interface.
///
/// This `_photoPicker` function displays a modal sheet for selecting photos from the user's photo library.
/// It utilizes a `PHPicker` to allow the user to pick multiple photos while respecting various settings like
/// filtering, maximum selection count, and asset representation mode.
///
/// - Parameters:
///   - isPresented: A binding to a Boolean value that determines whether the photo picker is presented.
///   - selection: A binding to an array of `PHPickerResult` representing the selected photos.
///   - filter: An optional filter for specifying the type of media to present in the picker.
///   - maxSelectionCount: An optional integer that specifies the maximum number of items the user can select.
///   - preferredAssetRepresentationMode: The mode that specifies how the assets should be represented.
///   - library: The photo library to be accessed by the photo picker.
public extension View {
  @ViewBuilder
  func _photoPicker(
    isPresented: Binding<Bool>,
    selection: Binding<[PHPickerResult]>,
    filter: PHPickerFilter?,
    maxSelectionCount: Int?,
    preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode,
    library: PHPhotoLibrary) -> some View {
      sheet(isPresented: isPresented) {
        PhotosViewController(
          isPresented: isPresented,
          selection: selection,
          filter: filter,
          maxSelectionCount: maxSelectionCount,
          preferredAssetRepresentationMode: preferredAssetRepresentationMode,
          library: library)
        .ignoresSafeArea()
      }
    }
}

/// A struct that acts as a bridge between SwiftUI and UIKit for presenting the photos picker.
///
/// This struct conforms to `UIViewControllerRepresentable` and manages the presentation of the `PHPickerViewController`
/// as well as the selection of photos.
fileprivate struct PhotosViewController: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  @Binding var selection: [PHPickerResult]
  let configuration: PHPickerConfiguration
  init(isPresented: Binding<Bool>,
       selection: Binding<[PHPickerResult]>,
       filter: PHPickerFilter?,
       maxSelectionCount: Int?,
       preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode,
       library: PHPhotoLibrary) {
    _isPresented = isPresented
    _selection = selection
    var configuration = PHPickerConfiguration(photoLibrary: library)
    configuration.preferredAssetRepresentationMode = preferredAssetRepresentationMode
    configuration.selectionLimit = maxSelectionCount ?? 0
    configuration.filter = filter
    self.configuration = configuration
  }
  
  /// Creates a `Coordinator` instance to manage the interaction between the SwiftUI view and the UIKit view controller.
  func makeCoordinator() -> Coordinator {
    Coordinator(isPresented: $isPresented, selection: $selection, configuration: configuration)
  }
  
  /// Creates and configures the `UIViewController` that represents the photo picker.
  ///
  /// - Parameter context: The contextual information for the view.
  /// - Returns: A configured `UIViewController`.
  func makeUIViewController(context: Context) -> UIViewController {
    context.coordinator.controller
  }
  
  /// Updates the `UIViewController` during lifecycle events to keep it in sync with SwiftUI state.
  ///
  /// - Parameters:
  ///   - controller: The controller to update.
  ///   - context: The contextual information for the view.
  func updateUIViewController(_ controller: UIViewController, context: Context) {
    context.coordinator.isPresented = $isPresented
    context.coordinator.selection = $selection
    context.coordinator.configuration = configuration
  }
}

/// A coordinator that manages delegation for the `PHPickerViewController`.
///
/// This class handles the selection of picked photos and dismissal of the picker.
fileprivate extension PhotosViewController {
  final class Coordinator: NSObject, PHPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    var isPresented: Binding<Bool>
    var selection: Binding<[PHPickerResult]>
    var configuration: PHPickerConfiguration
    lazy var controller: PHPickerViewController = {
      let controller = PHPickerViewController(configuration: configuration)
      controller.presentationController?.delegate = self
      controller.delegate = self
      return controller
    }()
    
    /// Initializes the coordinator with the necessary bindings and configuration.
    init(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, configuration: PHPickerConfiguration) {
      self.isPresented = isPresented
      self.selection = selection
      self.configuration = configuration
      super.init()
    }
    
    /// Handles the selection of results from the photo picker.
    ///
    /// This method is called when the user has finished picking photos, and it updates the selection and dismisses the picker.
    ///
    /// - Parameters:
    ///   - picker: The picker view controller that initiated the event.
    ///   - results: The selected results.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      isPresented.wrappedValue = false
      selection.wrappedValue = results
    }
    
    /// Called when the presentation controller is dismissed.
    ///
    /// This method updates the binding to reflect that the picker has been dismissed.
    ///
    /// - Parameter presentationController: The presentation controller that was dismissed.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
      isPresented.wrappedValue = false
    }
  }
}
#endif
