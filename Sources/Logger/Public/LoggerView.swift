import SwiftUI

#if canImport(UIKit)
@available(iOS 15.0, *)
public struct LoggerView: View {
  // Properties

  @StateObject private var logger: SwiftUILogger
  @State private var isMinimal = false
  @State private var isPresentedFilter = false

  private let shareAction: (String) -> Void

  // Computed Properties

  private var logs: [SwiftUILogger.Event] { self.logger.displayedLogs }

  private var tags: Set<String> {
    Set(
      self.logger.logs
        .flatMap(\.metadata.tags)
        .map(\.value)
    )
  }

  private var navigationTitle: String {
    "\(self.logs.count) \(self.logger.name.map { "\($0) " } ?? "")Events"
  }

  // Lifecycle

  public init(
    logger: SwiftUILogger = .default,
    shareAction: @escaping (String) -> Void = { print($0) }
  ) {
    self._logger = StateObject(wrappedValue: logger)
    self.shareAction = shareAction
  }

  // Content

  ///
  public var body: some View {
    self.navigation {
      Group {
        if self.logs.isEmpty {
          Text("Logs will show up here!")
            .font(.largeTitle)
        } else {
          ScrollViewReader { proxy in

            ScrollView {
              LazyVStack(spacing: 8) {
                let logCount = self.logs.count - 1
                ForEach(0...logCount, id: \.self) { index in
                  let log = self.logs[logCount - index]

                  LogEventView(
                    event: log,
                    isMinimal: self.isMinimal
                  )
                  .padding(.horizontal, 4)
                  .clipShape(
                    RoundedRectangle(cornerRadius: 6, style: .continuous),
                    style: .init(eoFill: true, antialiased: true)
                  )
                  .background {
                    let color = Color(
                      index.isMultiple(of: 2) ? .secondarySystemGroupedBackground : .tertiarySystemBackground
                    )
                    if #available(iOS 16.0, *) {
                      RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                          color.shadow(.inner(color: log.level.color, radius: 1.06)).shadow(
                            .drop(color: Color(.opaqueSeparator), radius: 1.66)
                          )
                        )
                    } else {
                      RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color)
                    }
                  }
                  Divider()
                }

              }.padding(1)
              Spacer(minLength: 66)
            }
            .overlay(alignment: .bottomTrailing) {
              Button {
                withAnimation(.smooth) {
                  proxy.scrollTo(self.logs.count - 1, anchor: .bottom)
                }
              } label: {
                Image(systemName: "arrow.down.circle.dotted")
                  .imageScale(.large)
                  .font(.title)
                  .symbolRenderingMode(.hierarchical)
                  .foregroundStyle(.purple)
                  .padding(8)
                  .background(.ultraThinMaterial, in: Circle())
                  .padding(12)
                  .shadow(radius: 3)
              }
            }
          }
        }
      }
      .navigationTitle(self.navigationTitle)
      .toolbar {
        HStack {
          self.shareBlobButton
          self.filterButton
          self.toggleMinimalButton
        }
        .disabled(self.logs.isEmpty)
      }
      .background(Color(.lightGray).opacity(0.16))
    }
  }

  @ViewBuilder
  private func navigation(content: () -> some View) -> some View {
    if #available(iOS 16.0, *) {
      NavigationStack {
        content()
      }
    } else {
      NavigationView {
        content()
      }
    }
  }

  private var shareBlobButton: some View {
    Button(
      action: {
        self.shareAction(self.logger.blob)
      },
      label: {
        Image(systemName: "square.and.arrow.up")
      }
    )
  }

  private var filterButton: some View {
    Button(
      action: {
        withAnimation {
          self.isPresentedFilter.toggle()
        }
      },
      label: {
        Image(systemName: "line.3.horizontal.decrease.circle")
      }
    )
    .sheet(isPresented: self.$isPresentedFilter) {
      LogFilterView(
        logger: self.logger,
        tags: Array(self.tags),
        isPresented: self.$isPresentedFilter
      )
    }
  }

  private var toggleMinimalButton: some View {
    Button(
      action: {
        withAnimation {
          self.isMinimal.toggle()
        }
      },
      label: {
        Image(systemName: self.isMinimal ? "list.bullet.circle" : "list.bullet.circle.fill")
      }
    )
  }
}
#endif
//
// struct LoggerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoggerView(
//            logger: SwiftUILogger(
//                name: "Preview",
//                logs: [
//                    .init(level: .success, message: "Accessing Environment<ChatTheme>'s value outside of being installed on a View. This will always read the default value and will not update."),
//                    .init(level: .warning, message: "init"),
//                    .init(level: .trace, message:
//                        """
//                          􁇵INFO: {
//                            "stage" : "setup",
//                            "status" : "complete" }
//                        """),
//                    .init(level: .error, message:
//                        """
//                        - nil
//                        ▿ Optional(FlomniChatSDK.SocketChatEvent)
//                        ▿ some: FlomniChatSDK.SocketChatEvent #0
//                        ▿ super: FlomniChatSDK.ChatEvent
//                        - type: "gtm-event"
//                        - id: "E95F0D0E-F806-42D3-B561-1D9016EE6820"
//                        ▿ event: Optional(FlomniChatSDK.SEvent.gtmEvent)
//                        - some: FlomniChatSDK.SEvent.gtmEvent
//                        - eventId: nil
//                        - mid: nil
//                        - time: nil
//                        - avatarUrl: nil
//                        ▿ name: Optional("intro")
//                        - some: "intro"
//                        - title: nil
//                        - timeout: nil
//                        - agentId: nil
//                        - originator: nil
//                        - threadId: nil
//                        - stage: nil
//                        """),
//                    .init(level: .info, message: "init"),
//                    .init(level: .fatal, message: "init"),
//                    .init(level: .debug, message: "init"),
//                ]
//            )
//        )
//    }
// }
