import SwiftUI

// MARK: - Audio

/// Represents an audio URL
public struct Audio: Identifiable, Hashable {
  public var id: String { url.path }
  public let url: URL

  init(url: URL) {
    self.url = url
  }

  init?(name: String, bundle: Bundle) {
    guard let url = bundle.url(forResource: name, withExtension: nil) else { return nil }
    self.url = url
  }

  /// Returns a new instance from the specified URL
  /// - Parameter url: The URL of the audio file
  public static func custom(url: URL) -> Self {
    .init(url: url)
  }

  /// Returns a new instance from a resource in the specified bundle
  /// - Parameters:
  ///   - name: The name of the resource
  ///   - bundle: The bundle where the resource is located
  public static func custom(named name: String, in bundle: Bundle = .main) -> Self? {
    .init(name: name, bundle: bundle)
  }
}

extension Audio {
  public static let busyToneANSI = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/busy_tone_ansi.caf")
  )

  public static let busyToneCEPT = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/busy_tone_cept.caf")
  )

  public static let callWaitingToneANSI = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/call_waiting_tone_ansi.caf")
  )

  public static let callWaitingToneCEPT = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/call_waiting_tone_cept.caf")
  )

  public static let ctCallWaiting = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ct-call-waiting.caf")
  )

  public static let dtmf0 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-0.caf")
  )

  public static let dtmf1 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-1.caf")
  )

  public static let dtmf2 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-2.caf")
  )

  public static let dtmf3 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-3.caf")
  )

  public static let dtmf4 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-4.caf")
  )

  public static let dtmf5 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-5.caf")
  )

  public static let dtmf6 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-6.caf")
  )

  public static let dtmf7 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-7.caf")
  )

  public static let dtmf8 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-8.caf")
  )

  public static let dtmf9 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-9.caf")
  )

  public static let dtmfPound = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-pound.caf")
  )

  public static let dtmfStar = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/dtmf-star.caf")
  )

  public static let endCallToneCEPT = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/end_call_tone_cept.caf")
  )

  public static let headphoneAudioExposureLimitExceeded = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/HeadphoneAudioExposureLimitExceeded.caf")
  )

  public static let healthNotificationUrgent = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/HealthNotificationUrgent.caf")
  )

  public static let mediaHandoff = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MediaHandoff.caf")
  )

  public static let mediaPaused = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MediaPaused.caf")
  )

  public static let micMute = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MicMute.caf")
  )

  public static let micUnmute = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MicUnmute.caf")
  )

  public static let micUnmuteFail = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MicUnmuteFail.caf")
  )

  public static let multiwayJoin = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MultiwayJoin.caf")
  )

  public static let multiwayLeave = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/MultiwayLeave.caf")
  )

  public static let pushToTalkJoined = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/PushToTalkJoined.caf")
  )

  public static let pushToTalkLeft = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/PushToTalkLeft.caf")
  )

  public static let pushToTalkMute = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/PushToTalkMute.caf")
  )

  public static let pushToTalkUnmute = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/PushToTalkUnmute.caf")
  )

  public static let pushToTalkUnmuteFail = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/PushToTalkUnmuteFail.caf")
  )

  public static let ringbackToneANSI = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ringback_tone_ansi.caf")
  )

  public static let ringbackToneAUS = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ringback_tone_aus.caf")
  )

  public static let ringbackToneCEPT = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ringback_tone_cept.caf")
  )

  public static let ringbackToneHK = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ringback_tone_hk.caf")
  )

  public static let ringbackToneUK = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ringback_tone_uk.caf")
  )

  public static let screenCapture = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ScreenCapture.caf")
  )

  public static let screenSharingStarted = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/ScreenSharingStarted.caf")
  )

  public static let vcEnded = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/vc~ended.caf")
  )

  public static let vcInvitationAccepted = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/vc~invitation-accepted.caf")
  )

  public static let vcRinging = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/vc~ringing.caf")
  )

  public static let vcRingingWatch = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/vc~ringing_watch.caf")
  )

  public static let workoutCompleteAutodetect = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutCompleteAutodetect.caf")
  )

  public static let workoutPaceAbove = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutPaceAbove.caf")
  )

  public static let workoutPaceBelow = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutPaceBelow.caf")
  )

  public static let workoutPausedAutoDetect = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutPausedAutoDetect.caf")
  )

  public static let workoutResumedAutoDetect = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutResumedAutoDetect.caf")
  )

  public static let workoutStartAutodetect = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/WorkoutStartAutodetect.caf")
  )

  public static let critical = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/3rd_party_critical.caf")
  )

  public static let accessScanComplete = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/access_scan_complete.caf")
  )

  public static let acknowledgmentReceived = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/acknowledgment_received.caf")
  )

  public static let acknowledgmentSent = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/acknowledgment_sent.caf")
  )

  public static let alarm = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/alarm.caf")
  )

  public static let beginRecord = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/begin_record.caf")
  )

  public static let cameraTimerCountdown = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/camera_timer_countdown.caf")
  )

  public static let cameraTimerFinalSecond = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/camera_timer_final_second.caf")
  )

  public static let connectPower = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/connect_power.caf")
  )

  public static let ctBusy = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ct-busy.caf")
  )

  public static let ctCongestion = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ct-congestion.caf")
  )

  public static let ctError = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ct-error.caf")
  )

  public static let ctKeytone2 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ct-keytone2.caf")
  )

  public static let ctPathACK = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ct-path-ack.caf")
  )

  public static let deviceShutdown = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/DeviceShutdown.caf")
  )

  public static let doorbell = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Doorbell.caf")
  )

  public static let endRecord = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/end_record.caf")
  )

  public static let focusChangeAppIcon = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/focus_change_app_icon.caf")
  )

  public static let focusChangeKeyboard = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/focus_change_keyboard.caf")
  )

  public static let focusChangeLarge = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/focus_change_large.caf")
  )

  public static let focusChangeSmall = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/focus_change_small.caf")
  )

  public static let gotoSleepAlert = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/go_to_sleep_alert.caf")
  )

  public static let healthNotification = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/health_notification.caf")
  )

  public static let jblAmbiguous = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_ambiguous.caf")
  )

  public static let jblBegin = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_begin.caf")
  )

  public static let jblBeginShort = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_begin_short.caf")
  )

  public static let jblBeginShortCarplay = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_begin_short_carplay.caf")
  )

  public static let jblCancel = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_cancel.caf")
  )

  public static let jblConfirm = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_confirm.caf")
  )

  public static let jblNoMatch = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/jbl_no_match.caf")
  )

  public static let keyPressClick = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_click.caf")
  )

  public static let keyPressDelete = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_delete.caf")
  )

  public static let keyPressModifier = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_modifier.caf")
  )

  public static let keyboardPressClear = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/keyboard_press_clear.caf")
  )

  public static let keyboardPressDelete = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/keyboard_press_delete.caf")
  )

  public static let keyboardPressNormal = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/keyboard_press_normal.caf")
  )

  public static let lock = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/lock.caf")
  )

  public static let longLowShortHigh = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/long_low_short_high.caf")
  )

  public static let lowPower = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/low_power.caf")
  )

  public static let mailSent = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/mail-sent.caf")
  )

  public static let middle9ShortDoubleLow = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/middle_9_short_double_low.caf")
  )

  public static let multiwayInvitation = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/multiway_invitation.caf")
  )

  public static let navigationPop = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/navigation_pop.caf")
  )

  public static let navigationPush = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/navigation_push.caf")
  )

  public static let navigationGenericManeuver = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/NavigationGenericManeuver.caf")
  )

  public static let newMail = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/new-mail.caf")
  )

  public static let nfcScanComplete = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nfc_scan_complete.caf")
  )

  public static let nfcScanFailure = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/nfc_scan_failure.caf")
  )

  public static let paymentFailure = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/payment_failure.caf")
  )

  public static let paymentSuccess = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/payment_success.caf")
  )

  public static let paymentReceived = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PaymentReceived.caf")
  )

  public static let paymentReceivedFailure = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PaymentReceivedFailure.caf")
  )

  public static let photoShutter = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/photoShutter.caf")
  )

  public static let pinDelete = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINDelete.caf")
  )

  public static let pinDeleteAX = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINDelete_AX.caf")
  )

  public static let pinEnterDigit = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINEnterDigit.caf")
  )

  public static let pinEnterDigitAX = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINEnterDigit_AX.caf")
  )

  public static let pinSubmitAX = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINSubmit_AX.caf")
  )

  public static let pinUnexpected = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/PINUnexpected.caf")
  )

  public static let receivedMessage = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ReceivedMessage.caf")
  )

  public static let ringerChanged = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/RingerChanged.caf")
  )

  public static let sentMessage = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SentMessage.caf")
  )

  public static let shake = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/shake.caf")
  )

  public static let shortDoubleHigh = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/short_double_high.caf")
  )

  public static let shortDoubleLow = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/short_double_low.caf")
  )

  public static let shortLowHigh = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/short_low_high.caf")
  )

  public static let simToolkitCallDropped = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitCallDropped.caf")
  )

  public static let simToolkitGeneralBeep = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf")
  )

  public static let simToolkitNegativeACK = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitNegativeACK.caf")
  )

  public static let simToolkitPositiveACK = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitPositiveACK.caf")
  )

  public static let simToolkitSMS = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitSMS.caf")
  )

  public static let smsReceived1 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received1.caf")
  )

  public static let smsReceived2 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received2.caf")
  )

  public static let smsReceived3 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received3.caf")
  )

  public static let smsReceived4 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received4.caf")
  )

  public static let smsReceived5 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received5.caf")
  )

  public static let smsReceived6 = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received6.caf")
  )

  public static let swish = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Swish.caf")
  )

  public static let tink = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tink.caf")
  )

  public static let tock = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
  )

  public static let tweetSent = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/tweet_sent.caf")
  )

  public static let ussd = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ussd.caf")
  )

  public static let warsaw = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/warsaw.caf")
  )

  public static let webcamStart = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/WebcamStart.caf")
  )

  public static let wheelsOfTime = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/wheels_of_time.caf")
  )

  public static let anticipate = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Anticipate.caf")
  )

  public static let bloom = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Bloom.caf")
  )

  public static let calypso = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Calypso.caf")
  )

  public static let chooChoo = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Choo_Choo.caf")
  )

  public static let descent = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Descent.caf")
  )

  public static let fanfare = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Fanfare.caf")
  )

  public static let ladder = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Ladder.caf")
  )

  public static let minuet = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Minuet.caf")
  )

  public static let newsFlash = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/News_Flash.caf")
  )

  public static let noir = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Noir.caf")
  )

  public static let sherwoodForest = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Sherwood_Forest.caf")
  )

  public static let spell = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Spell.caf")
  )

  public static let suspense = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Suspense.caf")
  )

  public static let telegraph = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Telegraph.caf")
  )

  public static let tiptoes = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Tiptoes.caf")
  )

  public static let typewriters = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Typewriters.caf")
  )

  public static let update = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Update.caf")
  )

  public static let cameraShutterBurst = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Modern/camera_shutter_burst.caf")
  )

  public static let cameraShutterBurstBegin = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Modern/camera_shutter_burst_begin.caf")
  )

  public static let cameraShutterBurstEnd = Self(
    url: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Modern/camera_shutter_burst_end.caf")
  )
}
