import SwiftUI

public struct LogEventView: View {
  public typealias Event = SwiftUILogger.Event

  let event: Event
  let isMinimal: Bool

  public init(
    event: Event,
    isMinimal: Bool = false
  ) {
    self.event = event
    self.isMinimal = isMinimal
  }

  public var body: some View {
    if isMinimal {
      HStack {
        //                let date = Event.dateFormatter.string(from: event.dateCreated)
        //                let time = Event.timeFormatter.string(from: event.dateCreated)
        VStack(
          alignment: .leading,
          spacing: 2,
          content: {
            Text(event.dateCreated, style: .offset)
              .font(.caption.weight(.regular).monospacedDigit())

            Text("\(event.level.emoji.symbolRenderingMode(.multicolor)) \u{25b8}: \(event.message)")
              .font(.footnote.monospaced().weight(.light))
              .lineLimit(nil)
              .multilineTextAlignment(.leading)
          }
        )
        .padding(.leading, 4)
        Spacer()
      }
      .frame(
        maxWidth: .infinity
      )
      .padding(.vertical)
    } else {
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 8) {
          Label(
            "\(event.metadata.file.description) \u{0040} **line: \(event.metadata.line)**",
            systemImage: "calendar.day.timeline.left"
          )
          .symbolRenderingMode(.multicolor).imageScale(.large)
          Spacer()
          Text(event.dateCreated.formatted(date: .abbreviated, time: .standard))
          if let error = event.error {
            Text("\(error.localizedDescription)")
              .font(.caption2.monospaced().weight(.thin))
              .foregroundStyle(.red)
              .lineLimit(1)
          }
        }
        .font(.caption2.monospaced()).lineLimit(1).truncationMode(.head)

        Divider().frame(height: 0.66).background(event.level.color).cornerRadius(100)
        HStack(content: {
          Text("\(event.level.emoji.symbolRenderingMode(.multicolor))\u{25b8} \(event.message)")
            .imageScale(.large)
            .font(.footnote.monospaced().weight(.thin))
            .lineLimit(nil)
            .multilineTextAlignment(.leading)

          Spacer()
        })
        .padding(8)
        .background(
          Rectangle().fill(event.level.color).opacity(0.0666)
        ).padding(-8).padding(.horizontal, -3)
        if let error = event.error {
          Divider()
          Text("🚨" + error.localizedDescription)
        }
      }
      .padding(8)
      .frame(
        maxWidth: .infinity
      )

      //            .background(content: {
      //                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(event.level.color.opacity(0.11))
      //            })
      //            .background(content: {
      //                RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(lineWidth: 1.488)
      //                    .fill(event.level.color.opacity(0.66)).blur(radius: 1.0)
      //            })
      //            .clipped(antialiased: true)
    }
  }
}
