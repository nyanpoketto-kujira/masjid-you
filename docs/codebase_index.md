# Codebase Index — Masjid You

> Dibuat otomatis oleh `dart run tools/codebase_index.dart`. Jangan edit manual — regenerate setelah perubahan kode.

Total simbol: **1036**

| Kategori | Jumlah |
|---|---:|
| `class` | 98 |
| `method` | 354 |
| `field` | 486 |
| `function` | 9 |
| `typedef` | 1 |
| `enum` | 10 |
| `getter` | 63 |
| `constructor` | 1 |
| `setter` | 1 |
| `operator` | 10 |
| `mixin` | 1 |
| `extension` | 2 |


### `apps/mobile_remote/lib/main.dart`
- `class` **RemoteHomeScreen** — baris 35 — `class RemoteHomeScreen extends StatefulWidget {`
- `method` **createState (RemoteHomeScreen)** — baris 39 — `  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();`
- `class` **_PinDialog** — baris 61 — `class _PinDialog extends StatefulWidget {`
- `field` **onSubmit (_PinDialog)** — baris 62 — `  final ValueChanged<String> onSubmit;`
- `field` **onCancel (_PinDialog)** — baris 63 — `  final VoidCallback onCancel;`
- `method` **createState (_PinDialog)** — baris 68 — `  State<_PinDialog> createState() => _PinDialogState();`
- `class` **_PinDialogState** — baris 71 — `class _PinDialogState extends State<_PinDialog> {`
- `field` **_pinController (_PinDialogState)** — baris 72 — `  final _pinController = TextEditingController();`
- `method` **dispose (_PinDialogState)** — baris 75 — `  void dispose() {`
- `method` **_submit (_PinDialogState)** — baris 80 — `  void _submit() {`
- `method` **build (_PinDialogState)** — baris 87 — `  Widget build(BuildContext context) {`
- `class` **_RemoteHomeScreenState** — baris 137 — `class _RemoteHomeScreenState extends State<RemoteHomeScreen>`
- `field` **_tabIndex (_RemoteHomeScreenState)** — baris 139 — `  int _tabIndex = 0;`
- `field` **_mainTabController (_RemoteHomeScreenState)** — baris 141 — `  late final TabController _mainTabController;`
- `field` **_subTabController (_RemoteHomeScreenState)** — baris 142 — `  late final TabController _subTabController;`
- `field` **_syncingControllers (_RemoteHomeScreenState)** — baris 143 — `  bool _syncingControllers = false;`
- `field` **_ipController (_RemoteHomeScreenState)** — baris 145 — `  final _ipController = TextEditingController(text: '192.168.1.');`
- `field` **_client (_RemoteHomeScreenState)** — baris 146 — `  final _client = RemoteWsClient();`
- `field` **_btClient (_RemoteHomeScreenState)** — baris 147 — `  final _btClient = BluetoothClientService();`
- `field` **_isConnecting (_RemoteHomeScreenState)** — baris 148 — `  bool _isConnecting = false;`
- `field` **_isConnected (_RemoteHomeScreenState)** — baris 149 — `  bool _isConnected = false;`
- `field` **_wasConnected (_RemoteHomeScreenState)** — baris 150 — `  bool _wasConnected = false;`
- `field` **_showDisconnectedNotice (_RemoteHomeScreenState)** — baris 151 — `  bool _showDisconnectedNotice = false;`
- `field` **_syncDialogOpen (_RemoteHomeScreenState)** — baris 152 — `  bool _syncDialogOpen = false;`
- `field` **_lastConnectionKind (_RemoteHomeScreenState)** — baris 153 — `  String? _lastConnectionKind;`
- `field` **_lastBtDevice (_RemoteHomeScreenState)** — baris 154 — `  BluetoothDeviceInfo? _lastBtDevice;`
- `field` **_btIsScanning (_RemoteHomeScreenState)** — baris 157 — `  bool _btIsScanning = false;`
- `field` **_btConnected (_RemoteHomeScreenState)** — baris 158 — `  bool _btConnected = false;`
- `field` **_btDevices (_RemoteHomeScreenState)** — baris 159 — `  List<BluetoothDeviceInfo> _btDevices = [];`
- `field` **_btStatus (_RemoteHomeScreenState)** — baris 160 — `  String _btStatus = 'Bluetooth: Stanby';`
- `field` **_btStateSub (_RemoteHomeScreenState)** — baris 161 — `  StreamSubscription<BluetoothClientState>? _btStateSub;`
- `field` **_hasUnsyncedChanges (_RemoteHomeScreenState)** — baris 163 — `  bool _hasUnsyncedChanges = false;`
- `field` **_pinDialogOpen (_RemoteHomeScreenState)** — baris 166 — `  bool _pinDialogOpen = false;`
- `field` **_pendingBtState (_RemoteHomeScreenState)** — baris 170 — `  BluetoothClientState? _pendingBtState;`
- `field` **_cacheStore (_RemoteHomeScreenState)** — baris 173 — `  final RemoteCacheStore _cacheStore = RemoteCacheStore();`
- `field` **_backupService (_RemoteHomeScreenState)** — baris 176 — `  final BackupService _backupService = BackupService();`
- `field` **_didBootstrapPush (_RemoteHomeScreenState)** — baris 180 — `  bool _didBootstrapPush = false;`
- `field` **_config (_RemoteHomeScreenState)** — baris 182 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_nameController (_RemoteHomeScreenState)** — baris 189 — `  final _nameController = TextEditingController();`
- `field` **_addressController (_RemoteHomeScreenState)** — baris 190 — `  final _addressController = TextEditingController();`
- `field` **_latitudeController (_RemoteHomeScreenState)** — baris 191 — `  final _latitudeController = TextEditingController();`
- `field` **_longitudeController (_RemoteHomeScreenState)** — baris 192 — `  final _longitudeController = TextEditingController();`
- `field` **_prayerOffsetControllers (_RemoteHomeScreenState)** — baris 193 — `  final Map<PrayerType, TextEditingController> _prayerOffsetControllers = {`
- `field` **_preAdhanController (_RemoteHomeScreenState)** — baris 196 — `  final _preAdhanController = TextEditingController();`
- `field` **_adhanController (_RemoteHomeScreenState)** — baris 197 — `  final _adhanController = TextEditingController();`
- `field` **_preIqomahController (_RemoteHomeScreenState)** — baris 198 — `  final _preIqomahController = TextEditingController();`
- `field` **_shalatController (_RemoteHomeScreenState)** — baris 199 — `  final _shalatController = TextEditingController();`
- `field` **_khutbahController (_RemoteHomeScreenState)** — baris 200 — `  final _khutbahController = TextEditingController();`
- `field` **_fridayKhatibController (_RemoteHomeScreenState)** — baris 201 — `  final _fridayKhatibController = TextEditingController();`
- `field` **_fridayMuadzinController (_RemoteHomeScreenState)** — baris 202 — `  final _fridayMuadzinController = TextEditingController();`
- `field` **_isFetchingLocation (_RemoteHomeScreenState)** — baris 203 — `  bool _isFetchingLocation = false;`
- `field` **_runningTextController (_RemoteHomeScreenState)** — baris 204 — `  final _runningTextController = TextEditingController();`
- `field` **_runningCategory (_RemoteHomeScreenState)** — baris 205 — `  String _runningCategory = _runningCategories.first;`
- `field` **_bannerHeaderController (_RemoteHomeScreenState)** — baris 207 — `  final _bannerHeaderController = TextEditingController();`
- `field` **_bannerTitleController (_RemoteHomeScreenState)** — baris 208 — `  final _bannerTitleController = TextEditingController();`
- `field` **_bannerContentController (_RemoteHomeScreenState)** — baris 209 — `  final _bannerContentController = TextEditingController();`
- `field` **_bannerFooterController (_RemoteHomeScreenState)** — baris 210 — `  final _bannerFooterController = TextEditingController();`
- `field` **_kasAmountController (_RemoteHomeScreenState)** — baris 212 — `  final _kasAmountController = TextEditingController();`
- `field` **_kasDescriptionController (_RemoteHomeScreenState)** — baris 213 — `  final _kasDescriptionController = TextEditingController();`
- `field` **_kasType (_RemoteHomeScreenState)** — baris 214 — `  KasType _kasType = KasType.masuk;`
- `field` **_tvPhase (_RemoteHomeScreenState)** — baris 217 — `  PrayerPhase _tvPhase = PrayerPhase.normal;`
- `field` **_kasTransactions (_RemoteHomeScreenState)** — baris 219 — `  final List<KasTransaction> _kasTransactions = [`
- `field` **_runningTexts (_RemoteHomeScreenState)** — baris 236 — `  final List<RunningTextMessage> _runningTexts = [`
- `field` **_banners (_RemoteHomeScreenState)** — baris 251 — `  final List<MediaBanner> _banners = [`
- `method` **initState (_RemoteHomeScreenState)** — baris 269 — `  void initState() {`
- `method` **didChangeAppLifecycleState (_RemoteHomeScreenState)** — baris 355 — `  void didChangeAppLifecycleState(AppLifecycleState state) {`
- `method` **_bottomNavIndexForPage (_RemoteHomeScreenState)** — baris 378 — `  int _bottomNavIndexForPage(int page) {`
- `method` **_mainPageForBottomNav (_RemoteHomeScreenState)** — baris 384 — `  int _mainPageForBottomNav(int bottom, int currentSub) {`
- `method` **_handleMainTabChange (_RemoteHomeScreenState)** — baris 395 — `  void _handleMainTabChange() {`
- `method` **_handleSubTabChange (_RemoteHomeScreenState)** — baris 410 — `  void _handleSubTabChange() {`
- `method` **_syncConfigControllers (_RemoteHomeScreenState)** — baris 420 — `  void _syncConfigControllers() {`
- `method` **_loadStartupData (_RemoteHomeScreenState)** — baris 441 — `  Future<void> _loadStartupData() async {`
- `method` **_applySnapshot (_RemoteHomeScreenState)** — baris 453 — `  void _applySnapshot(StateSnapshot snapshot) {`
- `method` **_requestTvState (_RemoteHomeScreenState)** — baris 468 — `  void _requestTvState() {`
- `method` **_showPinDialog (_RemoteHomeScreenState)** — baris 497 — `  void _showPinDialog() {`
- `method` **_closePinDialog (_RemoteHomeScreenState)** — baris 533 — `  void _closePinDialog() {`
- `method` **_drainPendingBtState (_RemoteHomeScreenState)** — baris 541 — `  void _drainPendingBtState() {`
- `method` **_loadSavedDurations (_RemoteHomeScreenState)** — baris 582 — `  Future<void> _loadSavedDurations() async {`
- `method` **_persistDurations (_RemoteHomeScreenState)** — baris 617 — `  Future<void> _persistDurations(MosqueConfig config) async {`
- `method` **_handleTvPacket (_RemoteHomeScreenState)** — baris 634 — `  void _handleTvPacket(SyncPacket packet) {`
- `method` **_applyTvPhase (_RemoteHomeScreenState)** — baris 648 — `  void _applyTvPhase(SyncPacket packet) {`
- `method` **_applyTvSnapshot (_RemoteHomeScreenState)** — baris 666 — `  void _applyTvSnapshot(StateSnapshot snapshot) {`
- `method` **_pushLocalDataToTv (_RemoteHomeScreenState)** — baris 685 — `  void _pushLocalDataToTv() {`
- `method` **_exportBackup (_RemoteHomeScreenState)** — baris 693 — `  Future<void> _exportBackup() async {`
- `method` **_importBackup (_RemoteHomeScreenState)** — baris 714 — `  Future<void> _importBackup() async {`
- `method` **_applyImportedBackup (_RemoteHomeScreenState)** — baris 768 — `  Future<void> _applyImportedBackup(BackupBundle bundle) async {`
- `method` **_connectToTv (_RemoteHomeScreenState)** — baris 791 — `  Future<void> _connectToTv() async {`
- `method` **_handleConnectionEstablished (_RemoteHomeScreenState)** — baris 822 — `  void _handleConnectionEstablished(String kind) {`
- `method` **_handleTransportDisconnected (_RemoteHomeScreenState)** — baris 841 — `  void _handleTransportDisconnected() {`
- `method` **_reconnectLast (_RemoteHomeScreenState)** — baris 850 — `  Future<void> _reconnectLast() async {`
- `method` **_showSyncConflictDialog (_RemoteHomeScreenState)** — baris 864 — `  void _showSyncConflictDialog() {`
- `method` **_disconnectFromTv (_RemoteHomeScreenState)** — baris 904 — `  Future<void> _disconnectFromTv() async {`
- `method` **_buildConfigFromForm (_RemoteHomeScreenState)** — baris 916 — `  MosqueConfig _buildConfigFromForm() {`
- `method` **_minutesFrom (_RemoteHomeScreenState)** — baris 949 — `  int _minutesFrom(TextEditingController controller, int fallback) {`
- `method` **_syncAllToTv (_RemoteHomeScreenState)** — baris 955 — `  void _syncAllToTv() {`
- `method` **_pushAllToTv (_RemoteHomeScreenState)** — baris 965 — `  void _pushAllToTv() {`
- `method` **_sendConfigUpdate (_RemoteHomeScreenState)** — baris 978 — `  void _sendConfigUpdate() {`
- `method` **_sendQuickAction (_RemoteHomeScreenState)** — baris 998 — `  void _sendQuickAction(SyncAction action) {`
- `method` **_sendForcePhase (_RemoteHomeScreenState)** — baris 1018 — `  void _sendForcePhase(PrayerPhase phase) {`
- `method` **_getLocationFromGps (_RemoteHomeScreenState)** — baris 1026 — `  Future<void> _getLocationFromGps() async {`
- `method` **_addRunningText (_RemoteHomeScreenState)** — baris 1085 — `  void _addRunningText() {`
- `method` **_removeRunningText (_RemoteHomeScreenState)** — baris 1107 — `  void _removeRunningText(String id) {`
- `method` **_editRunningText (_RemoteHomeScreenState)** — baris 1120 — `  void _editRunningText(RunningTextMessage item) {`
- `method` **_addBanner (_RemoteHomeScreenState)** — baris 1203 — `  void _addBanner(String? base64Image) {`
- `method` **_removeBanner (_RemoteHomeScreenState)** — baris 1234 — `  void _removeBanner(String id) {`
- `method` **_toggleBanner (_RemoteHomeScreenState)** — baris 1247 — `  void _toggleBanner(String id, bool val) {`
- `method` **_editBanner (_RemoteHomeScreenState)** — baris 1263 — `  void _editBanner(MediaBanner banner) {`
- `method` **_addKasTransaction (_RemoteHomeScreenState)** — baris 1341 — `  void _addKasTransaction() {`
- `method` **_removeKasTransaction (_RemoteHomeScreenState)** — baris 1368 — `  void _removeKasTransaction(String id) {`
- `method` **_startBtScan (_RemoteHomeScreenState)** — baris 1381 — `  void _startBtScan() {`
- `method` **_stopBtScan (_RemoteHomeScreenState)** — baris 1389 — `  void _stopBtScan() {`
- `method` **_connectBt (_RemoteHomeScreenState)** — baris 1397 — `  void _connectBt(BluetoothDeviceInfo device) {`
- `method` **_showScheduleSimulation (_RemoteHomeScreenState)** — baris 1407 — `  void _showScheduleSimulation(MosqueConfig formConfig) {`
- `method` **_formatDurationShort (_RemoteHomeScreenState)** — baris 1560 — `  String _formatDurationShort(Duration? duration) {`
- `method` **dispose (_RemoteHomeScreenState)** — baris 1568 — `  void dispose() {`
- `method` **build (_RemoteHomeScreenState)** — baris 1603 — `  Widget build(BuildContext context) {`
- `method` **_buildConnectionBadge (_RemoteHomeScreenState)** — baris 1793 — `  Widget _buildConnectionBadge(ColorScheme colorScheme) {`
- `method` **_buildDisconnectedBanner (_RemoteHomeScreenState)** — baris 1842 — `  Widget _buildDisconnectedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildContentTabBar (_RemoteHomeScreenState)** — baris 1871 — `  Widget _buildContentTabBar(ThemeData theme, ColorScheme colorScheme) {`
- `method` **_buildUnsyncedBanner (_RemoteHomeScreenState)** — baris 1894 — `  Widget _buildUnsyncedBanner(ThemeData theme, ColorScheme colorScheme) {`
- `class` **MasjidYouRemoteApp** — baris 1924 — `class MasjidYouRemoteApp extends StatelessWidget {`
- `method` **build (MasjidYouRemoteApp)** — baris 1928 — `  Widget build(BuildContext context) {`
- `function` **main** — baris 1943 — `void main() {`

### `apps/mobile_remote/lib/screens/connection/connection_gateway_screen.dart`
- `class` **ConnectionGatewayScreen** — baris 6 — `class ConnectionGatewayScreen extends StatelessWidget {`
- `field` **ipController (ConnectionGatewayScreen)** — baris 7 — `  final TextEditingController ipController;`
- `field` **isConnecting (ConnectionGatewayScreen)** — baris 8 — `  final bool isConnecting;`
- `field` **onConnectIp (ConnectionGatewayScreen)** — baris 9 — `  final VoidCallback onConnectIp;`
- `field` **btIsScanning (ConnectionGatewayScreen)** — baris 11 — `  final bool btIsScanning;`
- `field` **btDevices (ConnectionGatewayScreen)** — baris 12 — `  final List<BluetoothDeviceInfo> btDevices;`
- `field` **btStatus (ConnectionGatewayScreen)** — baris 13 — `  final String btStatus;`
- `field` **onBtStartScan (ConnectionGatewayScreen)** — baris 14 — `  final VoidCallback onBtStartScan;`
- `field` **onBtStopScan (ConnectionGatewayScreen)** — baris 15 — `  final VoidCallback onBtStopScan;`
- `field` **onBtConnect (ConnectionGatewayScreen)** — baris 16 — `  final ValueChanged<BluetoothDeviceInfo> onBtConnect;`
- `method` **build (ConnectionGatewayScreen)** — baris 32 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/banners_subtab.dart`
- `class` **BannersSubtab** — baris 9 — `class BannersSubtab extends StatefulWidget {`
- `field` **banners (BannersSubtab)** — baris 10 — `  final List<MediaBanner> banners;`
- `field` **headerController (BannersSubtab)** — baris 11 — `  final TextEditingController headerController;`
- `field` **titleController (BannersSubtab)** — baris 12 — `  final TextEditingController titleController;`
- `field` **contentController (BannersSubtab)** — baris 13 — `  final TextEditingController contentController;`
- `field` **footerController (BannersSubtab)** — baris 14 — `  final TextEditingController footerController;`
- `method` **createState (BannersSubtab)** — baris 34 — `  State<BannersSubtab> createState() => _BannersSubtabState();`
- `class` **_BannersSubtabState** — baris 37 — `class _BannersSubtabState extends State<BannersSubtab> {`
- `field` **_selectedBase64Image (_BannersSubtabState)** — baris 38 — `  String? _selectedBase64Image;`
- `field` **_imagePreviewFile (_BannersSubtabState)** — baris 39 — `  File? _imagePreviewFile;`
- `field` **_picker (_BannersSubtabState)** — baris 40 — `  final ImagePicker _picker = ImagePicker();`
- `method` **_pickImage (_BannersSubtabState)** — baris 42 — `  Future<void> _pickImage() async {`
- `method` **_clearImage (_BannersSubtabState)** — baris 62 — `  void _clearImage() {`
- `method` **build (_BannersSubtabState)** — baris 70 — `  Widget build(BuildContext context) {`
- `class` **_BannerThumbnail** — baris 262 — `class _BannerThumbnail extends StatefulWidget {`
- `field` **base64Image (_BannerThumbnail)** — baris 263 — `  final String base64Image;`
- `method` **createState (_BannerThumbnail)** — baris 268 — `  State<_BannerThumbnail> createState() => _BannerThumbnailState();`
- `class` **_BannerThumbnailState** — baris 271 — `class _BannerThumbnailState extends State<_BannerThumbnail> {`
- `field` **_cachedImageBytes (_BannerThumbnailState)** — baris 272 — `  late Uint8List _cachedImageBytes;`
- `method` **initState (_BannerThumbnailState)** — baris 275 — `  void initState() {`
- `method` **didUpdateWidget (_BannerThumbnailState)** — baris 281 — `  void didUpdateWidget(covariant _BannerThumbnail oldWidget) {`
- `method` **build (_BannerThumbnailState)** — baris 289 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/kas_subtab.dart`
- `class` **KasSubtab** — baris 8 — `class KasSubtab extends StatelessWidget {`
- `field` **transactions (KasSubtab)** — baris 9 — `  final List<KasTransaction> transactions;`
- `field` **amountController (KasSubtab)** — baris 10 — `  final TextEditingController amountController;`
- `field` **descriptionController (KasSubtab)** — baris 11 — `  final TextEditingController descriptionController;`
- `field` **kasType (KasSubtab)** — baris 12 — `  final KasType kasType;`
- `field` **onAddTransaction (KasSubtab)** — baris 14 — `  final VoidCallback onAddTransaction;`
- `method` **build (KasSubtab)** — baris 29 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/screens/content/running_text_subtab.dart`
- `class` **RunningTextSubtab** — baris 5 — `class RunningTextSubtab extends StatelessWidget {`
- `field` **runningTexts (RunningTextSubtab)** — baris 6 — `  final List<RunningTextMessage> runningTexts;`
- `field` **runningTextController (RunningTextSubtab)** — baris 7 — `  final TextEditingController runningTextController;`
- `field` **selectedCategory (RunningTextSubtab)** — baris 8 — `  final String selectedCategory;`
- `field` **categories (RunningTextSubtab)** — baris 9 — `  final List<String> categories;`
- `field` **onAddMessage (RunningTextSubtab)** — baris 11 — `  final VoidCallback onAddMessage;`
- `method` **build (RunningTextSubtab)** — baris 28 — `  Widget build(BuildContext context) {`

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
- `field` **isFetchingLocation (SettingsTab)** — baris 20 — `  final bool isFetchingLocation;`
- `field` **isConnected (SettingsTab)** — baris 21 — `  final bool isConnected;`
- `field` **tvPhase (SettingsTab)** — baris 22 — `  final PrayerPhase tvPhase;`
- `field` **onFetchLocation (SettingsTab)** — baris 23 — `  final VoidRefCallback onFetchLocation;`
- `field` **onSaveConfig (SettingsTab)** — baris 24 — `  final VoidRefCallback onSaveConfig;`
- `field` **onExportBackup (SettingsTab)** — baris 27 — `  final VoidRefCallback onExportBackup;`
- `field` **onImportBackup (SettingsTab)** — baris 28 — `  final VoidRefCallback onImportBackup;`
- `method` **build (SettingsTab)** — baris 57 — `  Widget build(BuildContext context) {`
- `method` **_buildQuickActionsCard (SettingsTab)** — baris 322 — `  Widget _buildQuickActionsCard(ThemeData theme, ColorScheme colorScheme) {`
- `typedef` **VoidRefCallback** — baris 393 — `typedef VoidRefCallback = void Function();`

### `apps/mobile_remote/lib/screens/simulation/simulation_tab.dart`
- `class` **SimulationTab** — baris 5 — `class SimulationTab extends StatelessWidget {`
- `field` **isConnected (SimulationTab)** — baris 6 — `  final bool isConnected;`
- `field` **tvPhase (SimulationTab)** — baris 7 — `  final PrayerPhase tvPhase;`
- `method` **build (SimulationTab)** — baris 18 — `  Widget build(BuildContext context) {`

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
- `method` **sendKasUpdate (RemoteWsClient)** — baris 118 — `  void sendKasUpdate(List<KasTransaction> transactions) {`
- `method` **sendSkipAdhan (RemoteWsClient)** — baris 128 — `  void sendSkipAdhan() {`
- `method` **sendStartShalat (RemoteWsClient)** — baris 133 — `  void sendStartShalat() {`
- `method` **sendStartIqomah (RemoteWsClient)** — baris 138 — `  void sendStartIqomah() {`
- `method` **sendFinishShalat (RemoteWsClient)** — baris 143 — `  void sendFinishShalat() {`
- `method` **sendForcePhase (RemoteWsClient)** — baris 148 — `  void sendForcePhase(PrayerPhase phase) {`
- `method` **disconnect (RemoteWsClient)** — baris 155 — `  void disconnect() {`

### `apps/mobile_remote/lib/theme/remote_theme.dart`
- `function` **buildRemoteTheme** — baris 3 — `ThemeData buildRemoteTheme(Brightness brightness, Color seedColor) {`

### `apps/mobile_remote/lib/widgets/kas_stat_card.dart`
- `class` **KasStatCard** — baris 3 — `class KasStatCard extends StatelessWidget {`
- `field` **title (KasStatCard)** — baris 4 — `  final String title;`
- `field` **amount (KasStatCard)** — baris 5 — `  final String amount;`
- `field` **icon (KasStatCard)** — baris 6 — `  final IconData icon;`
- `field` **color (KasStatCard)** — baris 7 — `  final Color color;`
- `method` **build (KasStatCard)** — baris 18 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/widgets/m3_pressable.dart`
- `class` **M3Pressable** — baris 9 — `class M3Pressable extends StatefulWidget {`
- `field` **child (M3Pressable)** — baris 16 — `  final Widget child;`
- `field` **pressedScale (M3Pressable)** — baris 17 — `  final double pressedScale;`
- `method` **createState (M3Pressable)** — baris 20 — `  State<M3Pressable> createState() => _M3PressableState();`
- `class` **_M3PressableState** — baris 23 — `class _M3PressableState extends State<M3Pressable>`
- `field` **_spring (_M3PressableState)** — baris 25 — `  static const SpringDescription _spring = SpringDescription(`
- `field` **_controller (_M3PressableState)** — baris 31 — `  late final AnimationController _controller = AnimationController(`
- `method` **dispose (_M3PressableState)** — baris 37 — `  void dispose() {`
- `method` **_pressDown (_M3PressableState)** — baris 42 — `  void _pressDown() {`
- `method` **_springBack (_M3PressableState)** — baris 50 — `  void _springBack() {`
- `method` **build (_M3PressableState)** — baris 57 — `  Widget build(BuildContext context) {`

### `apps/mobile_remote/lib/widgets/playful_nav_icon.dart`
- `class` **PlayfulNavIcon** — baris 5 — `class PlayfulNavIcon extends StatefulWidget {`
- `field` **unselectedIcon (PlayfulNavIcon)** — baris 6 — `  final IconData unselectedIcon;`
- `field` **selectedIcon (PlayfulNavIcon)** — baris 7 — `  final IconData selectedIcon;`
- `field` **isSelected (PlayfulNavIcon)** — baris 8 — `  final bool isSelected;`
- `field` **shouldRotate (PlayfulNavIcon)** — baris 9 — `  final bool shouldRotate;`
- `method` **createState (PlayfulNavIcon)** — baris 20 — `  State<PlayfulNavIcon> createState() => _PlayfulNavIconState();`
- `class` **_PlayfulNavIconState** — baris 23 — `class _PlayfulNavIconState extends State<PlayfulNavIcon>`
- `field` **_controller (_PlayfulNavIconState)** — baris 25 — `  late final AnimationController _controller;`
- `field` **_scale (_PlayfulNavIconState)** — baris 26 — `  late final Animation<double> _scale;`
- `field` **_jump (_PlayfulNavIconState)** — baris 27 — `  late final Animation<Offset> _jump;`
- `field` **_rotate (_PlayfulNavIconState)** — baris 28 — `  late final Animation<double> _rotate;`
- `method` **initState (_PlayfulNavIconState)** — baris 31 — `  void initState() {`
- `method` **didUpdateWidget (_PlayfulNavIconState)** — baris 86 — `  void didUpdateWidget(PlayfulNavIcon oldWidget) {`
- `method` **dispose (_PlayfulNavIconState)** — baris 97 — `  void dispose() {`
- `method` **build (_PlayfulNavIconState)** — baris 103 — `  Widget build(BuildContext context) {`

### `apps/tv_display/lib/main.dart`
- `function` **main** — baris 26 — `void main() async {`
- `class` **MasjidYouTVApp** — baris 42 — `class MasjidYouTVApp extends StatelessWidget {`
- `method` **build (MasjidYouTVApp)** — baris 46 — `  Widget build(BuildContext context) {`
- `class` **MasjidDisplayScreen** — baris 56 — `class MasjidDisplayScreen extends StatefulWidget {`
- `field` **initialConfig (MasjidDisplayScreen)** — baris 64 — `  final MosqueConfig? initialConfig;`
- `field` **autoPrayerCycle (MasjidDisplayScreen)** — baris 67 — `  final bool autoPrayerCycle;`
- `method` **createState (MasjidDisplayScreen)** — baris 70 — `  State<MasjidDisplayScreen> createState() => _MasjidDisplayScreenState();`
- `enum` **P2pMode** — baris 73 — `enum P2pMode { pending, directFull, directIpOnly }`
- `class` **_MasjidDisplayScreenState** — baris 75 — `class _MasjidDisplayScreenState extends State<MasjidDisplayScreen> {`
- `field` **_now (_MasjidDisplayScreenState)** — baris 76 — `  DateTime _now = DateTime.now();`
- `field` **_clockTimer (_MasjidDisplayScreenState)** — baris 77 — `  Timer? _clockTimer;`
- `field` **_localServer (_MasjidDisplayScreenState)** — baris 78 — `  LocalServer? _localServer;`
- `field` **_p2pHost (_MasjidDisplayScreenState)** — baris 79 — `  final P2pHostService _p2pHost = P2pHostService();`
- `field` **_p2pState (_MasjidDisplayScreenState)** — baris 80 — `  HotspotHostState? _p2pState;`
- `field` **_p2pMode (_MasjidDisplayScreenState)** — baris 81 — `  P2pMode _p2pMode = P2pMode.pending;`
- `field` **_btHost (_MasjidDisplayScreenState)** — baris 84 — `  BluetoothHostService? _btHost;`
- `field` **_btState (_MasjidDisplayScreenState)** — baris 85 — `  BluetoothHostState? _btState;`
- `field` **_btEnabled (_MasjidDisplayScreenState)** — baris 89 — `  bool _btEnabled = false;`
- `field` **_showAdminMenu (_MasjidDisplayScreenState)** — baris 92 — `  bool _showAdminMenu = false;`
- `field` **_config (_MasjidDisplayScreenState)** — baris 94 — `  MosqueConfig _config = const MosqueConfig(`
- `field` **_prayerStateMachine (_MasjidDisplayScreenState)** — baris 101 — `  final PrayerStateMachine _prayerStateMachine = PrayerStateMachine();`
- `field` **_showKasCard (_MasjidDisplayScreenState)** — baris 104 — `  bool _showKasCard = true;`
- `field` **_runningTexts (_MasjidDisplayScreenState)** — baris 106 — `  List<RunningTextMessage> _runningTexts = const [`
- `field` **_banners (_MasjidDisplayScreenState)** — baris 121 — `  List<MediaBanner> _banners = const [`
- `field` **_kasTransactions (_MasjidDisplayScreenState)** — baris 138 — `  List<KasTransaction> _kasTransactions = [`
- `field` **_prayerSchedule (_MasjidDisplayScreenState)** — baris 162 — `  late PrayerSchedule _prayerSchedule;`
- `field` **_store (_MasjidDisplayScreenState)** — baris 165 — `  final TvStore _store = TvStore();`
- `field` **_hasStoredData (_MasjidDisplayScreenState)** — baris 169 — `  bool _hasStoredData = false;`
- `method` **initState (_MasjidDisplayScreenState)** — baris 172 — `  void initState() {`
- `method` **_initFromStore (_MasjidDisplayScreenState)** — baris 202 — `  Future<void> _initFromStore() async {`
- `method` **_androidSdkVersion (_MasjidDisplayScreenState)** — baris 234 — `  int _androidSdkVersion() {`
- `method` **_initP2pHost (_MasjidDisplayScreenState)** — baris 247 — `  Future<void> _initP2pHost() async {`
- `method` **_showP2pPrereqDialog (_MasjidDisplayScreenState)** — baris 290 — `  void _showP2pPrereqDialog(P2pPrerequisites reqs) {`
- `method` **_prereqRow (_MasjidDisplayScreenState)** — baris 333 — `  Widget _prereqRow(String label, bool enabled) {`
- `method` **_enableAllP2pServices (_MasjidDisplayScreenState)** — baris 350 — `  Future<void> _enableAllP2pServices() async {`
- `method` **_recalculateSchedule (_MasjidDisplayScreenState)** — baris 413 — `  void _recalculateSchedule() {`
- `method` **_initLocalServer (_MasjidDisplayScreenState)** — baris 417 — `  Future<void> _initLocalServer() async {`
- `method` **_handleSyncPacket (_MasjidDisplayScreenState)** — baris 430 — `  void _handleSyncPacket(SyncPacket packet) {`
- `field` **_btStateSub (_MasjidDisplayScreenState)** — baris 518 — `  StreamSubscription<BluetoothHostState>? _btStateSub;`
- `method` **_initBluetoothHost (_MasjidDisplayScreenState)** — baris 520 — `  Future<void> _initBluetoothHost() async {`
- `method` **_toggleBluetooth (_MasjidDisplayScreenState)** — baris 551 — `  Future<void> _toggleBluetooth(bool enable) async {`
- `method` **_broadcastSnapshot (_MasjidDisplayScreenState)** — baris 580 — `  void _broadcastSnapshot() {`
- `method` **_broadcastState (_MasjidDisplayScreenState)** — baris 596 — `  void _broadcastState() {`
- `method` **_onStateMachineChanged (_MasjidDisplayScreenState)** — baris 610 — `  void _onStateMachineChanged() {`
- `method` **dispose (_MasjidDisplayScreenState)** — baris 616 — `  void dispose() {`
- `method` **build (_MasjidDisplayScreenState)** — baris 629 — `  Widget build(BuildContext context) {`

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
- `method` **_onEvent (BluetoothHostService)** — baris 230 — `  void _onEvent(BluetoothSyncEvent event) {`
- `method` **_handlePacket (BluetoothHostService)** — baris 296 — `  void _handlePacket(SyncPacket packet) {`
- `method` **_handleAuthResponse (BluetoothHostService)** — baris 318 — `  void _handleAuthResponse(SyncPacket packet) {`
- `method` **_registerAuthFailure (BluetoothHostService)** — baris 347 — `  void _registerAuthFailure(String reason) {`
- `method` **_sendAuthChallenge (BluetoothHostService)** — baris 374 — `  Future<void> _sendAuthChallenge() async {`
- `method` **_sendPacket (BluetoothHostService)** — baris 383 — `  Future<void> _sendPacket(SyncPacket packet) async {`
- `method` **_generatePin (BluetoothHostService)** — baris 394 — `  String _generatePin() {`
- `method` **_generateNonce (BluetoothHostService)** — baris 400 — `  String _generateNonce() {`
- `method` **broadcast (BluetoothHostService)** — baris 406 — `  Future<void> broadcast(SyncPacket packet) async {`
- `method` **stop (BluetoothHostService)** — baris 411 — `  Future<void> stop() async {`

### `apps/tv_display/lib/server/local_ws_server.dart`
- `class` **LocalServer** — baris 10 — `class LocalServer {`
- `field` **_server (LocalServer)** — baris 11 — `  HttpServer? _server;`
- `field` **_clients (LocalServer)** — baris 12 — `  final List<WebSocketChannel> _clients = [];`
- `method` **broadcast (LocalServer)** — baris 46 — `  void broadcast(SyncPacket packet) {`
- `method` **stop (LocalServer)** — baris 53 — `  Future<void> stop() async {`

### `apps/tv_display/lib/server/p2p_host_service.dart`
- `class` **P2pPrerequisites** — baris 6 — `class P2pPrerequisites {`
- `field` **wifiEnabled (P2pPrerequisites)** — baris 7 — `  final bool wifiEnabled;`
- `field` **bluetoothEnabled (P2pPrerequisites)** — baris 8 — `  final bool bluetoothEnabled;`
- `field` **locationEnabled (P2pPrerequisites)** — baris 9 — `  final bool locationEnabled;`
- `field` **p2pPermissionsGranted (P2pPrerequisites)** — baris 10 — `  final bool p2pPermissionsGranted;`
- `field` **bluetoothPermissionsGranted (P2pPrerequisites)** — baris 11 — `  final bool bluetoothPermissionsGranted;`
- `getter` **allPermissionsGranted (P2pPrerequisites)** — baris 21 — `  bool get allPermissionsGranted =>`
- `class` **P2pHostService** — baris 32 — `class P2pHostService {`
- `field` **_host (P2pHostService)** — baris 33 — `  FlutterP2pHost? _host;`
- `field` **_stateController (P2pHostService)** — baris 34 — `  final _stateController = StreamController<HotspotHostState?>.broadcast();`
- `field` **_subscription (P2pHostService)** — baris 35 — `  StreamSubscription<HotspotHostState?>? _subscription;`
- `field` **_started (P2pHostService)** — baris 36 — `  bool _started = false;`
- `field` **_currentState (P2pHostService)** — baris 38 — `  HotspotHostState? _currentState;`
- `getter` **currentState (P2pHostService)** — baris 39 — `  HotspotHostState? get currentState => _currentState;`
- `getter` **stateStream (P2pHostService)** — baris 41 — `  Stream<HotspotHostState?> get stateStream => _stateController.stream;`
- `getter` **isRunning (P2pHostService)** — baris 43 — `  bool get isRunning => _started;`
- `method` **_androidSdkVersion (P2pHostService)** — baris 45 — `  int _androidSdkVersion() {`
- `method` **checkPrerequisites (P2pHostService)** — baris 55 — `  Future<P2pPrerequisites> checkPrerequisites() async {`
- `method` **enableWifiIfNeeded (P2pHostService)** — baris 79 — `  Future<void> enableWifiIfNeeded() async {`
- `method` **enableBluetoothIfNeeded (P2pHostService)** — baris 86 — `  Future<void> enableBluetoothIfNeeded() async {`
- `method` **enableLocationIfNeeded (P2pHostService)** — baris 93 — `  Future<void> enableLocationIfNeeded() async {`
- `method` **askPermissionsIfNeeded (P2pHostService)** — baris 100 — `  Future<void> askPermissionsIfNeeded() async {`
- `method` **start (P2pHostService)** — baris 112 — `  Future<void> start() async {`
- `method` **stop (P2pHostService)** — baris 144 — `  Future<void> stop() async {`

### `apps/tv_display/lib/state/prayer_state_machine.dart`
- `class` **PrayerStateMachine** — baris 15 — `class PrayerStateMachine extends ChangeNotifier {`
- `field` **_config (PrayerStateMachine)** — baris 16 — `  MosqueConfig _config = const MosqueConfig();`
- `field` **_phase (PrayerStateMachine)** — baris 17 — `  PrayerPhase _phase = PrayerPhase.normal;`
- `field` **_prayer (PrayerStateMachine)** — baris 18 — `  PrayerType? _prayer;`
- `field` **_deadline (PrayerStateMachine)** — baris 19 — `  DateTime _deadline = DateTime.now();`
- `field` **_remaining (PrayerStateMachine)** — baris 20 — `  Duration _remaining = Duration.zero;`
- `field` **_total (PrayerStateMachine)** — baris 21 — `  Duration _total = Duration.zero;`
- `field` **_autoCycle (PrayerStateMachine)** — baris 22 — `  bool _autoCycle = true;`
- `getter` **phase (PrayerStateMachine)** — baris 24 — `  PrayerPhase get phase => _phase;`
- `getter` **prayer (PrayerStateMachine)** — baris 25 — `  PrayerType? get prayer => _prayer;`
- `getter` **remaining (PrayerStateMachine)** — baris 26 — `  Duration get remaining => _remaining;`
- `getter` **total (PrayerStateMachine)** — baris 27 — `  Duration get total => _total;`
- `getter` **autoCycle (PrayerStateMachine)** — baris 28 — `  bool get autoCycle => _autoCycle;`
- `getter` **deadline (PrayerStateMachine)** — baris 34 — `  DateTime get deadline => _deadline;`
- `getter` **progress (PrayerStateMachine)** — baris 36 — `  double get progress {`
- `method` **updateConfig (PrayerStateMachine)** — baris 49 — `  void updateConfig(MosqueConfig config, DateTime now) {`
- `method` **tick (PrayerStateMachine)** — baris 63 — `  void tick(DateTime now, PrayerSchedule schedule) {`
- `method` **startIqomah (PrayerStateMachine)** — baris 105 — `  void startIqomah() {`
- `method` **startShalat (PrayerStateMachine)** — baris 112 — `  void startShalat() {`
- `method` **finishShalat (PrayerStateMachine)** — baris 119 — `  void finishShalat() {`
- `method` **_advance (PrayerStateMachine)** — baris 155 — `  void _advance(DateTime now) {`
- `method` **_isFriday (PrayerStateMachine)** — baris 177 — `  bool _isFriday(DateTime date) => date.weekday == DateTime.friday;`
- `method` **_enter (PrayerStateMachine)** — baris 179 — `  void _enter(PrayerPhase phase, PrayerType? prayer, DateTime now) {`

### `apps/tv_display/lib/state/tv_store.dart`
- `class` **TvStore** — baris 13 — `class TvStore {`
- `field` **configKey (TvStore)** — baris 14 — `  static const String configKey = 'tv_config';`
- `field` **runningTextsKey (TvStore)** — baris 15 — `  static const String runningTextsKey = 'tv_runningTexts';`
- `field` **bannersKey (TvStore)** — baris 16 — `  static const String bannersKey = 'tv_banners';`
- `field` **kasKey (TvStore)** — baris 17 — `  static const String kasKey = 'tv_kas';`
- `field` **hasDataKey (TvStore)** — baris 18 — `  static const String hasDataKey = 'tv_hasData';`
- `method` **load (TvStore)** — baris 21 — `  Future<StateSnapshot?> load() async {`
- `method` **saveConfig (TvStore)** — baris 48 — `  Future<void> saveConfig(MosqueConfig config) =>`
- `method` **saveRunningTexts (TvStore)** — baris 51 — `  Future<void> saveRunningTexts(List<RunningTextMessage> messages) =>`
- `method` **saveBanners (TvStore)** — baris 54 — `  Future<void> saveBanners(List<MediaBanner> banners) =>`
- `method` **saveKas (TvStore)** — baris 57 — `  Future<void> saveKas(List<KasTransaction> transactions) =>`
- `method` **_save (TvStore)** — baris 60 — `  Future<void> _save(String key, Object value) async {`
- `method` **_decodeMap (TvStore)** — baris 72 — `  static Map<String, dynamic>? _decodeMap(String source) {`

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
- `class` **AdminMenuOverlay** — baris 23 — `class AdminMenuOverlay extends StatefulWidget {`
- `field` **btEnabled (AdminMenuOverlay)** — baris 25 — `  final bool btEnabled;`
- `field` **pin (AdminMenuOverlay)** — baris 28 — `  final String? pin;`
- `field` **statusText (AdminMenuOverlay)** — baris 31 — `  final String? statusText;`
- `field` **isError (AdminMenuOverlay)** — baris 34 — `  final bool isError;`
- `field` **onToggleBluetooth (AdminMenuOverlay)** — baris 37 — `  final ValueChanged<bool> onToggleBluetooth;`
- `field` **onClose (AdminMenuOverlay)** — baris 40 — `  final VoidCallback onClose;`
- `method` **createState (AdminMenuOverlay)** — baris 53 — `  State<AdminMenuOverlay> createState() => _AdminMenuOverlayState();`
- `class` **_AdminMenuOverlayState** — baris 56 — `class _AdminMenuOverlayState extends State<AdminMenuOverlay>`
- `field` **_controller (_AdminMenuOverlayState)** — baris 58 — `  late final AnimationController _controller;`
- `field` **_slideIn (_AdminMenuOverlayState)** — baris 59 — `  late final Animation<Offset> _slideIn;`
- `field` **_slideOut (_AdminMenuOverlayState)** — baris 60 — `  late final Animation<Offset> _slideOut;`
- `field` **_panelScope (_AdminMenuOverlayState)** — baris 64 — `  late final FocusScopeNode _panelScope;`
- `field` **_closing (_AdminMenuOverlayState)** — baris 67 — `  bool _closing = false;`
- `method` **initState (_AdminMenuOverlayState)** — baris 70 — `  void initState() {`
- `method` **dispose (_AdminMenuOverlayState)** — baris 92 — `  void dispose() {`
- `method` **_close (_AdminMenuOverlayState)** — baris 99 — `  void _close() {`
- `method` **build (_AdminMenuOverlayState)** — baris 108 — `  Widget build(BuildContext context) {`
- `class` **_AdminAction** — baris 304 — `class _AdminAction {`
- `field` **icon (_AdminAction)** — baris 305 — `  final IconData icon;`
- `field` **label (_AdminAction)** — baris 306 — `  final String label;`
- `field` **subtitle (_AdminAction)** — baris 307 — `  final String subtitle;`
- `field` **selected (_AdminAction)** — baris 310 — `  final bool selected;`
- `field` **onActivate (_AdminAction)** — baris 311 — `  final VoidCallback onActivate;`
- `class` **_FocusableAction** — baris 324 — `class _FocusableAction extends StatefulWidget {`
- `field` **action (_FocusableAction)** — baris 325 — `  final _AdminAction action;`
- `field` **autofocus (_FocusableAction)** — baris 328 — `  final bool autofocus;`
- `method` **createState (_FocusableAction)** — baris 333 — `  State<_FocusableAction> createState() => _FocusableActionState();`
- `class` **_FocusableActionState** — baris 336 — `class _FocusableActionState extends State<_FocusableAction> {`
- `field` **_focused (_FocusableActionState)** — baris 337 — `  bool _focused = false;`
- `method` **build (_FocusableActionState)** — baris 340 — `  Widget build(BuildContext context) {`

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
- `class` **HeaderClock** — baris 7 — `class HeaderClock extends StatelessWidget {`
- `field` **config (HeaderClock)** — baris 8 — `  final MosqueConfig config;`
- `field` **currentTime (HeaderClock)** — baris 9 — `  final DateTime currentTime;`
- `field` **p2pActive (HeaderClock)** — baris 12 — `  final bool p2pActive;`
- `field` **p2pError (HeaderClock)** — baris 16 — `  final bool p2pError;`
- `field` **p2pSsid (HeaderClock)** — baris 17 — `  final String? p2pSsid;`
- `field` **p2pIp (HeaderClock)** — baris 18 — `  final String? p2pIp;`
- `field` **p2pStatus (HeaderClock)** — baris 23 — `  final String? p2pStatus;`
- `method` **build (HeaderClock)** — baris 37 — `  Widget build(BuildContext context) {`

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
- `method` **build (PrayerCardsRow)** — baris 17 — `  Widget build(BuildContext context) {`
- `method` **_remainingFraction (PrayerCardsRow)** — baris 91 — `  double _remainingFraction(PrayerSchedule schedule) {`
- `class` **_NextPrayerTimer** — baris 113 — `class _NextPrayerTimer extends StatefulWidget {`
- `field` **formattedTime (_NextPrayerTimer)** — baris 114 — `  final String formattedTime;`
- `field` **remaining (_NextPrayerTimer)** — baris 115 — `  final Duration remaining;`
- `field` **progress (_NextPrayerTimer)** — baris 116 — `  final double progress;`
- `method` **createState (_NextPrayerTimer)** — baris 125 — `  State<_NextPrayerTimer> createState() => _NextPrayerTimerState();`
- `class` **_NextPrayerTimerState** — baris 128 — `class _NextPrayerTimerState extends State<_NextPrayerTimer> {`
- `field` **_showCountdown (_NextPrayerTimerState)** — baris 129 — `  bool _showCountdown = true;`
- `field` **_timer (_NextPrayerTimerState)** — baris 130 — `  Timer? _timer;`
- `method` **initState (_NextPrayerTimerState)** — baris 133 — `  void initState() {`
- `method` **dispose (_NextPrayerTimerState)** — baris 145 — `  void dispose() {`
- `method` **build (_NextPrayerTimerState)** — baris 151 — `  Widget build(BuildContext context) {`
- `method` **_formatDuration (_NextPrayerTimerState)** — baris 211 — `  String _formatDuration(Duration duration) {`

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

### `packages/flutter_p2p_connection/lib/flutter_p2p_connection_method_channel.dart`
- `class` **MethodChannelFlutterP2pConnection** — baris 9 — `class MethodChannelFlutterP2pConnection extends FlutterP2pConnectionPlatform {`
- `field` **methodChannel (MethodChannelFlutterP2pConnection)** — baris 12 — `  final MethodChannel methodChannel =`
- `method` **MethodChannel (MethodChannelFlutterP2pConnection)** — baris 13 — `      const MethodChannel('flutter_p2p_connection');`
- `field` **hotspotStateEventChannel (MethodChannelFlutterP2pConnection)** — baris 19 — `  final EventChannel hotspotStateEventChannel =`
- `method` **EventChannel (MethodChannelFlutterP2pConnection)** — baris 20 — `      const EventChannel('flutter_p2p_connection_hotspotState');`
- `field` **clientStateEventChannel (MethodChannelFlutterP2pConnection)** — baris 24 — `  final EventChannel clientStateEventChannel =`
- `field` **bleConnectionStateEventChannel (MethodChannelFlutterP2pConnection)** — baris 29 — `  final EventChannel bleConnectionStateEventChannel =`
- `field` **bleScanResultEventChannel (MethodChannelFlutterP2pConnection)** — baris 34 — `  final EventChannel bleScanResultEventChannel =`
- `field` **bleReceivedDataEventChannel (MethodChannelFlutterP2pConnection)** — baris 39 — `  final EventChannel bleReceivedDataEventChannel =`
- `field` **_hotspotInfoStream (MethodChannelFlutterP2pConnection)** — baris 44 — `  Stream<HotspotHostState>? _hotspotInfoStream;`
- `field` **_clientStateStream (MethodChannelFlutterP2pConnection)** — baris 45 — `  Stream<HotspotClientState>? _clientStateStream;`
- `field` **_bleConnectionStateStream (MethodChannelFlutterP2pConnection)** — baris 46 — `  Stream<BleConnectionState>? _bleConnectionStateStream;`
- `field` **_bleScanResultStream (MethodChannelFlutterP2pConnection)** — baris 47 — `  Stream<List<BleDiscoveredDevice>>? _bleScanResultStream;`
- `field` **_bleReceivedDataStream (MethodChannelFlutterP2pConnection)** — baris 48 — `  Stream<BleReceivedData>? _bleReceivedDataStream;`
- `method` **getPlatformVersion (MethodChannelFlutterP2pConnection)** — baris 55 — `  Future<String> getPlatformVersion() async {`
- `method` **getPlatformModel (MethodChannelFlutterP2pConnection)** — baris 67 — `  Future<String> getPlatformModel() async {`
- `method` **dispose (MethodChannelFlutterP2pConnection)** — baris 96 — `  Future<void> dispose() async {`
- `method` **createHotspot (MethodChannelFlutterP2pConnection)** — baris 111 — `  Future<void> createHotspot() async {`
- `method` **removeHotspot (MethodChannelFlutterP2pConnection)** — baris 119 — `  Future<void> removeHotspot() async {`
- `method` **connectToHotspot (MethodChannelFlutterP2pConnection)** — baris 130 — `  Future<void> connectToHotspot(String ssid, String psk) async {`
- `method` **disconnectFromHotspot (MethodChannelFlutterP2pConnection)** — baris 141 — `  Future<void> disconnectFromHotspot() async {`
- `method` **startBleAdvertising (MethodChannelFlutterP2pConnection)** — baris 153 — `  Future<void> startBleAdvertising(String ssid, String psk) async {`
- `method` **stopBleAdvertising (MethodChannelFlutterP2pConnection)** — baris 164 — `  Future<void> stopBleAdvertising() async {`
- `method` **startBleScan (MethodChannelFlutterP2pConnection)** — baris 174 — `  Future<void> startBleScan() async {`
- `method` **stopBleScan (MethodChannelFlutterP2pConnection)** — baris 182 — `  Future<void> stopBleScan() async {`
- `method` **connectBleDevice (MethodChannelFlutterP2pConnection)** — baris 193 — `  Future<void> connectBleDevice(String deviceAddress) async {`
- `method` **disconnectBleDevice (MethodChannelFlutterP2pConnection)** — baris 205 — `  Future<void> disconnectBleDevice(String deviceAddress) async {`
- `method` **checkP2pPermissions (MethodChannelFlutterP2pConnection)** — baris 217 — `  Future<bool> checkP2pPermissions() async {`
- `method` **askP2pPermissions (MethodChannelFlutterP2pConnection)** — baris 229 — `  Future<void> askP2pPermissions() async {`
- `method` **checkLocationEnabled (MethodChannelFlutterP2pConnection)** — baris 238 — `  Future<bool> checkLocationEnabled() async {`
- `method` **enableLocationServices (MethodChannelFlutterP2pConnection)** — baris 249 — `  Future<void> enableLocationServices() async {`
- `method` **checkWifiEnabled (MethodChannelFlutterP2pConnection)** — baris 257 — `  Future<bool> checkWifiEnabled() async {`
- `method` **enableWifiServices (MethodChannelFlutterP2pConnection)** — baris 267 — `  Future<void> enableWifiServices() async {`
- `method` **checkBluetoothEnabled (MethodChannelFlutterP2pConnection)** — baris 275 — `  Future<bool> checkBluetoothEnabled() async {`
- `method` **enableBluetoothServices (MethodChannelFlutterP2pConnection)** — baris 286 — `  Future<void> enableBluetoothServices() async {`
- `method` **streamHotspotInfo (MethodChannelFlutterP2pConnection)** — baris 299 — `  Stream<HotspotHostState> streamHotspotInfo() {`
- `method` **streamHotspotClientState (MethodChannelFlutterP2pConnection)** — baris 337 — `  Stream<HotspotClientState> streamHotspotClientState() {`
- `method` **streamBleConnectionState (MethodChannelFlutterP2pConnection)** — baris 366 — `  Stream<BleConnectionState> streamBleConnectionState() {`
- `method` **streamBleScanResult (MethodChannelFlutterP2pConnection)** — baris 396 — `  Stream<List<BleDiscoveredDevice>> streamBleScanResult() {`
- `method` **streamBleReceivedData (MethodChannelFlutterP2pConnection)** — baris 431 — `  Stream<BleReceivedData> streamBleReceivedData() {`

### `packages/flutter_p2p_connection/lib/flutter_p2p_connection_platform_interface.dart`
- `class` **FlutterP2pConnectionPlatform** — baris 6 — `abstract class FlutterP2pConnectionPlatform extends PlatformInterface {`
- `constructor` **FlutterP2pConnectionPlatform (FlutterP2pConnectionPlatform)** — baris 8 — `  FlutterP2pConnectionPlatform() : super(token: _token);`
- `field` **_token (FlutterP2pConnectionPlatform)** — baris 10 — `  static final Object _token = Object();`
- `field` **_instance (FlutterP2pConnectionPlatform)** — baris 12 — `  static FlutterP2pConnectionPlatform _instance =`
- `method` **MethodChannelFlutterP2pConnection (FlutterP2pConnectionPlatform)** — baris 13 — `      MethodChannelFlutterP2pConnection();`
- `getter` **instance (FlutterP2pConnectionPlatform)** — baris 18 — `  static FlutterP2pConnectionPlatform get instance => _instance;`
- `setter` **instance (FlutterP2pConnectionPlatform)** — baris 23 — `  static set instance(FlutterP2pConnectionPlatform instance) {`
- `method` **getPlatformVersion (FlutterP2pConnectionPlatform)** — baris 28 — `  Future<String> getPlatformVersion() async {`
- `method` **getPlatformModel (FlutterP2pConnectionPlatform)** — baris 32 — `  Future<String> getPlatformModel() async {`
- `method` **dispose (FlutterP2pConnectionPlatform)** — baris 44 — `  Future<void> dispose() async {`
- `method` **createHotspot (FlutterP2pConnectionPlatform)** — baris 48 — `  Future<void> createHotspot() async {`
- `method` **removeHotspot (FlutterP2pConnectionPlatform)** — baris 52 — `  Future<void> removeHotspot() async {`
- `method` **connectToHotspot (FlutterP2pConnectionPlatform)** — baris 56 — `  Future<void> connectToHotspot(String ssid, String psk) async {`
- `method` **disconnectFromHotspot (FlutterP2pConnectionPlatform)** — baris 60 — `  Future<void> disconnectFromHotspot() async {`
- `method` **startBleAdvertising (FlutterP2pConnectionPlatform)** — baris 65 — `  Future<void> startBleAdvertising(String ssid, String psk) async {`
- `method` **stopBleAdvertising (FlutterP2pConnectionPlatform)** — baris 69 — `  Future<void> stopBleAdvertising() async {`
- `method` **startBleScan (FlutterP2pConnectionPlatform)** — baris 73 — `  Future<void> startBleScan() async {`
- `method` **stopBleScan (FlutterP2pConnectionPlatform)** — baris 77 — `  Future<void> stopBleScan() async {`
- `method` **connectBleDevice (FlutterP2pConnectionPlatform)** — baris 81 — `  Future<void> connectBleDevice(String deviceAddress) async {`
- `method` **disconnectBleDevice (FlutterP2pConnectionPlatform)** — baris 85 — `  Future<void> disconnectBleDevice(String deviceAddress) async {`
- `method` **checkP2pPermissions (FlutterP2pConnectionPlatform)** — baris 89 — `  Future<bool> checkP2pPermissions() async {`
- `method` **askP2pPermissions (FlutterP2pConnectionPlatform)** — baris 93 — `  Future<void> askP2pPermissions() async {`
- `method` **checkLocationEnabled (FlutterP2pConnectionPlatform)** — baris 97 — `  Future<bool> checkLocationEnabled() async {`
- `method` **enableLocationServices (FlutterP2pConnectionPlatform)** — baris 102 — `  Future<void> enableLocationServices() async {`
- `method` **checkWifiEnabled (FlutterP2pConnectionPlatform)** — baris 107 — `  Future<bool> checkWifiEnabled() async {`
- `method` **enableWifiServices (FlutterP2pConnectionPlatform)** — baris 111 — `  Future<void> enableWifiServices() async {`
- `method` **checkBluetoothEnabled (FlutterP2pConnectionPlatform)** — baris 115 — `  Future<bool> checkBluetoothEnabled() async {`
- `method` **enableBluetoothServices (FlutterP2pConnectionPlatform)** — baris 120 — `  Future<void> enableBluetoothServices() async {`
- `method` **streamHotspotInfo (FlutterP2pConnectionPlatform)** — baris 125 — `  Stream<HotspotHostState> streamHotspotInfo() {`
- `method` **streamHotspotClientState (FlutterP2pConnectionPlatform)** — baris 129 — `  Stream<HotspotClientState> streamHotspotClientState() {`
- `method` **streamBleConnectionState (FlutterP2pConnectionPlatform)** — baris 134 — `  Stream<BleConnectionState> streamBleConnectionState() {`
- `method` **streamBleScanResult (FlutterP2pConnectionPlatform)** — baris 139 — `  Stream<List<BleDiscoveredDevice>> streamBleScanResult() {`
- `method` **streamBleReceivedData (FlutterP2pConnectionPlatform)** — baris 143 — `  Stream<BleReceivedData> streamBleReceivedData() {`

### `packages/flutter_p2p_connection/lib/src/client/p2p_client.dart`
- `class` **FlutterP2pClient** — baris 23 — `class FlutterP2pClient extends FlutterP2pConnectionBase {`
- `field` **_isScanning (FlutterP2pClient)** — baris 24 — `  bool _isScanning = false;`
- `field` **_p2pTransport (FlutterP2pClient)** — baris 25 — `  P2pTransportClient? _p2pTransport;`
- `field` **_lastKnownClientState (FlutterP2pClient)** — baris 26 — `  HotspotClientState? _lastKnownClientState; // To store client's IP in group`
- `field` **_scanStreamSub (FlutterP2pClient)** — baris 28 — `  StreamSubscription<List<BleDiscoveredDevice>>? _scanStreamSub;`
- `field` **_scanTimer (FlutterP2pClient)** — baris 29 — `  Timer? _scanTimer;`
- `getter` **isScanning (FlutterP2pClient)** — baris 46 — `  bool get isScanning => _isScanning;`
- `getter` **isConnected (FlutterP2pClient)** — baris 49 — `  bool get isConnected => _p2pTransport?.isConnected ?? false;`
- `getter` **clientList (FlutterP2pClient)** — baris 52 — `  List<P2pClientInfo> get clientList => _p2pTransport?.clientList ?? [];`
- `getter` **hostedFileInfos (FlutterP2pClient)** — baris 55 — `  List<HostedFileInfo> get hostedFileInfos =>`

### `packages/flutter_p2p_connection/lib/src/common/p2p_connection_base.dart`
- `class` **FlutterP2pConnectionBase** — baris 14 — `class FlutterP2pConnectionBase {`
- `field` **username (FlutterP2pConnectionBase)** — baris 16 — `  final String? username;`
- `field` **serviceUuid (FlutterP2pConnectionBase)** — baris 19 — `  final String? serviceUuid;`
- `field` **bondingRequired (FlutterP2pConnectionBase)** — baris 22 — `  final bool? bondingRequired;`
- `field` **encryptionRequired (FlutterP2pConnectionBase)** — baris 25 — `  final bool? encryptionRequired;`
- `method` **getDeviceModel (FlutterP2pConnectionBase)** — baris 39 — `  Future<String> getDeviceModel() =>`

### `packages/flutter_p2p_connection/lib/src/common/utils.dart`
- `function` **getLocalIpAddress** — baris 3 — `Future<String?> getLocalIpAddress() async {`

### `packages/flutter_p2p_connection/lib/src/host/p2p_host.dart`
- `class` **FlutterP2pHost** — baris 21 — `class FlutterP2pHost extends FlutterP2pConnectionBase {`
- `field` **_isGroupCreated (FlutterP2pHost)** — baris 22 — `  bool _isGroupCreated = false;`
- `field` **_isBleAdvertising (FlutterP2pHost)** — baris 23 — `  bool _isBleAdvertising = false;`
- `field` **_p2pTransport (FlutterP2pHost)** — baris 24 — `  P2pTransportHost? _p2pTransport;`
- `field` **_lastKnownHotspotState (FlutterP2pHost)** — baris 25 — `  HotspotHostState? _lastKnownHotspotState;`
- `getter` **isGroupCreated (FlutterP2pHost)** — baris 42 — `  bool get isGroupCreated => _isGroupCreated;`
- `getter` **isAdvertising (FlutterP2pHost)** — baris 45 — `  bool get isAdvertising => _isBleAdvertising;`
- `getter` **clientList (FlutterP2pHost)** — baris 48 — `  List<P2pClientInfo> get clientList => _p2pTransport?.clientList ?? [];`
- `getter` **hostedFileInfos (FlutterP2pHost)** — baris 51 — `  List<HostedFileInfo> get hostedFileInfos =>`

### `packages/flutter_p2p_connection/lib/src/models/p2p_connection_models.dart`
- `class` **HotspotHostState** — baris 5 — `class HotspotHostState {`
- `field` **isActive (HotspotHostState)** — baris 7 — `  final bool isActive;`
- `field` **ssid (HotspotHostState)** — baris 10 — `  final String? ssid;`
- `field` **preSharedKey (HotspotHostState)** — baris 13 — `  final String? preSharedKey;`
- `field` **hostIpAddress (HotspotHostState)** — baris 16 — `  final String? hostIpAddress;`
- `field` **failureReason (HotspotHostState)** — baris 19 — `  final int? failureReason;`
- `method` **toMap (HotspotHostState)** — baris 42 — `  Map<String, dynamic> toMap() {`
- `method` **toString (HotspotHostState)** — baris 53 — `  String toString() {`
- `operator` **operator == (HotspotHostState)** — baris 58 — `  bool operator ==(Object other) {`
- `getter` **hashCode (HotspotHostState)** — baris 69 — `  int get hashCode =>`

### `packages/flutter_p2p_connection/lib/src/transport/client/transport_client.dart`
- `class` **P2pTransportClient** — baris 20 — `class P2pTransportClient with FileRequestServerMixin {`
- `field` **hostIp (P2pTransportClient)** — baris 22 — `  final String hostIp;`
- `field` **defaultPort (P2pTransportClient)** — baris 25 — `  final int defaultPort;`
- `field` **defaultFilePort (P2pTransportClient)** — baris 28 — `  final int defaultFilePort;`
- `field` **username (P2pTransportClient)** — baris 31 — `  final String username;`
- `field` **clientId (P2pTransportClient)** — baris 34 — `  final String clientId = const Uuid().v4();`
- `field` **_socket (P2pTransportClient)** — baris 36 — `  WebSocket? _socket;`
- `field` **_isConnected (P2pTransportClient)** — baris 37 — `  bool _isConnected = false;`
- `field` **_isConnecting (P2pTransportClient)** — baris 38 — `  bool _isConnecting = false;`
- `field` **_socketSubscription (P2pTransportClient)** — baris 39 — `  StreamSubscription? _socketSubscription;`
- `field` **_clientList (P2pTransportClient)** — baris 40 — `  List<P2pClientInfo> _clientList = [];`
- `field` **_fileServer (P2pTransportClient)** — baris 41 — `  HttpServer? _fileServer;`
- `field` **_fileServerPortInUse (P2pTransportClient)** — baris 42 — `  int? _fileServerPortInUse;`
- `field` **_hostedFiles (P2pTransportClient)** — baris 43 — `  final Map<String, HostedFileInfo> _hostedFiles = {};`
- `field` **_receivableFiles (P2pTransportClient)** — baris 44 — `  final Map<String, ReceivableFileInfo> _receivableFiles = {};`
- `field` **_receivedTextController (P2pTransportClient)** — baris 45 — `  final StreamController<String> _receivedTextController =`
- `field` **_logPrefix (P2pTransportClient)** — baris 48 — `  static const String _logPrefix = "P2P Transport Client";`
- `field` **_connectionRetryAttempts (P2pTransportClient)** — baris 51 — `  int _connectionRetryAttempts = 0;`
- `field` **_maxConnectionRetries (P2pTransportClient)** — baris 52 — `  static const int _maxConnectionRetries = 3;`
- `field` **_isManuallyDisconnecting (P2pTransportClient)** — baris 53 — `  bool _isManuallyDisconnecting = false;`
- `getter` **hostedFiles (P2pTransportClient)** — baris 56 — `  Map<String, HostedFileInfo> get hostedFiles => _hostedFiles;`
- `getter` **transportUsername (P2pTransportClient)** — baris 58 — `  String get transportUsername => username;`
- `getter` **isConnected (P2pTransportClient)** — baris 61 — `  bool get isConnected => _isConnected && _socket?.readyState == WebSocket.open;`
- `getter` **clientList (P2pTransportClient)** — baris 64 — `  List<P2pClientInfo> get clientList => _clientList;`
- `getter` **fileServerPort (P2pTransportClient)** — baris 67 — `  int? get fileServerPort => _fileServerPortInUse;`
- `getter` **hostedFileInfos (P2pTransportClient)** — baris 70 — `  List<HostedFileInfo> get hostedFileInfos => _hostedFiles.values.toList();`
- `getter` **receivableFileInfos (P2pTransportClient)** — baris 73 — `  List<ReceivableFileInfo> get receivableFileInfos =>`

### `packages/flutter_p2p_connection/lib/src/transport/common/file_request_server_mixin.dart`
- `mixin` **FileRequestServerMixin** — baris 8 — `mixin FileRequestServerMixin {`
- `getter` **hostedFiles (FileRequestServerMixin)** — baris 10 — `  Map<String, HostedFileInfo> get hostedFiles;`
- `getter` **transportUsername (FileRequestServerMixin)** — baris 13 — `  String get transportUsername; // For logging prefix`
- `field` **_logPrefixBase (FileRequestServerMixin)** — baris 14 — `  static const String _logPrefixBase = "P2P FileServer";`
- `method` **handleFileRequest (FileRequestServerMixin)** — baris 20 — `  Future<void> handleFileRequest(HttpRequest request) async {`

### `packages/flutter_p2p_connection/lib/src/transport/common/transport_data_models.dart`
- `class` **P2pClientInfo** — baris 9 — `class P2pClientInfo {`
- `field` **id (P2pClientInfo)** — baris 11 — `  final String id;`
- `field` **username (P2pClientInfo)** — baris 14 — `  final String username;`
- `field` **isHost (P2pClientInfo)** — baris 17 — `  final bool isHost;`
- `method` **toJson (P2pClientInfo)** — baris 33 — `  Map<String, dynamic> toJson() => {`
- `method` **toString (P2pClientInfo)** — baris 40 — `  String toString() =>`

### `packages/flutter_p2p_connection/lib/src/transport/common/transport_enums.dart`
- `enum` **P2pMessageType** — baris 2 — `enum P2pMessageType {`
- `enum` **ReceivableFileState** — baris 17 — `enum ReceivableFileState {`

### `packages/flutter_p2p_connection/lib/src/transport/common/transport_file_models.dart`
- `class` **HostedFileInfo** — baris 5 — `class HostedFileInfo {`
- `field` **info (HostedFileInfo)** — baris 7 — `  final P2pFileInfo info;`
- `field` **localPath (HostedFileInfo)** — baris 10 — `  final String localPath;`
- `field` **_state (HostedFileInfo)** — baris 12 — `  ReceivableFileState _state = ReceivableFileState.idle;`
- `field` **_downloadProgressBytes (HostedFileInfo)** — baris 14 — `  final Map<String, int> _downloadProgressBytes;`
- `getter` **state (HostedFileInfo)** — baris 17 — `  ReceivableFileState get state => _state;`
- `getter` **receiverIds (HostedFileInfo)** — baris 20 — `  List<String> get receiverIds => _downloadProgressBytes.keys.toList();`
- `method` **getProgressPercent (HostedFileInfo)** — baris 36 — `  double getProgressPercent(String receiverId) {`
- `class` **ReceivableFileInfo** — baris 59 — `class ReceivableFileInfo {`
- `field` **info (ReceivableFileInfo)** — baris 61 — `  final P2pFileInfo info;`
- `field` **state (ReceivableFileInfo)** — baris 64 — `  ReceivableFileState state;`
- `field` **downloadProgressPercent (ReceivableFileInfo)** — baris 67 — `  double downloadProgressPercent;`
- `field` **savePath (ReceivableFileInfo)** — baris 70 — `  String? savePath;`
- `class` **FileDownloadProgressUpdate** — baris 82 — `class FileDownloadProgressUpdate {`
- `field` **fileId (FileDownloadProgressUpdate)** — baris 84 — `  final String fileId;`
- `field` **progressPercent (FileDownloadProgressUpdate)** — baris 87 — `  final double progressPercent;`
- `field` **bytesDownloaded (FileDownloadProgressUpdate)** — baris 90 — `  final int bytesDownloaded;`
- `field` **totalSize (FileDownloadProgressUpdate)** — baris 93 — `  final int totalSize;`
- `field` **savePath (FileDownloadProgressUpdate)** — baris 96 — `  final String savePath;`
- `method` **toString (FileDownloadProgressUpdate)** — baris 108 — `  String toString() =>`

### `packages/flutter_p2p_connection/lib/src/transport/host/transport_host.dart`
- `class` **P2pTransportHost** — baris 20 — `class P2pTransportHost with FileRequestServerMixin {`
- `field` **defaultPort (P2pTransportHost)** — baris 22 — `  final int defaultPort;`
- `field` **username (P2pTransportHost)** — baris 25 — `  final String username;`
- `field` **hostId (P2pTransportHost)** — baris 28 — `  final String hostId = const Uuid().v4();`
- `field` **_server (P2pTransportHost)** — baris 29 — `  HttpServer? _server;`
- `field` **_portInUse (P2pTransportHost)** — baris 30 — `  int? _portInUse;`
- `field` **_hostedFiles (P2pTransportHost)** — baris 32 — `  final Map<String, HostedFileInfo> _hostedFiles = {};`
- `field` **_receivableFiles (P2pTransportHost)** — baris 33 — `  final Map<String, ReceivableFileInfo> _receivableFiles = {};`
- `field` **_receivedTextController (P2pTransportHost)** — baris 34 — `  final StreamController<String> _receivedTextController =`
- `field` **_logPrefix (P2pTransportHost)** — baris 37 — `  static const String _logPrefix = "P2P Transport Host";`
- `getter` **hostedFiles (P2pTransportHost)** — baris 40 — `  Map<String, HostedFileInfo> get hostedFiles => _hostedFiles;`
- `getter` **transportUsername (P2pTransportHost)** — baris 42 — `  String get transportUsername => username;`
- `getter` **receivedTextStream (P2pTransportHost)** — baris 45 — `  Stream<String> get receivedTextStream => _receivedTextController.stream;`
- `getter` **portInUse (P2pTransportHost)** — baris 48 — `  int? get portInUse => _portInUse;`
- `getter` **clientList (P2pTransportHost)** — baris 51 — `  List<P2pClientInfo> get clientList =>`

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
- `class` **IqamahDuration** — baris 12 — `class IqamahDuration {`
- `field` **fajr (IqamahDuration)** — baris 13 — `  final int fajr;`
- `field` **dhuhr (IqamahDuration)** — baris 14 — `  final int dhuhr;`
- `field` **asr (IqamahDuration)** — baris 15 — `  final int asr;`
- `field` **maghrib (IqamahDuration)** — baris 16 — `  final int maghrib;`
- `field` **isha (IqamahDuration)** — baris 17 — `  final int isha;`
- `method` **toMap (IqamahDuration)** — baris 27 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (IqamahDuration)** — baris 46 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (IqamahDuration)** — baris 56 — `  int get hashCode => Object.hash(fajr, dhuhr, asr, maghrib, isha);`
- `method` **toString (IqamahDuration)** — baris 59 — `  String toString() =>`
- `class` **MosqueConfig** — baris 71 — `class MosqueConfig {`
- `field` **name (MosqueConfig)** — baris 72 — `  final String name;`
- `field` **address (MosqueConfig)** — baris 73 — `  final String address;`
- `field` **latitude (MosqueConfig)** — baris 74 — `  final double latitude;`
- `field` **longitude (MosqueConfig)** — baris 75 — `  final double longitude;`
- `field` **utcOffsetHours (MosqueConfig)** — baris 76 — `  final int utcOffsetHours;`
- `field` **iqamahDuration (MosqueConfig)** — baris 77 — `  final IqamahDuration iqamahDuration;`
- `field` **prayerOffsets (MosqueConfig)** — baris 78 — `  final Map<PrayerType, int> prayerOffsets;`
- `field` **preAdhanMinutes (MosqueConfig)** — baris 81 — `  final int preAdhanMinutes;`
- `field` **adhanMinutes (MosqueConfig)** — baris 84 — `  final int adhanMinutes;`
- `field` **preIqomahMinutes (MosqueConfig)** — baris 87 — `  final int preIqomahMinutes;`
- `field` **shalatMinutes (MosqueConfig)** — baris 90 — `  final int shalatMinutes;`
- `field` **khutbahMinutes (MosqueConfig)** — baris 93 — `  final int khutbahMinutes;`
- `field` **fridayKhatib (MosqueConfig)** — baris 96 — `  final String fridayKhatib;`
- `field` **fridayMuadzin (MosqueConfig)** — baris 99 — `  final String fridayMuadzin;`
- `method` **offsetFor (MosqueConfig)** — baris 137 — `  int offsetFor(PrayerType type) => prayerOffsets[type] ?? 0;`
- `method` **toMap (MosqueConfig)** — baris 139 — `  Map<String, dynamic> toMap() => {`
- `method` **toJson (MosqueConfig)** — baris 209 — `  String toJson() => json.encode(toMap());`
- `method` **_mapsEqual (MosqueConfig)** — baris 251 — `  static bool _mapsEqual(Map<PrayerType, int> a, Map<PrayerType, int> b) {`
- `operator` **operator == (MosqueConfig)** — baris 261 — `  bool operator ==(Object other) =>`
- `getter` **hashCode (MosqueConfig)** — baris 280 — `  int get hashCode => Object.hash(`
- `method` **toString (MosqueConfig)** — baris 298 — `  String toString() =>`

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

### `packages/shared_models/lib/src/state_snapshot.dart`
- `function` **_stringKeyed** — baris 10 — `Map<String, dynamic> _stringKeyed(Map raw) => {`
- `class` **StateSnapshot** — baris 41 — `class StateSnapshot {`
- `field` **config (StateSnapshot)** — baris 42 — `  final MosqueConfig config;`
- `field` **runningTexts (StateSnapshot)** — baris 43 — `  final List<RunningTextMessage> runningTexts;`
- `field` **banners (StateSnapshot)** — baris 44 — `  final List<MediaBanner> banners;`
- `field` **kasTransactions (StateSnapshot)** — baris 45 — `  final List<KasTransaction> kasTransactions;`
- `field` **hasData (StateSnapshot)** — baris 46 — `  final bool hasData;`
- `method` **toMap (StateSnapshot)** — baris 56 — `  Map<String, dynamic> toMap() => {`
- `operator` **operator == (StateSnapshot)** — baris 93 — `  bool operator ==(Object other) =>`
- `method` **_listsEqual (StateSnapshot)** — baris 100 — `          _listsEqual(other.kasTransactions, kasTransactions);`
- `getter` **hashCode (StateSnapshot)** — baris 103 — `  int get hashCode => Object.hash(`
- `method` **toString (StateSnapshot)** — baris 112 — `  String toString() =>`

### `packages/shared_models/lib/src/sync_packet.dart`
- `enum` **SyncAction** — baris 3 — `enum SyncAction {`
- `class` **SyncPacket** — baris 30 — `class SyncPacket {`
- `field` **action (SyncPacket)** — baris 31 — `  final SyncAction action;`
- `field` **payload (SyncPacket)** — baris 32 — `  final Map<String, dynamic> payload;`
- `method` **toMap (SyncPacket)** — baris 39 — `  Map<String, dynamic> toMap() => {`
- `method` **_parsePayload (SyncPacket)** — baris 61 — `  static Map<String, dynamic> _parsePayload(Object? raw) {`
- `method` **toJson (SyncPacket)** — baris 72 — `  String toJson() => json.encode(toMap());`
- `operator` **operator == (SyncPacket)** — baris 78 — `  bool operator ==(Object other) =>`
- `method` **_mapsEqual (SyncPacket)** — baris 82 — `  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {`
- `getter` **hashCode (SyncPacket)** — baris 91 — `  int get hashCode => Object.hash(action, Object.hashAll(payload.keys.toList()..sort()));`
- `method` **toString (SyncPacket)** — baris 94 — `  String toString() => 'SyncPacket(action: ${action.name}, payload: $payload)';`
