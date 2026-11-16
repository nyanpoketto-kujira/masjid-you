# Codebase Index — Masjid You

> Dibuat otomatis oleh `dart run tools/codebase_index.dart`. Jangan edit manual — regenerate setelah perubahan kode.

Total simbol: **932**

| Kategori | Jumlah |
|---|---:|
| `class` | 94 |
| `field` | 442 |
| `method` | 319 |
| `getter` | 39 |
| `function` | 15 |
| `typedef` | 1 |
| `enum` | 9 |
| `operator` | 11 |
| `extension` | 2 |


### `apps/mobile_remote/lib/main.dart`
- `class` **RemoteHomeScreen** — baris 37 — `class RemoteHomeScreen extends StatefulWidget {`
- `field` **themeMode (RemoteHomeScreen)** — baris 47 — `  final ThemeMode themeMode;`
- `field` **colorSource (RemoteHomeScreen)** — baris 48 — `  final AppColorSource colorSource;`
- `field` **onThemeModeChanged (RemoteHomeScreen)** — baris 49 — `  final ValueChanged<ThemeMode>? onThemeModeChanged;`
- `field` **onColorSourceChanged (RemoteHomeScreen)** — baris 50 — `  final ValueChanged<AppColorSource>? onColorSourceChanged;`
- `method` **createState (RemoteHomeScreen)** — baris 53 — `  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();`
- `class` **_PinDialog** — baris 75 — `class _PinDialog extends StatefulWidget {`
- `field` **onSubmit (_PinDialog)** — baris 76 — `  final ValueChanged<String> onSubmit;`
- `field` **onCancel (_PinDialog)** — baris 77 — `  final VoidCallback onCancel;`
- `method` **createState (_PinDialog)** — baris 82 — `  State<_PinDialog> createState() => _PinDialogState();`
- `class` **_PinDialogState** — baris 85 — `class _PinDialogState extends State<_PinDialog> {`
- `field` **_pinController (_PinDialogState)** — baris 86 — `  final _pinController = TextEditingController();`
- `method` **dispose (_PinDialogState)** — baris 89 — `  void dispose() {`
- `method` **_submit (_PinDialogState)** — baris 94 — `  void _submit() {`
- `method` **build (_PinDialogState)** — baris 101 — `  Widget build(BuildContext context) {`
- `class` **_RemoteHomeScreenState** — baris 151 — `class _RemoteHomeScreenState extends State<RemoteHomeScreen>`
- `field` **_tabIndex (_RemoteHomeScreenState)** — baris 154 — `  int _tabIndex = 0;`
- `field` **_subTabController (_RemoteHomeScreenState)** — baris 157 — `  late final TabController _subTabController;`
- `field` **_tvMuted (_RemoteHomeScreenState)** — baris 161 — `  bool _tvMuted = false;`
- `field` **_tvStandby (_RemoteHomeScreenState)** — baris 162 — `  bool _tvStandby = false;`
- `field` **_ipController (_RemoteHomeScreenState)** — baris 164 — `  final _ipController = TextEditingController(text: '192.168.1.');`
- `field` **_client (_RemoteHomeScreenState)** — baris 165 — `  final _client = RemoteWsClient();`
- `field` **_btClient (_RemoteHomeScreenState)** — baris 166 — `  final _btClient = BluetoothClientService();`
- `field` **_isConnecting (_RemoteHomeScreenState)** — baris 167 — `  bool _isConnecting = false;`
- `field` **_isConnected (_RemoteHomeScreenState)** — baris 168 — `  bool _isConnected = false;`
- `field` **_wasConnected (_RemoteHomeScreenState)** — baris 169 — `  bool _wasConnected = false;`
- `field` **_showDisconnectedNotice (_RemoteHomeScreenState)** — baris 170 — `  bool _showDisconnectedNotice = false;`
- `field` **_syncDialogOpen (_RemoteHomeScreenState)** — baris 171 — `  bool _syncDialogOpen = false;`
- `field` **_lastConnectionKind (_RemoteHomeScreenState)** — baris 172 — `  String? _lastConnectionKind;`
- `field` **_lastBtDevice (_RemoteHomeScreenState)** — baris 173 — `  BluetoothDeviceInfo? _lastBtDevice;`
- `field` **_btIsScanning (_RemoteHomeScreenState)** — baris 176 — `  bool _btIsScanning = false;`
- `field` **_btConnected (_RemoteHomeScreenState)** — baris 177 — `  bool _btConnected = false;`
- `field` **_btDevices (_RemoteHomeScreenState)** — baris 178 — `  List<BluetoothDeviceInfo> _btDevices = [];`
- `field` **_btStatus (_RemoteHomeScreenState)** — baris 179 — `  String _btStatus = 'Bluetooth: Stanby';`
- `field` **_btStateSub (_RemoteHomeScreenState)** — baris 180 — `  StreamSubscription<BluetoothClientState>? _btStateSub;`
- `field` **_hasUnsyncedChanges (_RemoteHomeScreenState)** — baris 182 — `  bool _hasUnsyncedChanges = false;`
- `field` **_pinDialogOpen (_RemoteHomeScreenState)** — baris 185 — `  bool _pinDialogOpen = false;`
- `field` **_pendingBtState (_RemoteHomeScreenState)** — baris 189 — `  BluetoothClientState? _pendingBtState;`
- `field` **_cacheStore (_RemoteHomeScreenState)** — baris 192 — `  final RemoteCacheStore _cacheStore = RemoteCacheStore();`
- `field` **_backupService (_RemoteHomeScreenState)** — baris 195 — `  final BackupService _backupService = BackupService();`
- `field` **_didBootstrapPush (_RemoteHomeScreenState)** — baris 199 — `  bool _didBootstrapPush = false;`
- `field` **_config (_RemoteHomeScreenState)** — baris 201 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_nameController (_RemoteHomeScreenState)** — baris 208 — `  final _nameController = TextEditingController();`
- `field` **_addressController (_RemoteHomeScreenState)** — baris 209 — `  final _addressController = TextEditingController();`
- `field` **_latitudeController (_RemoteHomeScreenState)** — baris 210 — `  final _latitudeController = TextEditingController();`
- `field` **_longitudeController (_RemoteHomeScreenState)** — baris 211 — `  final _longitudeController = TextEditingController();`
- `field` **_prayerOffsetControllers (_RemoteHomeScreenState)** — baris 212 — `  final Map<PrayerType, TextEditingController> _prayerOffsetControllers = {`
- `field` **_preAdhanController (_RemoteHomeScreenState)** — baris 215 — `  final _preAdhanController = TextEditingController();`
- `field` **_adhanController (_RemoteHomeScreenState)** — baris 216 — `  final _adhanController = TextEditingController();`
- `field` **_preIqomahController (_RemoteHomeScreenState)** — baris 217 — `  final _preIqomahController = TextEditingController();`
- `field` **_shalatController (_RemoteHomeScreenState)** — baris 218 — `  final _shalatController = TextEditingController();`
- `field` **_khutbahController (_RemoteHomeScreenState)** — baris 219 — `  final _khutbahController = TextEditingController();`
- `field` **_fridayKhatibController (_RemoteHomeScreenState)** — baris 220 — `  final _fridayKhatibController = TextEditingController();`
- `field` **_fridayMuadzinController (_RemoteHomeScreenState)** — baris 221 — `  final _fridayMuadzinController = TextEditingController();`
- `field` **_showKas (_RemoteHomeScreenState)** — baris 225 — `  bool _showKas = true;`
- `field` **_hasFridayPrayer (_RemoteHomeScreenState)** — baris 226 — `  bool _hasFridayPrayer = true;`
- `field` **_isFetchingLocation (_RemoteHomeScreenState)** — baris 227 — `  bool _isFetchingLocation = false;`
- `field` **_runningTextController (_RemoteHomeScreenState)** — baris 228 — `  final _runningTextController = TextEditingController();`
- `field` **_runningCategory (_RemoteHomeScreenState)** — baris 229 — `  String _runningCategory = _runningCategories.first;`
- `field` **_bannerHeaderController (_RemoteHomeScreenState)** — baris 231 — `  final _bannerHeaderController = TextEditingController();`
- `field` **_bannerTitleController (_RemoteHomeScreenState)** — baris 232 — `  final _bannerTitleController = TextEditingController();`
- `field` **_bannerContentController (_RemoteHomeScreenState)** — baris 233 — `  final _bannerContentController = TextEditingController();`
- `field` **_bannerFooterController (_RemoteHomeScreenState)** — baris 234 — `  final _bannerFooterController = TextEditingController();`
- `field` **_kasAmountController (_RemoteHomeScreenState)** — baris 236 — `  final _kasAmountController = TextEditingController();`
- `field` **_kasDescriptionController (_RemoteHomeScreenState)** — baris 237 — `  final _kasDescriptionController = TextEditingController();`
- `field` **_kasType (_RemoteHomeScreenState)** — baris 238 — `  KasType _kasType = KasType.masuk;`
- `field` **_tvPhase (_RemoteHomeScreenState)** — baris 241 — `  PrayerPhase _tvPhase = PrayerPhase.normal;`
- `field` **_kasTransactions (_RemoteHomeScreenState)** — baris 243 — `  final List<KasTransaction> _kasTransactions = [`
- `field` **_runningTexts (_RemoteHomeScreenState)** — baris 260 — `  final List<RunningTextMessage> _runningTexts = [`
- `field` **_banners (_RemoteHomeScreenState)** — baris 275 — `  final List<MediaBanner> _banners = [`
- `field` **_sideImages (_RemoteHomeScreenState)** — baris 293 — `  final List<SpecialImage> _sideImages = [];`
- `method` **initState (_RemoteHomeScreenState)** — baris 296 — `  void initState() {`
- `method` **didChangeAppLifecycleState (_RemoteHomeScreenState)** — baris 381 — `  void didChangeAppLifecycleState(AppLifecycleState state) {`
- `method` **_syncConfigControllers (_RemoteHomeScreenState)** — baris 401 — `  void _syncConfigControllers() {`
- `method` **_loadStartupData (_RemoteHomeScreenState)** — baris 424 — `  Future<void> _loadStartupData() async {`
- `method` **_applySnapshot (_RemoteHomeScreenState)** — baris 436 — `  void _applySnapshot(StateSnapshot snapshot) {`
- `method` **_requestTvState (_RemoteHomeScreenState)** — baris 454 — `  void _requestTvState() {`
- `method` **_showPinDialog (_RemoteHomeScreenState)** — baris 483 — `  void _showPinDialog() {`
- `method` **_closePinDialog (_RemoteHomeScreenState)** — baris 519 — `  void _closePinDialog() {`
- `method` **_drainPendingBtState (_RemoteHomeScreenState)** — baris 527 — `  void _drainPendingBtState() {`
- `method` **_loadSavedDurations (_RemoteHomeScreenState)** — baris 568 — `  Future<void> _loadSavedDurations() async {`
- `method` **_persistDurations (_RemoteHomeScreenState)** — baris 610 — `  Future<void> _persistDurations(MosqueConfig config) async {`
- `method` **_handleTvPacket (_RemoteHomeScreenState)** — baris 629 — `  void _handleTvPacket(SyncPacket packet) {`
- `method` **_applyTvPhase (_RemoteHomeScreenState)** — baris 645 — `  void _applyTvPhase(SyncPacket packet) {`
- `method` **_applyTvSnapshot (_RemoteHomeScreenState)** — baris 664 — `  void _applyTvSnapshot(StateSnapshot snapshot) {`
- `method` **_pushLocalDataToTv (_RemoteHomeScreenState)** — baris 683 — `  void _pushLocalDataToTv() {`
- `method` **_exportBackup (_RemoteHomeScreenState)** — baris 692 — `  Future<void> _exportBackup() async {`
- `method` **_importBackup (_RemoteHomeScreenState)** — baris 714 — `  Future<void> _importBackup() async {`
- `method` **_applyImportedBackup (_RemoteHomeScreenState)** — baris 765 — `  Future<void> _applyImportedBackup(BackupBundle bundle) async {`
- `method` **_connectToTv (_RemoteHomeScreenState)** — baris 789 — `  Future<void> _connectToTv() async {`
- `method` **_handleConnectionEstablished (_RemoteHomeScreenState)** — baris 821 — `  void _handleConnectionEstablished(String kind) {`
- `method` **_handleTransportDisconnected (_RemoteHomeScreenState)** — baris 840 — `  void _handleTransportDisconnected() {`
- `method` **_reconnectLast (_RemoteHomeScreenState)** — baris 849 — `  Future<void> _reconnectLast() async {`
- `method` **_showSyncConflictDialog (_RemoteHomeScreenState)** — baris 863 — `  void _showSyncConflictDialog() {`
- `method` **_disconnectFromTv (_RemoteHomeScreenState)** — baris 903 — `  Future<void> _disconnectFromTv() async {`
- `method` **_buildConfigFromForm (_RemoteHomeScreenState)** — baris 915 — `  MosqueConfig _buildConfigFromForm() {`
- `method` **_minutesFrom (_RemoteHomeScreenState)** — baris 950 — `  int _minutesFrom(TextEditingController controller, int fallback) {`
- `method` **_syncAllToTv (_RemoteHomeScreenState)** — baris 956 — `  void _syncAllToTv() {`
- `method` **_pushAllToTv (_RemoteHomeScreenState)** — baris 967 — `  void _pushAllToTv() {`
- `method` **_sendConfigUpdate (_RemoteHomeScreenState)** — baris 980 — `  void _sendConfigUpdate() {`
- `method` **_totalKas (_RemoteHomeScreenState)** — baris 1000 — `  int _totalKas(KasType type) => _kasTransactions`
- `method` **_toggleTvMuted (_RemoteHomeScreenState)** — baris 1006 — `  void _toggleTvMuted() {`
- `method` **_toggleTvStandby (_RemoteHomeScreenState)** — baris 1018 — `  void _toggleTvStandby() {`
- `method` **_sendQuickAction (_RemoteHomeScreenState)** — baris 1029 — `  void _sendQuickAction(SyncAction action) {`
- `method` **_sendForcePhase (_RemoteHomeScreenState)** — baris 1049 — `  void _sendForcePhase(PrayerPhase phase) {`
- `method` **_getLocationFromGps (_RemoteHomeScreenState)** — baris 1057 — `  Future<void> _getLocationFromGps() async {`
- `method` **_addRunningText (_RemoteHomeScreenState)** — baris 1116 — `  void _addRunningText() {`
- `method` **_removeRunningText (_RemoteHomeScreenState)** — baris 1138 — `  void _removeRunningText(String id) {`
- `method` **_editRunningText (_RemoteHomeScreenState)** — baris 1151 — `  void _editRunningText(RunningTextMessage item) {`
- `method` **_addBanner (_RemoteHomeScreenState)** — baris 1230 — `  void _addBanner(String? base64Image) {`
- `method` **_removeBanner (_RemoteHomeScreenState)** — baris 1265 — `  void _removeBanner(String id) {`
- `method` **_toggleBanner (_RemoteHomeScreenState)** — baris 1278 — `  void _toggleBanner(String id, bool val) {`
- `method` **_sendSideImagesIfConnected (_RemoteHomeScreenState)** — baris 1297 — `  void _sendSideImagesIfConnected() {`
- `method` **_addSideImage (_RemoteHomeScreenState)** — baris 1306 — `  void _addSideImage(String caption, String base64Image) {`
- `method` **_removeSideImage (_RemoteHomeScreenState)** — baris 1319 — `  void _removeSideImage(String id) {`
- `method` **_toggleSideImage (_RemoteHomeScreenState)** — baris 1327 — `  void _toggleSideImage(String id, bool val) {`
- `method` **_moveSideImage (_RemoteHomeScreenState)** — baris 1338 — `  void _moveSideImage(String id, int delta) {`
- `method` **_editBanner (_RemoteHomeScreenState)** — baris 1351 — `  void _editBanner(MediaBanner banner) {`
- `method` **_addKasTransaction (_RemoteHomeScreenState)** — baris 1426 — `  void _addKasTransaction() {`
- `method` **_removeKasTransaction (_RemoteHomeScreenState)** — baris 1453 — `  void _removeKasTransaction(String id) {`
- `method` **_startBtScan (_RemoteHomeScreenState)** — baris 1466 — `  void _startBtScan() {`
- `method` **_stopBtScan (_RemoteHomeScreenState)** — baris 1474 — `  void _stopBtScan() {`
- `method` **_connectBt (_RemoteHomeScreenState)** — baris 1482 — `  void _connectBt(BluetoothDeviceInfo device) {`
- `method` **_showScheduleSimulation (_RemoteHomeScreenState)** — baris 1492 — `  void _showScheduleSimulation(MosqueConfig formConfig) {`
- `method` **_formatDurationShort (_RemoteHomeScreenState)** — baris 1637 — `  String _formatDurationShort(Duration? duration) {`
- `method` **dispose (_RemoteHomeScreenState)** — baris 1645 — `  void dispose() {`
- `method` **build (_RemoteHomeScreenState)** — baris 1679 — `  Widget build(BuildContext context) {`
- `getter` **_transportLabel (_RemoteHomeScreenState)** — baris 1877 — `  String get _transportLabel =>`
- `method` **_buildConnectionStatusStrip (_RemoteHomeScreenState)** — baris 1882 — `  Widget _buildConnectionStatusStrip(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_showConnectionSheet (_RemoteHomeScreenState)** — baris 1925 — `  void _showConnectionSheet() {`
- `method` **_buildDisconnectedBanner (_RemoteHomeScreenState)** — baris 1999 — `  Widget _buildDisconnectedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildContentTabBar (_RemoteHomeScreenState)** — baris 2026 — `  Widget _buildContentTabBar(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildUnsyncedBanner (_RemoteHomeScreenState)** — baris 2053 — `  Widget _buildUnsyncedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `class` **MasjidYouRemoteApp** — baris 2081 — `class MasjidYouRemoteApp extends StatefulWidget {`
- `method` **createState (MasjidYouRemoteApp)** — baris 2085 — `  State<MasjidYouRemoteApp> createState() => _MasjidYouRemoteAppState();`
- `class` **_MasjidYouRemoteAppState** — baris 2088 — `class _MasjidYouRemoteAppState extends State<MasjidYouRemoteApp> {`
- `field` **_themeMode (_MasjidYouRemoteAppState)** — baris 2089 — `  ThemeMode _themeMode = ThemeMode.system;`
- `field` **_colorSource (_MasjidYouRemoteAppState)** — baris 2090 — `  AppColorSource _colorSource = AppColorSource.dynamic;`
- `method` **initState (_MasjidYouRemoteAppState)** — baris 2093 — `  void initState() {`
- `method` **_loadThemePreferences (_MasjidYouRemoteAppState)** — baris 2098 — `  Future<void> _loadThemePreferences() async {`
- `method` **_setThemeMode (_MasjidYouRemoteAppState)** — baris 2108 — `  Future<void> _setThemeMode(ThemeMode mode) async {`
- `method` **_setColorSource (_MasjidYouRemoteAppState)** — baris 2113 — `  Future<void> _setColorSource(AppColorSource source) async {`
- `method` **build (_MasjidYouRemoteAppState)** — baris 2119 — `  Widget build(BuildContext context) {`
- `function` **main** — baris 2155 — `void main() {`

### `apps/mobile_remote/lib/screens/connection/connection_gateway_screen.dart`
- `class` **ConnectionGatewayScreen** — baris 4 — `class ConnectionGatewayScreen extends StatelessWidget {`
- `field` **ipController (ConnectionGatewayScreen)** — baris 5 — `  final TextEditingController ipController;`
- `field` **isConnecting (ConnectionGatewayScreen)** — baris 6 — `  final bool isConnecting;`
- `field` **onConnectIp (ConnectionGatewayScreen)** — baris 7 — `  final VoidCallback onConnectIp;`
- `field` **btIsScanning (ConnectionGatewayScreen)** — baris 9 — `  final bool btIsScanning;`
- `field` **btDevices (ConnectionGatewayScreen)** — baris 10 — `  final List<BluetoothDeviceInfo> btDevices;`
- `field` **btStatus (ConnectionGatewayScreen)** — baris 11 — `  final String btStatus;`
- `field` **onBtStartScan (ConnectionGatewayScreen)** — baris 12 — `  final VoidCallback onBtStartScan;`
- `field` **onBtStopScan (ConnectionGatewayScreen)** — baris 13 — `  final VoidCallback onBtStopScan;`
- `field` **onBtConnect (ConnectionGatewayScreen)** — baris 14 — `  final ValueChanged<BluetoothDeviceInfo> onBtConnect;`
- `method` **build (ConnectionGatewayScreen)** — baris 30 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/banners_subtab.dart`
- `class` **BannersSubtab** — baris 8 — `class BannersSubtab extends StatefulWidget {`
- `field` **banners (BannersSubtab)** — baris 9 — `  final List<MediaBanner> banners;`
- `field` **headerController (BannersSubtab)** — baris 10 — `  final TextEditingController headerController;`
- `field` **titleController (BannersSubtab)** — baris 11 — `  final TextEditingController titleController;`
- `field` **contentController (BannersSubtab)** — baris 12 — `  final TextEditingController contentController;`
- `field` **footerController (BannersSubtab)** — baris 13 — `  final TextEditingController footerController;`
- `method` **createState (BannersSubtab)** — baris 33 — `  State<BannersSubtab> createState() => _BannersSubtabState();`
- `class` **_BannersSubtabState** — baris 36 — `class _BannersSubtabState extends State<BannersSubtab> {`
- `field` **_selectedBase64Image (_BannersSubtabState)** — baris 37 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_BannersSubtabState)** — baris 38 — `  File? _imagePreviewFile;`
- `field` **_picker (_BannersSubtabState)** — baris 39 — `  final ImagePicker _picker = ImagePicker();`
- `method` **_pickImage (_BannersSubtabState)** — baris 41 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_BannersSubtabState)** — baris 61 — `  void _clearImage() {`
- `method` **build (_BannersSubtabState)** — baris 69 — `  Widget build(BuildContext context) {`
- `class` **_BannerThumbnail** — baris 266 — `class _BannerThumbnail extends StatefulWidget {`
- `field` **base64Image (_BannerThumbnail)** — baris 267 — `  final String base64Image;`
- `method` **createState (_BannerThumbnail)** — baris 272 — `  State<_BannerThumbnail> createState() => _BannerThumbnailState();`
- `class` **_BannerThumbnailState** — baris 275 — `class _BannerThumbnailState extends State<_BannerThumbnail> {`
- `field` **_cachedImageBytes (_BannerThumbnailState)** — baris 276 — `  late Uint8List _cachedImageBytes;`
- `method` **initState (_BannerThumbnailState)** — baris 279 — `  void initState() {`
- `method` **didUpdateWidget (_BannerThumbnailState)** — baris 285 — `  void didUpdateWidget(covariant _BannerThumbnail oldWidget) {`
- `method` **build (_BannerThumbnailState)** — baris 293 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/kas_subtab.dart`
- `class` **KasSubtab** — baris 7 — `class KasSubtab extends StatelessWidget {`
- `field` **transactions (KasSubtab)** — baris 8 — `  final List<KasTransaction> transactions;`
- `field` **amountController (KasSubtab)** — baris 9 — `  final TextEditingController amountController;`
- `field` **descriptionController (KasSubtab)** — baris 10 — `  final TextEditingController descriptionController;`
- `field` **kasType (KasSubtab)** — baris 11 — `  final KasType kasType;`
- `field` **onAddTransaction (KasSubtab)** — baris 13 — `  final VoidCallback onAddTransaction;`
- `method` **build (KasSubtab)** — baris 28 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/running_text_subtab.dart`
- `class` **RunningTextSubtab** — baris 4 — `class RunningTextSubtab extends StatelessWidget {`
- `field` **runningTexts (RunningTextSubtab)** — baris 5 — `  final List<RunningTextMessage> runningTexts;`
- `field` **runningTextController (RunningTextSubtab)** — baris 6 — `  final TextEditingController runningTextController;`
- `field` **selectedCategory (RunningTextSubtab)** — baris 7 — `  final String selectedCategory;`
- `field` **categories (RunningTextSubtab)** — baris 8 — `  final List<String> categories;`
- `field` **onAddMessage (RunningTextSubtab)** — baris 10 — `  final VoidCallback onAddMessage;`
- `method` **build (RunningTextSubtab)** — baris 27 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/special_images_subtab.dart`
- `class` **SpecialImagesSubtab** — baris 15 — `class SpecialImagesSubtab extends StatefulWidget {`
- `field` **images (SpecialImagesSubtab)** — baris 16 — `  final List<SpecialImage> images;`
- `method` **createState (SpecialImagesSubtab)** — baris 34 — `  State<SpecialImagesSubtab> createState() => _SpecialImagesSubtabState();`
- `class` **_SpecialImagesSubtabState** — baris 37 — `class _SpecialImagesSubtabState extends State<SpecialImagesSubtab> {`
- `field` **_captionController (_SpecialImagesSubtabState)** — baris 38 — `  final _captionController = TextEditingController();`
- `field` **_selectedBase64Image (_SpecialImagesSubtabState)** — baris 39 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_SpecialImagesSubtabState)** — baris 40 — `  File? _imagePreviewFile;`
- `field` **_picker (_SpecialImagesSubtabState)** — baris 41 — `  final ImagePicker _picker = ImagePicker();`
- `method` **dispose (_SpecialImagesSubtabState)** — baris 44 — `  void dispose() {`
- `method` **_pickImage (_SpecialImagesSubtabState)** — baris 49 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_SpecialImagesSubtabState)** — baris 69 — `  void _clearImage() {`
- `method` **_submit (_SpecialImagesSubtabState)** — baris 76 — `  void _submit() {`
- `method` **build (_SpecialImagesSubtabState)** — baris 85 — `  Widget build(BuildContext context) {`
- `class` **_SpecialImageThumbnail** — baris 269 — `class _SpecialImageThumbnail extends StatefulWidget {`
- `field` **base64Image (_SpecialImageThumbnail)** — baris 270 — `  final String base64Image;`
- `method` **createState (_SpecialImageThumbnail)** — baris 275 — `  State<_SpecialImageThumbnail> createState() => _SpecialImageThumbnailState();`
- `class` **_SpecialImageThumbnailState** — baris 278 — `class _SpecialImageThumbnailState extends State<_SpecialImageThumbnail> {`
- `field` **_cachedImageBytes (_SpecialImageThumbnailState)** — baris 279 — `  Uint8List? _cachedImageBytes;`
- `method` **initState (_SpecialImageThumbnailState)** — baris 282 — `  void initState() {`
- `method` **didUpdateWidget (_SpecialImageThumbnailState)** — baris 288 — `  void didUpdateWidget(covariant _SpecialImageThumbnail oldWidget) {`
- `method` **_decode (_SpecialImageThumbnailState)** — baris 295 — `  void _decode() {`
- `method` **build (_SpecialImageThumbnailState)** — baris 304 — `  Widget build(BuildContext context) {`

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
- `class` **SettingsTab** — baris 6 — `class SettingsTab extends StatelessWidget {`
- `field` **config (SettingsTab)** — baris 7 — `  final MosqueConfig config;`
- `field` **nameController (SettingsTab)** — baris 8 — `  final TextEditingController nameController;`
- `field` **addressController (SettingsTab)** — baris 9 — `  final TextEditingController addressController;`
- `field` **latitudeController (SettingsTab)** — baris 10 — `  final TextEditingController latitudeController;`
- `field` **longitudeController (SettingsTab)** — baris 11 — `  final TextEditingController longitudeController;`
- `field` **prayerOffsetControllers (SettingsTab)** — baris 12 — `  final Map<PrayerType, TextEditingController> prayerOffsetControllers;`
- `field` **preAdhanController (SettingsTab)** — baris 13 — `  final TextEditingController preAdhanController;`
- `field` **adhanController (SettingsTab)** — baris 14 — `  final TextEditingController adhanController;`
- `field` **preIqomahController (SettingsTab)** — baris 15 — `  final TextEditingController preIqomahController;`
- `field` **shalatController (SettingsTab)** — baris 16 — `  final TextEditingController shalatController;`
- `field` **khutbahController (SettingsTab)** — baris 17 — `  final TextEditingController khutbahController;`
- `field` **fridayKhatibController (SettingsTab)** — baris 18 — `  final TextEditingController fridayKhatibController;`
- `field` **fridayMuadzinController (SettingsTab)** — baris 19 — `  final TextEditingController fridayMuadzinController;`
- `field` **showKas (SettingsTab)** — baris 22 — `  final bool showKas;`
- `field` **hasFridayPrayer (SettingsTab)** — baris 25 — `  final bool hasFridayPrayer;`
- `field` **onShowKasChanged (SettingsTab)** — baris 26 — `  final ValueChanged<bool> onShowKasChanged;`
- `field` **onHasFridayPrayerChanged (SettingsTab)** — baris 27 — `  final ValueChanged<bool> onHasFridayPrayerChanged;`
- `field` **isFetchingLocation (SettingsTab)** — baris 28 — `  final bool isFetchingLocation;`
- `field` **isConnected (SettingsTab)** — baris 29 — `  final bool isConnected;`
- `field` **tvPhase (SettingsTab)** — baris 30 — `  final PrayerPhase tvPhase;`
- `field` **onFetchLocation (SettingsTab)** — baris 31 — `  final VoidRefCallback onFetchLocation;`
- `field` **onSaveConfig (SettingsTab)** — baris 32 — `  final VoidRefCallback onSaveConfig;`
- `field` **onExportBackup (SettingsTab)** — baris 35 — `  final VoidRefCallback onExportBackup;`
- `field` **onImportBackup (SettingsTab)** — baris 36 — `  final VoidRefCallback onImportBackup;`
- `field` **themeMode (SettingsTab)** — baris 39 — `  final ThemeMode themeMode;`
- `field` **colorSource (SettingsTab)** — baris 40 — `  final AppColorSource colorSource;`
- `field` **onThemeModeChanged (SettingsTab)** — baris 41 — `  final ValueChanged<ThemeMode>? onThemeModeChanged;`
- `field` **onColorSourceChanged (SettingsTab)** — baris 42 — `  final ValueChanged<AppColorSource>? onColorSourceChanged;`
- `method` **build (SettingsTab)** — baris 79 — `  Widget build(BuildContext context) {`
- `method` **_buildQuickActionsCard (SettingsTab)** — baris 461 — `  Widget _buildQuickActionsCard(ThemeData theme, ColorScheme colorScheme) {`
- `typedef` **VoidRefCallback** — baris 529 — `typedef VoidRefCallback = void Function();`

### `apps/mobile_remote/lib/screens/simulation/simulation_tab.dart`
- `class` **SimulationTab** — baris 4 — `class SimulationTab extends StatelessWidget {`
- `field` **isConnected (SimulationTab)** — baris 5 — `  final bool isConnected;`
- `field` **tvPhase (SimulationTab)** — baris 6 — `  final PrayerPhase tvPhase;`
- `method` **build (SimulationTab)** — baris 17 — `  Widget build(BuildContext context) {`

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
- `field` **peerName (BluetoothClientState)** — baris 25 — `  final String? peerName;`
- `field` **error (BluetoothClientState)** — baris 26 — `  final String? error;`
- `class` **BluetoothClientService** — baris 43 — `class BluetoothClientService {`
- `field` **maxReconnectAttempts (BluetoothClientService)** — baris 45 — `  final int maxReconnectAttempts;`
- `field` **reconnectDelay (BluetoothClientService)** — baris 48 — `  final Duration reconnectDelay;`
- `field` **_stateController (BluetoothClientService)** — baris 50 — `  final _stateController = StreamController<BluetoothClientState>.broadcast();`
- `field` **_subscription (BluetoothClientService)** — baris 51 — `  StreamSubscription<BluetoothSyncEvent>? _subscription;`
- `field` **_reconnectTimer (BluetoothClientService)** — baris 52 — `  Timer? _reconnectTimer;`
- `field` **_connectWatchdog (BluetoothClientService)** — baris 53 — `  Timer? _connectWatchdog;`
- `field` **_discovering (BluetoothClientService)** — baris 54 — `  bool _discovering = false;`
- `field` **_connected (BluetoothClientService)** — baris 55 — `  bool _connected = false;`
- `field` **_connecting (BluetoothClientService)** — baris 56 — `  bool _connecting = false;`
- `field` **_reconnecting (BluetoothClientService)** — baris 57 — `  bool _reconnecting = false;`
- `field` **_disposed (BluetoothClientService)** — baris 58 — `  bool _disposed = false;`
- `field` **_reconnectAttempts (BluetoothClientService)** — baris 59 — `  int _reconnectAttempts = 0;`
- `field` **_devices (BluetoothClientService)** — baris 60 — `  List<BluetoothDeviceInfo> _devices = const [];`
- `field` **_peerName (BluetoothClientService)** — baris 61 — `  String? _peerName;`
- `field` **_error (BluetoothClientService)** — baris 62 — `  String? _error;`
- `field` **_pendingNonce (BluetoothClientService)** — baris 65 — `  String? _pendingNonce;`
- `field` **_authenticated (BluetoothClientService)** — baris 68 — `  bool _authenticated = false;`
- `field` **_lastDevice (BluetoothClientService)** — baris 85 — `  BluetoothDeviceInfo? _lastDevice;`
- `getter` **currentState (BluetoothClientService)** — baris 92 — `  BluetoothClientState get currentState => BluetoothClientState(`
- `getter` **stateStream (BluetoothClientService)** — baris 101 — `  Stream<BluetoothClientState> get stateStream => _stateController.stream;`
- `getter` **isConnected (BluetoothClientService)** — baris 103 — `  bool get isConnected => _connected;`
- `getter` **isAuthenticated (BluetoothClientService)** — baris 106 — `  bool get isAuthenticated => _authenticated;`
- `method` **shouldDisconnectBluetoothOnLifecycle (BluetoothClientService)** — baris 114 — `  static bool shouldDisconnectBluetoothOnLifecycle(AppLifecycleState state) {`
- `method` **_statusFromFlags (BluetoothClientService)** — baris 118 — `  BluetoothClientStatus _statusFromFlags() {`
- `method` **_emit (BluetoothClientService)** — baris 127 — `  void _emit() {`
- `method` **_setError (BluetoothClientService)** — baris 132 — `  void _setError(String message) {`
- `method` **startDiscovery (BluetoothClientService)** — baris 139 — `  Future<void> startDiscovery() async {`
- `method` **stopDiscovery (BluetoothClientService)** — baris 174 — `  Future<void> stopDiscovery() async {`
- `method` **handleAppLifecycleState (BluetoothClientService)** — baris 183 — `  Future<void> handleAppLifecycleState(AppLifecycleState state) async {`
- `method` **connectTo (BluetoothClientService)** — baris 190 — `  Future<void> connectTo(BluetoothDeviceInfo device) async {`
- `method` **sendPacket (BluetoothClientService)** — baris 242 — `  Future<void> sendPacket(SyncPacket packet) async {`
- `method` **_handlePacket (BluetoothClientService)** — baris 257 — `  void _handlePacket(SyncPacket packet) {`
- `method` **respondWithPin (BluetoothClientService)** — baris 288 — `  Future<void> respondWithPin(String pin) async {`
- `method` **cancelAuth (BluetoothClientService)** — baris 309 — `  Future<void> cancelAuth() async {`
- `method` **_onEvent (BluetoothClientService)** — baris 314 — `  void _onEvent(BluetoothSyncEvent event) {`
- `method` **_handleDisconnected (BluetoothClientService)** — baris 401 — `  void _handleDisconnected() {`
- `method` **_attemptReconnect (BluetoothClientService)** — baris 450 — `  Future<void> _attemptReconnect() async {`
- `method` **_cancelReconnect (BluetoothClientService)** — baris 467 — `  void _cancelReconnect() {`
- `method` **_cancelReconnectTimer (BluetoothClientService)** — baris 472 — `  void _cancelReconnectTimer() {`
- `method` **_subscribeEvents (BluetoothClientService)** — baris 477 — `  void _subscribeEvents() {`
- `method` **disconnect (BluetoothClientService)** — baris 487 — `  Future<void> disconnect() async {`
- `method` **dispose (BluetoothClientService)** — baris 507 — `  Future<void> dispose() async {`

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
- `method` **sendKasUpdate (RemoteWsClient)** — baris 127 — `  void sendKasUpdate(List<KasTransaction> transactions) {`
- `method` **sendSkipAdhan (RemoteWsClient)** — baris 137 — `  void sendSkipAdhan() {`
- `method` **sendStartShalat (RemoteWsClient)** — baris 142 — `  void sendStartShalat() {`
- `method` **sendStartIqomah (RemoteWsClient)** — baris 147 — `  void sendStartIqomah() {`
- `method` **sendFinishShalat (RemoteWsClient)** — baris 152 — `  void sendFinishShalat() {`
- `method` **sendSetMuted (RemoteWsClient)** — baris 157 — `  void sendSetMuted(bool muted) {`
- `method` **sendSetStandby (RemoteWsClient)** — baris 165 — `  void sendSetStandby(bool standby) {`
- `method` **sendForcePhase (RemoteWsClient)** — baris 173 — `  void sendForcePhase(PrayerPhase phase) {`
- `method` **disconnect (RemoteWsClient)** — baris 180 — `  void disconnect() {`

### `apps/mobile_remote/lib/theme/remote_theme.dart`
- `function` **masjidSeedScheme** — baris 9 — `ColorScheme masjidSeedScheme(Brightness brightness) {`
- `function` **buildRemoteTheme** — baris 41 — `ThemeData buildRemoteTheme(ColorScheme scheme) {`

### `apps/mobile_remote/lib/theme/theme_preferences.dart`
- `enum` **AppColorSource** — baris 5 — `enum AppColorSource {`
- `class` **ThemePreferences** — baris 19 — `class ThemePreferences {`
- `field` **modeKey (ThemePreferences)** — baris 22 — `  static const String modeKey = 'theme_mode_preference';`
- `field` **colorSourceKey (ThemePreferences)** — baris 23 — `  static const String colorSourceKey = 'color_source_preference';`
- `method` **loadMode (ThemePreferences)** — baris 25 — `  static Future<ThemeMode> loadMode() async {`
- `method` **loadColorSource (ThemePreferences)** — baris 34 — `  static Future<AppColorSource> loadColorSource() async {`
- `method` **saveMode (ThemePreferences)** — baris 43 — `  static Future<void> saveMode(ThemeMode mode) async {`
- `method` **saveColorSource (ThemePreferences)** — baris 48 — `  static Future<void> saveColorSource(AppColorSource source) async {`

### `apps/mobile_remote/lib/widgets/kas_stat_card.dart`
- `class` **KasStatCard** — baris 3 — `class KasStatCard extends StatelessWidget {`
- `field` **title (KasStatCard)** — baris 4 — `  final String title;`
- `field` **amount (KasStatCard)** — baris 5 — `  final String amount;`
- `field` **icon (KasStatCard)** — baris 6 — `  final IconData icon;`
- `field` **color (KasStatCard)** — baris 7 — `  final Color color;`
- `method` **build (KasStatCard)** — baris 18 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/main.dart`
- `function` **main** — baris 23 — `void main() async {`
- `class` **MasjidYouTVApp** — baris 39 — `class MasjidYouTVApp extends StatelessWidget {`
- `method` **build (MasjidYouTVApp)** — baris 43 — `  Widget build(BuildContext context) {`
- `class` **MasjidDisplayScreen** — baris 53 — `class MasjidDisplayScreen extends StatefulWidget {`
- `field` **initialConfig (MasjidDisplayScreen)** — baris 61 — `  final MosqueConfig? initialConfig;`
- `field` **autoPrayerCycle (MasjidDisplayScreen)** — baris 64 — `  final bool autoPrayerCycle;`
- `method` **createState (MasjidDisplayScreen)** — baris 67 — `  State<MasjidDisplayScreen> createState() => _MasjidDisplayScreenState();`
- `class` **_MasjidDisplayScreenState** — baris 70 — `class _MasjidDisplayScreenState extends State<MasjidDisplayScreen> {`
- `field` **_now (_MasjidDisplayScreenState)** — baris 71 — `  DateTime _now = DateTime.now();`
- `field` **_clockTimer (_MasjidDisplayScreenState)** — baris 72 — `  Timer? _clockTimer;`
- `field` **_localServer (_MasjidDisplayScreenState)** — baris 73 — `  LocalServer? _localServer;`
- `field` **_btHost (_MasjidDisplayScreenState)** — baris 76 — `  BluetoothHostService? _btHost;`
- `field` **_btState (_MasjidDisplayScreenState)** — baris 77 — `  BluetoothHostState? _btState;`
- `field` **_btEnabled (_MasjidDisplayScreenState)** — baris 81 — `  bool _btEnabled = false;`
- `field` **_showAdminMenu (_MasjidDisplayScreenState)** — baris 84 — `  bool _showAdminMenu = false;`
- `field` **_config (_MasjidDisplayScreenState)** — baris 86 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_prayerStateMachine (_MasjidDisplayScreenState)** — baris 93 — `  final PrayerStateMachine _prayerStateMachine = PrayerStateMachine();`
- `field` **_sideImages (_MasjidDisplayScreenState)** — baris 96 — `  List<SpecialImage> _sideImages = const [];`
- `field` **_runningTexts (_MasjidDisplayScreenState)** — baris 98 — `  List<RunningTextMessage> _runningTexts = const [`
- `field` **_banners (_MasjidDisplayScreenState)** — baris 113 — `  List<MediaBanner> _banners = const [`
- `field` **_kasTransactions (_MasjidDisplayScreenState)** — baris 130 — `  List<KasTransaction> _kasTransactions = [`
- `field` **_prayerSchedule (_MasjidDisplayScreenState)** — baris 154 — `  late PrayerSchedule _prayerSchedule;`
- `field` **_store (_MasjidDisplayScreenState)** — baris 157 — `  final TvStore _store = TvStore();`
- `field` **_hasStoredData (_MasjidDisplayScreenState)** — baris 161 — `  bool _hasStoredData = false;`
- `field` **_muted (_MasjidDisplayScreenState)** — baris 165 — `  bool _muted = false;`
- `field` **_standby (_MasjidDisplayScreenState)** — baris 166 — `  bool _standby = false;`
- `method` **initState (_MasjidDisplayScreenState)** — baris 169 — `  void initState() {`
- `method` **_initFromStore (_MasjidDisplayScreenState)** — baris 195 — `  Future<void> _initFromStore() async {`
- `method` **_recalculateSchedule (_MasjidDisplayScreenState)** — baris 231 — `  void _recalculateSchedule() {`
- `method` **_initLocalServer (_MasjidDisplayScreenState)** — baris 235 — `  Future<void> _initLocalServer() async {`
- `method` **_handleSyncPacket (_MasjidDisplayScreenState)** — baris 248 — `  void _handleSyncPacket(SyncPacket packet) {`
- `field` **_btStateSub (_MasjidDisplayScreenState)** — baris 359 — `  StreamSubscription<BluetoothHostState>? _btStateSub;`
- `method` **_initBluetoothHost (_MasjidDisplayScreenState)** — baris 361 — `  Future<void> _initBluetoothHost() async {`
- `method` **_toggleBluetooth (_MasjidDisplayScreenState)** — baris 392 — `  Future<void> _toggleBluetooth(bool enable) async {`
- `method` **_broadcastSnapshot (_MasjidDisplayScreenState)** — baris 421 — `  void _broadcastSnapshot() {`
- `method` **_broadcastState (_MasjidDisplayScreenState)** — baris 438 — `  void _broadcastState() {`
- `method` **_onStateMachineChanged (_MasjidDisplayScreenState)** — baris 454 — `  void _onStateMachineChanged() {`
- `method` **dispose (_MasjidDisplayScreenState)** — baris 460 — `  void dispose() {`
- `method` **build (_MasjidDisplayScreenState)** — baris 472 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/server/bluetooth_host_service.dart`
- `enum` **BluetoothHostStatus** — baris 10 — `enum BluetoothHostStatus {`
- `class` **BluetoothHostState** — baris 17 — `class BluetoothHostState {`
- `field` **status (BluetoothHostState)** — baris 18 — `  final BluetoothHostStatus status;`
- `field` **peerName (BluetoothHostState)** — baris 19 — `  final String? peerName;`
- `field` **error (BluetoothHostState)** — baris 20 — `  final String? error;`
- `field` **authenticated (BluetoothHostState)** — baris 24 — `  final bool authenticated;`
- `getter` **isActive (BluetoothHostState)** — baris 33 — `  bool get isActive => status == BluetoothHostStatus.connected;`
- `getter` **isAuthenticated (BluetoothHostState)** — baris 36 — `  bool get isAuthenticated => isActive && authenticated;`
- `class` **BluetoothHostService** — baris 43 — `class BluetoothHostService {`
- `field` **discoverableRefresh (BluetoothHostService)** — baris 47 — `  final Duration discoverableRefresh;`
- `field` **discoverableSeconds (BluetoothHostService)** — baris 50 — `  final int discoverableSeconds;`
- `field` **_stateController (BluetoothHostService)** — baris 52 — `  final _stateController = StreamController<BluetoothHostState>.broadcast();`
- `field` **_subscription (BluetoothHostService)** — baris 53 — `  StreamSubscription<BluetoothSyncEvent>? _subscription;`
- `field` **_discoverableTimer (BluetoothHostService)** — baris 54 — `  Timer? _discoverableTimer;`
- `field` **_started (BluetoothHostService)** — baris 55 — `  bool _started = false;`
- `field` **_connected (BluetoothHostService)** — baris 56 — `  bool _connected = false;`
- `field` **_peerName (BluetoothHostService)** — baris 57 — `  String? _peerName;`
- `field` **_discoverableFailures (BluetoothHostService)** — baris 58 — `  int _discoverableFailures = 0;`
- `field` **_discoverableRequestInFlight (BluetoothHostService)** — baris 59 — `  bool _discoverableRequestInFlight = false;`
- `field` **_pin (BluetoothHostService)** — baris 63 — `  String? _pin;`
- `getter` **pin (BluetoothHostService)** — baris 64 — `  String? get pin => _pin;`
- `field` **_nonce (BluetoothHostService)** — baris 67 — `  String? _nonce;`
- `field` **_authenticated (BluetoothHostService)** — baris 70 — `  bool _authenticated = false;`
- `field` **_maxAuthAttempts (BluetoothHostService)** — baris 73 — `  static const int _maxAuthAttempts = 3;`
- `field` **_authAttempts (BluetoothHostService)** — baris 74 — `  int _authAttempts = 0;`
- `field` **_pinLength (BluetoothHostService)** — baris 77 — `  static const int _pinLength = 4;`
- `field` **_random (BluetoothHostService)** — baris 78 — `  final Random _random = Random.secure();`
- `field` **_currentState (BluetoothHostService)** — baris 86 — `  BluetoothHostState _currentState =`
- `method` **BluetoothHostState (BluetoothHostService)** — baris 87 — `      const BluetoothHostState(status: BluetoothHostStatus.idle);`
- `getter` **currentState (BluetoothHostService)** — baris 88 — `  BluetoothHostState get currentState => _currentState;`
- `getter` **stateStream (BluetoothHostService)** — baris 90 — `  Stream<BluetoothHostState> get stateStream => _stateController.stream;`
- `getter` **isRunning (BluetoothHostService)** — baris 92 — `  bool get isRunning => _started;`
- `getter` **isConnected (BluetoothHostService)** — baris 93 — `  bool get isConnected => _connected;`
- `method` **_emit (BluetoothHostService)** — baris 95 — `  void _emit(BluetoothHostState state) {`
- `method` **start (BluetoothHostService)** — baris 103 — `  Future<void> start() async {`
- `method` **_requestPermission (BluetoothHostService)** — baris 164 — `  Future<bool> _requestPermission() async {`
- `method` **_makeDiscoverable (BluetoothHostService)** — baris 181 — `  Future<bool> _makeDiscoverable() async {`
- `method` **_fail (BluetoothHostService)** — baris 217 — `  void _fail(String message) {`
- `method` **_onEvent (BluetoothHostService)** — baris 231 — `  void _onEvent(BluetoothSyncEvent event) {`
- `method` **_handlePacket (BluetoothHostService)** — baris 297 — `  void _handlePacket(SyncPacket packet) {`
- `method` **_handleAuthResponse (BluetoothHostService)** — baris 319 — `  void _handleAuthResponse(SyncPacket packet) {`
- `method` **_registerAuthFailure (BluetoothHostService)** — baris 348 — `  void _registerAuthFailure(String reason) {`
- `method` **_sendAuthChallenge (BluetoothHostService)** — baris 375 — `  Future<void> _sendAuthChallenge() async {`
- `method` **_sendPacket (BluetoothHostService)** — baris 384 — `  Future<void> _sendPacket(SyncPacket packet) async {`
- `method` **_generatePin (BluetoothHostService)** — baris 395 — `  String _generatePin() {`
- `method` **_generateNonce (BluetoothHostService)** — baris 401 — `  String _generateNonce() {`
- `method` **broadcast (BluetoothHostService)** — baris 407 — `  Future<void> broadcast(SyncPacket packet) async {`
- `method` **stop (BluetoothHostService)** — baris 412 — `  Future<void> stop() async {`

### `apps/tv_display/lib/server/local_ws_server.dart`
- `class` **LocalServer** — baris 10 — `class LocalServer {`
- `field` **_server (LocalServer)** — baris 11 — `  HttpServer? _server;`
- `field` **_clients (LocalServer)** — baris 12 — `  final List<WebSocketChannel> _clients = [];`
- `method` **broadcast (LocalServer)** — baris 48 — `  void broadcast(SyncPacket packet) {`
- `method` **stop (LocalServer)** — baris 55 — `  Future<void> stop() async {`

### `apps/tv_display/lib/state/prayer_state_machine.dart`
- `class` **PrayerStateMachine** — baris 17 — `class PrayerStateMachine extends ChangeNotifier {`
- `field` **_config (PrayerStateMachine)** — baris 18 — `  MosqueConfig _config = const MosqueConfig();`
- `field` **_phase (PrayerStateMachine)** — baris 19 — `  PrayerPhase _phase = PrayerPhase.normal;`
- `field` **_prayer (PrayerStateMachine)** — baris 20 — `  PrayerType? _prayer;`
- `field` **_deadline (PrayerStateMachine)** — baris 21 — `  DateTime _deadline = DateTime.now();`
- `field` **_remaining (PrayerStateMachine)** — baris 22 — `  Duration _remaining = Duration.zero;`
- `field` **_total (PrayerStateMachine)** — baris 23 — `  Duration _total = Duration.zero;`
- `field` **_autoCycle (PrayerStateMachine)** — baris 24 — `  bool _autoCycle = true;`
- `getter` **phase (PrayerStateMachine)** — baris 26 — `  PrayerPhase get phase => _phase;`
- `getter` **prayer (PrayerStateMachine)** — baris 27 — `  PrayerType? get prayer => _prayer;`
- `getter` **remaining (PrayerStateMachine)** — baris 28 — `  Duration get remaining => _remaining;`
- `getter` **total (PrayerStateMachine)** — baris 29 — `  Duration get total => _total;`
- `getter` **autoCycle (PrayerStateMachine)** — baris 30 — `  bool get autoCycle => _autoCycle;`
- `getter` **deadline (PrayerStateMachine)** — baris 36 — `  DateTime get deadline => _deadline;`
- `getter` **progress (PrayerStateMachine)** — baris 38 — `  double get progress {`
- `method` **updateConfig (PrayerStateMachine)** — baris 51 — `  void updateConfig(MosqueConfig config, DateTime now) {`
- `method` **tick (PrayerStateMachine)** — baris 65 — `  void tick(DateTime now, PrayerSchedule schedule) {`
- `method` **startIqomah (PrayerStateMachine)** — baris 106 — `  void startIqomah() {`
- `method` **startShalat (PrayerStateMachine)** — baris 113 — `  void startShalat() {`
- `method` **finishShalat (PrayerStateMachine)** — baris 120 — `  void finishShalat() {`
- `method` **_advance (PrayerStateMachine)** — baris 156 — `  void _advance(DateTime now) {`
- `method` **_isFridayPrayerDay (PrayerStateMachine)** — baris 181 — `  bool _isFridayPrayerDay(DateTime date) =>`
- `method` **_enter (PrayerStateMachine)** — baris 184 — `  void _enter(PrayerPhase phase, PrayerType? prayer, DateTime now) {`

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
- `field` **hasDataKey (TvStore)** — baris 19 — `  static const String hasDataKey = 'tv_hasData';`
- `field` **mutedKey (TvStore)** — baris 20 — `  static const String mutedKey = 'tv_muted';`
- `field` **standbyKey (TvStore)** — baris 21 — `  static const String standbyKey = 'tv_standby';`
- `method` **load (TvStore)** — baris 24 — `  Future<StateSnapshot?> load() async {`
- `method` **saveConfig (TvStore)** — baris 56 — `  Future<void> saveConfig(MosqueConfig config) =>`
- `method` **saveRunningTexts (TvStore)** — baris 59 — `  Future<void> saveRunningTexts(List<RunningTextMessage> messages) =>`
- `method` **saveBanners (TvStore)** — baris 62 — `  Future<void> saveBanners(List<MediaBanner> banners) =>`
- `method` **saveKas (TvStore)** — baris 65 — `  Future<void> saveKas(List<KasTransaction> transactions) =>`
- `method` **saveSideImages (TvStore)** — baris 68 — `  Future<void> saveSideImages(List<SpecialImage> images) =>`
- `method` **saveMuted (TvStore)** — baris 86 — `  Future<void> saveMuted(bool muted) => _saveBool(mutedKey, muted);`
- `method` **saveStandby (TvStore)** — baris 88 — `  Future<void> saveStandby(bool standby) => _saveBool(standbyKey, standby);`
- `method` **_saveBool (TvStore)** — baris 90 — `  Future<void> _saveBool(String key, bool value) async {`
- `method` **_save (TvStore)** — baris 99 — `  Future<void> _save(String key, Object value) async {`
- `method` **_decodeMap (TvStore)** — baris 111 — `  static Map<String, dynamic>? _decodeMap(String source) {`

### `apps/tv_display/lib/theme/app_theme.dart`
- `class` **AppTheme** — baris 6 — `class AppTheme {`
- `getter` **darkTheme (AppTheme)** — baris 7 — `  static ThemeData get darkTheme {`

### `apps/tv_display/lib/theme/m3_shape_border.dart`
- `class` **M3ShapeBorder** — baris 14 — `class M3ShapeBorder extends OutlinedBorder {`
- `field` **polygon (M3ShapeBorder)** — baris 17 — `  final RoundedPolygon polygon;`
- `method` **_scaledPath (M3ShapeBorder)** — baris 34 — `  Path _scaledPath(Rect rect) {`
- `method` **scale (M3ShapeBorder)** — baris 58 — `  ShapeBorder scale(double t) {`
- `class` **ArchBorder** — baris 69 — `class ArchBorder extends OutlinedBorder {`
- `field` **bottomRadius (ArchBorder)** — baris 77 — `  final double bottomRadius;`
- `field` **domeFactor (ArchBorder)** — baris 81 — `  final double domeFactor;`
- `getter` **dimensions (ArchBorder)** — baris 84 — `  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);`
- `method` **scale (ArchBorder)** — baris 126 — `  ShapeBorder scale(double t) {`

### `apps/tv_display/lib/widgets/admin_menu_overlay.dart`
- `class` **AdminMenuOverlay** — baris 23 — `class AdminMenuOverlay extends StatefulWidget {`
- `field` **btEnabled (AdminMenuOverlay)** — baris 25 — `  final bool btEnabled;`
- `field` **pin (AdminMenuOverlay)** — baris 28 — `  final String? pin;`
- `field` **statusText (AdminMenuOverlay)** — baris 31 — `  final String? statusText;`
- `field` **isError (AdminMenuOverlay)** — baris 34 — `  final bool isError;`
- `field` **onToggleBluetooth (AdminMenuOverlay)** — baris 37 — `  final ValueChanged<bool> onToggleBluetooth;`
- `field` **onClose (AdminMenuOverlay)** — baris 40 — `  final VoidCallback onClose;`
- `method` **createState (AdminMenuOverlay)** — baris 52 — `  State<AdminMenuOverlay> createState() => _AdminMenuOverlayState();`
- `class` **_AdminMenuOverlayState** — baris 55 — `class _AdminMenuOverlayState extends State<AdminMenuOverlay>`
- `field` **_controller (_AdminMenuOverlayState)** — baris 57 — `  late final AnimationController _controller;`
- `field` **_slideIn (_AdminMenuOverlayState)** — baris 58 — `  late final Animation<Offset> _slideIn;`
- `field` **_slideOut (_AdminMenuOverlayState)** — baris 59 — `  late final Animation<Offset> _slideOut;`
- `field` **_panelScope (_AdminMenuOverlayState)** — baris 63 — `  late final FocusScopeNode _panelScope;`
- `field` **_closing (_AdminMenuOverlayState)** — baris 66 — `  bool _closing = false;`
- `method` **initState (_AdminMenuOverlayState)** — baris 69 — `  void initState() {`
- `method` **dispose (_AdminMenuOverlayState)** — baris 91 — `  void dispose() {`
- `method` **_close (_AdminMenuOverlayState)** — baris 98 — `  void _close() {`
- `method` **build (_AdminMenuOverlayState)** — baris 107 — `  Widget build(BuildContext context) {`
- `class` **_AdminAction** — baris 303 — `class _AdminAction {`
- `field` **icon (_AdminAction)** — baris 304 — `  final IconData icon;`
- `field` **label (_AdminAction)** — baris 305 — `  final String label;`
- `field` **subtitle (_AdminAction)** — baris 306 — `  final String subtitle;`
- `field` **selected (_AdminAction)** — baris 309 — `  final bool selected;`
- `field` **onActivate (_AdminAction)** — baris 310 — `  final VoidCallback onActivate;`
- `class` **_FocusableAction** — baris 323 — `class _FocusableAction extends StatefulWidget {`
- `field` **action (_FocusableAction)** — baris 324 — `  final _AdminAction action;`
- `field` **autofocus (_FocusableAction)** — baris 327 — `  final bool autofocus;`
- `method` **createState (_FocusableAction)** — baris 332 — `  State<_FocusableAction> createState() => _FocusableActionState();`
- `class` **_FocusableActionState** — baris 335 — `class _FocusableActionState extends State<_FocusableAction> {`
- `field` **_focused (_FocusableActionState)** — baris 336 — `  bool _focused = false;`
- `method` **build (_FocusableActionState)** — baris 339 — `  Widget build(BuildContext context) {`

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
- `method` **build (_BannerCarouselState)** — baris 72 — `  Widget build(BuildContext context) {`
- `class` **_BannerPage** — baris 145 — `class _BannerPage extends StatefulWidget {`
- `field` **banner (_BannerPage)** — baris 146 — `  final MediaBanner banner;`
- `field` **active (_BannerPage)** — baris 147 — `  final bool active;`
- `method` **createState (_BannerPage)** — baris 155 — `  State<_BannerPage> createState() => _BannerPageState();`
- `class` **_BannerPageState** — baris 158 — `class _BannerPageState extends State<_BannerPage> {`
- `field` **_scrollController (_BannerPageState)** — baris 159 — `  final _scrollController = ScrollController();`
- `field` **_scrollTimer (_BannerPageState)** — baris 160 — `  Timer? _scrollTimer;`
- `field` **_cachedImageBytes (_BannerPageState)** — baris 161 — `  Uint8List? _cachedImageBytes;`
- `field` **_cachedBase64 (_BannerPageState)** — baris 162 — `  String? _cachedBase64;`
- `method` **initState (_BannerPageState)** — baris 165 — `  void initState() {`
- `method` **_decodeImageIfNeeded (_BannerPageState)** — baris 171 — `  void _decodeImageIfNeeded() {`
- `method` **didUpdateWidget (_BannerPageState)** — baris 181 — `  void didUpdateWidget(covariant _BannerPage oldWidget) {`
- `method` **_startAutoScroll (_BannerPageState)** — baris 206 — `  void _startAutoScroll() {`
- `method` **dispose (_BannerPageState)** — baris 232 — `  void dispose() {`
- `method` **build (_BannerPageState)** — baris 239 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/friday_staff_card.dart`
- `class` **FridayStaffCard** — baris 7 — `class FridayStaffCard extends StatelessWidget {`
- `field` **khatib (FridayStaffCard)** — baris 8 — `  final String khatib;`
- `field` **muadzin (FridayStaffCard)** — baris 9 — `  final String muadzin;`
- `method` **build (FridayStaffCard)** — baris 18 — `  Widget build(BuildContext context) {`
- `class` **_StaffRow** — baris 74 — `class _StaffRow extends StatelessWidget {`
- `field` **icon (_StaffRow)** — baris 75 — `  final IconData icon;`
- `field` **label (_StaffRow)** — baris 76 — `  final String label;`
- `field` **name (_StaffRow)** — baris 77 — `  final String name;`
- `method` **build (_StaffRow)** — baris 86 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/header_clock.dart`
- `class` **HeaderClock** — baris 7 — `class HeaderClock extends StatelessWidget {`
- `field` **config (HeaderClock)** — baris 8 — `  final MosqueConfig config;`
- `field` **currentTime (HeaderClock)** — baris 9 — `  final DateTime currentTime;`
- `method` **build (HeaderClock)** — baris 18 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/kas_summary_card.dart`
- `class` **KasSummaryCard** — baris 5 — `class KasSummaryCard extends StatelessWidget {`
- `field` **transactions (KasSummaryCard)** — baris 6 — `  final List<KasTransaction> transactions;`
- `method` **build (KasSummaryCard)** — baris 14 — `  Widget build(BuildContext context) {`
- `class` **_KasAmountRow** — baris 93 — `class _KasAmountRow extends StatelessWidget {`
- `field` **icon (_KasAmountRow)** — baris 94 — `  final IconData icon;`
- `field` **label (_KasAmountRow)** — baris 95 — `  final String label;`
- `field` **amount (_KasAmountRow)** — baris 96 — `  final String amount;`
- `field` **color (_KasAmountRow)** — baris 97 — `  final Color color;`
- `method` **build (_KasAmountRow)** — baris 107 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/widgets/material_blob_background.dart`
- `class` **MaterialBlobBackground** — baris 14 — `class MaterialBlobBackground extends StatefulWidget {`
- `method` **createState (MaterialBlobBackground)** — baris 18 — `  State<MaterialBlobBackground> createState() => _MaterialBlobBackgroundState();`
- `class` **_MaterialBlobBackgroundState** — baris 21 — `class _MaterialBlobBackgroundState extends State<MaterialBlobBackground>`
- `field` **_controller (_MaterialBlobBackgroundState)** — baris 23 — `  late final AnimationController _controller = AnimationController(`
- `method` **dispose (_MaterialBlobBackgroundState)** — baris 29 — `  void dispose() {`
- `method` **build (_MaterialBlobBackgroundState)** — baris 35 — `  Widget build(BuildContext context) {`
- `class` **_ShapeSpec** — baris 107 — `class _ShapeSpec {`
- `field` **polygon (_ShapeSpec)** — baris 108 — `  final RoundedPolygon polygon;`
- `field` **color (_ShapeSpec)** — baris 109 — `  final Color color;`
- `field` **centerX (_ShapeSpec)** — baris 110 — `  final double centerX;`
- `field` **centerY (_ShapeSpec)** — baris 111 — `  final double centerY;`
- `field` **radiusX (_ShapeSpec)** — baris 112 — `  final double radiusX;`
- `field` **radiusY (_ShapeSpec)** — baris 113 — `  final double radiusY;`
- `field` **rotationSpeed (_ShapeSpec)** — baris 114 — `  final double rotationSpeed;`
- `field` **driftSpeed (_ShapeSpec)** — baris 115 — `  final double driftSpeed;`
- `field` **driftPhase (_ShapeSpec)** — baris 116 — `  final double driftPhase;`
- `field` **size (_ShapeSpec)** — baris 117 — `  final double size;`
- `field` **centeredPath (_ShapeSpec)** — baris 119 — `  late final Path centeredPath = _buildCenteredPath();`
- `method` **_buildCenteredPath (_ShapeSpec)** — baris 136 — `  Path _buildCenteredPath() {`
- `class` **_M3ShapePainter** — baris 148 — `class _M3ShapePainter extends CustomPainter {`
- `field` **animation (_M3ShapePainter)** — baris 149 — `  final Animation<double> animation;`
- `field` **blobs (_M3ShapePainter)** — baris 150 — `  final List<_ShapeSpec> blobs;`
- `method` **paint (_M3ShapePainter)** — baris 158 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_M3ShapePainter)** — baris 185 — `  bool shouldRepaint(covariant _M3ShapePainter oldDelegate) {`

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
- `method` **_formatDuration (_NextPrayerTimerState)** — baris 225 — `  String _formatDuration(Duration duration) {`

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
- `class` **_AdhanOverlay** — baris 161 — `class _AdhanOverlay extends StatelessWidget {`
- `field` **prayerName (_AdhanOverlay)** — baris 162 — `  final String prayerName;`
- `field` **remaining (_AdhanOverlay)** — baris 163 — `  final Duration remaining;`
- `field` **total (_AdhanOverlay)** — baris 164 — `  final Duration total;`
- `field` **deadline (_AdhanOverlay)** — baris 165 — `  final DateTime? deadline;`
- `method` **build (_AdhanOverlay)** — baris 175 — `  Widget build(BuildContext context) {`
- `class` **_KhutbahOverlay** — baris 247 — `class _KhutbahOverlay extends StatelessWidget {`
- `field` **khatib (_KhutbahOverlay)** — baris 248 — `  final String? khatib;`
- `field` **muadzin (_KhutbahOverlay)** — baris 249 — `  final String? muadzin;`
- `field` **remaining (_KhutbahOverlay)** — baris 250 — `  final Duration remaining;`
- `field` **total (_KhutbahOverlay)** — baris 251 — `  final Duration total;`
- `method` **build (_KhutbahOverlay)** — baris 261 — `  Widget build(BuildContext context) {`
- `class` **_StaffChip** — baris 351 — `class _StaffChip extends StatelessWidget {`
- `field` **icon (_StaffChip)** — baris 352 — `  final IconData icon;`
- `field` **label (_StaffChip)** — baris 353 — `  final String label;`
- `field` **name (_StaffChip)** — baris 354 — `  final String? name;`
- `method` **build (_StaffChip)** — baris 363 — `  Widget build(BuildContext context) {`
- `class` **_ShalatOverlay** — baris 404 — `class _ShalatOverlay extends StatelessWidget {`
- `field` **prayerName (_ShalatOverlay)** — baris 405 — `  final String prayerName;`
- `method` **build (_ShalatOverlay)** — baris 410 — `  Widget build(BuildContext context) {`
- `class` **_AnimatedProgressRing** — baris 428 — `class _AnimatedProgressRing extends StatelessWidget {`
- `field` **progress (_AnimatedProgressRing)** — baris 429 — `  final double progress;`
- `field` **size (_AnimatedProgressRing)** — baris 430 — `  final double size;`
- `field` **strokeWidth (_AnimatedProgressRing)** — baris 431 — `  final double strokeWidth;`
- `field` **color (_AnimatedProgressRing)** — baris 432 — `  final Color color;`
- `field` **trackColor (_AnimatedProgressRing)** — baris 433 — `  final Color trackColor;`
- `field` **child (_AnimatedProgressRing)** — baris 434 — `  final Widget child;`
- `method` **build (_AnimatedProgressRing)** — baris 446 — `  Widget build(BuildContext context) {`
- `class` **_WavyProgressBar** — baris 481 — `class _WavyProgressBar extends StatefulWidget {`
- `field` **remaining (_WavyProgressBar)** — baris 482 — `  final Duration remaining;`
- `field` **total (_WavyProgressBar)** — baris 483 — `  final Duration total;`
- `field` **deadline (_WavyProgressBar)** — baris 484 — `  final DateTime? deadline;`
- `field` **activeColor (_WavyProgressBar)** — baris 485 — `  final Color activeColor;`
- `field` **trackColor (_WavyProgressBar)** — baris 486 — `  final Color trackColor;`
- `method` **createState (_WavyProgressBar)** — baris 497 — `  State<_WavyProgressBar> createState() => _WavyProgressBarState();`
- `class` **_WavyProgressBarState** — baris 500 — `class _WavyProgressBarState extends State<_WavyProgressBar>`
- `field` **_controller (_WavyProgressBarState)** — baris 502 — `  late final AnimationController _controller = AnimationController(`
- `method` **dispose (_WavyProgressBarState)** — baris 508 — `  void dispose() {`
- `method` **build (_WavyProgressBarState)** — baris 514 — `  Widget build(BuildContext context) {`
- `function` **_formatCountdown** — baris 529 — `String _formatCountdown(Duration duration) {`
- `class` **_CircularRingPainter** — baris 548 — `class _CircularRingPainter extends CustomPainter {`
- `field` **progress (_CircularRingPainter)** — baris 549 — `  final double progress;`
- `field` **trackColor (_CircularRingPainter)** — baris 550 — `  final Color trackColor;`
- `field` **progressColor (_CircularRingPainter)** — baris 551 — `  final Color progressColor;`
- `field` **strokeWidth (_CircularRingPainter)** — baris 552 — `  final double strokeWidth;`
- `method` **paint (_CircularRingPainter)** — baris 562 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_CircularRingPainter)** — baris 589 — `  bool shouldRepaint(covariant _CircularRingPainter oldDelegate) {`
- `class` **_WavyProgressPainter** — baris 604 — `class _WavyProgressPainter extends CustomPainter {`
- `field` **animation (_WavyProgressPainter)** — baris 605 — `  final Animation<double> animation;`
- `field` **remaining (_WavyProgressPainter)** — baris 606 — `  final Duration remaining;`
- `field` **total (_WavyProgressPainter)** — baris 607 — `  final Duration total;`
- `field` **deadline (_WavyProgressPainter)** — baris 608 — `  final DateTime? deadline;`
- `field` **activeColor (_WavyProgressPainter)** — baris 609 — `  final Color activeColor;`
- `field` **trackColor (_WavyProgressPainter)** — baris 610 — `  final Color trackColor;`
- `method` **paint (_WavyProgressPainter)** — baris 622 — `  void paint(Canvas canvas, Size size) {`
- `method` **shouldRepaint (_WavyProgressPainter)** — baris 697 — `  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {`

### `apps/tv_display/lib/widgets/running_text_bar.dart`
- `class` **RunningTextBar** — baris 5 — `class RunningTextBar extends StatefulWidget {`
- `field` **messages (RunningTextBar)** — baris 6 — `  final List<RunningTextMessage> messages;`
- `method` **createState (RunningTextBar)** — baris 14 — `  State<RunningTextBar> createState() => _RunningTextBarState();`
- `class` **_RunningTextBarState** — baris 17 — `class _RunningTextBarState extends State<RunningTextBar> {`
- `field` **_scrollController (_RunningTextBarState)** — baris 18 — `  late ScrollController _scrollController;`
- `field` **_timer (_RunningTextBarState)** — baris 19 — `  Timer? _timer;`
- `method` **initState (_RunningTextBarState)** — baris 22 — `  void initState() {`
- `method` **didUpdateWidget (_RunningTextBarState)** — baris 31 — `  void didUpdateWidget(RunningTextBar oldWidget) {`
- `method` **_startAutoScroll (_RunningTextBarState)** — baris 65 — `  void _startAutoScroll() {`
- `method` **dispose (_RunningTextBarState)** — baris 83 — `  void dispose() {`
- `method` **build (_RunningTextBarState)** — baris 90 — `  Widget build(BuildContext context) {`
- `method` **_buildEmptyState (_RunningTextBarState)** — baris 104 — `  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {`

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
- `method` **stopDiscovery (BluetoothSync)** — baris 212 — `  static Future<void> stopDiscovery() =>`
- `method` **connect (BluetoothSync)** — baris 216 — `  static Future<void> connect(String address) =>`
- `method` **disconnect (BluetoothSync)** — baris 219 — `  static Future<void> disconnect() => _channel.invokeMethod('disconnect');`
- `method` **send (BluetoothSync)** — baris 224 — `  static Future<void> send(Uint8List bytes) =>`

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

### `packages/shared_models/lib/src/kas_transaction.dart`
- `enum` **KasType** — baris 3 — `enum KasType { masuk, keluar }`
- `class` **KasTransaction** — baris 5 — `class KasTransaction {`
- `field` **id (KasTransaction)** — baris 6 — `  final String id;`
- `field` **type (KasTransaction)** — baris 7 — `  final KasType type;`
- `field` **amount (KasTransaction)** — baris 8 — `  final int amount;`
- `field` **description (KasTransaction)** — baris 9 — `  final String description;`
- `field` **date (KasTransaction)** — baris 10 — `  final DateTime date;`
- `method` **toMap (KasTransaction)** — baris 20 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (KasTransaction)** — baris 49 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (KasTransaction)** — baris 55 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (KasTransaction)** — baris 65 — `  int get hashCode => Object.hash(id, type, amount, description, date);`
- `method` **toString (KasTransaction)** — baris 68 — `  String toString() =>`
- `class` **KasSummary** — baris 73 — `class KasSummary {`
- `field` **totalMasuk (KasSummary)** — baris 74 — `  final int totalMasuk;`
- `field` **totalKeluar (KasSummary)** — baris 75 — `  final int totalKeluar;`
- `field` **saldo (KasSummary)** — baris 76 — `  final int saldo;`
- `operator` **operator == (KasSummary)** — baris 102 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (KasSummary)** — baris 110 — `  int get hashCode => Object.hash(totalMasuk, totalKeluar, saldo);`
- `method` **toString (KasSummary)** — baris 113 — `  String toString() =>`

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
- `method` **offsetFor (MosqueConfig)** — baris 159 — `  int offsetFor(PrayerType type) => prayerOffsets[type] ?? 0;`
- `method` **toMap (MosqueConfig)** — baris 161 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (MosqueConfig)** — baris 237 — `  String toJson() => json.encode(toMap());`
- `method` **_mapsEqual (MosqueConfig)** — baris 283 — `  static bool _mapsEqual(Map<PrayerType, int> a, Map<PrayerType, int> b) {`
- `operator` **operator == (MosqueConfig)** — baris 293 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (MosqueConfig)** — baris 314 — `  int get hashCode => Object.hash(`
- `method` **toString (MosqueConfig)** — baris 334 — `  String toString() =>`

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
- `function` **_stringKeyed** — baris 11 — `Map<String, dynamic> _stringKeyed(Map raw) => {`
- `class` **StateSnapshot** — baris 43 — `class StateSnapshot {`
- `field` **config (StateSnapshot)** — baris 44 — `  final MosqueConfig config;`
- `field` **runningTexts (StateSnapshot)** — baris 45 — `  final List<RunningTextMessage> runningTexts;`
- `field` **banners (StateSnapshot)** — baris 46 — `  final List<MediaBanner> banners;`
- `field` **kasTransactions (StateSnapshot)** — baris 47 — `  final List<KasTransaction> kasTransactions;`
- `field` **sideImages (StateSnapshot)** — baris 50 — `  final List<SpecialImage> sideImages;`
- `field` **hasData (StateSnapshot)** — baris 51 — `  final bool hasData;`
- `method` **toMap (StateSnapshot)** — baris 62 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (StateSnapshot)** — baris 101 — `  bool operator ==(Object other) =>`
- `method` **_listsEqual (StateSnapshot)** — baris 109 — `          _listsEqual(other.sideImages, sideImages);`
- `getter` **hashCode (StateSnapshot)** — baris 112 — `  int get hashCode => Object.hash(`
- `method` **toString (StateSnapshot)** — baris 122 — `  String toString() => 'StateSnapshot(hasData: $hasData, config: $config, '`

### `packages/shared_models/lib/src/sync_packet.dart`
- `enum` **SyncAction** — baris 3 — `enum SyncAction {`
- `class` **SyncPacket** — baris 47 — `class SyncPacket {`
- `field` **action (SyncPacket)** — baris 48 — `  final SyncAction action;`
- `field` **payload (SyncPacket)** — baris 49 — `  final Map<String, dynamic> payload;`
- `method` **toMap (SyncPacket)** — baris 56 — `  Map<String, dynamic> toMap() => {`
- `method` **_parsePayload (SyncPacket)** — baris 76 — `  static Map<String, dynamic> _parsePayload(Object? raw) {`
- `method` **toJson (SyncPacket)** — baris 87 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (SyncPacket)** — baris 93 — `  bool operator ==(Object other) =>`
- `method` **_mapsEqual (SyncPacket)** — baris 97 — `          _mapsEqual(other.payload, payload);`
- `getter` **hashCode (SyncPacket)** — baris 108 — `  int get hashCode =>`
- `method` **toString (SyncPacket)** — baris 112 — `  String toString() => 'SyncPacket(action: ${action.name}, payload: $payload)';`
