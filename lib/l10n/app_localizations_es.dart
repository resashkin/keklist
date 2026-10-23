// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Periodo más intenso';

  @override
  String get insightsPeriodWeek => 'Semana';

  @override
  String get insightsPeriodMonth => 'Mes';

  @override
  String get insightsPeriodYear => 'Año';

  @override
  String get insightsPeriodAllTime => 'Todo';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta vs. la semana pasada';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta vs. el mes pasado';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta vs. el año pasado';
  }

  @override
  String get insightsCategorySummary => 'Resumen';

  @override
  String get insightsCategoryEmotions => 'Emociones';

  @override
  String get insightsCategoryActivity => 'Actividad';

  @override
  String get insightsCategoryMemories => 'Recuerdos';

  @override
  String get insightsCategoryMedia => 'Multimedia';

  @override
  String get insightsCounters => 'En números';

  @override
  String get insightsMinds => 'Notas';

  @override
  String get insightsActiveDays => 'Días activos';

  @override
  String get insightsWords => 'Palabras';

  @override
  String get insightsBrightestDay => 'Día más intenso';

  @override
  String get insightsBrightestWeek => 'Semana más intensa';

  @override
  String get insightsBrightestMonth => 'Mes más intenso';

  @override
  String get insightsBrightestYear => 'Año más intenso';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return '$minds notas · $emotions emociones · $media multimedia';
  }

  @override
  String get insightsEmotionDistribution => 'Emociones';

  @override
  String get insightsEmotionTrend => 'Tendencia de emociones';

  @override
  String get insightsEmotionPairs => 'Emociones juntas';

  @override
  String get insightsEmotionRhythm => 'Ritmo emocional';

  @override
  String get insightsByWeekday => 'Por día de la semana';

  @override
  String get insightsByDayPart => 'Por momento del día';

  @override
  String get insightsNight => 'Noche';

  @override
  String get insightsMorning => 'Mañana';

  @override
  String get insightsAfternoon => 'Tarde';

  @override
  String get insightsEvening => 'Atardecer';

  @override
  String get insightsStreak => 'Racha';

  @override
  String get insightsStreakLabel => 'días seguidos';

  @override
  String insightsLongestStreak(String count) {
    return 'Récord: $count';
  }

  @override
  String get insightsStreakKeepGoing => 'Añade una nota hoy para mantenerla';

  @override
  String get insightsHeatmap => 'Mapa de actividad';

  @override
  String get insightsActivityTime => 'Momento del día';

  @override
  String insightsPeakHour(String hour) {
    return 'Más activo hacia las $hour';
  }

  @override
  String get insightsOnThisDay => 'En aquel entonces';

  @override
  String get insightsMediaCounters => 'Multimedia';

  @override
  String get insightsPhotos => 'Fotos';

  @override
  String get insightsVideos => 'Vídeos';

  @override
  String get insightsVoiceNotes => 'Notas de voz';

  @override
  String get insightsRoundVideos => 'Vídeos redondos';

  @override
  String get insightsEmptyPeriod => 'Aún no hay notas en este periodo';

  @override
  String get insightsEmptyEmotions =>
      'Etiqueta notas con emociones para ver esto';

  @override
  String get insightsEmptyPairs =>
      'Etiqueta una nota con dos emociones para ver pares';

  @override
  String get insightsEmptyOnThisDay =>
      'Aún no hay nada de hace una semana, un mes, medio año o un año';

  @override
  String get insightsEmptyRoundVideos =>
      'No hay notas de voz ni videos redondos en este período';

  @override
  String get insightsEmptyStreak => 'Añade una nota hoy para empezar una racha';

  @override
  String get insightsCustomize => 'Personalizar análisis';

  @override
  String get insightsCustomizeDescription =>
      'Activa o desactiva tarjetas y arrástralas para ordenarlas';

  @override
  String get insightsResetLayout => 'Restablecer';

  @override
  String get activeTasks => 'Tareas activas';

  @override
  String get galleryIndex => 'Índice de la galería';

  @override
  String get galleryIndexNoAccess => 'Sin acceso a Fotos';

  @override
  String get galleryIndexNotIndexed => 'Aún sin indexar';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indexando $done de $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count fotos y vídeos · actualizado $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Caché de miniaturas: $size';
  }

  @override
  String get galleryIndexRebuildTitle =>
      '¿Reconstruir el índice de la galería?';

  @override
  String get galleryIndexRebuildMessage =>
      'Se borrarán las miniaturas y la fototeca se analizará de nuevo.';

  @override
  String get galleryIndexRebuild => 'Reconstruir';

  @override
  String get settings => 'Configuración';

  @override
  String get userData => 'Datos de usuario';

  @override
  String get appearance => 'Apariencia';

  @override
  String get interfaceStyle => 'Estilo de interfaz';

  @override
  String get exportToCsv => 'Exportar a CSV';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get done => 'HECHO';

  @override
  String get chatWithAI => 'Chatear con IA';

  @override
  String get photosPerDay => 'Fotos por día';

  @override
  String get extraActions => 'Acciones extra';

  @override
  String get mindOptions => 'Opciones de mente';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get share => 'Compartir';

  @override
  String get saveToFiles => 'Guardar en archivos';

  @override
  String get switchDay => 'Cambiar día';

  @override
  String get goToDate => 'Ir a fecha';

  @override
  String get showDigest => 'Mostrar resumen para ...';

  @override
  String get translateToEnglish => 'Traducir al inglés';

  @override
  String get convertToStandalone => 'Convertir a independiente';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get showDayDividers => 'Mostrar divisores de día';

  @override
  String get tabsSettings => 'Configuración de pestañas';

  @override
  String get whatsNew => '¿Qué hay de nuevo?';

  @override
  String get releaseNotes => 'Notas de la versión';

  @override
  String get suggestFeature => 'Sugerir una función';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get emailUs => 'Envíanos un correo';

  @override
  String get clearOfflineDataWarning =>
      'Todos tus datos sin conexión se eliminarán. Asegúrate de haberlos exportado.';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get clearOnDeviceData => 'Limpiar datos del dispositivo';

  @override
  String get setOpenAIToken => 'Establecer Token Open AI';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get mind => 'Mente';

  @override
  String get profile => 'Perfil';

  @override
  String get insights => 'Perfil';

  @override
  String get calendar => 'Calendario';

  @override
  String get debugMenu => 'Menú Debug';

  @override
  String get discussion => 'Discusión';

  @override
  String get about => 'Acerca de';

  @override
  String get dangerZone => 'Zona de Peligro';

  @override
  String get enterTokenHere => 'Ingresa token aquí';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get activeTabs => 'Pestañas activas';

  @override
  String get hiddenTabs => 'Pestañas ocultas';

  @override
  String get error => 'Error';

  @override
  String get startDiscussion => 'Iniciar discusión';

  @override
  String get send => 'ENVIAR';

  @override
  String get create => 'Crear';

  @override
  String get yourFolderName => 'Nombre de tu carpeta';

  @override
  String get noMindsInSelectedPeriod =>
      'No hay mentes en el período seleccionado';

  @override
  String get noMindsForPeriod => 'No hay mentes para este período';

  @override
  String get selectPeriod => 'Seleccionar período ...';

  @override
  String get digest => 'Resumen';

  @override
  String get minds => 'Mentes';

  @override
  String get searchForYourNotes => 'Buscar tus notas';

  @override
  String get searchYourEmoji => 'Buscar tu emoji...';

  @override
  String get writeSomething => 'Escribe algo...';

  @override
  String get todayMinds => 'Mentes de hoy';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Aún no has recopilado ninguna entrada';

  @override
  String get areYouSure => '¿Estás seguro?';

  @override
  String get cannotRemoveMainScreen =>
      'No se puede eliminar la pantalla principal. Perderás la opción de configurar pestañas.';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastTwoWeeks => 'Últimas 2 semanas';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String get calendarDescription =>
      'Pantalla principal con Calendario de entradas';

  @override
  String get insightsDescription => 'Tú y las estadísticas de tus notas';

  @override
  String get settingsDescription =>
      'Pantalla con toda la configuración (modo oscuro, sincronización, etc.)';

  @override
  String get todayDescription => 'Solo mentes de hoy';

  @override
  String get debugMenuDescription =>
      'Herramientas de desarrollador para activar funciones experimentales';

  @override
  String get noMindsForThisDay => 'No hay mentes para este día';

  @override
  String get week => 'Semana';

  @override
  String get password => 'Contraseña';

  @override
  String get archivePassword => 'Contraseña del archivo';

  @override
  String get enterPassword => 'Introducir contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get reenterPassword => 'Volver a introducir contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get exportPassword => '¿Proteger exportación con contraseña?';

  @override
  String get exportPasswordDescription =>
      'Agrega una contraseña para cifrar tu exportación. Puedes omitir esto para exportación sin cifrar.';

  @override
  String get importPassword => 'Introducir contraseña';

  @override
  String get importPasswordDescription =>
      'Este archivo está protegido con contraseña. Por favor introduce la contraseña para descifrar.';

  @override
  String get skipPassword => 'Omitir (sin contraseña)';

  @override
  String get continue_ => 'Continuar';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get incorrectPasswordMessage =>
      'La contraseña que introdujiste es incorrecta. Por favor intenta de nuevo.';

  @override
  String get corruptedFile => 'Archivo dañado';

  @override
  String get invalidFormat => 'Formato inválido';

  @override
  String get missingAudioFiles => 'Faltan algunos archivos de audio';

  @override
  String get insufficientStorage => 'Almacenamiento insuficiente';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get retry => 'Reintentar';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Exportación exitosa';

  @override
  String get exportError => 'Exportación fallida';

  @override
  String get importSuccess => 'Importación exitosa';

  @override
  String get importError => 'Importación fallida';

  @override
  String get mindsToExport => 'Mentes';

  @override
  String get audioFilesToExport => 'Archivos de audio';

  @override
  String get emotionsToExport => 'Emociones';

  @override
  String get mindsExported => 'Mentes exportadas';

  @override
  String get audioFilesExported => 'Archivos de audio exportados';

  @override
  String get mindsImported => 'Mentes importadas';

  @override
  String get audioFilesImported => 'Archivos de audio importados';

  @override
  String get onboardingMind1 => '¡Hola!';

  @override
  String get onboardingMind2 =>
      'Soy keklist - un diario personal de notas cortas';

  @override
  String get onboardingMind2Comment1 => 'Las notas se pueden comentar';

  @override
  String get onboardingMind2Comment2 => 'Para abrir una nota, tócala';

  @override
  String get onboardingMind3 =>
      'En la pestaña \'Calendario\', todas las notas se muestran por días, semanas y meses';

  @override
  String get onboardingMind4 =>
      'La pestaña \'Estadísticas\' muestra breves estadísticas de tus entradas';

  @override
  String get onboardingMind5 =>
      'Todas las notas se almacenan solo en tu teléfono';

  @override
  String get onboardingMind6 => 'Para crear una nueva nota, toca \'Escribir\'';

  @override
  String get noPhotosForDay => 'No se encontraron fotos para este día';

  @override
  String get sourcesMediaFolder => 'Archivos multimedia';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Fotos y videos de una carpeta personalizada';

  @override
  String get mediaFolderSettings => 'Archivos multimedia';

  @override
  String get licenses => 'Licencias';

  @override
  String get sourcesWeather => 'Clima';

  @override
  String get sourcesWeatherSubtitle =>
      'Condiciones meteorológicas locales para este día';

  @override
  String get weatherSettings => 'Configuración del clima';

  @override
  String get weatherLatitude => 'Latitud';

  @override
  String get weatherLongitude => 'Longitud';

  @override
  String get weatherSaveLocation => 'Guardar ubicación';

  @override
  String get weatherUseMyLocation => 'Usar mi ubicación';

  @override
  String get weatherDetectingLocation => 'Detectando ubicación...';

  @override
  String get weatherOrEnterManually => 'o ingresar manualmente';

  @override
  String get weatherLocationError =>
      'No se pudo detectar la ubicación. Por favor, ingrésela manualmente.';

  @override
  String get weatherLocationServicesDisabled =>
      'Los servicios de ubicación están desactivados. Actívalos en Ajustes.';

  @override
  String get weatherLocationPermissionDenied =>
      'Permiso de ubicación denegado.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Permiso de ubicación denegado permanentemente. Abriendo ajustes de la app.';

  @override
  String get audioRecordTitle => 'Grabar audio';

  @override
  String get audioRecordTitleRecording => 'Grabando…';

  @override
  String get audioRecordHint => 'Toca Detener para guardar en tu dispositivo.';

  @override
  String get audioRecordStart => 'Iniciar';

  @override
  String get audioRecordStop => 'Detener';

  @override
  String get audioRecordCancel => 'Cancelar';

  @override
  String get audioRecordPermissionError =>
      'Se necesita permiso de micrófono para grabar audio.';

  @override
  String get audioRecordStartError =>
      'No se pudo iniciar la grabación. Inténtalo de nuevo.';

  @override
  String get audioRecordStopError =>
      'No se pudo detener la grabación. Inténtalo de nuevo.';

  @override
  String proUserFooter(String price, String date) {
    return 'Eres usuario PRO. El próximo pago de $price será el $date.';
  }

  @override
  String get emotions => 'Emociones';

  @override
  String get archived => 'Archivadas';

  @override
  String get archive => 'Archivar';

  @override
  String get restore => 'Restaurar';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get newEmotion => 'Nueva emoción';

  @override
  String get editEmotion => 'Editar emoción';

  @override
  String get addEmotion => 'Añadir emoción';

  @override
  String get addEmotionsToMind => 'Añadir emociones';

  @override
  String get emotionNameHint => 'Nombre';

  @override
  String get doneEditing => 'Listo';

  @override
  String get emotionEditHint =>
      'Toca para renombrar · ✕ para quitar · arrastra para reordenar';

  @override
  String get emotionInUseMessage =>
      'Esta emoción se usa en algunas mentes. Archívala para conservarla ahí, o elimínala en todas partes.';

  @override
  String get noEmotionsYet => 'Aún no hay emociones';

  @override
  String get noArchivedEmotions => 'No hay emociones archivadas';

  @override
  String get deleteEmotionMessage =>
      '¿Eliminar esta emoción? Se quitará de todas las mentes que la usan.';

  @override
  String get dayFeedTileSettings => 'Ajustes de mosaicos';

  @override
  String get dayFeedColumns => 'Columnas';

  @override
  String get dayFeedMindTileSize => 'Tamaño del mosaico';

  @override
  String get dayFeedMindTileSquare => 'Cuadrado';

  @override
  String get dayFeedMindTileWide => 'Ancho';

  @override
  String get dayFeedShowMindText => 'Mostrar texto';

  @override
  String get dayFeedPhotoAccessHint =>
      'Permite el acceso a fotos para ver aquí tus fotos y vídeos';

  @override
  String get dayFeedAllowAccess => 'Permitir';

  @override
  String get dayFeedFolderHint =>
      'Elige una carpeta de medios para ver aquí tus fotos y vídeos';

  @override
  String get dayFeedChooseFolder => 'Elegir';

  @override
  String get dayFeedMute => 'Silenciar';

  @override
  String get dayFeedUnmute => 'Activar sonido';

  @override
  String get holdToRecordAudio =>
      'Mantén pulsado para grabar un mensaje de voz';

  @override
  String get holdToRecordVideo => 'Mantén pulsado para grabar un videomensaje';

  @override
  String get roundVideoRecordError => 'No se pudo grabar el vídeo';

  @override
  String get roundVideoCameraUnavailable =>
      'La cámara no está disponible en este dispositivo';

  @override
  String get roundVideoRetake => 'Repetir';

  @override
  String get roundVideoUse => 'Usar';

  @override
  String get removeMedia => 'Quitar multimedia';

  @override
  String get shakeToCustomize => 'Agita para personalizar';

  @override
  String get shakeToCustomizeHint => 'o mantén pulsado el título';

  @override
  String get customizeSettings => 'Personalizar ajustes';

  @override
  String get customizeSettingsDescription =>
      'Las secciones y filas desmarcadas se ocultan en Ajustes.';

  @override
  String get calendarSettings => 'Ajustes del calendario';

  @override
  String get calendarShowMedia => 'Mostrar fotos y vídeos';

  @override
  String get calendarWeekTitles => 'Títulos de semana';

  @override
  String get calendarPlayStories => 'Ver historias';

  @override
  String get storyBackgroundTweak => 'Fondo de historias';

  @override
  String get storyAnimationOff => 'Desactivado';

  @override
  String get storyAnimationPulse => 'Pulso';

  @override
  String get storyAnimationWave => 'Ola';

  @override
  String get storyAnimationEqualizer => 'Ecualizador';

  @override
  String get storyAnimationDrift => 'Deriva';

  @override
  String get storyAnimationGlow => 'Brillo';

  @override
  String get viewerCommentHint => 'Comentario…';

  @override
  String get calendarToCurrentWeek => 'A la semana actual';

  @override
  String get storyDateLines => 'Líneas de fecha';

  @override
  String get storyTextureTitle => 'Textura';

  @override
  String get storySpectrum => 'Espectro de sonido';

  @override
  String get storySensitivity => 'Sensibilidad';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Consciente $count días',
      one: 'Consciente $count día',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Nombre';

  @override
  String get profilePhoto => 'Foto';

  @override
  String get profileEmoji => 'Emoji';

  @override
  String get profileInitial => 'Letra';

  @override
  String get webVersion => 'Versión web';

  @override
  String get webVersionAddressHint =>
      'Ábrela en el navegador de un ordenador en la misma Wi‑Fi; mantén keklist abierto';

  @override
  String get webVersionCopied => 'Dirección copiada';

  @override
  String get webVersionNeedsPin =>
      'Define un PIN para abrir keklist en el navegador de un ordenador en la misma Wi‑Fi.';

  @override
  String get webVersionStarting => 'Iniciando…';

  @override
  String get webVersionNoWifi =>
      'Conéctate a una Wi‑Fi para abrir keklist en un navegador.';

  @override
  String get webVersionNoBundle => 'Esta versión no incluye la versión web.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => 'Cada navegador lo pide una vez cada 30 días';

  @override
  String get webVersionPinNotSet => 'Sin definir';

  @override
  String get webVersionPinHint => '4–8 dígitos';

  @override
  String get webVersionRemovePin => 'Eliminar PIN';

  @override
  String get webVersionPort => 'Puerto';

  @override
  String get aiTab => 'Chat';

  @override
  String get aiTabDescription =>
      'Habla de tus notas con una IA que funciona en tu teléfono';

  @override
  String get aiPrivacyNote =>
      'Solo funciona en tu teléfono: tus notas nunca salen del dispositivo.';

  @override
  String get aiDisclaimer =>
      'No es un servicio médico. Si estás en peligro, contacta con los servicios de emergencia.';

  @override
  String get aiYesterday => 'Ayer';

  @override
  String get aiSessions => 'Sesiones';

  @override
  String get aiNoSessions => 'Aún no hay sesiones';

  @override
  String get aiNewSession => 'Nueva sesión';

  @override
  String get aiChooseRole => 'Elige un rol';

  @override
  String get aiRoleTherapist => 'Terapeuta';

  @override
  String get aiRoleCoach => 'Coach';

  @override
  String get aiRoleFriend => 'Amigo';

  @override
  String get aiMessageHint => 'Mensaje';

  @override
  String get aiStarterWeek => '¿Cómo fue mi semana?';

  @override
  String get aiStarterWorry => '¿Qué me ha preocupado últimamente?';

  @override
  String get aiStarterJoy => '¿Qué me ha alegrado últimamente?';

  @override
  String get aiActionSaveAsMind => 'Guardar como nota';

  @override
  String get aiActionOpenDay => 'Abrir día';

  @override
  String get aiActionWeekSummary => 'Resumen de la semana';

  @override
  String get aiWeekSummaryPrompt =>
      'Resume mis últimos 7 días: qué pasó, cómo me sentí, qué destacó.';

  @override
  String get aiSavedAsMind => 'Guardado en hoy';

  @override
  String get aiStop => 'Detener';

  @override
  String get aiNoModelTitle => 'Elige un modelo';

  @override
  String get aiNoModelMessage =>
      'Descarga un modelo para empezar. Funciona en tu teléfono, sin conexión.';

  @override
  String get aiNoModelOnPhone =>
      'Descarga un modelo en la app del teléfono: Ajustes → IA → Modelos.';

  @override
  String get aiModels => 'Modelos';

  @override
  String get aiRoles => 'Roles';

  @override
  String get aiDownloaded => 'Descargados';

  @override
  String get aiDownloads => 'Descargando';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'Buscar modelos GGUF';

  @override
  String get aiDownload => 'Descargar';

  @override
  String get aiPause => 'Pausar';

  @override
  String get aiPaused => 'En pausa';

  @override
  String get aiResume => 'Reanudar';

  @override
  String get aiDownloadFailed => 'Error en la descarga';

  @override
  String get aiCellularTitle => '¿Descargar con datos móviles?';

  @override
  String aiCellularMessage(String size) {
    return 'Se descargarán $size con datos móviles.';
  }

  @override
  String get aiDeleteModel => '¿Eliminar el modelo?';

  @override
  String aiStorageUsed(String size) {
    return 'En este teléfono: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Memoria del teléfono: $size';
  }

  @override
  String get aiCatalogFailed =>
      'No se pudo cargar la lista. Revisa la conexión.';

  @override
  String get aiNoFilesFit =>
      'Ningún archivo de este modelo cabe en la memoria del teléfono.';

  @override
  String get aiBuiltInRole => 'Integrados';

  @override
  String get aiOwnRoles => 'Tus roles';

  @override
  String get aiDuplicate => 'Duplicar';

  @override
  String get aiNewRole => 'Nuevo rol';

  @override
  String get aiRoleName => 'Nombre';

  @override
  String get aiRoleEmoji => 'Emoji';

  @override
  String get aiRolePrompt => 'Prompt';

  @override
  String get aiRolePromptHint => 'Cómo debe hablar la IA y en qué centrarse';

  @override
  String get aiReadOnlyRole =>
      'Los roles integrados no se pueden cambiar. Duplica uno para crear el tuyo.';

  @override
  String get aiDeleteSession => '¿Eliminar la sesión?';

  @override
  String get aiDeleteRole => '¿Eliminar el rol?';

  @override
  String get aiRecommended => 'Recomendado';

  @override
  String get aiLowQuality => 'Baja calidad';

  @override
  String get aiModelDoesNotFit =>
      'Este modelo no cabe en la memoria del teléfono. Elige uno más pequeño.';

  @override
  String get aiChooseAnotherModel => 'Elegir otro modelo';

  @override
  String get creatorEmotionsTitle => 'Emociones';

  @override
  String get creatorEmotionsAfterSave => 'Preguntar al guardar';

  @override
  String get creatorEmotionsButton => 'Botón sobre el teclado';

  @override
  String get creatorEmotionsNever => 'No preguntar';

  @override
  String get insightsWeekAgo => 'Hace una semana';

  @override
  String get insightsMonthAgo => 'Hace un mes';

  @override
  String get insightsHalfYearAgo => 'Hace medio año';

  @override
  String get insightsYearAgo => 'Hace un año';

  @override
  String get insightsTwoYearsAgo => 'Hace dos años';

  @override
  String get insightsVoiceAndVideos => 'Voz y videos redondos';

  @override
  String insightsWeekNumber(String number) {
    return 'Semana $number';
  }
}
