abstract class Call {
  ///Mute call
  void mute(bool mute);

  /// Reject call
  void reject();

  /// Accept call
  void accept();

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  void on(dynamic name, Function callback);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  void addListener(dynamic name, Function callback);

  /// Removes all listeners
  ///
  /// Don`t use this method, use [removeCallListeners] and [removeVolumeListener] instead
  void removeAllListeners(List<String> events);
}
