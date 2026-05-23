/// All user-visible copy for default widgets — override per app / locale.
class InAppLocationStrings {
  const InAppLocationStrings({
    this.permissionTitle = 'Find places near you',
    this.permissionBody =
        'We use your location to show nearby options and accurate delivery. '
        'Your location is only used to improve your experience.',
    this.allowLocationButton = 'Allow Location',
    this.turningOnLocationButton = 'Turning on location...',
    this.manualEntryButton = 'Enter location manually',
    this.useCurrentLocationButton = 'Use current location',
    this.checkingLocation = 'Checking location...',
    this.fetchingLocation = 'Fetching your location...',
    this.usingLocation = 'Using location',
    this.findingNearYou = 'Finding places near you',
    this.settingUpLocation = 'Setting up your location',
    this.gpsOffDialogTitle = 'Location is off',
    this.gpsOffDialogBody =
        'Turn on location in Settings so we can find your address.',
    this.permissionDeniedForeverTitle = 'Location permission required',
    this.permissionDeniedForeverBody =
        'Location permission is permanently denied. Please enable it in app settings.',
    this.cancel = 'Cancel',
    this.openSettings = 'Open Settings',
    this.retry = 'Retry',
    this.permissionDeniedSnack =
        'Location permission is required to use this feature',
    this.gpsDisabledSnack = 'Location services are disabled. Please enable GPS.',
    this.mapConfirmButton = 'Confirm location',
    this.mapSearchHint = 'Search area or move the pin',
  });

  final String permissionTitle;
  final String permissionBody;
  final String allowLocationButton;
  final String turningOnLocationButton;
  final String manualEntryButton;
  final String useCurrentLocationButton;
  final String checkingLocation;
  final String fetchingLocation;
  final String usingLocation;
  final String findingNearYou;
  final String settingUpLocation;
  final String gpsOffDialogTitle;
  final String gpsOffDialogBody;
  final String permissionDeniedForeverTitle;
  final String permissionDeniedForeverBody;
  final String cancel;
  final String openSettings;
  final String retry;
  final String permissionDeniedSnack;
  final String gpsDisabledSnack;
  final String mapConfirmButton;
  final String mapSearchHint;
}
