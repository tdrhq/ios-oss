import Foundation

public enum OptimizelyFeature {
  public enum Key: String {
    case commentFlaggingDisabled = "ios_comment_threading_comment_flagging"
    case commentThreading = "ios_comment_threading"
    case commentThreadingRepliesDisabled = "ios_comment_threading_reply_buttons"
    case lightsOn = "ios_lights_on"
    case signInWithAppleKillswitch = "ios_sign_in_with_apple_killswitch"
  }
}
