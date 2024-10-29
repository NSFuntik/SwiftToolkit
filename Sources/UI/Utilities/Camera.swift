//
//  Camera.swift
//
//
//  Created by Dmitry Mikhaylov on 01.03.2024.
//

import os.log
import Photos
import SwiftUI
import Feedback
import CoreImage
import CoreMedia
import AVFoundation
#if canImport(UIKit)
  import UIKit

  extension UIImage: Identifiable {
    public var id: Int {
      return hashValue
    }
  }

  #Preview {
    CameraView(.constant(UIImage(ciImage: .empty())))
  }

  public extension View {
    func cameraSheet(
      isPresented: Binding<Bool>,
      captureResult: Binding<UIImage?>) -> some View {
      fullScreenCover(isPresented: isPresented, content: {
        CameraView(captureResult)
      })
    }
  }

  class CameraUtility {
    /// Checks if the device has a camera available.
    static func isCameraAvailable() async -> Bool {
      guard await UIImagePickerController.isSourceTypeAvailable(.camera) else { return false }
      return await hasCameraPermission()
    }

    /// Checks camera authorization status.
    static func hasCameraPermission() async -> Bool {
      guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized
      else { return await AVCaptureDevice.requestAccess(for: .video) }
      return true
    }
  }

  @frozen
  public struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    private let camera: Camera = .init()
    @State var viewfinderImage: Image? = nil
    @Binding var outputImage: UIImage?
    @State var capturedImage: UIImage? = nil
    @State private var authorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var outputSize: CGSize = .zero

    private let options: CameraViewOptions = .init()
    private let barHeightFactor = 0.15
    public init(_ outputImage: Binding<UIImage?>) {
      _outputImage = outputImage
      UIApplication.shared.keyWindow?.rootViewController?.view.backgroundColor = .clear
    }

    //    @State private var showsTakePictureFeedback: Bool = false

    public var body: some View {
      GeometryReader { geometry in
        ViewfinderView(image: $viewfinderImage)
          .overlay(alignment: .bottom) {
            buttonsView()
              .frame(height: geometry.size.height * self.barHeightFactor)
              .background(.regularMaterial, in: Rectangle())
          }
      }
      .vibrantForeground()
      .environment(\.takePicture, TakePictureAction {
        //            showsTakePictureFeedback = true

        guard let capturedPhoto = try? await camera.takePhoto(),
              let image = UIImage(photo: capturedPhoto)
        else { return }
        capturedImage = image
        if let capturedImage {
          withAnimation {
            viewfinderImage = Image(uiImage: capturedImage)
          }
        }

      })
      .preferredColorScheme(.dark)
      .ignoresSafeArea()
      .statusBar(hidden: true)
      .onAppear(perform: {
        Task { @MainActor in
          guard await !CameraUtility.isCameraAvailable() else { return }
          cameraNotAutorizedAfterAppear = true
        }
      })
      .task {
        await handleCameraPreviews()
      }
      .sheet(isPresented: $cameraNotAutorizedAfterAppear,
             onDismiss: {
               Task { @MainActor in
                 guard await CameraUtility.isCameraAvailable() else { dismiss(); return }
                 cameraNotAutorizedAfterAppear = false
                 await camera.start()
               }
             }, content: {
               cameraUnavailable
             })
      .onChange(of: authorizationStatus) { newValue in
        if newValue == .authorized {
          Task { @MainActor in
            await camera.start()
          }
        }
      }
    }

    @State var cameraNotAutorizedAfterAppear: Bool = false

    @ViewBuilder
    private func buttonsView() -> some View {
      LazyVGrid(columns: .init(repeating: .init(.adaptive(minimum: .screenWidth / 4, maximum: .screenWidth / 2), alignment: .center), count: 3)) {
        Button {
          dismiss()
        } label: {
          Label {
            Text("Close Camera")
          } icon: {
            Image(sf: .xmarkCircle)
              .symbolRenderingMode(.palette)
              .foregroundStyle(Color(.systemRed).opacity(0.66), Color(.secondaryLabel))
          }
          .labelStyle(.cameraControl(tint: .bar, size: 14.88))
        }

        if capturedImage != nil {
          Button {
            withAnimation {
              outputImage = capturedImage
            }
          } label: {
            Label {
              Text("Send Photo")
            } icon: {
              Image(sf: .paperplaneCircleFill)
                .symbolRenderingMode(.multicolor)
                .imageScale(.large)
                .rotationEffect(.degrees(45), anchor: .center)
            }
            .labelStyle(.cameraControl(tint: .selection.opacity(0.44), size: 18))
          }
        } else {
          Button {
            Task { @MainActor in
              do {
                //                            $showsTakePictureFeedback.wrappedValue = true
                let capturePhoto = try await camera.takePhoto()

                withFeedback(
                  .flash(Color.white.opacity(0.88), duration: 0.1488)
                    .combined(with: .haptic(.impact))
                ) {
                  camera.stop()
                }
                let image = UIImage(photo: capturePhoto)
                capturedImage = image?.fixOrientation().scaleToFill(in: outputSize)
              } catch {
                capturedImage = nil
                throw error
              }
            }
          } label: {
            Label {
              Text("Take Photo")
            } icon: {
              Image(sf: .circleInsetFilled)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.secondary, .primary.opacity(0.88))
            }
            .labelStyle(.cameraControl(tint: .background.opacity(0.44), size: 18))
          }
        }

        Button {
          if capturedImage != nil {
            capturedImage = nil
            Task { @MainActor in
              await camera.start()
            }
          } else {
            camera.switchCaptureDevice()
          }
        } label: {
          Label {
            Text("Switch Camera")
          } icon: {
            Image(sf: capturedImage != nil ? .arrowTriangle2CirclepathCamera : .arrowTriangle2CirclepathCircle)
              .symbolRenderingMode(.hierarchical)
              .imageScale(.large)
          }
          .labelStyle(.cameraControl(tint: .bar, size: 14.88))
        }
      }
      .buttonStyle(.plain)
      .padding()
      .animation(.bouncy, value: capturedImage)
    }

    func handleCameraPreviews() async {
      guard await CameraUtility.isCameraAvailable() else {
        debugPrint("Camera is not available.")
        viewfinderImage = Image(sf: .pc)
          .symbolRenderingMode(.multicolor)
          .resizable(resizingMode: .stretch)
          .interpolation(.high)
          .renderingMode(.original)

        return
      }
      await camera.start()

      let imageStream = camera.previewStream
        .map { $0.image }

      for await image in imageStream {
        Task { @MainActor in
          viewfinderImage = image
        }
      }
    }

    struct ViewfinderView: View {
      @Binding var image: Image?
      ///        @Binding var showsTakePictureFeedback: Bool
      var body: some View {
        GeometryReader { geometry in
          if let image = image {
            image
              .resizable()
              .scaledToFill()
              .background(.background, in: Rectangle())
              .frame(width: geometry.size.width, height: geometry.size.height)
          }
        }.background(.clear)
      }
    }

    public struct CameraViewOptions {
      public init(automaticallyRequestAuthorization: Bool = true, isTakePictureFeedbackEnabled: Bool = true) {
        self.automaticallyRequestAuthorization = automaticallyRequestAuthorization
        self.isTakePictureFeedbackEnabled = isTakePictureFeedbackEnabled
      }

      public private(set) static var `default` = CameraViewOptions()
      var automaticallyRequestAuthorization: Bool = true
      var isTakePictureFeedbackEnabled: Bool = true
    }
  }

  extension LabelStyle where Self == CameraContolLabelStyle<Material> {
    static func cameraControl<S: ShapeStyle>(tint: S, size: CGFloat) -> CameraContolLabelStyle<S> { CameraContolLabelStyle(tint: tint, size: size)
    }
  }

  struct CameraContolLabelStyle<S>: LabelStyle where S: ShapeStyle {
    var tint: S
    var size: CGFloat
    @ScaledMetric(relativeTo: .title) private var iconWidth = 3.14
    init(tint: S, size: CGFloat) where S: ShapeStyle {
      self.tint = tint
      self.size = size
    }

    func makeBody(configuration: Configuration) -> some View where S: ShapeStyle {
      Label {
        configuration.title.hidden()
      } icon: {
        configuration.icon
          .font(Font(CTFont(.controlContent, size: size * iconWidth)))
          .aspectRatio(contentMode: .fill)
          .imageScale(.large)
          .foregroundStyle(.foreground)
          .vibrantForeground(thick: true)
          .background(tint, in: Circle())
          .shadow(color: Color(.secondarySystemFill), radius: 4)
      }
      .labelStyle(IconOnlyLabelStyle())
    }
  }

  extension Label where Title == Text, Icon == Image {
    func controlButton(with size: Font) -> some View {
      self
    }
  }

  //// Example dimensions assuming a square video frame for simplicity
  // let pixels = 5000000 // Total pixels from calculation
  // let dimension = Int32(sqrt(Double(pixels))) // Calculate dimension for a square
//
  ////let videoDimensions = CMVideoFormatDescriptionGetDimensions(.)(width: dimension, height: dimension)

  public class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!
    private var didTakePicture: ((Result<AVCapturePhoto, Error>) -> Void)?

    private var allCaptureDevices: [AVCaptureDevice] {
      AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
    }

    private var frontCaptureDevices: [AVCaptureDevice] {
      allCaptureDevices
        .filter { $0.position == .front }
    }

    private var backCaptureDevices: [AVCaptureDevice] {
      allCaptureDevices
        .filter { $0.position == .back }
    }

    private var captureDevices: [AVCaptureDevice] {
      var devices = [AVCaptureDevice]()
      #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
      #else
        if let backDevice = backCaptureDevices.first {
          devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
          devices += [frontDevice]
        }
      #endif
      return devices
    }

    private var availableCaptureDevices: [AVCaptureDevice] {
      captureDevices
        .filter { $0.isConnected }
        .filter { !$0.isSuspended }
    }

    private var captureDevice: AVCaptureDevice? {
      didSet {
        guard let captureDevice = captureDevice else { return }
        logger.debug("Using capture device: \(captureDevice.localizedName)")
        sessionQueue.async {
          self.updateSessionForCaptureDevice(captureDevice)
        }
      }
    }

    var isRunning: Bool {
      captureSession.isRunning
    }

    var isUsingFrontCaptureDevice: Bool {
      guard let captureDevice = captureDevice else { return false }
      return frontCaptureDevices.contains(captureDevice)
    }

    var isUsingBackCaptureDevice: Bool {
      guard let captureDevice = captureDevice else { return false }
      return backCaptureDevices.contains(captureDevice)
    }

    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?

    private var addToPreviewStream: ((CIImage) -> Void)?

    var isPreviewPaused = false

    lazy var previewStream: AsyncStream<CIImage> = AsyncStream { continuation in
      addToPreviewStream = { ciImage in
        if !self.isPreviewPaused {
          continuation.yield(ciImage)
        }
      }
    }

    lazy var photoStream: AsyncStream<AVCapturePhoto> = AsyncStream { continuation in
      addToPhotoStream = { photo in
        continuation.yield(photo)
      }
    }

    @usableFromInline override init() {
      super.init()
      initialize()
    }

    private func initialize() {
      sessionQueue = DispatchQueue(label: "session queue")

      captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)

      UIDevice.current.beginGeneratingDeviceOrientationNotifications()
      NotificationCenter.default.addObserver(self, selector: #selector(updateForDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
      var success = false

      self.captureSession.beginConfiguration()

      defer {
        self.captureSession.commitConfiguration()
        completionHandler(success)
      }

      guard
        let captureDevice = captureDevice,
        let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
      else {
        logger.error("Failed to obtain video input.")
        return
      }

      let photoOutput = AVCapturePhotoOutput()

      captureSession.sessionPreset = AVCaptureSession.Preset.photo

      let videoOutput = AVCaptureVideoDataOutput()
      videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))

      guard captureSession.canAddInput(deviceInput) else {
        logger.error("Unable to add device input to capture session.")
        return
      }
      guard captureSession.canAddOutput(photoOutput) else {
        logger.error("Unable to add photo output to capture session.")
        return
      }
      guard captureSession.canAddOutput(videoOutput) else {
        logger.error("Unable to add video output to capture session.")
        return
      }

      captureSession.addInput(deviceInput)
      captureSession.addOutput(photoOutput)
      captureSession.addOutput(videoOutput)

      self.deviceInput = deviceInput
      self.photoOutput = photoOutput
      self.videoOutput = videoOutput
      photoOutput.maxPhotoQualityPrioritization = .speed
      photoOutput.isHighResolutionCaptureEnabled = false

      if #available(macOS 10.15, iOS 16.0, tvOS 16.0, *) {
        if let dimention = deviceInput.device.activeFormat.supportedMaxPhotoDimensions.sorted(by: { ($0.width * $0.height) < ($1.width * $1.height) }).first {
          photoOutput.maxPhotoDimensions = dimention
        }
      }

      updateVideoOutputConnection()

      isCaptureSessionConfigured = true

      success = true
    }

    private func checkAuthorization() async -> Bool {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized:
        logger.debug("Camera access authorized.")
        return true
      case .notDetermined:
        logger.debug("Camera access not determined.")
        sessionQueue.suspend()
        let status = await AVCaptureDevice.requestAccess(for: .video)
        sessionQueue.resume()
        return status
      case .denied:
        logger.debug("Camera access denied.")
        return false
      case .restricted:
        logger.debug("Camera library access restricted.")
        return false
      @unknown default:
        return false
      }
    }

    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
      guard let validDevice = device else { return nil }
      do {
        return try AVCaptureDeviceInput(device: validDevice)
      } catch {
        logger.error("Error getting capture device input: \(error.localizedDescription)")
        return nil
      }
    }

    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
      guard isCaptureSessionConfigured else { return }

      captureSession.beginConfiguration()
      defer { captureSession.commitConfiguration() }

      for input in captureSession.inputs {
        if let deviceInput = input as? AVCaptureDeviceInput {
          captureSession.removeInput(deviceInput)
        }
      }

      if let deviceInput = deviceInputFor(device: captureDevice) {
        if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
          captureSession.addInput(deviceInput)
        }
      }

      updateVideoOutputConnection()
    }

    private func updateVideoOutputConnection() {
      if let videoOutput = videoOutput,
         let videoOutputConnection = videoOutput.connection(with: .video) {
        if videoOutputConnection.isVideoMirroringSupported {
          videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
        }
      }
    }

    func start() async {
      let authorized = await checkAuthorization()
      guard authorized else {
        logger.error("Camera access was not authorized.")
        return
      }

      if isCaptureSessionConfigured {
        if !captureSession.isRunning {
          sessionQueue.async { [self] in
            self.captureSession.startRunning()
          }
        }
        return
      }

      sessionQueue.async { [self] in
        self.configureCaptureSession { success in
          guard success else { return }
          self.captureSession.startRunning()
        }
      }
    }

    func stop() {
      guard isCaptureSessionConfigured else { return }

      if captureSession.isRunning {
        sessionQueue.async {
          self.captureSession.stopRunning()
        }
      }
    }

    func switchCaptureDevice() {
      if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
        let nextIndex = (index + 1) % availableCaptureDevices.count
        self.captureDevice = availableCaptureDevices[nextIndex]
      } else {
        self.captureDevice = AVCaptureDevice.default(for: .video)
      }
    }

    private var deviceOrientation: UIDeviceOrientation {
      var orientation = UIDevice.current.orientation
      if orientation == UIDeviceOrientation.unknown {
        orientation = UIScreen.mainScreen.orientation
      }
      return orientation
    }

    @objc
    func updateForDeviceOrientation() {
      // TODO: Figure out if we need this for anything.
    }

    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
      switch deviceOrientation {
      case .portrait: return AVCaptureVideoOrientation.portrait
      case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
      case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
      case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
      default: return nil
      }
    }

    lazy var photoSettings: AVCapturePhotoSettings = {
      guard let photoOutput = photoOutput else { return
        AVCapturePhotoSettings()
      }

      var photoSettings = AVCapturePhotoSettings()

      if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
      }

      let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
      photoSettings.flashMode = isFlashAvailable ? .auto : .off

      photoSettings.isHighResolutionPhotoEnabled = false
      photoSettings.photoQualityPrioritization = .speed
      if #available(macOS 10.15, iOS 16.0, tvOS 16.0, *) {
        if let dimention = self.deviceInput?.device.activeFormat.supportedMaxPhotoDimensions.sorted(by: { ($0.width * $0.height) < ($1.width * $1.height) }).first {
          photoSettings.maxPhotoDimensions = dimention
        }
      }
      if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
      }
      photoSettings.photoQualityPrioritization = .speed

      if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
        if photoOutputVideoConnection.isVideoOrientationSupported,
           let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
          photoOutputVideoConnection.videoOrientation = videoOrientation
        }
      }
      return photoSettings
    }()

    func takePhoto() async throws -> AVCapturePhoto {
      guard let photoOutput = photoOutput else { throw CameraError.missingPhotoOutput }
      defer { didTakePicture = nil }

      return try await withCheckedThrowingContinuation { continuation in
        didTakePicture = { continuation.resume(with: $0) }
        sessionQueue.async {
          photoOutput.capturePhoto(with: self.photoSettings, delegate: self)
        }
      }
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      if let error = error {
        logger.error("Error capturing photo: \(error.localizedDescription)")
        self.didTakePicture?(.failure(error))

        return
      }
      addToPhotoStream?(photo)
      self.didTakePicture?(.success(photo))
    }
  }

  extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

      if connection.isVideoOrientationSupported,
         let videoOrientation = videoOrientationFor(deviceOrientation) {
        connection.videoOrientation = videoOrientation
      }

      addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
  }

  fileprivate extension UIScreen {
    var orientation: UIDeviceOrientation {
      let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
      if point == CGPoint.zero {
        return .portrait
      } else if point.x != 0 && point.y != 0 {
        return .portraitUpsideDown
      } else if point.x == 0 && point.y != 0 {
        return .landscapeRight // .landscapeLeft
      } else if point.x != 0 && point.y == 0 {
        return .landscapeLeft // .landscapeRight
      } else {
        return .unknown
      }
    }
  }

  fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "camera")

  public enum CameraError: Error {
    case missingPhotoOutput, missingVideoOutput
  }

  struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
  }

  public extension CIImage {
    var image: Image? {
      let ciContext = CIContext()
      guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }

      return Image(decorative: cgImage, scale: 0.5, orientation: .up)
    }
  }

  fileprivate extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
      switch cgImageOrientation {
      case .up: self = .up
      case .upMirrored: self = .upMirrored
      case .down: self = .down
      case .downMirrored: self = .downMirrored
      case .left: self = .left
      case .leftMirrored: self = .leftMirrored
      case .right: self = .right
      case .rightMirrored: self = .rightMirrored
      }
    }
  }

  public struct TakePictureAction {
    var handler: () async -> Void = {
      assertionFailure("@Environment(\\.takePicture) must be accessed from a camera overlay view")
    }

    public func callAsFunction() {
      Task { await handler() }
    }
  }

  private enum TakePictureEnvironmentKey: EnvironmentKey {
    static var defaultValue: TakePictureAction = .init()
  }

  public extension EnvironmentValues {
    internal(set) var takePicture: TakePictureAction {
      get { self[TakePictureEnvironmentKey.self] }
      set { self[TakePictureEnvironmentKey.self] = newValue }
    }
  }
#else
  import AppKit
#endif
