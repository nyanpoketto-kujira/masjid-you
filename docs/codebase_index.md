# Codebase Index — Masjid You

> Dibuat otomatis oleh `dart run tools/codebase_index.dart`. Jangan edit manual — regenerate setelah perubahan kode.

Total simbol: **1189**

| Kategori | Jumlah |
|---|---:|
| `class` | 119 |
| `field` | 552 |
| `method` | 410 |
| `getter` | 47 |
| `function` | 28 |
| `constructor` | 2 |
| `typedef` | 6 |
| `enum` | 11 |
| `operator` | 12 |
| `extension` | 2 |


### `apps/mobile_remote/lib/main.dart`
- `class` **RemoteHomeScreen** — baris 44 — `class RemoteHomeScreen extends StatefulWidget {`
- `field` **themeMode (RemoteHomeScreen)** — baris 54 — `  final ThemeMode themeMode;`
- `field` **colorSource (RemoteHomeScreen)** — baris 55 — `  final AppColorSource colorSource;`
- `field` **onThemeModeChanged (RemoteHomeScreen)** — baris 56 — `  final ValueChanged<ThemeMode>? onThemeModeChanged;`
- `field` **onColorSourceChanged (RemoteHomeScreen)** — baris 57 — `  final ValueChanged<AppColorSource>? onColorSourceChanged;`
- `method` **createState (RemoteHomeScreen)** — baris 60 — `  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();`
- `class` **_PinDialog** — baris 96 — `class _PinDialog extends StatefulWidget {`
- `field` **onSubmit (_PinDialog)** — baris 97 — `  final ValueChanged<String> onSubmit;`
- `field` **onCancel (_PinDialog)** — baris 98 — `  final VoidCallback onCancel;`
- `method` **createState (_PinDialog)** — baris 103 — `  State<_PinDialog> createState() => _PinDialogState();`
- `class` **_PinDialogState** — baris 106 — `class _PinDialogState extends State<_PinDialog> {`
- `field` **_pinController (_PinDialogState)** — baris 107 — `  final _pinController = TextEditingController();`
- `method` **dispose (_PinDialogState)** — baris 110 — `  void dispose() {`
- `method` **_submit (_PinDialogState)** — baris 115 — `  void _submit() {`
- `method` **build (_PinDialogState)** — baris 122 — `  Widget build(BuildContext context) {`
- `class` **_RemoteHomeScreenState** — baris 172 — `class _RemoteHomeScreenState extends State<RemoteHomeScreen>`
- `field` **_tabIndex (_RemoteHomeScreenState)** — baris 175 — `  int _tabIndex = 0;`
- `field` **_subTabController (_RemoteHomeScreenState)** — baris 178 — `  late final TabController _subTabController;`
- `field` **_tvMuted (_RemoteHomeScreenState)** — baris 182 — `  bool _tvMuted = false;`
- `field` **_tvStandby (_RemoteHomeScreenState)** — baris 183 — `  bool _tvStandby = false;`
- `field` **_ipController (_RemoteHomeScreenState)** — baris 185 — `  final _ipController = TextEditingController(text: '192.168.1.');`
- `field` **_client (_RemoteHomeScreenState)** — baris 186 — `  final _client = RemoteWsClient();`
- `field` **_btClient (_RemoteHomeScreenState)** — baris 187 — `  final _btClient = BluetoothClientService();`
- `field` **_isConnecting (_RemoteHomeScreenState)** — baris 188 — `  bool _isConnecting = false;`
- `field` **_isConnected (_RemoteHomeScreenState)** — baris 189 — `  bool _isConnected = false;`
- `field` **_wasConnected (_RemoteHomeScreenState)** — baris 190 — `  bool _wasConnected = false;`
- `field` **_showDisconnectedNotice (_RemoteHomeScreenState)** — baris 191 — `  bool _showDisconnectedNotice = false;`
- `field` **_syncDialogOpen (_RemoteHomeScreenState)** — baris 192 — `  bool _syncDialogOpen = false;`
- `field` **_lastConnectionKind (_RemoteHomeScreenState)** — baris 193 — `  String? _lastConnectionKind;`
- `field` **_lastBtDevice (_RemoteHomeScreenState)** — baris 194 — `  BluetoothDeviceInfo? _lastBtDevice;`
- `field` **_btIsScanning (_RemoteHomeScreenState)** — baris 197 — `  bool _btIsScanning = false;`
- `field` **_btConnected (_RemoteHomeScreenState)** — baris 198 — `  bool _btConnected = false;`
- `field` **_btDevices (_RemoteHomeScreenState)** — baris 199 — `  List<BluetoothDeviceInfo> _btDevices = [];`
- `field` **_btKnownDevices (_RemoteHomeScreenState)** — baris 203 — `  List<BluetoothDeviceInfo> _btKnownDevices = [];`
- `field` **_btStatus (_RemoteHomeScreenState)** — baris 204 — `  String _btStatus = 'Bluetooth: Stanby';`
- `field` **_btStateSub (_RemoteHomeScreenState)** — baris 205 — `  StreamSubscription<BluetoothClientState>? _btStateSub;`
- `field` **_hasUnsyncedChanges (_RemoteHomeScreenState)** — baris 207 — `  bool _hasUnsyncedChanges = false;`
- `field` **_settingsDirty (_RemoteHomeScreenState)** — baris 212 — `  bool _settingsDirty = false;`
- `field` **_pinDialogOpen (_RemoteHomeScreenState)** — baris 215 — `  bool _pinDialogOpen = false;`
- `field` **_pendingBtState (_RemoteHomeScreenState)** — baris 219 — `  BluetoothClientState? _pendingBtState;`
- `field` **_cacheStore (_RemoteHomeScreenState)** — baris 222 — `  final RemoteCacheStore _cacheStore = RemoteCacheStore();`
- `field` **_backupService (_RemoteHomeScreenState)** — baris 225 — `  final BackupService _backupService = BackupService();`
- `field` **_didBootstrapPush (_RemoteHomeScreenState)** — baris 229 — `  bool _didBootstrapPush = false;`
- `field` **_config (_RemoteHomeScreenState)** — baris 231 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_nameController (_RemoteHomeScreenState)** — baris 238 — `  final _nameController = TextEditingController();`
- `field` **_addressController (_RemoteHomeScreenState)** — baris 239 — `  final _addressController = TextEditingController();`
- `field` **_latitudeController (_RemoteHomeScreenState)** — baris 240 — `  final _latitudeController = TextEditingController();`
- `field` **_longitudeController (_RemoteHomeScreenState)** — baris 241 — `  final _longitudeController = TextEditingController();`
- `field` **_prayerOffsetControllers (_RemoteHomeScreenState)** — baris 242 — `  final Map<PrayerType, TextEditingController> _prayerOffsetControllers = {`
- `field` **_preAdhanController (_RemoteHomeScreenState)** — baris 245 — `  final _preAdhanController = TextEditingController();`
- `field` **_adhanController (_RemoteHomeScreenState)** — baris 246 — `  final _adhanController = TextEditingController();`
- `field` **_preIqomahController (_RemoteHomeScreenState)** — baris 247 — `  final _preIqomahController = TextEditingController();`
- `field` **_shalatController (_RemoteHomeScreenState)** — baris 248 — `  final _shalatController = TextEditingController();`
- `field` **_khutbahController (_RemoteHomeScreenState)** — baris 249 — `  final _khutbahController = TextEditingController();`
- `field` **_fridayKhatibController (_RemoteHomeScreenState)** — baris 250 — `  final _fridayKhatibController = TextEditingController();`
- `field` **_fridayMuadzinController (_RemoteHomeScreenState)** — baris 251 — `  final _fridayMuadzinController = TextEditingController();`
- `field` **_backgroundSlideController (_RemoteHomeScreenState)** — baris 257 — `  final _backgroundSlideController = TextEditingController();`
- `field` **_showKas (_RemoteHomeScreenState)** — baris 261 — `  bool _showKas = true;`
- `field` **_hasFridayPrayer (_RemoteHomeScreenState)** — baris 262 — `  bool _hasFridayPrayer = true;`
- `field` **_isFetchingLocation (_RemoteHomeScreenState)** — baris 263 — `  bool _isFetchingLocation = false;`
- `field` **_runningTextController (_RemoteHomeScreenState)** — baris 264 — `  final _runningTextController = TextEditingController();`
- `field` **_runningCategory (_RemoteHomeScreenState)** — baris 265 — `  String _runningCategory = _runningCategories.first;`
- `field` **_bannerHeaderController (_RemoteHomeScreenState)** — baris 267 — `  final _bannerHeaderController = TextEditingController();`
- `field` **_bannerTitleController (_RemoteHomeScreenState)** — baris 268 — `  final _bannerTitleController = TextEditingController();`
- `field` **_bannerContentController (_RemoteHomeScreenState)** — baris 269 — `  final _bannerContentController = TextEditingController();`
- `field` **_bannerFooterController (_RemoteHomeScreenState)** — baris 270 — `  final _bannerFooterController = TextEditingController();`
- `field` **_kasAmountController (_RemoteHomeScreenState)** — baris 272 — `  final _kasAmountController = TextEditingController();`
- `field` **_kasDescriptionController (_RemoteHomeScreenState)** — baris 273 — `  final _kasDescriptionController = TextEditingController();`
- `field` **_kasType (_RemoteHomeScreenState)** — baris 274 — `  KasType _kasType = KasType.masuk;`
- `field` **_tvPhase (_RemoteHomeScreenState)** — baris 277 — `  PrayerPhase _tvPhase = PrayerPhase.normal;`
- `field` **_kasTransactions (_RemoteHomeScreenState)** — baris 279 — `  final List<KasTransaction> _kasTransactions = [`
- `field` **_runningTexts (_RemoteHomeScreenState)** — baris 296 — `  final List<RunningTextMessage> _runningTexts = [`
- `field` **_banners (_RemoteHomeScreenState)** — baris 311 — `  final List<MediaBanner> _banners = [`
- `field` **_sideImages (_RemoteHomeScreenState)** — baris 329 — `  final List<SpecialImage> _sideImages = [];`
- `field` **_backgroundImages (_RemoteHomeScreenState)** — baris 332 — `  final List<BackgroundImage> _backgroundImages = [];`
- `field` **_bgSendUncompressed (_RemoteHomeScreenState)** — baris 336 — `  bool _bgSendUncompressed = false;`
- `field` **_bgSendProgress (_RemoteHomeScreenState)** — baris 340 — `  double? _bgSendProgress;`
- `field` **_mosqueLogoBase64 (_RemoteHomeScreenState)** — baris 345 — `  String? _mosqueLogoBase64;`
- `field` **_mosqueLogoBytes (_RemoteHomeScreenState)** — baris 346 — `  Uint8List? _mosqueLogoBytes;`
- `field` **_logoSendProgress (_RemoteHomeScreenState)** — baris 350 — `  double? _logoSendProgress;`
- `method` **initState (_RemoteHomeScreenState)** — baris 353 — `  void initState() {`
- `method` **didChangeAppLifecycleState (_RemoteHomeScreenState)** — baris 457 — `  void didChangeAppLifecycleState(AppLifecycleState state) {`
- `method` **_syncConfigControllers (_RemoteHomeScreenState)** — baris 477 — `  void _syncConfigControllers() {`
- `method` **_attachConfigListeners (_RemoteHomeScreenState)** — baris 502 — `  void _attachConfigListeners() {`
- `method` **_onConfigControllerChanged (_RemoteHomeScreenState)** — baris 525 — `  void _onConfigControllerChanged() {`
- `method` **_loadStartupData (_RemoteHomeScreenState)** — baris 536 — `  Future<void> _loadStartupData() async {`
- `method` **_applySnapshot (_RemoteHomeScreenState)** — baris 548 — `  void _applySnapshot(StateSnapshot snapshot) {`
- `method` **_setMosqueLogoLocal (_RemoteHomeScreenState)** — baris 573 — `  void _setMosqueLogoLocal(String? logoBase64) {`
- `method` **_requestTvState (_RemoteHomeScreenState)** — baris 588 — `  void _requestTvState() {`
- `method` **_showUndoSnack (_RemoteHomeScreenState)** — baris 617 — `  void _showUndoSnack(String message, VoidCallback onUndo) {`
- `method` **_sendRunningTextsIfConnected (_RemoteHomeScreenState)** — baris 631 — `  void _sendRunningTextsIfConnected() {`
- `method` **_sendBannersIfConnected (_RemoteHomeScreenState)** — baris 640 — `  void _sendBannersIfConnected() {`
- `method` **_sendKasIfConnected (_RemoteHomeScreenState)** — baris 649 — `  void _sendKasIfConnected() {`
- `method` **_showPinDialog (_RemoteHomeScreenState)** — baris 661 — `  void _showPinDialog() {`
- `method` **_closePinDialog (_RemoteHomeScreenState)** — baris 697 — `  void _closePinDialog() {`
- `method` **_drainPendingBtState (_RemoteHomeScreenState)** — baris 705 — `  void _drainPendingBtState() {`
- `method` **_loadSavedDurations (_RemoteHomeScreenState)** — baris 747 — `  Future<void> _loadSavedDurations() async {`
- `method` **_persistDurations (_RemoteHomeScreenState)** — baris 789 — `  Future<void> _persistDurations(MosqueConfig config) async {`
- `method` **_handleTvPacket (_RemoteHomeScreenState)** — baris 808 — `  void _handleTvPacket(SyncPacket packet) {`
- `method` **_applyTvPhase (_RemoteHomeScreenState)** — baris 824 — `  void _applyTvPhase(SyncPacket packet) {`
- `method` **_applyTvSnapshot (_RemoteHomeScreenState)** — baris 843 — `  void _applyTvSnapshot(StateSnapshot snapshot) {`
- `method` **_pushLocalDataToTv (_RemoteHomeScreenState)** — baris 862 — `  void _pushLocalDataToTv() {`
- `method` **_exportBackup (_RemoteHomeScreenState)** — baris 872 — `  Future<void> _exportBackup() async {`
- `method` **_importBackup (_RemoteHomeScreenState)** — baris 895 — `  Future<void> _importBackup() async {`
- `method` **_applyImportedBackup (_RemoteHomeScreenState)** — baris 947 — `  Future<void> _applyImportedBackup(BackupBundle bundle) async {`
- `method` **_connectToTv (_RemoteHomeScreenState)** — baris 972 — `  Future<void> _connectToTv() async {`
- `method` **_handleConnectionEstablished (_RemoteHomeScreenState)** — baris 1004 — `  void _handleConnectionEstablished(String kind) {`
- `method` **_handleTransportDisconnected (_RemoteHomeScreenState)** — baris 1023 — `  void _handleTransportDisconnected() {`
- `method` **_reconnectLast (_RemoteHomeScreenState)** — baris 1032 — `  Future<void> _reconnectLast() async {`
- `method` **_showSyncConflictDialog (_RemoteHomeScreenState)** — baris 1046 — `  void _showSyncConflictDialog() {`
- `method` **_disconnectFromTv (_RemoteHomeScreenState)** — baris 1086 — `  Future<void> _disconnectFromTv() async {`
- `method` **_buildConfigFromForm (_RemoteHomeScreenState)** — baris 1098 — `  MosqueConfig _buildConfigFromForm() {`
- `method` **_minutesFrom (_RemoteHomeScreenState)** — baris 1137 — `  int _minutesFrom(TextEditingController controller, int fallback) {`
- `method` **_syncAllToTv (_RemoteHomeScreenState)** — baris 1143 — `  void _syncAllToTv() {`
- `method` **_pushAllToTv (_RemoteHomeScreenState)** — baris 1155 — `  void _pushAllToTv() {`
- `method` **_sendConfigUpdate (_RemoteHomeScreenState)** — baris 1168 — `  void _sendConfigUpdate() {`
- `method` **_totalKas (_RemoteHomeScreenState)** — baris 1192 — `  int _totalKas(KasType type) => _kasTransactions`
- `method` **_toggleTvMuted (_RemoteHomeScreenState)** — baris 1198 — `  void _toggleTvMuted() {`
- `method` **_toggleTvStandby (_RemoteHomeScreenState)** — baris 1210 — `  void _toggleTvStandby() {`
- `method` **_sendQuickAction (_RemoteHomeScreenState)** — baris 1221 — `  void _sendQuickAction(SyncAction action) {`
- `method` **_sendForcePhase (_RemoteHomeScreenState)** — baris 1241 — `  void _sendForcePhase(PrayerPhase phase) {`
- `method` **_getLocationFromGps (_RemoteHomeScreenState)** — baris 1249 — `  Future<void> _getLocationFromGps() async {`
- `method` **_addRunningText (_RemoteHomeScreenState)** — baris 1291 — `  void _addRunningText() {`
- `method` **_removeRunningText (_RemoteHomeScreenState)** — baris 1315 — `  void _removeRunningText(String id) {`
- `method` **_editRunningText (_RemoteHomeScreenState)** — baris 1335 — `  void _editRunningText(RunningTextMessage item) {`
- `method` **_addBanner (_RemoteHomeScreenState)** — baris 1370 — `  void _addBanner(String? base64Image) {`
- `method` **_removeBanner (_RemoteHomeScreenState)** — baris 1405 — `  void _removeBanner(String id) {`
- `method` **_toggleBanner (_RemoteHomeScreenState)** — baris 1423 — `  void _toggleBanner(String id, bool val) {`
- `method` **_sendSideImagesIfConnected (_RemoteHomeScreenState)** — baris 1442 — `  void _sendSideImagesIfConnected() {`
- `method` **_addSideImage (_RemoteHomeScreenState)** — baris 1451 — `  void _addSideImage(String caption, String base64Image) {`
- `method` **_removeSideImage (_RemoteHomeScreenState)** — baris 1464 — `  void _removeSideImage(String id) {`
- `method` **_toggleSideImage (_RemoteHomeScreenState)** — baris 1482 — `  void _toggleSideImage(String id, bool val) {`
- `method` **_reorderRunningTexts (_RemoteHomeScreenState)** — baris 1497 — `  void _reorderRunningTexts(int oldIndex, int newIndex) {`
- `method` **_reorderBanners (_RemoteHomeScreenState)** — baris 1506 — `  void _reorderBanners(int oldIndex, int newIndex) {`
- `method` **_reorderSideImages (_RemoteHomeScreenState)** — baris 1515 — `  void _reorderSideImages(int oldIndex, int newIndex) {`
- `method` **_sendBackgroundImagesIfConnected (_RemoteHomeScreenState)** — baris 1528 — `  void _sendBackgroundImagesIfConnected() {`
- `method` **_mirrorBackgroundImagesToBt (_RemoteHomeScreenState)** — baris 1546 — `  Future<void> _mirrorBackgroundImagesToBt(SyncPacket packet) async {`
- `method` **_sendLogoIfConnected (_RemoteHomeScreenState)** — baris 1577 — `  void _sendLogoIfConnected() {`
- `method` **_mirrorLogoToBt (_RemoteHomeScreenState)** — baris 1592 — `  Future<void> _mirrorLogoToBt(SyncPacket packet) async {`
- `method` **_pickMosqueLogo (_RemoteHomeScreenState)** — baris 1617 — `  Future<void> _pickMosqueLogo() async {`
- `method` **_removeMosqueLogo (_RemoteHomeScreenState)** — baris 1639 — `  void _removeMosqueLogo() {`
- `method` **_addBackgroundImage (_RemoteHomeScreenState)** — baris 1655 — `  void _addBackgroundImage(String base64Image) {`
- `method` **_removeBackgroundImage (_RemoteHomeScreenState)** — baris 1667 — `  void _removeBackgroundImage(String id) {`
- `method` **_toggleBackgroundImage (_RemoteHomeScreenState)** — baris 1685 — `  void _toggleBackgroundImage(String id, bool val) {`
- `method` **_reorderBackgroundImages (_RemoteHomeScreenState)** — baris 1697 — `  void _reorderBackgroundImages(int oldIndex, int newIndex) {`
- `method` **_onBgSendUncompressedChanged (_RemoteHomeScreenState)** — baris 1708 — `  void _onBgSendUncompressedChanged(bool value) {`
- `method` **_editBanner (_RemoteHomeScreenState)** — baris 1715 — `  void _editBanner(MediaBanner banner) {`
- `method` **_addKasTransaction (_RemoteHomeScreenState)** — baris 1804 — `  void _addKasTransaction() {`
- `method` **_removeKasTransaction (_RemoteHomeScreenState)** — baris 1831 — `  void _removeKasTransaction(String id) {`
- `method` **_startBtScan (_RemoteHomeScreenState)** — baris 1849 — `  void _startBtScan() {`
- `method` **_stopBtScan (_RemoteHomeScreenState)** — baris 1857 — `  void _stopBtScan() {`
- `method` **_connectBt (_RemoteHomeScreenState)** — baris 1865 — `  void _connectBt(BluetoothDeviceInfo device) {`
- `method` **_showScheduleSimulation (_RemoteHomeScreenState)** — baris 1875 — `  void _showScheduleSimulation(MosqueConfig formConfig) {`
- `method` **dispose (_RemoteHomeScreenState)** — baris 1886 — `  void dispose() {`
- `method` **build (_RemoteHomeScreenState)** — baris 1921 — `  Widget build(BuildContext context) {`
- `method` **_handleDestinationSelected (_RemoteHomeScreenState)** — baris 2163 — `  Future<void> _handleDestinationSelected(int index) async {`
- `getter` **_transportLabel (_RemoteHomeScreenState)** — baris 2201 — `  String get _transportLabel =>`
- `method` **_buildConnectionStatusStrip (_RemoteHomeScreenState)** — baris 2206 — `  Widget _buildConnectionStatusStrip(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_showConnectionSheet (_RemoteHomeScreenState)** — baris 2249 — `  void _showConnectionSheet() {`
- `method` **_buildDisconnectedBanner (_RemoteHomeScreenState)** — baris 2323 — `  Widget _buildDisconnectedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildContentTabBar (_RemoteHomeScreenState)** — baris 2350 — `  Widget _buildContentTabBar(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildUnsyncedBanner (_RemoteHomeScreenState)** — baris 2381 — `  Widget _buildUnsyncedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `class` **MasjidYouRemoteApp** — baris 2409 — `class MasjidYouRemoteApp extends StatefulWidget {`
- `method` **createState (MasjidYouRemoteApp)** — baris 2413 — `  State<MasjidYouRemoteApp> createState() => _MasjidYouRemoteAppState();`
- `class` **_MasjidYouRemoteAppState** — baris 2416 — `class _MasjidYouRemoteAppState extends State<MasjidYouRemoteApp> {`
- `field` **_themeMode (_MasjidYouRemoteAppState)** — baris 2417 — `  ThemeMode _themeMode = ThemeMode.system;`
- `field` **_colorSource (_MasjidYouRemoteAppState)** — baris 2418 — `  AppColorSource _colorSource = AppColorSource.dynamic;`
- `method` **initState (_MasjidYouRemoteAppState)** — baris 2421 — `  void initState() {`
- `method` **_loadThemePreferences (_MasjidYouRemoteAppState)** — baris 2426 — `  Future<void> _loadThemePreferences() async {`
- `method` **_setThemeMode (_MasjidYouRemoteAppState)** — baris 2436 — `  Future<void> _setThemeMode(ThemeMode mode) async {`
- `method` **_setColorSource (_MasjidYouRemoteAppState)** — baris 2441 — `  Future<void> _setColorSource(AppColorSource source) async {`
- `method` **build (_MasjidYouRemoteAppState)** — baris 2447 — `  Widget build(BuildContext context) {`
- `function` **main** — baris 2483 — `Future<void> main() async {`

### `apps/mobile_remote/lib/screens/connection/connection_gateway_screen.dart`
- `class` **ConnectionGatewayScreen** — baris 4 — `class ConnectionGatewayScreen extends StatelessWidget {`
- `field` **ipController (ConnectionGatewayScreen)** — baris 5 — `  final TextEditingController ipController;`
- `field` **isConnecting (ConnectionGatewayScreen)** — baris 6 — `  final bool isConnecting;`
- `field` **onConnectIp (ConnectionGatewayScreen)** — baris 7 — `  final VoidCallback onConnectIp;`
- `field` **btIsScanning (ConnectionGatewayScreen)** — baris 9 — `  final bool btIsScanning;`
- `field` **btDevices (ConnectionGatewayScreen)** — baris 10 — `  final List<BluetoothDeviceInfo> btDevices;`
- `field` **btKnownDevices (ConnectionGatewayScreen)** — baris 14 — `  final List<BluetoothDeviceInfo> btKnownDevices;`
- `field` **btStatus (ConnectionGatewayScreen)** — baris 15 — `  final String btStatus;`
- `field` **onBtStartScan (ConnectionGatewayScreen)** — baris 16 — `  final VoidCallback onBtStartScan;`
- `field` **onBtStopScan (ConnectionGatewayScreen)** — baris 17 — `  final VoidCallback onBtStopScan;`
- `field` **onBtConnect (ConnectionGatewayScreen)** — baris 18 — `  final ValueChanged<BluetoothDeviceInfo> onBtConnect;`
- `method` **build (ConnectionGatewayScreen)** — baris 35 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/background_images_subtab.dart`
- `class` **BackgroundImagesSubtab** — baris 26 — `class BackgroundImagesSubtab extends StatelessWidget {`
- `field` **images (BackgroundImagesSubtab)** — baris 27 — `  final List<BackgroundImage> images;`
- `field` **intervalController (BackgroundImagesSubtab)** — baris 36 — `  final TextEditingController intervalController;`
- `field` **sendUncompressed (BackgroundImagesSubtab)** — baris 39 — `  final bool sendUncompressed;`
- `field` **onSendUncompressedChanged (BackgroundImagesSubtab)** — baris 40 — `  final ValueChanged<bool> onSendUncompressedChanged;`
- `field` **sendProgress (BackgroundImagesSubtab)** — baris 44 — `  final double? sendProgress;`
- `method` **_openAddDialog (BackgroundImagesSubtab)** — baris 59 — `  void _openAddDialog(BuildContext context) {`
- `method` **build (BackgroundImagesSubtab)** — baris 69 — `  Widget build(BuildContext context) {`
- `class` **_AddBackgroundDialog** — baris 223 — `class _AddBackgroundDialog extends StatefulWidget {`
- `method` **createState (_AddBackgroundDialog)** — baris 229 — `  State<_AddBackgroundDialog> createState() => _AddBackgroundDialogState();`
- `class` **_AddBackgroundDialogState** — baris 232 — `class _AddBackgroundDialogState extends State<_AddBackgroundDialog> {`
- `field` **_selectedBase64Image (_AddBackgroundDialogState)** — baris 233 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_AddBackgroundDialogState)** — baris 234 — `  File? _imagePreviewFile;`
- `field` **_picker (_AddBackgroundDialogState)** — baris 235 — `  final ImagePicker _picker = ImagePicker();`
- `method` **_pickImage (_AddBackgroundDialogState)** — baris 237 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_AddBackgroundDialogState)** — baris 255 — `  void _clearImage() {`
- `method` **_save (_AddBackgroundDialogState)** — baris 262 — `  void _save() {`
- `method` **build (_AddBackgroundDialogState)** — baris 270 — `  Widget build(BuildContext context) {`
- `class` **_BackgroundThumbnail** — baris 361 — `class _BackgroundThumbnail extends StatefulWidget {`
- `field` **base64Image (_BackgroundThumbnail)** — baris 362 — `  final String base64Image;`
- `method` **createState (_BackgroundThumbnail)** — baris 367 — `  State<_BackgroundThumbnail> createState() => _BackgroundThumbnailState();`
- `class` **_BackgroundThumbnailState** — baris 370 — `class _BackgroundThumbnailState extends State<_BackgroundThumbnail> {`
- `field` **_cachedImageBytes (_BackgroundThumbnailState)** — baris 371 — `  Uint8List? _cachedImageBytes;`
- `method` **initState (_BackgroundThumbnailState)** — baris 374 — `  void initState() {`
- `method` **didUpdateWidget (_BackgroundThumbnailState)** — baris 380 — `  void didUpdateWidget(covariant _BackgroundThumbnail oldWidget) {`
- `method` **_decode (_BackgroundThumbnailState)** — baris 387 — `  void _decode() {`
- `method` **build (_BackgroundThumbnailState)** — baris 396 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/banners_subtab.dart`
- `class` **BannersSubtab** — baris 13 — `class BannersSubtab extends StatelessWidget {`
- `field` **banners (BannersSubtab)** — baris 14 — `  final List<MediaBanner> banners;`
- `field` **headerController (BannersSubtab)** — baris 15 — `  final TextEditingController headerController;`
- `field` **titleController (BannersSubtab)** — baris 16 — `  final TextEditingController titleController;`
- `field` **contentController (BannersSubtab)** — baris 17 — `  final TextEditingController contentController;`
- `field` **footerController (BannersSubtab)** — baris 18 — `  final TextEditingController footerController;`
- `method` **_openAddDialog (BannersSubtab)** — baris 41 — `  void _openAddDialog(BuildContext context) {`
- `method` **build (BannersSubtab)** — baris 57 — `  Widget build(BuildContext context) {`
- `class` **_AddBannerDialog** — baris 170 — `class _AddBannerDialog extends StatefulWidget {`
- `field` **headerController (_AddBannerDialog)** — baris 179 — `  final TextEditingController headerController;`
- `field` **titleController (_AddBannerDialog)** — baris 180 — `  final TextEditingController titleController;`
- `field` **contentController (_AddBannerDialog)** — baris 181 — `  final TextEditingController contentController;`
- `field` **footerController (_AddBannerDialog)** — baris 182 — `  final TextEditingController footerController;`
- `method` **createState (_AddBannerDialog)** — baris 186 — `  State<_AddBannerDialog> createState() => _AddBannerDialogState();`
- `class` **_AddBannerDialogState** — baris 189 — `class _AddBannerDialogState extends State<_AddBannerDialog> {`
- `field` **_selectedBase64Image (_AddBannerDialogState)** — baris 190 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_AddBannerDialogState)** — baris 191 — `  File? _imagePreviewFile;`
- `field` **_picker (_AddBannerDialogState)** — baris 192 — `  final ImagePicker _picker = ImagePicker();`
- `method` **_pickImage (_AddBannerDialogState)** — baris 194 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_AddBannerDialogState)** — baris 214 — `  void _clearImage() {`
- `method` **_save (_AddBannerDialogState)** — baris 221 — `  void _save() {`
- `method` **build (_AddBannerDialogState)** — baris 227 — `  Widget build(BuildContext context) {`
- `class` **_BannerThumbnail** — baris 351 — `class _BannerThumbnail extends StatefulWidget {`
- `field` **base64Image (_BannerThumbnail)** — baris 352 — `  final String base64Image;`
- `method` **createState (_BannerThumbnail)** — baris 357 — `  State<_BannerThumbnail> createState() => _BannerThumbnailState();`
- `class` **_BannerThumbnailState** — baris 360 — `class _BannerThumbnailState extends State<_BannerThumbnail> {`
- `field` **_cachedImageBytes (_BannerThumbnailState)** — baris 361 — `  late Uint8List _cachedImageBytes;`
- `method` **initState (_BannerThumbnailState)** — baris 364 — `  void initState() {`
- `method` **didUpdateWidget (_BannerThumbnailState)** — baris 370 — `  void didUpdateWidget(covariant _BannerThumbnail oldWidget) {`
- `method` **build (_BannerThumbnailState)** — baris 378 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/kas_subtab.dart`
- `class` **KasSubtab** — baris 12 — `class KasSubtab extends StatelessWidget {`
- `field` **transactions (KasSubtab)** — baris 13 — `  final List<KasTransaction> transactions;`
- `field` **amountController (KasSubtab)** — baris 14 — `  final TextEditingController amountController;`
- `field` **descriptionController (KasSubtab)** — baris 15 — `  final TextEditingController descriptionController;`
- `field` **kasType (KasSubtab)** — baris 16 — `  final KasType kasType;`
- `field` **onAddTransaction (KasSubtab)** — baris 18 — `  final VoidCallback onAddTransaction;`
- `method` **_openAddDialog (KasSubtab)** — baris 32 — `  void _openAddDialog(BuildContext context) {`
- `method` **build (KasSubtab)** — baris 48 — `  Widget build(BuildContext context) {`
- `class` **_AddKasDialog** — baris 173 — `class _AddKasDialog extends StatefulWidget {`
- `field` **amountController (_AddKasDialog)** — baris 182 — `  final TextEditingController amountController;`
- `field` **descriptionController (_AddKasDialog)** — baris 183 — `  final TextEditingController descriptionController;`
- `field` **kasType (_AddKasDialog)** — baris 184 — `  final KasType kasType;`
- `field` **onTypeChanged (_AddKasDialog)** — baris 185 — `  final ValueChanged<KasType> onTypeChanged;`
- `field` **onAddTransaction (_AddKasDialog)** — baris 186 — `  final VoidCallback onAddTransaction;`
- `method` **createState (_AddKasDialog)** — baris 189 — `  State<_AddKasDialog> createState() => _AddKasDialogState();`
- `class` **_AddKasDialogState** — baris 192 — `class _AddKasDialogState extends State<_AddKasDialog> {`
- `field` **_type (_AddKasDialogState)** — baris 193 — `  late KasType _type;`
- `method` **initState (_AddKasDialogState)** — baris 196 — `  void initState() {`
- `method` **_canSave (_AddKasDialogState)** — baris 201 — `  bool _canSave(String amountText, String descriptionText) {`
- `method` **_save (_AddKasDialogState)** — baris 206 — `  void _save() {`
- `method` **build (_AddKasDialogState)** — baris 213 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/running_text_subtab.dart`
- `class` **RunningTextSubtab** — baris 9 — `class RunningTextSubtab extends StatelessWidget {`
- `field` **runningTexts (RunningTextSubtab)** — baris 10 — `  final List<RunningTextMessage> runningTexts;`
- `field` **runningTextController (RunningTextSubtab)** — baris 11 — `  final TextEditingController runningTextController;`
- `field` **selectedCategory (RunningTextSubtab)** — baris 12 — `  final String selectedCategory;`
- `field` **categories (RunningTextSubtab)** — baris 13 — `  final List<String> categories;`
- `field` **onAddMessage (RunningTextSubtab)** — baris 15 — `  final VoidCallback onAddMessage;`
- `method` **_openAddDialog (RunningTextSubtab)** — baris 35 — `  void _openAddDialog(BuildContext context) {`
- `method` **build (RunningTextSubtab)** — baris 52 — `  Widget build(BuildContext context) {`
- `class` **_OrderNumber** — baris 113 — `class _OrderNumber extends StatelessWidget {`
- `constructor` **_OrderNumber (_OrderNumber)** — baris 114 — `  const _OrderNumber(this.number);`
- `field` **number (_OrderNumber)** — baris 116 — `  final int number;`
- `method` **build (_OrderNumber)** — baris 119 — `  Widget build(BuildContext context) {`
- `class` **RunningTextFormDialog** — baris 144 — `class RunningTextFormDialog extends StatefulWidget {`
- `field` **title (RunningTextFormDialog)** — baris 155 — `  final String title;`
- `field` **textController (RunningTextFormDialog)** — baris 156 — `  final TextEditingController textController;`
- `field` **category (RunningTextFormDialog)** — baris 157 — `  final String category;`
- `field` **categories (RunningTextFormDialog)** — baris 158 — `  final List<String> categories;`
- `field` **onCategoryChanged (RunningTextFormDialog)** — baris 159 — `  final ValueChanged<String> onCategoryChanged;`
- `field` **onSave (RunningTextFormDialog)** — baris 160 — `  final VoidCallback onSave;`
- `method` **createState (RunningTextFormDialog)** — baris 163 — `  State<RunningTextFormDialog> createState() => RunningTextFormDialogState();`
- `class` **RunningTextFormDialogState** — baris 166 — `class RunningTextFormDialogState extends State<RunningTextFormDialog> {`
- `field` **_category (RunningTextFormDialogState)** — baris 167 — `  late String _category;`
- `method` **initState (RunningTextFormDialogState)** — baris 170 — `  void initState() {`
- `method` **_save (RunningTextFormDialogState)** — baris 175 — `  void _save() {`
- `method` **build (RunningTextFormDialogState)** — baris 182 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/special_images_subtab.dart`
- `class` **SpecialImagesSubtab** — baris 18 — `class SpecialImagesSubtab extends StatelessWidget {`
- `field` **images (SpecialImagesSubtab)** — baris 19 — `  final List<SpecialImage> images;`
- `method` **_openAddDialog (SpecialImagesSubtab)** — baris 36 — `  void _openAddDialog(BuildContext context) {`
- `method` **build (SpecialImagesSubtab)** — baris 46 — `  Widget build(BuildContext context) {`
- `class` **_AddImageDialog** — baris 150 — `class _AddImageDialog extends StatefulWidget {`
- `method` **createState (_AddImageDialog)** — baris 156 — `  State<_AddImageDialog> createState() => _AddImageDialogState();`
- `class` **_AddImageDialogState** — baris 159 — `class _AddImageDialogState extends State<_AddImageDialog> {`
- `field` **_captionController (_AddImageDialogState)** — baris 160 — `  final _captionController = TextEditingController();`
- `field` **_selectedBase64Image (_AddImageDialogState)** — baris 161 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_AddImageDialogState)** — baris 162 — `  File? _imagePreviewFile;`
- `field` **_picker (_AddImageDialogState)** — baris 163 — `  final ImagePicker _picker = ImagePicker();`
- `method` **dispose (_AddImageDialogState)** — baris 166 — `  void dispose() {`
- `method` **_pickImage (_AddImageDialogState)** — baris 171 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_AddImageDialogState)** — baris 191 — `  void _clearImage() {`
- `method` **_save (_AddImageDialogState)** — baris 198 — `  void _save() {`
- `method` **build (_AddImageDialogState)** — baris 206 — `  Widget build(BuildContext context) {`
- `class` **_SpecialImageThumbnail** — baris 305 — `class _SpecialImageThumbnail extends StatefulWidget {`
- `field` **base64Image (_SpecialImageThumbnail)** — baris 306 — `  final String base64Image;`
- `method` **createState (_SpecialImageThumbnail)** — baris 311 — `  State<_SpecialImageThumbnail> createState() => _SpecialImageThumbnailState();`
- `class` **_SpecialImageThumbnailState** — baris 314 — `class _SpecialImageThumbnailState extends State<_SpecialImageThumbnail> {`
- `field` **_cachedImageBytes (_SpecialImageThumbnailState)** — baris 315 — `  Uint8List? _cachedImageBytes;`
- `method` **initState (_SpecialImageThumbnailState)** — baris 318 — `  void initState() {`
- `method` **didUpdateWidget (_SpecialImageThumbnailState)** — baris 324 — `  void didUpdateWidget(covariant _SpecialImageThumbnail oldWidget) {`
- `method` **_decode (_SpecialImageThumbnailState)** — baris 331 — `  void _decode() {`
- `method` **build (_SpecialImageThumbnailState)** — baris 340 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/home/home_tab.dart`
- `function` **tvPhaseLabel** — baris 10 — `String tvPhaseLabel(PrayerPhase phase) => switch (phase) {`
- `function` **formatTanggalId** — baris 46 — `String formatTanggalId(DateTime date) =>`
- `function` **_dua** — baris 49 — `String _dua(int n) => n.toString().padLeft(2, '0');`
- `function` **formatJam** — baris 52 — `String formatJam(DateTime time) =>`
- `function` **formatHitungMundur** — baris 56 — `String formatHitungMundur(Duration duration) {`
- `class` **HomeTab** — baris 77 — `class HomeTab extends StatefulWidget {`
- `field` **mosqueName (HomeTab)** — baris 93 — `  final String mosqueName;`
- `field` **transportLabel (HomeTab)** — baris 94 — `  final String transportLabel;`
- `field` **tvPhase (HomeTab)** — baris 95 — `  final PrayerPhase tvPhase;`
- `field` **tvMuted (HomeTab)** — baris 96 — `  final bool tvMuted;`
- `field` **tvStandby (HomeTab)** — baris 97 — `  final bool tvStandby;`
- `field` **config (HomeTab)** — baris 98 — `  final MosqueConfig config;`
- `field` **totalKasMasuk (HomeTab)** — baris 99 — `  final int totalKasMasuk;`
- `field` **totalKasKeluar (HomeTab)** — baris 100 — `  final int totalKasKeluar;`
- `field` **onToggleMuted (HomeTab)** — baris 101 — `  final VoidCallback onToggleMuted;`
- `field` **onToggleStandby (HomeTab)** — baris 102 — `  final VoidCallback onToggleStandby;`
- `field` **onSyncNow (HomeTab)** — baris 103 — `  final VoidCallback onSyncNow;`
- `method` **createState (HomeTab)** — baris 106 — `  State<HomeTab> createState() => _HomeTabState();`
- `class` **_HomeTabState** — baris 109 — `class _HomeTabState extends State<HomeTab> {`
- `field` **_now (_HomeTabState)** — baris 110 — `  late DateTime _now;`
- `field` **_ticker (_HomeTabState)** — baris 111 — `  Timer? _ticker;`
- `method` **initState (_HomeTabState)** — baris 115 — `  void initState() {`
- `method` **didUpdateWidget (_HomeTabState)** — baris 131 — `  void didUpdateWidget(HomeTab oldWidget) {`
- `method` **dispose (_HomeTabState)** — baris 139 — `  void dispose() {`
- `method` **build (_HomeTabState)** — baris 145 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/settings/settings_tab.dart`
- `class` **SettingsTab** — baris 13 — `class SettingsTab extends StatelessWidget {`
- `field` **config (SettingsTab)** — baris 14 — `  final MosqueConfig config;`
- `field` **nameController (SettingsTab)** — baris 15 — `  final TextEditingController nameController;`
- `field` **addressController (SettingsTab)** — baris 16 — `  final TextEditingController addressController;`
- `field` **latitudeController (SettingsTab)** — baris 17 — `  final TextEditingController latitudeController;`
- `field` **longitudeController (SettingsTab)** — baris 18 — `  final TextEditingController longitudeController;`
- `field` **prayerOffsetControllers (SettingsTab)** — baris 19 — `  final Map<PrayerType, TextEditingController> prayerOffsetControllers;`
- `field` **preAdhanController (SettingsTab)** — baris 20 — `  final TextEditingController preAdhanController;`
- `field` **adhanController (SettingsTab)** — baris 21 — `  final TextEditingController adhanController;`
- `field` **preIqomahController (SettingsTab)** — baris 22 — `  final TextEditingController preIqomahController;`
- `field` **shalatController (SettingsTab)** — baris 23 — `  final TextEditingController shalatController;`
- `field` **khutbahController (SettingsTab)** — baris 24 — `  final TextEditingController khutbahController;`
- `field` **fridayKhatibController (SettingsTab)** — baris 25 — `  final TextEditingController fridayKhatibController;`
- `field` **fridayMuadzinController (SettingsTab)** — baris 26 — `  final TextEditingController fridayMuadzinController;`
- `field` **showKas (SettingsTab)** — baris 29 — `  final bool showKas;`
- `field` **hasFridayPrayer (SettingsTab)** — baris 32 — `  final bool hasFridayPrayer;`
- `field` **onShowKasChanged (SettingsTab)** — baris 33 — `  final ValueChanged<bool> onShowKasChanged;`
- `field` **onHasFridayPrayerChanged (SettingsTab)** — baris 34 — `  final ValueChanged<bool> onHasFridayPrayerChanged;`
- `field` **isFetchingLocation (SettingsTab)** — baris 35 — `  final bool isFetchingLocation;`
- `field` **isConnected (SettingsTab)** — baris 36 — `  final bool isConnected;`
- `field` **tvPhase (SettingsTab)** — baris 37 — `  final PrayerPhase tvPhase;`
- `field` **onFetchLocation (SettingsTab)** — baris 38 — `  final VoidRefCallback onFetchLocation;`
- `field` **onSaveConfig (SettingsTab)** — baris 39 — `  final VoidRefCallback onSaveConfig;`
- `field` **onExportBackup (SettingsTab)** — baris 42 — `  final VoidRefCallback onExportBackup;`
- `field` **onImportBackup (SettingsTab)** — baris 43 — `  final VoidRefCallback onImportBackup;`
- `field` **themeMode (SettingsTab)** — baris 46 — `  final ThemeMode themeMode;`
- `field` **colorSource (SettingsTab)** — baris 47 — `  final AppColorSource colorSource;`
- `field` **onThemeModeChanged (SettingsTab)** — baris 48 — `  final ValueChanged<ThemeMode>? onThemeModeChanged;`
- `field` **onColorSourceChanged (SettingsTab)** — baris 49 — `  final ValueChanged<AppColorSource>? onColorSourceChanged;`
- `field` **isDirty (SettingsTab)** — baris 55 — `  final bool isDirty;`
- `field` **logoBytes (SettingsTab)** — baris 61 — `  final Uint8List? logoBytes;`
- `field` **logoSendProgress (SettingsTab)** — baris 65 — `  final double? logoSendProgress;`
- `field` **onPickLogo (SettingsTab)** — baris 66 — `  final VoidRefCallback? onPickLogo;`
- `field` **onRemoveLogo (SettingsTab)** — baris 67 — `  final VoidRefCallback? onRemoveLogo;`
- `method` **build (SettingsTab)** — baris 109 — `  Widget build(BuildContext context) {`
- `method` **_buildStickySaveBar (SettingsTab)** — baris 531 — `  Widget _buildStickySaveBar(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildQuickActionsCard (SettingsTab)** — baris 581 — `  Widget _buildQuickActionsCard(ThemeData theme, ColorScheme colorScheme) {`
- `class` **_SettingsGroup** — baris 633 — `class _SettingsGroup extends StatelessWidget {`
- `field` **title (_SettingsGroup)** — baris 640 — `  final String title;`
- `field` **children (_SettingsGroup)** — baris 641 — `  final List<Widget> children;`
- `field` **footer (_SettingsGroup)** — baris 642 — `  final String? footer;`
- `method` **build (_SettingsGroup)** — baris 645 — `  Widget build(BuildContext context) {`
- `typedef` **VoidRefCallback** — baris 672 — `typedef VoidRefCallback = void Function();`

### `apps/mobile_remote/lib/screens/simulation/schedule_simulation_dialog.dart`
- `class` **ScheduleSimulationDialog** — baris 18 — `class ScheduleSimulationDialog extends StatefulWidget {`
- `field` **config (ScheduleSimulationDialog)** — baris 20 — `  final MosqueConfig config;`
- `field` **hasFridayPrayer (ScheduleSimulationDialog)** — baris 23 — `  final bool hasFridayPrayer;`
- `field` **initialDateTime (ScheduleSimulationDialog)** — baris 27 — `  final DateTime? initialDateTime;`
- `method` **createState (ScheduleSimulationDialog)** — baris 37 — `  State<ScheduleSimulationDialog> createState() =>`
- `method` **_ScheduleSimulationDialogState (ScheduleSimulationDialog)** — baris 38 — `      _ScheduleSimulationDialogState();`
- `class` **_ScheduleSimulationDialogState** — baris 41 — `class _ScheduleSimulationDialogState extends State<ScheduleSimulationDialog> {`
- `field` **_simDateTime (_ScheduleSimulationDialogState)** — baris 42 — `  late DateTime _simDateTime;`
- `method` **initState (_ScheduleSimulationDialogState)** — baris 45 — `  void initState() {`
- `method` **build (_ScheduleSimulationDialogState)** — baris 51 — `  Widget build(BuildContext context) {`
- `method` **_formatDurationShort (_ScheduleSimulationDialogState)** — baris 177 — `  String _formatDurationShort(Duration? duration) {`

### `apps/mobile_remote/lib/screens/simulation/simulation_tab.dart`
- `class` **SimulationTab** — baris 4 — `class SimulationTab extends StatelessWidget {`
- `field` **isConnected (SimulationTab)** — baris 5 — `  final bool isConnected;`
- `field` **tvPhase (SimulationTab)** — baris 6 — `  final PrayerPhase tvPhase;`
- `method` **build (SimulationTab)** — baris 17 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/services/background_send_service.dart`
- `enum` **BackgroundSendTransport** — baris 9 — `enum BackgroundSendTransport { bluetooth, websocket }`
- `function` **compressBackgroundImageBytes** — baris 40 — `Uint8List compressBackgroundImageBytes(Uint8List bytes) {`
- `function` **compressBackgroundBase64** — baris 65 — `String compressBackgroundBase64(String base64Image) {`
- `function` **compressedBackgroundPacket** — baris 78 — `SyncPacket compressedBackgroundPacket(SyncPacket packet) {`
- `class` **BackgroundSendPreferences** — baris 105 — `class BackgroundSendPreferences {`
- `field` **sendUncompressedKey (BackgroundSendPreferences)** — baris 108 — `  static const String sendUncompressedKey = 'bg_send_uncompressed';`
- `method` **loadSendUncompressed (BackgroundSendPreferences)** — baris 110 — `  static Future<bool> loadSendUncompressed() async {`
- `method` **saveSendUncompressed (BackgroundSendPreferences)** — baris 119 — `  static Future<void> saveSendUncompressed(bool value) async {`

### `apps/mobile_remote/lib/services/backup_service.dart`
- `class` **BackupImportResult** — baris 12 — `class BackupImportResult {`
- `field` **success (BackupImportResult)** — baris 13 — `  final bool success;`
- `field` **bundle (BackupImportResult)** — baris 14 — `  final BackupBundle? bundle;`
- `field` **errorMessage (BackupImportResult)** — baris 15 — `  final String? errorMessage;`
- `class` **BackupService** — baris 37 — `class BackupService {`
- `method` **importFromFile (BackupService)** — baris 87 — `  Future<BackupImportResult> importFromFile() async {`
- `method` **_slugify (BackupService)** — baris 179 — `  String _slugify(String name) {`

### `apps/mobile_remote/lib/services/bluetooth_client_service.dart`
- `enum` **BluetoothClientStatus** — baris 10 — `enum BluetoothClientStatus {`
- `class` **BluetoothClientState** — baris 20 — `class BluetoothClientState {`
- `field` **status (BluetoothClientState)** — baris 21 — `  final BluetoothClientStatus status;`
- `field` **isScanning (BluetoothClientState)** — baris 22 — `  final bool isScanning;`
- `field` **isConnected (BluetoothClientState)** — baris 23 — `  final bool isConnected;`
- `field` **devices (BluetoothClientState)** — baris 24 — `  final List<BluetoothDeviceInfo> devices;`
- `field` **knownDevices (BluetoothClientState)** — baris 28 — `  final List<BluetoothDeviceInfo> knownDevices;`
- `field` **peerName (BluetoothClientState)** — baris 29 — `  final String? peerName;`
- `field` **error (BluetoothClientState)** — baris 30 — `  final String? error;`
- `class` **BluetoothClientService** — baris 48 — `class BluetoothClientService {`
- `field` **maxReconnectAttempts (BluetoothClientService)** — baris 50 — `  final int maxReconnectAttempts;`
- `field` **reconnectDelay (BluetoothClientService)** — baris 53 — `  final Duration reconnectDelay;`
- `field` **_stateController (BluetoothClientService)** — baris 55 — `  final _stateController = StreamController<BluetoothClientState>.broadcast();`
- `field` **_subscription (BluetoothClientService)** — baris 56 — `  StreamSubscription<BluetoothSyncEvent>? _subscription;`
- `field` **_reconnectTimer (BluetoothClientService)** — baris 57 — `  Timer? _reconnectTimer;`
- `field` **_connectWatchdog (BluetoothClientService)** — baris 58 — `  Timer? _connectWatchdog;`
- `field` **_discovering (BluetoothClientService)** — baris 59 — `  bool _discovering = false;`
- `field` **_connected (BluetoothClientService)** — baris 60 — `  bool _connected = false;`
- `field` **_connecting (BluetoothClientService)** — baris 61 — `  bool _connecting = false;`
- `field` **_reconnecting (BluetoothClientService)** — baris 62 — `  bool _reconnecting = false;`
- `field` **_disposed (BluetoothClientService)** — baris 63 — `  bool _disposed = false;`
- `field` **_reconnectAttempts (BluetoothClientService)** — baris 64 — `  int _reconnectAttempts = 0;`
- `field` **_devices (BluetoothClientService)** — baris 65 — `  List<BluetoothDeviceInfo> _devices = const [];`
- `field` **_knownDevices (BluetoothClientService)** — baris 66 — `  List<BluetoothDeviceInfo> _knownDevices = const [];`
- `field` **_peerName (BluetoothClientService)** — baris 67 — `  String? _peerName;`
- `field` **_error (BluetoothClientService)** — baris 68 — `  String? _error;`
- `field` **_pendingNonce (BluetoothClientService)** — baris 71 — `  String? _pendingNonce;`
- `field` **_authenticated (BluetoothClientService)** — baris 74 — `  bool _authenticated = false;`
- `field` **_lastDevice (BluetoothClientService)** — baris 91 — `  BluetoothDeviceInfo? _lastDevice;`
- `getter` **currentState (BluetoothClientService)** — baris 98 — `  BluetoothClientState get currentState => BluetoothClientState(`
- `getter` **stateStream (BluetoothClientService)** — baris 108 — `  Stream<BluetoothClientState> get stateStream => _stateController.stream;`
- `getter` **isConnected (BluetoothClientService)** — baris 110 — `  bool get isConnected => _connected;`
- `getter` **isAuthenticated (BluetoothClientService)** — baris 113 — `  bool get isAuthenticated => _authenticated;`
- `method` **shouldDisconnectBluetoothOnLifecycle (BluetoothClientService)** — baris 121 — `  static bool shouldDisconnectBluetoothOnLifecycle(AppLifecycleState state) {`
- `method` **_statusFromFlags (BluetoothClientService)** — baris 125 — `  BluetoothClientStatus _statusFromFlags() {`
- `method` **_emit (BluetoothClientService)** — baris 134 — `  void _emit() {`
- `method` **_setError (BluetoothClientService)** — baris 139 — `  void _setError(String message) {`
- `method` **startDiscovery (BluetoothClientService)** — baris 146 — `  Future<void> startDiscovery() async {`
- `method` **stopDiscovery (BluetoothClientService)** — baris 181 — `  Future<void> stopDiscovery() async {`
- `method` **refreshKnownDevices (BluetoothClientService)** — baris 195 — `  Future<void> refreshKnownDevices() async {`
- `method` **handleAppLifecycleState (BluetoothClientService)** — baris 207 — `  Future<void> handleAppLifecycleState(AppLifecycleState state) async {`
- `method` **connectTo (BluetoothClientService)** — baris 214 — `  Future<void> connectTo(BluetoothDeviceInfo device) async {`
- `method` **sendPacket (BluetoothClientService)** — baris 266 — `  Future<void> sendPacket(SyncPacket packet) async {`
- `method` **_handlePacket (BluetoothClientService)** — baris 281 — `  void _handlePacket(SyncPacket packet) {`
- `method` **respondWithPin (BluetoothClientService)** — baris 312 — `  Future<void> respondWithPin(String pin) async {`
- `method` **cancelAuth (BluetoothClientService)** — baris 333 — `  Future<void> cancelAuth() async {`
- `method` **_onEvent (BluetoothClientService)** — baris 338 — `  void _onEvent(BluetoothSyncEvent event) {`
- `method` **_handleDisconnected (BluetoothClientService)** — baris 428 — `  void _handleDisconnected() {`
- `method` **_attemptReconnect (BluetoothClientService)** — baris 477 — `  Future<void> _attemptReconnect() async {`
- `method` **_cancelReconnect (BluetoothClientService)** — baris 494 — `  void _cancelReconnect() {`
- `method` **_cancelReconnectTimer (BluetoothClientService)** — baris 499 — `  void _cancelReconnectTimer() {`
- `method` **_subscribeEvents (BluetoothClientService)** — baris 504 — `  void _subscribeEvents() {`
- `method` **disconnect (BluetoothClientService)** — baris 514 — `  Future<void> disconnect() async {`
- `method` **dispose (BluetoothClientService)** — baris 534 — `  Future<void> dispose() async {`

### `apps/mobile_remote/lib/services/gps_location_service.dart`
- `enum` **GpsLocationStatus** — baris 17 — `enum GpsLocationStatus {`
- `class` **GpsLocationResult** — baris 40 — `class GpsLocationResult {`
- `field` **status (GpsLocationResult)** — baris 43 — `  final GpsLocationStatus status;`
- `field` **latitude (GpsLocationResult)** — baris 44 — `  final double? latitude;`
- `field` **longitude (GpsLocationResult)** — baris 45 — `  final double? longitude;`
- `getter` **hasCoordinates (GpsLocationResult)** — baris 48 — `  bool get hasCoordinates =>`
- `typedef` **GpsServiceEnabledCheck** — baris 53 — `typedef GpsServiceEnabledCheck = Future<bool> Function();`
- `typedef` **GpsPermissionCheck** — baris 54 — `typedef GpsPermissionCheck = Future<LocationPermission> Function();`
- `typedef` **GpsCurrentPositionFetch** — baris 55 — `typedef GpsCurrentPositionFetch = Future<Position> Function();`
- `typedef` **GpsLastKnownPositionFetch** — baris 56 — `typedef GpsLastKnownPositionFetch = Future<Position?> Function();`
- `class` **GpsLocationService** — baris 70 — `class GpsLocationService {`
- `field` **_isServiceEnabled (GpsLocationService)** — baris 92 — `  final GpsServiceEnabledCheck _isServiceEnabled;`
- `field` **_checkPermission (GpsLocationService)** — baris 93 — `  final GpsPermissionCheck _checkPermission;`
- `field` **_requestPermission (GpsLocationService)** — baris 94 — `  final GpsPermissionCheck _requestPermission;`
- `field` **_getCurrentPosition (GpsLocationService)** — baris 95 — `  final GpsCurrentPositionFetch _getCurrentPosition;`
- `field` **_getLastKnownPosition (GpsLocationService)** — baris 96 — `  final GpsLastKnownPositionFetch _getLastKnownPosition;`
- `method` **fetchCoordinates (GpsLocationService)** — baris 100 — `  Future<GpsLocationResult> fetchCoordinates() async {`

### `apps/mobile_remote/lib/services/logo_send_service.dart`
- `function` **prepareLogoBytesForBluetooth** — baris 30 — `Uint8List prepareLogoBytesForBluetooth(Uint8List bytes) {`
- `function` **prepareLogoBase64ForBluetooth** — baris 52 — `String prepareLogoBase64ForBluetooth(String base64Image) {`
- `function` **compressedLogoPacket** — baris 65 — `SyncPacket compressedLogoPacket(SyncPacket packet) {`

### `apps/mobile_remote/lib/services/remote_cache_store.dart`
- `class` **RemoteCacheStore** — baris 12 — `class RemoteCacheStore {`
- `field` **snapshotKey (RemoteCacheStore)** — baris 13 — `  static const String snapshotKey = 'remote_cache_snapshot';`
- `method` **load (RemoteCacheStore)** — baris 16 — `  Future<StateSnapshot?> load() async {`
- `method` **save (RemoteCacheStore)** — baris 33 — `  Future<void> save(StateSnapshot snapshot) async {`

### `apps/mobile_remote/lib/services/ws_client.dart`
- `class` **RemoteWsClient** — baris 6 — `class RemoteWsClient {`
- `field` **_channel (RemoteWsClient)** — baris 7 — `  WebSocketChannel? _channel;`
- `field` **_isConnected (RemoteWsClient)** — baris 8 — `  bool _isConnected = false;`
- `getter` **isConnected (RemoteWsClient)** — baris 24 — `  bool get isConnected => _isConnected;`
- `field` **_ipv4 (RemoteWsClient)** — baris 26 — `  static final RegExp _ipv4 = RegExp(`
- `method` **isValidIp (RemoteWsClient)** — baris 31 — `  static bool isValidIp(String ipAddress) => _ipv4.hasMatch(ipAddress);`
- `method` **_disconnectChannel (RemoteWsClient)** — baris 78 — `  void _disconnectChannel() {`
- `method` **sendPacket (RemoteWsClient)** — baris 84 — `  void sendPacket(SyncPacket packet) {`
- `method` **sendConfigUpdate (RemoteWsClient)** — baris 93 — `  void sendConfigUpdate(MosqueConfig config) {`
- `method` **sendRunningTextsUpdate (RemoteWsClient)** — baris 100 — `  void sendRunningTextsUpdate(List<RunningTextMessage> messages) {`
- `method` **sendBannersUpdate (RemoteWsClient)** — baris 109 — `  void sendBannersUpdate(List<MediaBanner> banners) {`
- `method` **sendSideImagesUpdate (RemoteWsClient)** — baris 118 — `  void sendSideImagesUpdate(List<SpecialImage> images) {`
- `method` **sendBackgroundImagesUpdate (RemoteWsClient)** — baris 130 — `  void sendBackgroundImagesUpdate(List<BackgroundImage> images) {`
- `method` **sendLogoUpdate (RemoteWsClient)** — baris 143 — `  void sendLogoUpdate(String? logoBase64) {`
- `method` **sendKasUpdate (RemoteWsClient)** — baris 152 — `  void sendKasUpdate(List<KasTransaction> transactions) {`
- `method` **sendSkipAdhan (RemoteWsClient)** — baris 162 — `  void sendSkipAdhan() {`
- `method` **sendStartShalat (RemoteWsClient)** — baris 167 — `  void sendStartShalat() {`
- `method` **sendStartIqomah (RemoteWsClient)** — baris 172 — `  void sendStartIqomah() {`
- `method` **sendFinishShalat (RemoteWsClient)** — baris 177 — `  void sendFinishShalat() {`
- `method` **sendSetMuted (RemoteWsClient)** — baris 182 — `  void sendSetMuted(bool muted) {`
- `method` **sendSetStandby (RemoteWsClient)** — baris 190 — `  void sendSetStandby(bool standby) {`
- `method` **sendForcePhase (RemoteWsClient)** — baris 198 — `  void sendForcePhase(PrayerPhase phase) {`
- `method` **disconnect (RemoteWsClient)** — baris 205 — `  void disconnect() {`

### `apps/mobile_remote/lib/theme/remote_theme.dart`
- `function` **masjidSeedScheme** — baris 10 — `ColorScheme masjidSeedScheme(Brightness brightness) {`
- `function` **buildRemoteTheme** — baris 42 — `ThemeData buildRemoteTheme(ColorScheme scheme) {`

### `apps/mobile_remote/lib/theme/theme_preferences.dart`
- `enum` **AppColorSource** — baris 5 — `enum AppColorSource {`
- `class` **ThemePreferences** — baris 19 — `class ThemePreferences {`
- `field` **modeKey (ThemePreferences)** — baris 22 — `  static const String modeKey = 'theme_mode_preference';`
- `field` **colorSourceKey (ThemePreferences)** — baris 23 — `  static const String colorSourceKey = 'color_source_preference';`
- `method` **loadMode (ThemePreferences)** — baris 25 — `  static Future<ThemeMode> loadMode() async {`
- `method` **loadColorSource (ThemePreferences)** — baris 34 — `  static Future<AppColorSource> loadColorSource() async {`
- `method` **saveMode (ThemePreferences)** — baris 43 — `  static Future<void> saveMode(ThemeMode mode) async {`
- `method` **saveColorSource (ThemePreferences)** — baris 48 — `  static Future<void> saveColorSource(AppColorSource source) async {`

### `apps/mobile_remote/lib/widgets/editor_empty_state.dart`
- `class` **EditorEmptyState** — baris 6 — `class EditorEmptyState extends StatelessWidget {`
- `field` **icon (EditorEmptyState)** — baris 16 — `  final IconData icon;`
- `field` **title (EditorEmptyState)** — baris 17 — `  final String title;`
- `field` **message (EditorEmptyState)** — baris 18 — `  final String message;`
- `field` **actionLabel (EditorEmptyState)** — baris 19 — `  final String actionLabel;`
- `field` **onAction (EditorEmptyState)** — baris 20 — `  final VoidCallback onAction;`
- `method` **build (EditorEmptyState)** — baris 23 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/widgets/kas_stat_card.dart`
- `class` **KasStatCard** — baris 3 — `class KasStatCard extends StatelessWidget {`
- `field` **title (KasStatCard)** — baris 4 — `  final String title;`
- `field` **amount (KasStatCard)** — baris 5 — `  final String amount;`
- `field` **icon (KasStatCard)** — baris 6 — `  final IconData icon;`
- `field` **color (KasStatCard)** — baris 7 — `  final Color color;`
- `method` **build (KasStatCard)** — baris 18 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/widgets/stepper_row.dart`
- `class` **StepperRow** — baris 10 — `class StepperRow extends StatelessWidget {`
- `field` **label (StepperRow)** — baris 22 — `  final String label;`
- `field` **controller (StepperRow)** — baris 25 — `  final TextEditingController controller;`
- `field` **enabled (StepperRow)** — baris 28 — `  final bool enabled;`
- `field` **min (StepperRow)** — baris 31 — `  final int min;`
- `field` **max (StepperRow)** — baris 32 — `  final int max;`
- `field` **unit (StepperRow)** — baris 35 — `  final String unit;`
- `method` **_setValue (StepperRow)** — baris 37 — `  void _setValue(int value) {`
- `method` **build (StepperRow)** — baris 42 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/main.dart`
- `function` **main** — baris 27 — `void main() async {`
- `class` **MasjidYouTVApp** — baris 48 — `class MasjidYouTVApp extends StatelessWidget {`
- `method` **build (MasjidYouTVApp)** — baris 52 — `  Widget build(BuildContext context) {`
- `class` **MasjidDisplayScreen** — baris 62 — `class MasjidDisplayScreen extends StatefulWidget {`
- `field` **initialConfig (MasjidDisplayScreen)** — baris 70 — `  final MosqueConfig? initialConfig;`
- `field` **autoPrayerCycle (MasjidDisplayScreen)** — baris 73 — `  final bool autoPrayerCycle;`
- `method` **createState (MasjidDisplayScreen)** — baris 76 — `  State<MasjidDisplayScreen> createState() => _MasjidDisplayScreenState();`
- `class` **_MasjidDisplayScreenState** — baris 79 — `class _MasjidDisplayScreenState extends State<MasjidDisplayScreen> {`
- `field` **_now (_MasjidDisplayScreenState)** — baris 80 — `  DateTime _now = DateTime.now();`
- `field` **_clockTimer (_MasjidDisplayScreenState)** — baris 81 — `  Timer? _clockTimer;`
- `field` **_localServer (_MasjidDisplayScreenState)** — baris 82 — `  LocalServer? _localServer;`
- `field` **_btHost (_MasjidDisplayScreenState)** — baris 85 — `  BluetoothHostService? _btHost;`
- `field` **_btState (_MasjidDisplayScreenState)** — baris 86 — `  BluetoothHostState? _btState;`
- `field` **_btEnabled (_MasjidDisplayScreenState)** — baris 90 — `  bool _btEnabled = false;`
- `field` **_showAdminMenu (_MasjidDisplayScreenState)** — baris 93 — `  bool _showAdminMenu = false;`
- `field` **_localIp (_MasjidDisplayScreenState)** — baris 97 — `  String? _localIp;`
- `field` **_config (_MasjidDisplayScreenState)** — baris 99 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_prayerStateMachine (_MasjidDisplayScreenState)** — baris 106 — `  final PrayerStateMachine _prayerStateMachine = PrayerStateMachine();`
- `field` **_sideImages (_MasjidDisplayScreenState)** — baris 109 — `  List<SpecialImage> _sideImages = const [];`
- `field` **_backgroundImages (_MasjidDisplayScreenState)** — baris 112 — `  List<BackgroundImage> _backgroundImages = const [];`
- `field` **_mosqueLogoBase64 (_MasjidDisplayScreenState)** — baris 119 — `  String? _mosqueLogoBase64;`
- `field` **_mosqueLogoBytes (_MasjidDisplayScreenState)** — baris 120 — `  Uint8List? _mosqueLogoBytes;`
- `method` **_applyMosqueLogo (_MasjidDisplayScreenState)** — baris 124 — `  void _applyMosqueLogo(String? logoBase64) {`
- `field` **_chunkReassembler (_MasjidDisplayScreenState)** — baris 141 — `  final ChunkReassembler _chunkReassembler = ChunkReassembler();`
- `field` **_runningTexts (_MasjidDisplayScreenState)** — baris 143 — `  List<RunningTextMessage> _runningTexts = const [`
- `field` **_banners (_MasjidDisplayScreenState)** — baris 158 — `  List<MediaBanner> _banners = const [`
- `field` **_kasTransactions (_MasjidDisplayScreenState)** — baris 175 — `  List<KasTransaction> _kasTransactions = [`
- `field` **_prayerSchedule (_MasjidDisplayScreenState)** — baris 199 — `  late PrayerSchedule _prayerSchedule;`
- `field` **_store (_MasjidDisplayScreenState)** — baris 202 — `  final TvStore _store = TvStore();`
- `field` **_hasStoredData (_MasjidDisplayScreenState)** — baris 206 — `  bool _hasStoredData = false;`
- `field` **_muted (_MasjidDisplayScreenState)** — baris 210 — `  bool _muted = false;`
- `field` **_standby (_MasjidDisplayScreenState)** — baris 211 — `  bool _standby = false;`
- `method` **initState (_MasjidDisplayScreenState)** — baris 214 — `  void initState() {`
- `method` **_initFromStore (_MasjidDisplayScreenState)** — baris 246 — `  Future<void> _initFromStore() async {`
- `method` **_recalculateSchedule (_MasjidDisplayScreenState)** — baris 284 — `  void _recalculateSchedule() {`
- `method` **_initLocalServer (_MasjidDisplayScreenState)** — baris 288 — `  Future<void> _initLocalServer() async {`
- `method` **_handleSyncPacket (_MasjidDisplayScreenState)** — baris 301 — `  void _handleSyncPacket(SyncPacket packet) {`
- `field` **_btStateSub (_MasjidDisplayScreenState)** — baris 449 — `  StreamSubscription<BluetoothHostState>? _btStateSub;`
- `method` **_initBluetoothHost (_MasjidDisplayScreenState)** — baris 451 — `  Future<void> _initBluetoothHost() async {`
- `method` **_maybeRunIntroPairing (_MasjidDisplayScreenState)** — baris 483 — `  Future<void> _maybeRunIntroPairing() async {`
- `method` **_startPairingMode (_MasjidDisplayScreenState)** — baris 503 — `  Future<void> _startPairingMode() async {`
- `method` **_refreshLocalIp (_MasjidDisplayScreenState)** — baris 515 — `  Future<void> _refreshLocalIp() async {`
- `method` **_toggleBluetooth (_MasjidDisplayScreenState)** — baris 530 — `  Future<void> _toggleBluetooth(bool enable) async {`
- `method` **_broadcastSnapshot (_MasjidDisplayScreenState)** — baris 560 — `  void _broadcastSnapshot() {`
- `method` **_broadcastState (_MasjidDisplayScreenState)** — baris 579 — `  void _broadcastState() {`
- `method` **_handleTvRemoteKey (_MasjidDisplayScreenState)** — baris 602 — `  bool _handleTvRemoteKey(KeyEvent event) {`
- `method` **_onStateMachineChanged (_MasjidDisplayScreenState)** — baris 614 — `  void _onStateMachineChanged() {`
- `method` **dispose (_MasjidDisplayScreenState)** — baris 620 — `  void dispose() {`
- `method` **build (_MasjidDisplayScreenState)** — baris 633 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/server/bluetooth_host_service.dart`
- `enum` **BluetoothHostStatus** — baris 10 — `enum BluetoothHostStatus {`
- `class` **BluetoothHostState** — baris 17 — `class BluetoothHostState {`
- `field` **status (BluetoothHostState)** — baris 18 — `  final BluetoothHostStatus status;`
- `field` **peerName (BluetoothHostState)** — baris 19 — `  final String? peerName;`
- `field` **error (BluetoothHostState)** — baris 20 — `  final String? error;`
- `field` **authenticated (BluetoothHostState)** — baris 24 — `  final bool authenticated;`
- `field` **pairingActive (BluetoothHostState)** — baris 27 — `  final bool pairingActive;`
- `field` **pairingRemainingSeconds (BluetoothHostState)** — baris 30 — `  final int pairingRemainingSeconds;`
- `getter` **isActive (BluetoothHostState)** — baris 41 — `  bool get isActive => status == BluetoothHostStatus.connected;`
- `getter` **isAuthenticated (BluetoothHostState)** — baris 44 — `  bool get isAuthenticated => isActive && authenticated;`
- `class` **BluetoothHostService** — baris 51 — `class BluetoothHostService {`
- `field` **pairingSeconds (BluetoothHostService)** — baris 60 — `  final int pairingSeconds;`
- `field` **defaultPairingSeconds (BluetoothHostService)** — baris 63 — `  static const int defaultPairingSeconds = 300;`
- `field` **_stateController (BluetoothHostService)** — baris 65 — `  final _stateController = StreamController<BluetoothHostState>.broadcast();`
- `field` **_subscription (BluetoothHostService)** — baris 66 — `  StreamSubscription<BluetoothSyncEvent>? _subscription;`
- `field` **_started (BluetoothHostService)** — baris 67 — `  bool _started = false;`
- `field` **_connected (BluetoothHostService)** — baris 68 — `  bool _connected = false;`
- `field` **_peerName (BluetoothHostService)** — baris 69 — `  String? _peerName;`
- `field` **_pairingDeadline (BluetoothHostService)** — baris 72 — `  DateTime? _pairingDeadline;`
- `field` **_pairingTimer (BluetoothHostService)** — baris 75 — `  Timer? _pairingTimer;`
- `field` **_pairingRequestInFlight (BluetoothHostService)** — baris 76 — `  bool _pairingRequestInFlight = false;`
- `field` **_pin (BluetoothHostService)** — baris 80 — `  String? _pin;`
- `getter` **pin (BluetoothHostService)** — baris 81 — `  String? get pin => _pin;`
- `field` **_nonce (BluetoothHostService)** — baris 84 — `  String? _nonce;`
- `field` **_authenticated (BluetoothHostService)** — baris 87 — `  bool _authenticated = false;`
- `field` **_maxAuthAttempts (BluetoothHostService)** — baris 90 — `  static const int _maxAuthAttempts = 3;`
- `field` **_authAttempts (BluetoothHostService)** — baris 91 — `  int _authAttempts = 0;`
- `field` **_pinLength (BluetoothHostService)** — baris 94 — `  static const int _pinLength = 4;`
- `field` **_random (BluetoothHostService)** — baris 95 — `  final Random _random = Random.secure();`
- `field` **_currentState (BluetoothHostService)** — baris 102 — `  BluetoothHostState _currentState =`
- `method` **BluetoothHostState (BluetoothHostService)** — baris 103 — `      const BluetoothHostState(status: BluetoothHostStatus.idle);`
- `getter` **currentState (BluetoothHostService)** — baris 104 — `  BluetoothHostState get currentState => _currentState;`
- `getter` **stateStream (BluetoothHostService)** — baris 106 — `  Stream<BluetoothHostState> get stateStream => _stateController.stream;`
- `getter` **isRunning (BluetoothHostService)** — baris 108 — `  bool get isRunning => _started;`
- `getter` **isConnected (BluetoothHostService)** — baris 109 — `  bool get isConnected => _connected;`
- `getter` **pairingActive (BluetoothHostService)** — baris 112 — `  bool get pairingActive {`
- `getter` **pairingRemaining (BluetoothHostService)** — baris 118 — `  Duration get pairingRemaining {`
- `method` **_emit (BluetoothHostService)** — baris 125 — `  void _emit(BluetoothHostState state) {`
- `method` **start (BluetoothHostService)** — baris 147 — `  Future<void> start() async {`
- `method` **_requestPermission (BluetoothHostService)** — baris 200 — `  Future<bool> _requestPermission() async {`
- `method` **startPairingMode (BluetoothHostService)** — baris 220 — `  Future<bool> startPairingMode() async {`
- `method` **_onPairingWindowEnded (BluetoothHostService)** — baris 250 — `  void _onPairingWindowEnded() {`
- `method` **_clearPairing (BluetoothHostService)** — baris 256 — `  void _clearPairing() {`
- `method` **_fail (BluetoothHostService)** — baris 263 — `  void _fail(String message) {`
- `method` **_onEvent (BluetoothHostService)** — baris 273 — `  void _onEvent(BluetoothSyncEvent event) {`
- `method` **_handlePacket (BluetoothHostService)** — baris 339 — `  void _handlePacket(SyncPacket packet) {`
- `method` **_handleAuthResponse (BluetoothHostService)** — baris 361 — `  void _handleAuthResponse(SyncPacket packet) {`
- `method` **_registerAuthFailure (BluetoothHostService)** — baris 390 — `  void _registerAuthFailure(String reason) {`
- `method` **_sendAuthChallenge (BluetoothHostService)** — baris 417 — `  Future<void> _sendAuthChallenge() async {`
- `method` **_sendPacket (BluetoothHostService)** — baris 426 — `  Future<void> _sendPacket(SyncPacket packet) async {`
- `method` **_generatePin (BluetoothHostService)** — baris 437 — `  String _generatePin() {`
- `method` **_generateNonce (BluetoothHostService)** — baris 443 — `  String _generateNonce() {`
- `method` **broadcast (BluetoothHostService)** — baris 449 — `  Future<void> broadcast(SyncPacket packet) async {`
- `method` **stop (BluetoothHostService)** — baris 454 — `  Future<void> stop() async {`

### `apps/tv_display/lib/server/local_ws_server.dart`
- `class` **LocalServer** — baris 10 — `class LocalServer {`
- `field` **_server (LocalServer)** — baris 11 — `  HttpServer? _server;`
- `field` **_clients (LocalServer)** — baris 12 — `  final List<WebSocketChannel> _clients = [];`
- `method` **broadcast (LocalServer)** — baris 46 — `  void broadcast(SyncPacket packet) {`
- `method` **stop (LocalServer)** — baris 53 — `  Future<void> stop() async {`

### `apps/tv_display/lib/state/local_ip.dart`
- `typedef` **NetworkInterfaceInfo** — baris 5 — `typedef NetworkInterfaceInfo = ({`
- `function` **pickLocalIpv4** — baris 18 — `String? pickLocalIpv4(List<NetworkInterfaceInfo> interfaces) {`
- `function` **_interfaceScore** — baris 39 — `int _interfaceScore(String name) {`
- `function` **loadLocalIpv4** — baris 52 — `Future<String?> loadLocalIpv4() async {`
- `function` **formatTvIpText** — baris 68 — `String formatTvIpText(String? ip) =>`

### `apps/tv_display/lib/state/prayer_state_machine.dart`
- `class` **PrayerStateMachine** — baris 18 — `class PrayerStateMachine extends ChangeNotifier {`
- `field` **_config (PrayerStateMachine)** — baris 19 — `  MosqueConfig _config = const MosqueConfig();`
- `field` **_phase (PrayerStateMachine)** — baris 20 — `  PrayerPhase _phase = PrayerPhase.normal;`
- `field` **_prayer (PrayerStateMachine)** — baris 21 — `  PrayerType? _prayer;`
- `field` **_deadline (PrayerStateMachine)** — baris 22 — `  DateTime _deadline = DateTime.now();`
- `field` **_remaining (PrayerStateMachine)** — baris 23 — `  Duration _remaining = Duration.zero;`
- `field` **_total (PrayerStateMachine)** — baris 24 — `  Duration _total = Duration.zero;`
- `field` **_autoCycle (PrayerStateMachine)** — baris 25 — `  bool _autoCycle = true;`
- `getter` **phase (PrayerStateMachine)** — baris 27 — `  PrayerPhase get phase => _phase;`
- `getter` **prayer (PrayerStateMachine)** — baris 28 — `  PrayerType? get prayer => _prayer;`
- `getter` **remaining (PrayerStateMachine)** — baris 29 — `  Duration get remaining => _remaining;`
- `getter` **total (PrayerStateMachine)** — baris 30 — `  Duration get total => _total;`
- `getter` **autoCycle (PrayerStateMachine)** — baris 31 — `  bool get autoCycle => _autoCycle;`
- `getter` **deadline (PrayerStateMachine)** — baris 37 — `  DateTime get deadline => _deadline;`
- `getter` **progress (PrayerStateMachine)** — baris 39 — `  double get progress {`
- `method` **updateConfig (PrayerStateMachine)** — baris 52 — `  void updateConfig(MosqueConfig config, DateTime now) {`
- `method` **tick (PrayerStateMachine)** — baris 66 — `  void tick(DateTime now, PrayerSchedule schedule) {`
- `method` **startIqomah (PrayerStateMachine)** — baris 108 — `  void startIqomah() {`
- `method` **startShalat (PrayerStateMachine)** — baris 115 — `  void startShalat() {`
- `method` **finishShalat (PrayerStateMachine)** — baris 122 — `  void finishShalat() {`
- `method` **_advance (PrayerStateMachine)** — baris 169 — `  void _advance(DateTime now) {`
- `method` **_isFridayPrayerDay (PrayerStateMachine)** — baris 194 — `  bool _isFridayPrayerDay(DateTime date) =>`
- `method` **_enter (PrayerStateMachine)** — baris 197 — `  void _enter(PrayerPhase phase, PrayerType? prayer, DateTime now) {`

### `apps/tv_display/lib/state/side_card_playlist.dart`
- `enum` **SideCardKind** — baris 4 — `enum SideCardKind {`
- `class` **SideCardItem** — baris 19 — `class SideCardItem {`
- `field` **kind (SideCardItem)** — baris 20 — `  final SideCardKind kind;`
- `field` **image (SideCardItem)** — baris 21 — `  final SpecialImage? image;`
- `getter` **key (SideCardItem)** — baris 27 — `  String get key => switch (kind) {`
- `operator` **operator == (SideCardItem)** — baris 34 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (SideCardItem)** — baris 39 — `  int get hashCode => Object.hash(kind, image);`
- `method` **toString (SideCardItem)** — baris 42 — `  String toString() => 'SideCardItem($key)';`

### `apps/tv_display/lib/state/tv_store.dart`
- `class` **TvStore** — baris 13 — `class TvStore {`
- `field` **configKey (TvStore)** — baris 14 — `  static const String configKey = 'tv_config';`
- `field` **runningTextsKey (TvStore)** — baris 15 — `  static const String runningTextsKey = 'tv_runningTexts';`
- `field` **bannersKey (TvStore)** — baris 16 — `  static const String bannersKey = 'tv_banners';`
- `field` **kasKey (TvStore)** — baris 17 — `  static const String kasKey = 'tv_kas';`
- `field` **sideImagesKey (TvStore)** — baris 18 — `  static const String sideImagesKey = 'tv_sideImages';`
- `field` **backgroundImagesKey (TvStore)** — baris 19 — `  static const String backgroundImagesKey = 'tv_backgroundImages';`
- `field` **mosqueLogoKey (TvStore)** — baris 20 — `  static const String mosqueLogoKey = 'tv_mosqueLogo';`
- `field` **hasDataKey (TvStore)** — baris 21 — `  static const String hasDataKey = 'tv_hasData';`
- `field` **mutedKey (TvStore)** — baris 22 — `  static const String mutedKey = 'tv_muted';`
- `field` **standbyKey (TvStore)** — baris 23 — `  static const String standbyKey = 'tv_standby';`
- `field` **pairingIntroDoneKey (TvStore)** — baris 28 — `  static const String pairingIntroDoneKey = 'tv_btPairingIntroDone';`
- `method` **load (TvStore)** — baris 31 — `  Future<StateSnapshot?> load() async {`
- `method` **saveConfig (TvStore)** — baris 70 — `  Future<void> saveConfig(MosqueConfig config) =>`
- `method` **saveRunningTexts (TvStore)** — baris 73 — `  Future<void> saveRunningTexts(List<RunningTextMessage> messages) =>`
- `method` **saveBanners (TvStore)** — baris 76 — `  Future<void> saveBanners(List<MediaBanner> banners) =>`
- `method` **saveKas (TvStore)** — baris 79 — `  Future<void> saveKas(List<KasTransaction> transactions) =>`
- `method` **saveSideImages (TvStore)** — baris 82 — `  Future<void> saveSideImages(List<SpecialImage> images) =>`
- `method` **saveBackgroundImages (TvStore)** — baris 85 — `  Future<void> saveBackgroundImages(List<BackgroundImage> images) =>`
- `method` **saveMosqueLogo (TvStore)** — baris 92 — `  Future<void> saveMosqueLogo(String? logoBase64) async {`
- `method` **_decodeLogo (TvStore)** — baris 107 — `  static String? _decodeLogo(String? raw) {`
- `method` **saveMuted (TvStore)** — baris 134 — `  Future<void> saveMuted(bool muted) => _saveBool(mutedKey, muted);`
- `method` **saveStandby (TvStore)** — baris 136 — `  Future<void> saveStandby(bool standby) => _saveBool(standbyKey, standby);`
- `method` **loadPairingIntroDone (TvStore)** — baris 140 — `  Future<bool> loadPairingIntroDone() async {`
- `method` **savePairingIntroDone (TvStore)** — baris 149 — `  Future<void> savePairingIntroDone() =>`
- `method` **_saveBool (TvStore)** — baris 150 — `      _saveBool(pairingIntroDoneKey, true);`
- `method` **_save (TvStore)** — baris 161 — `  Future<void> _save(String key, Object value) async {`
- `method` **_decodeMap (TvStore)** — baris 173 — `  static Map<String, dynamic>? _decodeMap(String source) {`

### `apps/tv_display/lib/theme/app_theme.dart`
- `class` **AppTheme** — baris 6 — `class AppTheme {`
- `getter` **darkTheme (AppTheme)** — baris 7 — `  static ThemeData get darkTheme {`

### `apps/tv_display/lib/theme/m3_shape_border.dart`
- `class` **M3ShapeBorder** — baris 14 — `class M3ShapeBorder extends OutlinedBorder {`
- `field` **polygon (M3ShapeBorder)** — baris 17 — `  final RoundedPolygon polygon;`
- `method` **_scaledPath (M3ShapeBorder)** — baris 34 — `  Path _scaledPath(Rect rect) {`
- `method` **scale (M3ShapeBorder)** — baris 58 — `  ShapeBorder scale(double t) {`
- `class` **ArchBorder** — baris 68 — `class ArchBorder extends OutlinedBorder {`
- `field` **bottomRadius (ArchBorder)** — baris 76 — `  final double bottomRadius;`
- `field` **domeFactor (ArchBorder)** — baris 80 — `  final double domeFactor;`
- `getter` **dimensions (ArchBorder)** — baris 83 — `  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);`
- `method` **scale (ArchBorder)** — baris 124 — `  ShapeBorder scale(double t) {`

### `apps/tv_display/lib/widgets/admin_menu_overlay.dart`
- `class` **AdminMenuOverlay** — baris 28 — `class AdminMenuOverlay extends StatefulWidget {`
- `field` **btEnabled (AdminMenuOverlay)** — baris 30 — `  final bool btEnabled;`
- `field` **pin (AdminMenuOverlay)** — baris 33 — `  final String? pin;`
- `field` **statusText (AdminMenuOverlay)** — baris 36 — `  final String? statusText;`
- `field` **isError (AdminMenuOverlay)** — baris 39 — `  final bool isError;`
- `field` **ipText (AdminMenuOverlay)** — baris 42 — `  final String ipText;`
- `field` **pairingActive (AdminMenuOverlay)** — baris 45 — `  final bool pairingActive;`
- `field` **pairingRemainingSeconds (AdminMenuOverlay)** — baris 48 — `  final int pairingRemainingSeconds;`
- `field` **onStartPairingMode (AdminMenuOverlay)** — baris 51 — `  final VoidCallback onStartPairingMode;`
- `field` **onToggleBluetooth (AdminMenuOverlay)** — baris 54 — `  final ValueChanged<bool> onToggleBluetooth;`
- `field` **onClose (AdminMenuOverlay)** — baris 57 — `  final VoidCallback onClose;`
- `method` **createState (AdminMenuOverlay)** — baris 74 — `  State<AdminMenuOverlay> createState() => _AdminMenuOverlayState();`
- `class` **_AdminMenuOverlayState** — baris 77 — `class _AdminMenuOverlayState extends State<AdminMenuOverlay>`
- `field` **_controller (_AdminMenuOverlayState)** — baris 79 — `  late final AnimationController _controller;`
- `field` **_slideIn (_AdminMenuOverlayState)** — baris 80 — `  late final Animation<Offset> _slideIn;`
- `field` **_slideOut (_AdminMenuOverlayState)** — baris 81 — `  late final Animation<Offset> _slideOut;`
- `field` **_panelScope (_AdminMenuOverlayState)** — baris 85 — `  late final FocusScopeNode _panelScope;`
- `field` **_closing (_AdminMenuOverlayState)** — baris 88 — `  bool _closing = false;`
- `method` **initState (_AdminMenuOverlayState)** — baris 91 — `  void initState() {`
- `method` **dispose (_AdminMenuOverlayState)** — baris 113 — `  void dispose() {`
- `method` **_close (_AdminMenuOverlayState)** — baris 120 — `  void _close() {`
- `method` **build (_AdminMenuOverlayState)** — baris 129 — `  Widget build(BuildContext context) {`
- `function` **formatPairingCountdown** — baris 389 — `String formatPairingCountdown(int totalSeconds) {`
- `class` **_AdminAction** — baris 397 — `class _AdminAction {`
- `field` **icon (_AdminAction)** — baris 398 — `  final IconData icon;`
- `field` **label (_AdminAction)** — baris 399 — `  final String label;`
- `field` **subtitle (_AdminAction)** — baris 400 — `  final String subtitle;`
- `field` **selected (_AdminAction)** — baris 403 — `  final bool selected;`
- `field` **onActivate (_AdminAction)** — baris 404 — `  final VoidCallback onActivate;`
- `class` **_FocusableAction** — baris 417 — `class _FocusableAction extends StatefulWidget {`
- `field` **action (_FocusableAction)** — baris 418 — `  final _AdminAction action;`
- `field` **autofocus (_FocusableAction)** — baris 421 — `  final bool autofocus;`
- `method` **createState (_FocusableAction)** — baris 426 — `  State<_FocusableAction> createState() => _FocusableActionState();`
- `class` **_FocusableActionState** — baris 429 — `class _FocusableActionState extends State<_FocusableAction> {`
- `field` **_focused (_FocusableActionState)** — baris 430 — `  bool _focused = false;`
- `method` **build (_FocusableActionState)** — baris 433 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/background_slideshow.dart`
- `function` **nextSlideshowIndex** — baris 11 — `int nextSlideshowIndex(int current, int count) {`
- `class` **BackgroundSlideshow** — baris 27 — `class BackgroundSlideshow extends StatefulWidget {`
- `field` **images (BackgroundSlideshow)** — baris 28 — `  final List<BackgroundImage> images;`
- `field` **intervalSeconds (BackgroundSlideshow)** — baris 29 — `  final int intervalSeconds;`
- `field` **fallback (BackgroundSlideshow)** — baris 33 — `  final Widget fallback;`
- `method` **createState (BackgroundSlideshow)** — baris 43 — `  State<BackgroundSlideshow> createState() => _BackgroundSlideshowState();`
- `class` **_BackgroundSlideshowState** — baris 46 — `class _BackgroundSlideshowState extends State<BackgroundSlideshow> {`
- `field` **_index (_BackgroundSlideshowState)** — baris 47 — `  int _index = 0;`
- `field` **_timer (_BackgroundSlideshowState)** — baris 48 — `  Timer? _timer;`
- `field` **_bytesCache (_BackgroundSlideshowState)** — baris 52 — `  final Map<String, Uint8List?> _bytesCache = {};`
- `getter` **_activeImages (_BackgroundSlideshowState)** — baris 54 — `  List<BackgroundImage> get _activeImages => [`
- `method` **initState (_BackgroundSlideshowState)** — baris 60 — `  void initState() {`
- `method` **didUpdateWidget (_BackgroundSlideshowState)** — baris 66 — `  void didUpdateWidget(covariant BackgroundSlideshow oldWidget) {`
- `method` **dispose (_BackgroundSlideshowState)** — baris 78 — `  void dispose() {`
- `method` **_restartTimer (_BackgroundSlideshowState)** — baris 83 — `  void _restartTimer() {`
- `method` **_bytesFor (_BackgroundSlideshowState)** — baris 96 — `  Uint8List? _bytesFor(BackgroundImage image) {`
- `method` **build (_BackgroundSlideshowState)** — baris 110 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/banner_carousel.dart`
- `class` **BannerCarousel** — baris 10 — `class BannerCarousel extends StatefulWidget {`
- `field` **banners (BannerCarousel)** — baris 11 — `  final List<MediaBanner> banners;`
- `method` **createState (BannerCarousel)** — baris 19 — `  State<BannerCarousel> createState() => _BannerCarouselState();`
- `class` **_BannerCarouselState** — baris 22 — `class _BannerCarouselState extends State<BannerCarousel> {`
- `field` **_pageController (_BannerCarouselState)** — baris 23 — `  late PageController _pageController;`
- `field` **_currentIndex (_BannerCarouselState)** — baris 24 — `  int _currentIndex = 0;`
- `field` **_timer (_BannerCarouselState)** — baris 25 — `  Timer? _timer;`
- `getter` **_activeBanners (_BannerCarouselState)** — baris 27 — `  List<MediaBanner> get _activeBanners =>`
- `method` **initState (_BannerCarouselState)** — baris 31 — `  void initState() {`
- `method` **_startTimer (_BannerCarouselState)** — baris 37 — `  void _startTimer() {`
- `method` **dispose (_BannerCarouselState)** — baris 52 — `  void dispose() {`
- `method` **didUpdateWidget (_BannerCarouselState)** — baris 59 — `  void didUpdateWidget(BannerCarousel oldWidget) {`
- `method` **build (_BannerCarouselState)** — baris 71 — `  Widget build(BuildContext context) {`
- `class` **_BannerPage** — baris 142 — `class _BannerPage extends StatefulWidget {`
- `field` **banner (_BannerPage)** — baris 143 — `  final MediaBanner banner;`
- `field` **active (_BannerPage)** — baris 144 — `  final bool active;`
- `method` **createState (_BannerPage)** — baris 152 — `  State<_BannerPage> createState() => _BannerPageState();`
- `class` **_BannerPageState** — baris 155 — `class _BannerPageState extends State<_BannerPage> {`
- `field` **_scrollController (_BannerPageState)** — baris 156 — `  final _scrollController = ScrollController();`
- `field` **_scrollTimer (_BannerPageState)** — baris 157 — `  Timer? _scrollTimer;`
- `field` **_cachedImageBytes (_BannerPageState)** — baris 158 — `  Uint8List? _cachedImageBytes;`
- `field` **_cachedBase64 (_BannerPageState)** — baris 159 — `  String? _cachedBase64;`
- `method` **initState (_BannerPageState)** — baris 162 — `  void initState() {`
- `method` **_decodeImageIfNeeded (_BannerPageState)** — baris 168 — `  void _decodeImageIfNeeded() {`
- `method` **didUpdateWidget (_BannerPageState)** — baris 178 — `  void didUpdateWidget(covariant _BannerPage oldWidget) {`
- `method` **_startAutoScroll (_BannerPageState)** — baris 203 — `  void _startAutoScroll() {`
- `method` **dispose (_BannerPageState)** — baris 228 — `  void dispose() {`
- `method` **build (_BannerPageState)** — baris 235 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/friday_staff_card.dart`
- `class` **FridayStaffCard** — baris 7 — `class FridayStaffCard extends StatelessWidget {`
- `field` **khatib (FridayStaffCard)** — baris 8 — `  final String khatib;`
- `field` **muadzin (FridayStaffCard)** — baris 9 — `  final String muadzin;`
- `method` **build (FridayStaffCard)** — baris 18 — `  Widget build(BuildContext context) {`
- `class` **_StaffRow** — baris 73 — `class _StaffRow extends StatelessWidget {`
- `field` **icon (_StaffRow)** — baris 74 — `  final IconData icon;`
- `field` **label (_StaffRow)** — baris 75 — `  final String label;`
- `field` **name (_StaffRow)** — baris 76 — `  final String name;`
- `method` **build (_StaffRow)** — baris 85 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/header_clock.dart`
- `class` **HeaderClock** — baris 9 — `class HeaderClock extends StatelessWidget {`
- `field` **config (HeaderClock)** — baris 10 — `  final MosqueConfig config;`
- `field` **currentTime (HeaderClock)** — baris 11 — `  final DateTime currentTime;`
- `field` **logoBytes (HeaderClock)** — baris 17 — `  final Uint8List? logoBytes;`
- `field` **logoSize (HeaderClock)** — baris 21 — `  static const double logoSize = 76;`
- `method` **build (HeaderClock)** — baris 31 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/kas_summary_card.dart`
- `class` **KasSummaryCard** — baris 5 — `class KasSummaryCard extends StatelessWidget {`
- `field` **transactions (KasSummaryCard)** — baris 6 — `  final List<KasTransaction> transactions;`
- `method` **build (KasSummaryCard)** — baris 14 — `  Widget build(BuildContext context) {`
- `class` **_KasAmountRow** — baris 92 — `class _KasAmountRow extends StatelessWidget {`
- `field` **icon (_KasAmountRow)** — baris 93 — `  final IconData icon;`
- `field` **label (_KasAmountRow)** — baris 94 — `  final String label;`
- `field` **amount (_KasAmountRow)** — baris 95 — `  final String amount;`
- `field` **color (_KasAmountRow)** — baris 96 — `  final Color color;`
- `method` **build (_KasAmountRow)** — baris 106 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/material_blob_background.dart`
- `class` **MaterialBlobBackground** — baris 16 — `class MaterialBlobBackground extends StatefulWidget {`
- `method` **createState (MaterialBlobBackground)** — baris 20 — `  State<MaterialBlobBackground> createState() => _MaterialBlobBackgroundState();`
- `class` **_MaterialBlobBackgroundState** — baris 23 — `class _MaterialBlobBackgroundState extends State<MaterialBlobBackground>`
- `field` **_controller (_MaterialBlobBackgroundState)** — baris 25 — `  late final AnimationController _controller = AnimationController(`
- `method` **dispose (_MaterialBlobBackgroundState)** — baris 31 — `  void dispose() {`
- `method` **build (_MaterialBlobBackgroundState)** — baris 37 — `  Widget build(BuildContext context) {`
- `class` **_ShapeSpec** — baris 109 — `class _ShapeSpec {`
- `field` **polygon (_ShapeSpec)** — baris 110 — `  final RoundedPolygon polygon;`
- `field` **color (_ShapeSpec)** — baris 111 — `  final Color color;`
- `field` **centerX (_ShapeSpec)** — baris 112 — `  final double centerX;`
- `field` **centerY (_ShapeSpec)** — baris 113 — `  final double centerY;`
- `field` **radiusX (_ShapeSpec)** — baris 114 — `  final double radiusX;`
- `field` **radiusY (_ShapeSpec)** — baris 115 — `  final double radiusY;`
- `field` **rotationSpeed (_ShapeSpec)** — baris 116 — `  final double rotationSpeed;`
- `field` **driftSpeed (_ShapeSpec)** — baris 117 — `  final double driftSpeed;`
- `field` **driftPhase (_ShapeSpec)** — baris 118 — `  final double driftPhase;`
- `field` **size (_ShapeSpec)** — baris 119 — `  final double size;`
- `field` **centeredPath (_ShapeSpec)** — baris 121 — `  late final Path centeredPath = _buildCenteredPath();`
- `method` **_buildCenteredPath (_ShapeSpec)** — baris 138 — `  Path _buildCenteredPath() {`
- `class` **_M3ShapePainter** — baris 150 — `class _M3ShapePainter extends CustomPainter {`
- `field` **animation (_M3ShapePainter)** — baris 151 — `  final Animation<double> animation;`
- `field` **blobs (_M3ShapePainter)** — baris 152 — `  final List<_ShapeSpec> blobs;`
- `method` **paint (_M3ShapePainter)** — baris 160 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_M3ShapePainter)** — baris 187 — `  bool shouldRepaint(covariant _M3ShapePainter oldDelegate) {`

### `apps/tv_display/lib/widgets/prayer_cards.dart`
- `class` **PrayerCardsRow** — baris 8 — `class PrayerCardsRow extends StatelessWidget {`
- `field` **schedule (PrayerCardsRow)** — baris 9 — `  final PrayerSchedule schedule;`
- `field` **hasFridayPrayer (PrayerCardsRow)** — baris 13 — `  final bool hasFridayPrayer;`
- `method` **build (PrayerCardsRow)** — baris 22 — `  Widget build(BuildContext context) {`
- `method` **_remainingFraction (PrayerCardsRow)** — baris 103 — `  double _remainingFraction(PrayerSchedule schedule) {`
- `class` **_NextPrayerTimer** — baris 125 — `class _NextPrayerTimer extends StatefulWidget {`
- `field` **formattedTime (_NextPrayerTimer)** — baris 126 — `  final String formattedTime;`
- `field` **remaining (_NextPrayerTimer)** — baris 127 — `  final Duration remaining;`
- `field` **progress (_NextPrayerTimer)** — baris 128 — `  final double progress;`
- `method` **createState (_NextPrayerTimer)** — baris 137 — `  State<_NextPrayerTimer> createState() => _NextPrayerTimerState();`
- `class` **_NextPrayerTimerState** — baris 140 — `class _NextPrayerTimerState extends State<_NextPrayerTimer> {`
- `field` **_showCountdown (_NextPrayerTimerState)** — baris 141 — `  bool _showCountdown = true;`
- `field` **_timer (_NextPrayerTimerState)** — baris 142 — `  Timer? _timer;`
- `method` **initState (_NextPrayerTimerState)** — baris 145 — `  void initState() {`
- `method` **dispose (_NextPrayerTimerState)** — baris 157 — `  void dispose() {`
- `method` **build (_NextPrayerTimerState)** — baris 163 — `  Widget build(BuildContext context) {`
- `method` **_formatDuration (_NextPrayerTimerState)** — baris 223 — `  String _formatDuration(Duration duration) {`

### `apps/tv_display/lib/widgets/prayer_state_overlay.dart`
- `class` **PrayerStateOverlay** — baris 12 — `class PrayerStateOverlay extends StatelessWidget {`
- `field` **phase (PrayerStateOverlay)** — baris 13 — `  final PrayerPhase phase;`
- `field` **prayerName (PrayerStateOverlay)** — baris 14 — `  final String? prayerName;`
- `field` **remaining (PrayerStateOverlay)** — baris 15 — `  final Duration remaining;`
- `field` **total (PrayerStateOverlay)** — baris 16 — `  final Duration total;`
- `field` **deadline (PrayerStateOverlay)** — baris 17 — `  final DateTime? deadline;`
- `field` **fridayKhatib (PrayerStateOverlay)** — baris 18 — `  final String? fridayKhatib;`
- `field` **fridayMuadzin (PrayerStateOverlay)** — baris 19 — `  final String? fridayMuadzin;`
- `method` **build (PrayerStateOverlay)** — baris 33 — `  Widget build(BuildContext context) {`
- `class` **_CountdownOverlay** — baris 77 — `class _CountdownOverlay extends StatelessWidget {`
- `field` **icon (_CountdownOverlay)** — baris 78 — `  final IconData icon;`
- `field` **headline (_CountdownOverlay)** — baris 79 — `  final String headline;`
- `field` **caption (_CountdownOverlay)** — baris 80 — `  final String caption;`
- `field` **progressColor (_CountdownOverlay)** — baris 81 — `  final Color progressColor;`
- `field` **remaining (_CountdownOverlay)** — baris 82 — `  final Duration remaining;`
- `field` **total (_CountdownOverlay)** — baris 83 — `  final Duration total;`
- `method` **build (_CountdownOverlay)** — baris 95 — `  Widget build(BuildContext context) {`
- `class` **_AdhanOverlay** — baris 159 — `class _AdhanOverlay extends StatelessWidget {`
- `field` **prayerName (_AdhanOverlay)** — baris 160 — `  final String prayerName;`
- `field` **remaining (_AdhanOverlay)** — baris 161 — `  final Duration remaining;`
- `field` **total (_AdhanOverlay)** — baris 162 — `  final Duration total;`
- `field` **deadline (_AdhanOverlay)** — baris 163 — `  final DateTime? deadline;`
- `method` **build (_AdhanOverlay)** — baris 173 — `  Widget build(BuildContext context) {`
- `class` **_KhutbahOverlay** — baris 244 — `class _KhutbahOverlay extends StatelessWidget {`
- `field` **khatib (_KhutbahOverlay)** — baris 245 — `  final String? khatib;`
- `field` **muadzin (_KhutbahOverlay)** — baris 246 — `  final String? muadzin;`
- `field` **remaining (_KhutbahOverlay)** — baris 247 — `  final Duration remaining;`
- `field` **total (_KhutbahOverlay)** — baris 248 — `  final Duration total;`
- `method` **build (_KhutbahOverlay)** — baris 258 — `  Widget build(BuildContext context) {`
- `class` **_StaffChip** — baris 348 — `class _StaffChip extends StatelessWidget {`
- `field` **icon (_StaffChip)** — baris 349 — `  final IconData icon;`
- `field` **label (_StaffChip)** — baris 350 — `  final String label;`
- `field` **name (_StaffChip)** — baris 351 — `  final String? name;`
- `method` **build (_StaffChip)** — baris 360 — `  Widget build(BuildContext context) {`
- `class` **_ShalatOverlay** — baris 401 — `class _ShalatOverlay extends StatelessWidget {`
- `field` **prayerName (_ShalatOverlay)** — baris 402 — `  final String prayerName;`
- `method` **build (_ShalatOverlay)** — baris 407 — `  Widget build(BuildContext context) {`
- `class` **_AnimatedProgressRing** — baris 425 — `class _AnimatedProgressRing extends StatelessWidget {`
- `field` **progress (_AnimatedProgressRing)** — baris 426 — `  final double progress;`
- `field` **size (_AnimatedProgressRing)** — baris 427 — `  final double size;`
- `field` **strokeWidth (_AnimatedProgressRing)** — baris 428 — `  final double strokeWidth;`
- `field` **color (_AnimatedProgressRing)** — baris 429 — `  final Color color;`
- `field` **trackColor (_AnimatedProgressRing)** — baris 430 — `  final Color trackColor;`
- `field` **child (_AnimatedProgressRing)** — baris 431 — `  final Widget child;`
- `method` **build (_AnimatedProgressRing)** — baris 443 — `  Widget build(BuildContext context) {`
- `class` **_WavyProgressBar** — baris 478 — `class _WavyProgressBar extends StatefulWidget {`
- `field` **remaining (_WavyProgressBar)** — baris 479 — `  final Duration remaining;`
- `field` **total (_WavyProgressBar)** — baris 480 — `  final Duration total;`
- `field` **deadline (_WavyProgressBar)** — baris 481 — `  final DateTime? deadline;`
- `field` **activeColor (_WavyProgressBar)** — baris 482 — `  final Color activeColor;`
- `field` **trackColor (_WavyProgressBar)** — baris 483 — `  final Color trackColor;`
- `method` **createState (_WavyProgressBar)** — baris 494 — `  State<_WavyProgressBar> createState() => _WavyProgressBarState();`
- `class` **_WavyProgressBarState** — baris 497 — `class _WavyProgressBarState extends State<_WavyProgressBar>`
- `field` **_controller (_WavyProgressBarState)** — baris 499 — `  late final AnimationController _controller = AnimationController(`
- `method` **dispose (_WavyProgressBarState)** — baris 505 — `  void dispose() {`
- `method` **build (_WavyProgressBarState)** — baris 511 — `  Widget build(BuildContext context) {`
- `function` **_formatCountdown** — baris 526 — `String _formatCountdown(Duration duration) {`
- `class` **_CircularRingPainter** — baris 545 — `class _CircularRingPainter extends CustomPainter {`
- `field` **progress (_CircularRingPainter)** — baris 546 — `  final double progress;`
- `field` **trackColor (_CircularRingPainter)** — baris 547 — `  final Color trackColor;`
- `field` **progressColor (_CircularRingPainter)** — baris 548 — `  final Color progressColor;`
- `field` **strokeWidth (_CircularRingPainter)** — baris 549 — `  final double strokeWidth;`
- `method` **paint (_CircularRingPainter)** — baris 559 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_CircularRingPainter)** — baris 586 — `  bool shouldRepaint(covariant _CircularRingPainter oldDelegate) {`
- `class` **_WavyProgressPainter** — baris 601 — `class _WavyProgressPainter extends CustomPainter {`
- `field` **animation (_WavyProgressPainter)** — baris 602 — `  final Animation<double> animation;`
- `field` **remaining (_WavyProgressPainter)** — baris 603 — `  final Duration remaining;`
- `field` **total (_WavyProgressPainter)** — baris 604 — `  final Duration total;`
- `field` **deadline (_WavyProgressPainter)** — baris 605 — `  final DateTime? deadline;`
- `field` **activeColor (_WavyProgressPainter)** — baris 606 — `  final Color activeColor;`
- `field` **trackColor (_WavyProgressPainter)** — baris 607 — `  final Color trackColor;`
- `method` **paint (_WavyProgressPainter)** — baris 619 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_WavyProgressPainter)** — baris 695 — `  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {`

### `apps/tv_display/lib/widgets/running_text_bar.dart`
- `class` **RunningTextBar** — baris 5 — `class RunningTextBar extends StatefulWidget {`
- `field` **messages (RunningTextBar)** — baris 6 — `  final List<RunningTextMessage> messages;`
- `method` **createState (RunningTextBar)** — baris 14 — `  State<RunningTextBar> createState() => _RunningTextBarState();`
- `class` **_RunningTextBarState** — baris 17 — `class _RunningTextBarState extends State<RunningTextBar> {`
- `field` **_scrollController (_RunningTextBarState)** — baris 18 — `  late ScrollController _scrollController;`
- `field` **_timer (_RunningTextBarState)** — baris 19 — `  Timer? _timer;`
- `method` **initState (_RunningTextBarState)** — baris 22 — `  void initState() {`
- `method` **didUpdateWidget (_RunningTextBarState)** — baris 31 — `  void didUpdateWidget(RunningTextBar oldWidget) {`
- `method` **_startAutoScroll (_RunningTextBarState)** — baris 58 — `  void _startAutoScroll() {`
- `method` **dispose (_RunningTextBarState)** — baris 76 — `  void dispose() {`
- `method` **build (_RunningTextBarState)** — baris 83 — `  Widget build(BuildContext context) {`
- `method` **_buildEmptyState (_RunningTextBarState)** — baris 97 — `  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {`

### `apps/tv_display/lib/widgets/side_card_rotator.dart`
- `class` **SideCardRotator** — baris 22 — `class SideCardRotator extends StatefulWidget {`
- `field` **config (SideCardRotator)** — baris 23 — `  final MosqueConfig config;`
- `field` **transactions (SideCardRotator)** — baris 24 — `  final List<KasTransaction> transactions;`
- `field` **images (SideCardRotator)** — baris 25 — `  final List<SpecialImage> images;`
- `field` **date (SideCardRotator)** — baris 28 — `  final DateTime date;`
- `field` **interval (SideCardRotator)** — baris 31 — `  final Duration interval;`
- `method` **createState (SideCardRotator)** — baris 43 — `  State<SideCardRotator> createState() => _SideCardRotatorState();`
- `class` **_SideCardRotatorState** — baris 46 — `class _SideCardRotatorState extends State<SideCardRotator> {`
- `field` **_timer (_SideCardRotatorState)** — baris 47 — `  Timer? _timer;`
- `field` **_currentIndex (_SideCardRotatorState)** — baris 48 — `  int _currentIndex = 0;`
- `getter` **_playlist (_SideCardRotatorState)** — baris 50 — `  List<SideCardItem> get _playlist => buildSideCardPlaylist(`
- `getter` **_signature (_SideCardRotatorState)** — baris 58 — `  String get _signature => _playlist.map((item) => item.key).join('|');`
- `method` **initState (_SideCardRotatorState)** — baris 61 — `  void initState() {`
- `method` **didUpdateWidget (_SideCardRotatorState)** — baris 67 — `  void didUpdateWidget(SideCardRotator oldWidget) {`
- `method` **_restartTimer (_SideCardRotatorState)** — baris 84 — `  void _restartTimer() {`
- `method` **dispose (_SideCardRotatorState)** — baris 96 — `  void dispose() {`
- `method` **build (_SideCardRotatorState)** — baris 102 — `  Widget build(BuildContext context) {`
- `method` **_buildCard (_SideCardRotatorState)** — baris 130 — `  Widget _buildCard(SideCardItem item) {`
- `class` **_SidePlaceholderCard** — baris 151 — `class _SidePlaceholderCard extends StatelessWidget {`
- `method` **build (_SidePlaceholderCard)** — baris 155 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/special_image_card.dart`
- `class` **SpecialImageCard** — baris 12 — `class SpecialImageCard extends StatelessWidget {`
- `field` **image (SpecialImageCard)** — baris 13 — `  final SpecialImage image;`
- `method` **build (SpecialImageCard)** — baris 21 — `  Widget build(BuildContext context) {`
- `method` **_buildFallback (SpecialImageCard)** — baris 82 — `  Widget _buildFallback(BuildContext context) {`

### `packages/bluetooth_sync/lib/bluetooth_sync.dart`
- `class` **BluetoothDeviceInfo** — baris 7 — `class BluetoothDeviceInfo {`
- `field` **name (BluetoothDeviceInfo)** — baris 8 — `  final String name;`
- `field` **address (BluetoothDeviceInfo)** — baris 9 — `  final String address;`
- `field` **bonded (BluetoothDeviceInfo)** — baris 10 — `  final bool bonded;`
- `method` **toString (BluetoothDeviceInfo)** — baris 28 — `  String toString() => 'BluetoothDeviceInfo($name, $address, bonded=$bonded)';`
- `enum` **BluetoothSyncEventType** — baris 31 — `enum BluetoothSyncEventType {`
- `class` **BluetoothSyncEvent** — baris 54 — `class BluetoothSyncEvent {`
- `field` **type (BluetoothSyncEvent)** — baris 55 — `  final BluetoothSyncEventType type;`
- `field` **deviceAddress (BluetoothSyncEvent)** — baris 56 — `  final String? deviceAddress;`
- `field` **deviceName (BluetoothSyncEvent)** — baris 57 — `  final String? deviceName;`
- `field` **data (BluetoothSyncEvent)** — baris 58 — `  final Uint8List? data;`
- `field` **error (BluetoothSyncEvent)** — baris 59 — `  final String? error;`
- `field` **bonded (BluetoothSyncEvent)** — baris 62 — `  final bool bonded;`
- `method` **_asBytes (BluetoothSyncEvent)** — baris 91 — `  static Uint8List? _asBytes(Object? raw) {`
- `class` **BluetoothSync** — baris 107 — `class BluetoothSync {`
- `field` **_channel (BluetoothSync)** — baris 110 — `  static const MethodChannel _channel =`
- `method` **MethodChannel (BluetoothSync)** — baris 111 — `      MethodChannel('com.masjidyou/bluetooth_sync');`
- `field` **_eventsChannel (BluetoothSync)** — baris 112 — `  static const EventChannel _eventsChannel =`
- `method` **EventChannel (BluetoothSync)** — baris 113 — `      EventChannel('com.masjidyou/bluetooth_sync/events');`
- `field` **_cachedController (BluetoothSync)** — baris 115 — `  static StreamController<BluetoothSyncEvent>? _cachedController;`
- `field` **_cachedStream (BluetoothSync)** — baris 116 — `  static Stream<BluetoothSyncEvent>? _cachedStream;`
- `field` **_nativeSubscription (BluetoothSync)** — baris 117 — `  static StreamSubscription<dynamic>? _nativeSubscription;`
- `getter` **events (BluetoothSync)** — baris 130 — `  static Stream<BluetoothSyncEvent> get events =>`
- `method` **_createEventsController (BluetoothSync)** — baris 133 — `  static StreamController<BluetoothSyncEvent> _createEventsController() {`
- `method` **_ensureNativeSubscription (BluetoothSync)** — baris 141 — `  static void _ensureNativeSubscription() {`
- `method` **debugResetEvents (BluetoothSync)** — baris 158 — `  static void debugResetEvents() {`
- `method` **isSupported (BluetoothSync)** — baris 168 — `  static Future<bool> isSupported() async =>`
- `method` **isEnabled (BluetoothSync)** — baris 171 — `  static Future<bool> isEnabled() async =>`
- `method` **enable (BluetoothSync)** — baris 176 — `  static Future<bool> enable() async =>`
- `method` **makeDiscoverable (BluetoothSync)** — baris 191 — `  static Future<bool> makeDiscoverable(int seconds) async =>`
- `method` **startHost (BluetoothSync)** — baris 200 — `  static Future<void> startHost(String serviceName) =>`
- `method` **stopHost (BluetoothSync)** — baris 203 — `  static Future<void> stopHost() => _channel.invokeMethod('stopHost');`
- `method` **getBondedDevices (BluetoothSync)** — baris 214 — `  static Future<List<BluetoothDeviceInfo>> getBondedDevices() async {`
- `method` **stopDiscovery (BluetoothSync)** — baris 230 — `  static Future<void> stopDiscovery() =>`
- `method` **connect (BluetoothSync)** — baris 234 — `  static Future<void> connect(String address) =>`
- `method` **disconnect (BluetoothSync)** — baris 237 — `  static Future<void> disconnect() => _channel.invokeMethod('disconnect');`
- `method` **send (BluetoothSync)** — baris 242 — `  static Future<void> send(Uint8List bytes) =>`

### `packages/shared_models/lib/src/background_image.dart`
- `class` **BackgroundImage** — baris 13 — `class BackgroundImage {`
- `field` **id (BackgroundImage)** — baris 14 — `  final String id;`
- `field` **base64Image (BackgroundImage)** — baris 17 — `  final String base64Image;`
- `field` **isActive (BackgroundImage)** — baris 19 — `  final bool isActive;`
- `method` **toMap (BackgroundImage)** — baris 27 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (BackgroundImage)** — baris 48 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (BackgroundImage)** — baris 66 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (BackgroundImage)** — baris 74 — `  int get hashCode => Object.hash(id, base64Image, isActive);`
- `method` **toString (BackgroundImage)** — baris 77 — `  String toString() => 'BackgroundImage(id: $id, '`

### `packages/shared_models/lib/src/backup_bundle.dart`
- `function` **_stringKeyed** — baris 7 — `Map<String, dynamic> _stringKeyed(Map raw) => {`
- `class` **BackupBundle** — baris 17 — `class BackupBundle {`
- `field` **currentFormatVersion (BackupBundle)** — baris 19 — `  static const int currentFormatVersion = 1;`
- `field` **formatVersion (BackupBundle)** — baris 21 — `  final int formatVersion;`
- `field` **exportedAt (BackupBundle)** — baris 22 — `  final DateTime exportedAt;`
- `field` **mosqueName (BackupBundle)** — baris 25 — `  final String mosqueName;`
- `field` **snapshot (BackupBundle)** — baris 27 — `  final StateSnapshot snapshot;`
- `method` **toMap (BackupBundle)** — baris 36 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (BackupBundle)** — baris 87 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (BackupBundle)** — baris 96 — `  int get hashCode =>`
- `method` **toString (BackupBundle)** — baris 100 — `  String toString() =>`

### `packages/shared_models/lib/src/chunked_transfer.dart`
- `function` **newChunkTransferId** — baris 37 — `String newChunkTransferId() {`
- `class` **ChunkedEncoding** — baris 45 — `class ChunkedEncoding {`
- `field` **packets (ChunkedEncoding)** — baris 48 — `  final List<SyncPacket> packets;`
- `field` **chunked (ChunkedEncoding)** — baris 51 — `  final bool chunked;`
- `constructor` **ChunkedEncoding (ChunkedEncoding)** — baris 53 — `  const ChunkedEncoding(this.packets, this.chunked);`
- `class` **ChunkReassembler** — baris 100 — `class ChunkReassembler {`
- `field` **_transferId (ChunkReassembler)** — baris 101 — `  String? _transferId;`
- `field` **_actionName (ChunkReassembler)** — baris 102 — `  String? _actionName;`
- `field` **_total (ChunkReassembler)** — baris 103 — `  int _total = 0;`
- `field` **_chunks (ChunkReassembler)** — baris 104 — `  final Map<int, String> _chunks = {};`
- `field` **lastError (ChunkReassembler)** — baris 108 — `  String? lastError;`
- `getter` **hasPendingTransfer (ChunkReassembler)** — baris 111 — `  bool get hasPendingTransfer => _transferId != null;`
- `getter` **receivedCount (ChunkReassembler)** — baris 114 — `  int get receivedCount => _chunks.length;`
- `getter` **expectedTotal (ChunkReassembler)** — baris 117 — `  int get expectedTotal => _total;`
- `method` **reset (ChunkReassembler)** — baris 119 — `  void reset() {`
- `method` **_fail (ChunkReassembler)** — baris 126 — `  SyncPacket? _fail(String message) {`
- `method` **addChunk (ChunkReassembler)** — baris 135 — `  SyncPacket? addChunk(SyncPacket packet) {`

### `packages/shared_models/lib/src/kas_transaction.dart`
- `enum` **KasType** — baris 3 — `enum KasType { masuk, keluar }`
- `class` **KasTransaction** — baris 5 — `class KasTransaction {`
- `field` **id (KasTransaction)** — baris 6 — `  final String id;`
- `field` **type (KasTransaction)** — baris 7 — `  final KasType type;`
- `field` **amount (KasTransaction)** — baris 8 — `  final int amount;`
- `field` **description (KasTransaction)** — baris 9 — `  final String description;`
- `field` **date (KasTransaction)** — baris 10 — `  final DateTime date;`
- `method` **toMap (KasTransaction)** — baris 20 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (KasTransaction)** — baris 47 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (KasTransaction)** — baris 53 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (KasTransaction)** — baris 63 — `  int get hashCode => Object.hash(id, type, amount, description, date);`
- `method` **toString (KasTransaction)** — baris 66 — `  String toString() =>`
- `class` **KasSummary** — baris 71 — `class KasSummary {`
- `field` **totalMasuk (KasSummary)** — baris 72 — `  final int totalMasuk;`
- `field` **totalKeluar (KasSummary)** — baris 73 — `  final int totalKeluar;`
- `field` **saldo (KasSummary)** — baris 74 — `  final int saldo;`
- `operator` **operator == (KasSummary)** — baris 100 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (KasSummary)** — baris 108 — `  int get hashCode => Object.hash(totalMasuk, totalKeluar, saldo);`
- `method` **toString (KasSummary)** — baris 111 — `  String toString() =>`

### `packages/shared_models/lib/src/media_banner.dart`
- `class` **MediaBanner** — baris 3 — `class MediaBanner {`
- `field` **id (MediaBanner)** — baris 4 — `  final String id;`
- `field` **header (MediaBanner)** — baris 5 — `  final String header;`
- `field` **title (MediaBanner)** — baris 6 — `  final String title;`
- `field` **content (MediaBanner)** — baris 7 — `  final String content;`
- `field` **footer (MediaBanner)** — baris 8 — `  final String footer;`
- `field` **isActive (MediaBanner)** — baris 9 — `  final bool isActive;`
- `field` **base64Image (MediaBanner)** — baris 10 — `  final String? base64Image;`
- `method` **toMap (MediaBanner)** — baris 22 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (MediaBanner)** — baris 59 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (MediaBanner)** — baris 91 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (MediaBanner)** — baris 103 — `  int get hashCode =>`
- `method` **toString (MediaBanner)** — baris 107 — `  String toString() =>`

### `packages/shared_models/lib/src/mosque_config.dart`
- `function` **_intOf** — baris 7 — `int _intOf(Object? raw, int fallback) => raw is num ? raw.toInt() : fallback;`
- `function` **_doubleOf** — baris 9 — `double _doubleOf(Object? raw, double fallback) =>`
- `function` **_boolOf** — baris 15 — `bool _boolOf(Object? raw, bool fallback) => raw is bool ? raw : fallback;`
- `class` **IqamahDuration** — baris 17 — `class IqamahDuration {`
- `field` **fajr (IqamahDuration)** — baris 18 — `  final int fajr;`
- `field` **dhuhr (IqamahDuration)** — baris 19 — `  final int dhuhr;`
- `field` **asr (IqamahDuration)** — baris 20 — `  final int asr;`
- `field` **maghrib (IqamahDuration)** — baris 21 — `  final int maghrib;`
- `field` **isha (IqamahDuration)** — baris 22 — `  final int isha;`
- `method` **toMap (IqamahDuration)** — baris 32 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (IqamahDuration)** — baris 51 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (IqamahDuration)** — baris 61 — `  int get hashCode => Object.hash(fajr, dhuhr, asr, maghrib, isha);`
- `method` **toString (IqamahDuration)** — baris 64 — `  String toString() =>`
- `class` **MosqueConfig** — baris 76 — `class MosqueConfig {`
- `field` **name (MosqueConfig)** — baris 77 — `  final String name;`
- `field` **address (MosqueConfig)** — baris 78 — `  final String address;`
- `field` **latitude (MosqueConfig)** — baris 79 — `  final double latitude;`
- `field` **longitude (MosqueConfig)** — baris 80 — `  final double longitude;`
- `field` **utcOffsetHours (MosqueConfig)** — baris 81 — `  final int utcOffsetHours;`
- `field` **iqamahDuration (MosqueConfig)** — baris 82 — `  final IqamahDuration iqamahDuration;`
- `field` **prayerOffsets (MosqueConfig)** — baris 83 — `  final Map<PrayerType, int> prayerOffsets;`
- `field` **preAdhanMinutes (MosqueConfig)** — baris 86 — `  final int preAdhanMinutes;`
- `field` **adhanMinutes (MosqueConfig)** — baris 89 — `  final int adhanMinutes;`
- `field` **preIqomahMinutes (MosqueConfig)** — baris 92 — `  final int preIqomahMinutes;`
- `field` **shalatMinutes (MosqueConfig)** — baris 95 — `  final int shalatMinutes;`
- `field` **khutbahMinutes (MosqueConfig)** — baris 98 — `  final int khutbahMinutes;`
- `field` **fridayKhatib (MosqueConfig)** — baris 101 — `  final String fridayKhatib;`
- `field` **fridayMuadzin (MosqueConfig)** — baris 104 — `  final String fridayMuadzin;`
- `field` **showKas (MosqueConfig)** — baris 110 — `  final bool showKas;`
- `field` **hasFridayPrayer (MosqueConfig)** — baris 117 — `  final bool hasFridayPrayer;`
- `field` **backgroundSlideSeconds (MosqueConfig)** — baris 124 — `  final int backgroundSlideSeconds;`
- `field` **minBackgroundSlideSeconds (MosqueConfig)** — baris 127 — `  static const int minBackgroundSlideSeconds = 5;`
- `field` **maxBackgroundSlideSeconds (MosqueConfig)** — baris 130 — `  static const int maxBackgroundSlideSeconds = 300;`
- `field` **defaultBackgroundSlideSeconds (MosqueConfig)** — baris 133 — `  static const int defaultBackgroundSlideSeconds = 30;`
- `method` **clampBackgroundSlideSeconds (MosqueConfig)** — baris 136 — `  static int clampBackgroundSlideSeconds(int seconds) => seconds.clamp(`
- `method` **offsetFor (MosqueConfig)** — baris 183 — `  int offsetFor(PrayerType type) => prayerOffsets[type] ?? 0;`
- `method` **toMap (MosqueConfig)** — baris 185 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (MosqueConfig)** — baris 268 — `  String toJson() => json.encode(toMap());`
- `method` **_mapsEqual (MosqueConfig)** — baris 318 — `  static bool _mapsEqual(Map<PrayerType, int> a, Map<PrayerType, int> b) {`
- `operator` **operator == (MosqueConfig)** — baris 328 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (MosqueConfig)** — baris 350 — `  int get hashCode => Object.hash(`
- `method` **toString (MosqueConfig)** — baris 371 — `  String toString() =>`

### `packages/shared_models/lib/src/prayer_phase.dart`
- `enum` **PrayerPhase** — baris 8 — `enum PrayerPhase {`
- `method` **fromName (PrayerPhase)** — baris 17 — `  static PrayerPhase fromName(String? name) => PrayerPhase.values.firstWhere(`
- `extension` **PrayerPhaseX** — baris 23 — `extension PrayerPhaseX on PrayerPhase {`

### `packages/shared_models/lib/src/prayer_schedule.dart`
- `class` **PrayerScheduleItem** — baris 8 — `class PrayerScheduleItem {`
- `field` **type (PrayerScheduleItem)** — baris 9 — `  final PrayerType type;`
- `field` **time (PrayerScheduleItem)** — baris 10 — `  final DateTime time;`
- `getter` **formattedTime (PrayerScheduleItem)** — baris 17 — `  String get formattedTime => DateFormat('HH:mm').format(time);`
- `class` **PrayerSchedule** — baris 20 — `class PrayerSchedule {`
- `field` **date (PrayerSchedule)** — baris 21 — `  final DateTime date;`
- `field` **items (PrayerSchedule)** — baris 22 — `  final List<PrayerScheduleItem> items;`
- `field` **nextPrayer (PrayerSchedule)** — baris 23 — `  final PrayerType? nextPrayer;`
- `field` **timeUntilNextPrayer (PrayerSchedule)** — baris 24 — `  final Duration? timeUntilNextPrayer;`

### `packages/shared_models/lib/src/prayer_type.dart`
- `enum` **PrayerType** — baris 1 — `enum PrayerType {`
- `extension` **PrayerTypeX** — baris 10 — `extension PrayerTypeX on PrayerType {`

### `packages/shared_models/lib/src/running_text.dart`
- `class` **RunningTextMessage** — baris 3 — `class RunningTextMessage {`
- `field` **id (RunningTextMessage)** — baris 4 — `  final String id;`
- `field` **content (RunningTextMessage)** — baris 5 — `  final String content;`
- `field` **isActive (RunningTextMessage)** — baris 6 — `  final bool isActive;`
- `field` **category (RunningTextMessage)** — baris 7 — `  final String category; // e.g. 'Umum', 'Kas', 'Kajian'`
- `method` **toMap (RunningTextMessage)** — baris 16 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (RunningTextMessage)** — baris 40 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (RunningTextMessage)** — baris 46 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (RunningTextMessage)** — baris 55 — `  int get hashCode => Object.hash(id, content, isActive, category);`
- `method` **toString (RunningTextMessage)** — baris 58 — `  String toString() =>`

### `packages/shared_models/lib/src/special_image.dart`
- `class` **SpecialImage** — baris 12 — `class SpecialImage {`
- `field` **id (SpecialImage)** — baris 13 — `  final String id;`
- `field` **caption (SpecialImage)** — baris 16 — `  final String caption;`
- `field` **base64Image (SpecialImage)** — baris 19 — `  final String base64Image;`
- `field` **isActive (SpecialImage)** — baris 21 — `  final bool isActive;`
- `method` **toMap (SpecialImage)** — baris 30 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (SpecialImage)** — baris 54 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (SpecialImage)** — baris 74 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (SpecialImage)** — baris 83 — `  int get hashCode => Object.hash(id, caption, base64Image, isActive);`
- `method` **toString (SpecialImage)** — baris 86 — `  String toString() => 'SpecialImage(id: $id, caption: $caption, '`

### `packages/shared_models/lib/src/state_snapshot.dart`
- `function` **_stringKeyed** — baris 12 — `Map<String, dynamic> _stringKeyed(Map raw) => {`
- `class` **StateSnapshot** — baris 44 — `class StateSnapshot {`
- `field` **config (StateSnapshot)** — baris 45 — `  final MosqueConfig config;`
- `field` **runningTexts (StateSnapshot)** — baris 46 — `  final List<RunningTextMessage> runningTexts;`
- `field` **banners (StateSnapshot)** — baris 47 — `  final List<MediaBanner> banners;`
- `field` **kasTransactions (StateSnapshot)** — baris 48 — `  final List<KasTransaction> kasTransactions;`
- `field` **sideImages (StateSnapshot)** — baris 51 — `  final List<SpecialImage> sideImages;`
- `field` **backgroundImages (StateSnapshot)** — baris 54 — `  final List<BackgroundImage> backgroundImages;`
- `field` **mosqueLogo (StateSnapshot)** — baris 59 — `  final String? mosqueLogo;`
- `field` **hasData (StateSnapshot)** — baris 60 — `  final bool hasData;`
- `method` **toMap (StateSnapshot)** — baris 73 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (StateSnapshot)** — baris 125 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (StateSnapshot)** — baris 138 — `  int get hashCode => Object.hash(`
- `method` **toString (StateSnapshot)** — baris 150 — `  String toString() => 'StateSnapshot(hasData: $hasData, config: $config, '`

### `packages/shared_models/lib/src/sync_packet.dart`
- `enum` **SyncAction** — baris 3 — `enum SyncAction {`
- `class` **SyncPacket** — baris 64 — `class SyncPacket {`
- `field` **action (SyncPacket)** — baris 65 — `  final SyncAction action;`
- `field` **payload (SyncPacket)** — baris 66 — `  final Map<String, dynamic> payload;`
- `method` **toMap (SyncPacket)** — baris 73 — `  Map<String, dynamic> toMap() => {`
- `method` **_parsePayload (SyncPacket)** — baris 93 — `  static Map<String, dynamic> _parsePayload(Object? raw) {`
- `method` **toJson (SyncPacket)** — baris 104 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (SyncPacket)** — baris 110 — `  bool operator ==(Object other) =>`
- `method` **_mapsEqual (SyncPacket)** — baris 114 — `          _mapsEqual(other.payload, payload);`
- `getter` **hashCode (SyncPacket)** — baris 125 — `  int get hashCode =>`
- `method` **toString (SyncPacket)** — baris 129 — `  String toString() => 'SyncPacket(action: ${action.name}, payload: $payload)';`
