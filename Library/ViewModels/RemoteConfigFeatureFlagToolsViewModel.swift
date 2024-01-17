import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias RemoteConfigFeatures = [(RemoteConfigFeature, Bool)]

public protocol RemoteConfigFeatureFlagToolsViewModelOutputs {
  var reloadWithData: Signal<RemoteConfigFeatures, Never> { get }
  var updateUserDefaultsWithFeatures: Signal<RemoteConfigFeatures, Never> { get }
}

public protocol RemoteConfigFeatureFlagToolsViewModelInputs {
  func didUpdateUserDefaults()
  func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool)
  func viewDidLoad()
}

public protocol RemoteConfigFeatureFlagToolsViewModelType {
  var inputs: RemoteConfigFeatureFlagToolsViewModelInputs { get }
  var outputs: RemoteConfigFeatureFlagToolsViewModelOutputs { get }
}

public final class RemoteConfigFeatureFlagToolsViewModel: RemoteConfigFeatureFlagToolsViewModelType,
  RemoteConfigFeatureFlagToolsViewModelInputs,
  RemoteConfigFeatureFlagToolsViewModelOutputs {
  public init() {
    let didUpdateUserDefaultsAndUI = self.didUpdateUserDefaultsProperty.signal
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let features = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateUserDefaultsAndUI
    )
    .map { _ in AppEnvironment.current.remoteConfigClient?.allFeatures() }
    .skipNil()

    let remoteConfigFeatures = features
      .map { features in
        features.map { feature -> (RemoteConfigFeature, Bool) in
          (feature, isFeatureEnabled(feature))
        }
      }

    self.reloadWithData = remoteConfigFeatures

    self.updateUserDefaultsWithFeatures = remoteConfigFeatures
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, isEnabled -> RemoteConfigFeatures? in
        let (feature, _) = features[index]
        var mutatedFeatures = features

        setValueInUserDefaults(for: feature, and: isEnabled)

        mutatedFeatures[index] = (feature, isEnabled)
        return mutatedFeatures
      }
      .skipNil()
  }

  private let setFeatureEnabledAtIndexProperty = MutableProperty<(Int, Bool)?>(nil)
  public func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool) {
    self.setFeatureEnabledAtIndexProperty.value = (index, isEnabled)
  }

  private let didUpdateUserDefaultsProperty = MutableProperty(())
  public func didUpdateUserDefaults() {
    self.didUpdateUserDefaultsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadWithData: Signal<RemoteConfigFeatures, Never>
  public let updateUserDefaultsWithFeatures: Signal<RemoteConfigFeatures, Never>

  public var inputs: RemoteConfigFeatureFlagToolsViewModelInputs { return self }
  public var outputs: RemoteConfigFeatureFlagToolsViewModelOutputs { return self }
}

// MARK: - Private Helpers

private func isFeatureEnabled(_ feature: RemoteConfigFeature) -> Bool {
  switch feature {
  case .blockUsersEnabled:
    return featureBlockUsersEnabled()
  case .consentManagementDialogEnabled:
    return featureConsentManagementDialogEnabled()
  case .darkModeEnabled:
    return featureDarkModeEnabled()
  case .facebookLoginInterstitialEnabled:
    return featureFacebookLoginInterstitialEnabled()
  case .postCampaignPledgeEnabled:
    return featurePostCampaignPledgeEnabled()
  case .reportThisProjectEnabled:
    return featureReportThisProjectEnabled()
  }
}

/** Returns the value of the User Defaults key in the AppEnvironment.
 */
private func getValueFromUserDefaults(for feature: RemoteConfigFeature) -> Bool? {
  switch feature {
  case .blockUsersEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.blockUsersEnabled.rawValue]
  case .consentManagementDialogEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.consentManagementDialogEnabled.rawValue]
  case .darkModeEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.darkModeEnabled.rawValue]
  case .facebookLoginInterstitialEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue]
  case .postCampaignPledgeEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.postCampaignPledgeEnabled.rawValue]
  case .reportThisProjectEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.reportThisProjectEnabled.rawValue]
  }
}

/** Sets the value for the UserDefaults key in the AppEnvironment.
 */
private func setValueInUserDefaults(for feature: RemoteConfigFeature, and value: Bool) {
  switch feature {
  case .blockUsersEnabled:
    AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.blockUsersEnabled.rawValue] = value
  case .consentManagementDialogEnabled:
    AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.consentManagementDialogEnabled.rawValue] = value
  case .darkModeEnabled:
    AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.darkModeEnabled.rawValue] = value
  case .facebookLoginInterstitialEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue] = value
  case .postCampaignPledgeEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.postCampaignPledgeEnabled.rawValue] = value
  case .reportThisProjectEnabled:
    return AppEnvironment.current.userDefaults
      .remoteConfigFeatureFlags[RemoteConfigFeature.reportThisProjectEnabled.rawValue] = value
  }
}
