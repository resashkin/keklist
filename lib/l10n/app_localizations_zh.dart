// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get insightsBrightestPeriod => '最精彩的时段';

  @override
  String get insightsPeriodWeek => '周';

  @override
  String get insightsPeriodMonth => '月';

  @override
  String get insightsPeriodYear => '年';

  @override
  String get insightsPeriodAllTime => '全部';

  @override
  String insightsVsLastWeek(String delta) {
    return '较上周 $delta';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '较上月 $delta';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '较去年 $delta';
  }

  @override
  String get insightsCategorySummary => '概览';

  @override
  String get insightsCategoryEmotions => '情绪';

  @override
  String get insightsCategoryActivity => '活跃度';

  @override
  String get insightsCategoryMemories => '回忆';

  @override
  String get insightsCategoryMedia => '媒体';

  @override
  String get insightsCounters => '数据一览';

  @override
  String get insightsMinds => '笔记';

  @override
  String get insightsActiveDays => '活跃天数';

  @override
  String get insightsWords => '字数';

  @override
  String get insightsBrightestDay => '最精彩的一天';

  @override
  String get insightsBrightestWeek => '最精彩的一周';

  @override
  String get insightsBrightestMonth => '最精彩的一个月';

  @override
  String get insightsBrightestYear => '最精彩的一年';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return '笔记 $minds · 情绪 $emotions · 媒体 $media';
  }

  @override
  String get insightsEmotionDistribution => '情绪';

  @override
  String get insightsEmotionTrend => '情绪趋势';

  @override
  String get insightsEmotionPairs => '同时出现的情绪';

  @override
  String get insightsEmotionRhythm => '情绪节律';

  @override
  String get insightsByWeekday => '按星期';

  @override
  String get insightsByDayPart => '按时段';

  @override
  String get insightsNight => '夜间';

  @override
  String get insightsMorning => '上午';

  @override
  String get insightsAfternoon => '下午';

  @override
  String get insightsEvening => '晚上';

  @override
  String get insightsStreak => '连续记录';

  @override
  String get insightsStreakLabel => '天连续';

  @override
  String insightsLongestStreak(String count) {
    return '最长：$count';
  }

  @override
  String get insightsStreakKeepGoing => '今天添加一条笔记以保持连续';

  @override
  String get insightsHeatmap => '活跃度地图';

  @override
  String get insightsActivityTime => '时段';

  @override
  String insightsPeakHour(String hour) {
    return '最常在 $hour 左右';
  }

  @override
  String get insightsOnThisDay => '那时';

  @override
  String get insightsMediaCounters => '媒体';

  @override
  String get insightsPhotos => '照片';

  @override
  String get insightsVideos => '视频';

  @override
  String get insightsVoiceNotes => '语音笔记';

  @override
  String get insightsRoundVideos => '圆形视频';

  @override
  String get insightsEmptyPeriod => '此期间还没有笔记';

  @override
  String get insightsEmptyEmotions => '为笔记标记情绪后即可查看';

  @override
  String get insightsEmptyPairs => '为一条笔记标记两种情绪即可查看组合';

  @override
  String get insightsEmptyOnThisDay => '一周、一个月、半年和一年前还没有记录';

  @override
  String get insightsEmptyRoundVideos => '此期间没有语音或圆形视频';

  @override
  String get insightsEmptyStreak => '今天添加一条笔记开始连续记录';

  @override
  String get insightsCustomize => '自定义分析';

  @override
  String get insightsCustomizeDescription => '开关卡片，拖动以重新排序';

  @override
  String get insightsResetLayout => '重置';

  @override
  String get activeTasks => '进行中的任务';

  @override
  String get galleryIndex => '图库索引';

  @override
  String get galleryIndexNoAccess => '无法访问照片';

  @override
  String get galleryIndexNotIndexed => '尚未建立索引';

  @override
  String galleryIndexIndexing(String done, String total) {
    return '正在索引 $done / $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count 张照片和视频 · 更新于 $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return '缩略图缓存：$size';
  }

  @override
  String get galleryIndexRebuildTitle => '要重建图库索引吗？';

  @override
  String get galleryIndexRebuildMessage => '缩略图将被清除，并重新扫描图库。';

  @override
  String get galleryIndexRebuild => '重建';

  @override
  String get settings => '设置';

  @override
  String get userData => '用户数据';

  @override
  String get appearance => '外观';

  @override
  String get interfaceStyle => '界面风格';

  @override
  String get exportToCsv => '导出到CSV';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get done => '完成';

  @override
  String get chatWithAI => '与AI聊天';

  @override
  String get photosPerDay => '每日照片';

  @override
  String get extraActions => '额外操作';

  @override
  String get mindOptions => '笔记选项';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get share => '分享';

  @override
  String get saveToFiles => '保存到文件';

  @override
  String get switchDay => '切换日期';

  @override
  String get goToDate => '转到日期';

  @override
  String get showDigest => '显示摘要...';

  @override
  String get translateToEnglish => '翻译为英文';

  @override
  String get convertToStandalone => '转换为独立';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get theme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get showDayDividers => '显示日期分隔符';

  @override
  String get tabsSettings => '标签页设置';

  @override
  String get whatsNew => '新功能';

  @override
  String get releaseNotes => '发行说明';

  @override
  String get suggestFeature => '建议功能';

  @override
  String get sendFeedback => '发送反馈';

  @override
  String get emailUs => '给我们发邮件';

  @override
  String get clearOfflineDataWarning => '所有离线数据都会被删除。请确保已提前导出。';

  @override
  String get sourceCode => '源代码';

  @override
  String get termsOfUse => '使用条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get clearOnDeviceData => '清除设备数据';

  @override
  String get setOpenAIToken => '设置Open AI令牌';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get mind => '笔记';

  @override
  String get profile => '个人资料';

  @override
  String get insights => '个人资料';

  @override
  String get calendar => '日历';

  @override
  String get debugMenu => '调试菜单';

  @override
  String get discussion => '讨论';

  @override
  String get about => '关于';

  @override
  String get dangerZone => '危险区域';

  @override
  String get enterTokenHere => '在此输入令牌';

  @override
  String get token => '令牌';

  @override
  String get clearCache => '清除缓存';

  @override
  String get activeTabs => '活动标签页';

  @override
  String get hiddenTabs => '隐藏标签页';

  @override
  String get error => '错误';

  @override
  String get startDiscussion => '开始讨论';

  @override
  String get send => '发送';

  @override
  String get create => '创建';

  @override
  String get yourFolderName => '您的文件夹名称';

  @override
  String get noMindsInSelectedPeriod => '所选期间没有笔记';

  @override
  String get noMindsForPeriod => '此期间没有笔记';

  @override
  String get selectPeriod => '选择期间...';

  @override
  String get digest => '摘要';

  @override
  String get minds => '笔记';

  @override
  String get searchForYourNotes => '搜索您的笔记';

  @override
  String get searchYourEmoji => '搜索您的表情符号...';

  @override
  String get writeSomething => '写点什么...';

  @override
  String get todayMinds => '今天的笔记';

  @override
  String get youDidNotCollectAnyEntriesYet => '您还没有收集任何条目';

  @override
  String get areYouSure => '您确定吗？';

  @override
  String get cannotRemoveMainScreen => '无法删除主屏幕。您将失去设置标签页的选项。';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get thisWeek => '本周';

  @override
  String get lastTwoWeeks => '最近2周';

  @override
  String get thisMonth => '本月';

  @override
  String get thisYear => '今年';

  @override
  String get calendarDescription => '带有条目日历的主屏幕';

  @override
  String get insightsDescription => '你和你的记录统计';

  @override
  String get settingsDescription => '包含所有设置的屏幕（深色模式、同步等）';

  @override
  String get todayDescription => '仅今天的笔记';

  @override
  String get debugMenuDescription => '用于切换实验性功能的开发者工具';

  @override
  String get noMindsForThisDay => '这一天没有笔记';

  @override
  String get week => '周';

  @override
  String get password => '密码';

  @override
  String get archivePassword => '归档密码';

  @override
  String get enterPassword => '输入密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get reenterPassword => '重新输入密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get exportPassword => '导出为ZIP';

  @override
  String get exportPasswordDescription => '添加密码以加密您的导出。您可以跳过此步骤进行不加密导出。';

  @override
  String get importPassword => '输入密码';

  @override
  String get importPasswordDescription => '此文件受密码保护。请输入密码以解密。';

  @override
  String get skipPassword => '跳过（无密码）';

  @override
  String get continue_ => '继续';

  @override
  String get incorrectPassword => '密码错误';

  @override
  String get incorrectPasswordMessage => '您输入的密码不正确。请重试。';

  @override
  String get corruptedFile => '文件已损坏';

  @override
  String get invalidFormat => '格式无效';

  @override
  String get missingAudioFiles => '某些音频文件缺失';

  @override
  String get insufficientStorage => '存储空间不足';

  @override
  String get unknownError => '未知错误';

  @override
  String get retry => '重试';

  @override
  String get ok => '确定';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get exportError => '导出失败';

  @override
  String get importSuccess => '导入成功';

  @override
  String get importError => '导入失败';

  @override
  String get mindsToExport => '笔记';

  @override
  String get audioFilesToExport => '音频文件';

  @override
  String get emotionsToExport => '情绪';

  @override
  String get mindsExported => '笔记已导出';

  @override
  String get audioFilesExported => '音频文件已导出';

  @override
  String get mindsImported => '笔记已导入';

  @override
  String get audioFilesImported => '音频文件已导入';

  @override
  String get onboardingMind1 => '你好！';

  @override
  String get onboardingMind2 => '我是keklist - 一个短笔记的个人日记';

  @override
  String get onboardingMind2Comment1 => '笔记可以添加评论';

  @override
  String get onboardingMind2Comment2 => '要打开笔记，请点击它';

  @override
  String get onboardingMind3 => '在\'日历\'标签页中，所有笔记按天、周和月显示';

  @override
  String get onboardingMind4 => '\'分析\'标签页显示您条目的简要统计信息';

  @override
  String get onboardingMind5 => '所有笔记仅存储在您的手机上';

  @override
  String get onboardingMind6 => '要创建新笔记，请点击\'写入\'';

  @override
  String get noPhotosForDay => '未找到当天的照片';

  @override
  String get sourcesMediaFolder => '媒体文件';

  @override
  String get sourcesMediaFolderSubtitle => '来自自定义文件夹的照片和视频';

  @override
  String get mediaFolderSettings => '媒体文件';

  @override
  String get licenses => '许可证';

  @override
  String get sourcesWeather => '天气';

  @override
  String get sourcesWeatherSubtitle => '本日当地天气状况';

  @override
  String get weatherSettings => '天气设置';

  @override
  String get weatherLatitude => '纬度';

  @override
  String get weatherLongitude => '经度';

  @override
  String get weatherSaveLocation => '保存位置';

  @override
  String get weatherUseMyLocation => '使用我的位置';

  @override
  String get weatherDetectingLocation => '正在检测位置...';

  @override
  String get weatherOrEnterManually => '或手动输入';

  @override
  String get weatherLocationError => '无法检测位置，请手动输入。';

  @override
  String get weatherLocationServicesDisabled => '位置服务已关闭，请在设置中开启。';

  @override
  String get weatherLocationPermissionDenied => '位置权限被拒绝。';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      '位置权限被永久拒绝，正在打开应用设置。';

  @override
  String get audioRecordTitle => '录制音频';

  @override
  String get audioRecordTitleRecording => '录制中…';

  @override
  String get audioRecordHint => '点击停止以保存到设备。';

  @override
  String get audioRecordStart => '开始';

  @override
  String get audioRecordStop => '停止';

  @override
  String get audioRecordCancel => '取消';

  @override
  String get audioRecordPermissionError => '需要麦克风权限才能录制音频。';

  @override
  String get audioRecordStartError => '无法开始录制。请重试。';

  @override
  String get audioRecordStopError => '无法停止录制。请重试。';

  @override
  String proUserFooter(String price, String date) {
    return '您是PRO用户。下一次 $price 的付款将于 $date 进行。';
  }

  @override
  String get emotions => '情绪';

  @override
  String get archived => '已归档';

  @override
  String get archive => '归档';

  @override
  String get restore => '恢复';

  @override
  String get deletePermanently => '永久删除';

  @override
  String get newEmotion => '新建情绪';

  @override
  String get editEmotion => '编辑情绪';

  @override
  String get addEmotion => '添加情绪';

  @override
  String get addEmotionsToMind => '添加情绪';

  @override
  String get emotionNameHint => '名称';

  @override
  String get doneEditing => '完成';

  @override
  String get emotionEditHint => '点按重命名 · ✕ 删除 · 拖动排序';

  @override
  String get emotionInUseMessage => '此情绪已被一些 mind 使用。归档可将其保留在那里，或彻底删除。';

  @override
  String get noEmotionsYet => '还没有情绪';

  @override
  String get noArchivedEmotions => '没有已归档的情绪';

  @override
  String get deleteEmotionMessage => '删除此情绪？它将从所有使用它的 mind 中移除。';

  @override
  String get dayFeedTileSettings => '磁贴设置';

  @override
  String get dayFeedColumns => '列数';

  @override
  String get dayFeedMindTileSize => '磁贴大小';

  @override
  String get dayFeedMindTileSquare => '方形';

  @override
  String get dayFeedMindTileWide => '宽';

  @override
  String get dayFeedShowMindText => '显示文字';

  @override
  String get dayFeedPhotoAccessHint => '允许访问照片以在此查看你的照片和视频';

  @override
  String get dayFeedAllowAccess => '允许';

  @override
  String get dayFeedFolderHint => '选择媒体文件夹以在此查看你的照片和视频';

  @override
  String get dayFeedChooseFolder => '选择';

  @override
  String get dayFeedMute => '静音';

  @override
  String get dayFeedUnmute => '取消静音';

  @override
  String get holdToRecordAudio => '按住录制语音消息';

  @override
  String get holdToRecordVideo => '按住录制视频消息';

  @override
  String get roundVideoRecordError => '无法录制视频';

  @override
  String get roundVideoCameraUnavailable => '此设备上的相机不可用';

  @override
  String get roundVideoRetake => '重拍';

  @override
  String get roundVideoUse => '使用';

  @override
  String get removeMedia => '移除媒体';

  @override
  String get shakeToCustomize => '摇一摇进行自定义';

  @override
  String get shakeToCustomizeHint => '或长按标题';

  @override
  String get customizeSettings => '自定义设置';

  @override
  String get customizeSettingsDescription => '取消勾选的分区和行将在设置页面中隐藏。';

  @override
  String get calendarSettings => '日历设置';

  @override
  String get calendarShowMedia => '显示照片和视频';

  @override
  String get calendarWeekTitles => '周标题';

  @override
  String get calendarPlayStories => '播放故事';

  @override
  String get storyBackgroundTweak => '故事背景';

  @override
  String get storyAnimationOff => '关闭';

  @override
  String get storyAnimationPulse => '脉动';

  @override
  String get storyAnimationWave => '波浪';

  @override
  String get storyAnimationEqualizer => '均衡器';

  @override
  String get storyAnimationDrift => '漂移';

  @override
  String get storyAnimationGlow => '光晕';

  @override
  String get viewerCommentHint => '评论…';

  @override
  String get calendarToCurrentWeek => '回到本周';

  @override
  String get storyDateLines => '日期行数';

  @override
  String get storyTextureTitle => '纹理';

  @override
  String get storySpectrum => '声音频谱';

  @override
  String get storySensitivity => '灵敏度';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '用心记录 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get profileName => '名字';

  @override
  String get profilePhoto => '照片';

  @override
  String get profileEmoji => '表情';

  @override
  String get profileInitial => '字母';

  @override
  String get webVersion => '网页版';

  @override
  String get webVersionAddressHint => '在同一 Wi‑Fi 下的电脑浏览器中打开；请保持 keklist 打开';

  @override
  String get webVersionCopied => '地址已复制';

  @override
  String get webVersionNeedsPin => '设置 PIN 后即可在同一 Wi‑Fi 下的电脑浏览器中打开 keklist。';

  @override
  String get webVersionStarting => '正在启动…';

  @override
  String get webVersionNoWifi => '连接 Wi‑Fi 后即可在浏览器中打开 keklist。';

  @override
  String get webVersionNoBundle => '此版本不包含网页版。';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => '每个浏览器每 30 天询问一次';

  @override
  String get webVersionPinNotSet => '未设置';

  @override
  String get webVersionPinHint => '4–8 位数字';

  @override
  String get webVersionRemovePin => '删除 PIN';

  @override
  String get webVersionPort => '端口';

  @override
  String get aiTab => '聊天';

  @override
  String get aiTabDescription => '与在手机上运行的 AI 聊聊你的记录';

  @override
  String get aiPrivacyNote => '仅在手机上运行：你的记录不会离开设备。';

  @override
  String get aiDisclaimer => '这不是医疗服务。如果你处于危险中，请联系紧急服务。';

  @override
  String get aiYesterday => '昨天';

  @override
  String get aiSessions => '会话';

  @override
  String get aiNoSessions => '还没有会话';

  @override
  String get aiNewSession => '新会话';

  @override
  String get aiChooseRole => '选择角色';

  @override
  String get aiRoleTherapist => '心理咨询师';

  @override
  String get aiRoleCoach => '教练';

  @override
  String get aiRoleFriend => '朋友';

  @override
  String get aiMessageHint => '消息';

  @override
  String get aiStarterWeek => '我这周过得怎么样？';

  @override
  String get aiStarterWorry => '最近什么让我烦恼？';

  @override
  String get aiStarterJoy => '最近什么让我开心？';

  @override
  String get aiActionSaveAsMind => '保存为记录';

  @override
  String get aiActionOpenDay => '打开当天';

  @override
  String get aiActionWeekSummary => '本周总结';

  @override
  String get aiWeekSummaryPrompt => '总结我最近 7 天：发生了什么、我感受如何、什么最突出。';

  @override
  String get aiSavedAsMind => '已保存到今天';

  @override
  String get aiThinking => '思考中…';

  @override
  String get aiStop => '停止';

  @override
  String get aiNoModelTitle => '选择模型';

  @override
  String get aiNoModelMessage => '下载一个模型即可开始。它在手机上离线运行。';

  @override
  String get aiNoModelOnPhone => '请在手机上的应用中下载模型：设置 → AI → 模型。';

  @override
  String get aiModels => '模型';

  @override
  String get aiRoles => '角色';

  @override
  String get aiDownloaded => '已下载';

  @override
  String get aiDownloads => '下载中';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => '搜索 GGUF 模型';

  @override
  String get aiDownload => '下载';

  @override
  String get aiPause => '暂停';

  @override
  String get aiPaused => '已暂停';

  @override
  String get aiResume => '继续';

  @override
  String get aiDownloadFailed => '下载失败';

  @override
  String get aiCellularTitle => '使用移动数据下载？';

  @override
  String aiCellularMessage(String size) {
    return '将使用移动数据下载 $size。';
  }

  @override
  String get aiDeleteModel => '删除模型？';

  @override
  String aiStorageUsed(String size) {
    return '本机占用：$size';
  }

  @override
  String aiDeviceMemory(String size) {
    return '手机内存：$size';
  }

  @override
  String get aiCatalogFailed => '无法加载列表。请检查网络连接。';

  @override
  String get aiNoFilesFit => '该模型没有可放入本机内存的文件。';

  @override
  String get aiBuiltInRole => '内置';

  @override
  String get aiOwnRoles => '你的角色';

  @override
  String get aiDuplicate => '复制';

  @override
  String get aiNewRole => '新角色';

  @override
  String get aiRoleName => '名称';

  @override
  String get aiRoleEmoji => '表情';

  @override
  String get aiRolePrompt => '提示词';

  @override
  String get aiRolePromptHint => 'AI 应如何说话以及关注什么';

  @override
  String get aiReadOnlyRole => '内置角色无法修改。复制一个来创建你自己的角色。';

  @override
  String get aiDeleteSession => '删除会话？';

  @override
  String get aiDeleteRole => '删除角色？';

  @override
  String get aiRecommended => '推荐';

  @override
  String get aiLowQuality => '质量较低';

  @override
  String get aiModelDoesNotFit => '此模型超出手机内存。请选择更小的模型。';

  @override
  String get aiChooseAnotherModel => '选择其他模型';

  @override
  String get creatorEmotionsTitle => '情绪';

  @override
  String get creatorEmotionsAfterSave => '保存后询问';

  @override
  String get creatorEmotionsButton => '键盘上方的按钮';

  @override
  String get creatorEmotionsNever => '不询问';

  @override
  String get insightsWeekAgo => '一周前';

  @override
  String get insightsMonthAgo => '一个月前';

  @override
  String get insightsHalfYearAgo => '半年前';

  @override
  String get insightsYearAgo => '一年前';

  @override
  String get insightsTwoYearsAgo => '两年前';

  @override
  String get insightsVoiceAndVideos => '语音和圆形视频';

  @override
  String insightsWeekNumber(String number) {
    return '第$number周';
  }
}
