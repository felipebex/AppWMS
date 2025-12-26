import 'dart:async';
import 'dart:io'; // Para exit(0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para SystemNavigator
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onSessionExpired;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    required this.onSessionExpired,
    this.duration = const Duration(minutes: 5), // Configurar tiempo aquí
  });

  @override
  State<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager> with WidgetsBindingObserver {

  
  Timer? _timer;
  DateTime? _lastTimePaused;
  bool _isChecking = false; 
  String _loadingMessage = "Validando sesión..."; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Intentamos iniciar el timer (él mismo validará si hay sesión)
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ------------------------------------------------------------------------
  // CICLO DE VIDA (SEGUNDO PLANO)
  // ------------------------------------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Solo guardamos la hora de pausa si NO la hemos guardado ya
      if (_lastTimePaused == null) {
        _lastTimePaused = DateTime.now();
        _timer?.cancel();
      }
    } 
    else if (state == AppLifecycleState.resumed) {
      _handleResume();
    }
  }

  /// Maneja el regreso de la app a primer plano
  Future<void> _handleResume() async {
    // 1. Si no está logueado, no hacemos nada
    bool isLoggedIn = await PrefUtils.getIsLoggedIn();
    if (!isLoggedIn) {
      _lastTimePaused = null;
      return; 
    }

    // 2. Mostramos "Validando..." inmediatamente
    if (mounted) {
      setState(() {
        _loadingMessage = "Validando inactividad...";
        _isChecking = true;
      });
    }

    // 3. Pequeño delay para evitar parpadeos visuales
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkTimeInBackground();
    });
  }

  /// Verifica si el tiempo que estuvo minimizada excedió el límite
  Future<void> _checkTimeInBackground() async {
    // Doble validación de sesión
    bool isLoggedIn = await PrefUtils.getIsLoggedIn();
    if (!isLoggedIn) {
      if (mounted) setState(() => _isChecking = false);
      return;
    }

    if (_lastTimePaused != null) {
      final timeNow = DateTime.now();
      final difference = timeNow.difference(_lastTimePaused!);

      if (difference >= widget.duration) {
        // --- CASO: EXPIRADO EN SEGUNDO PLANO ---
        await _performLogoutAndExit("Cerrando aplicación por seguridad...");
      } else {
        // --- CASO: NO EXPIRÓ ---
        _lastTimePaused = null; 
        _startTimer(); 
        if (mounted) setState(() => _isChecking = false);
      }
    } else {
      // Reinicio rápido
      _startTimer();
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // ------------------------------------------------------------------------
  // TIMER DE PANTALLA (FOREGROUND)
  // ------------------------------------------------------------------------
  void _startTimer() async {
    _timer?.cancel();
    
    // Si no hay sesión, no iniciamos nada.
    if (!await PrefUtils.getIsLoggedIn()) return; 

    _timer = Timer(widget.duration, () async {
      // Al terminar el tiempo, validamos de nuevo por seguridad
      if (!await PrefUtils.getIsLoggedIn()) return;
      
      // --- CASO: EXPIRADO EN PANTALLA ---
      await _performLogoutAndExit("Cerrando aplicación por inactividad...");
    });
  }

  void _resetTimer() {
    if (!_isChecking) {
      _checkLoginAndSave(); // Guarda la hora para casos de muerte súbita
      _startTimer(); 
    }
  }

  /// Guarda la hora actual en disco solo si hay sesión
  Future<void> _checkLoginAndSave() async {
    if (await PrefUtils.getIsLoggedIn()) {
      PrefUtils.saveLastActiveTime();
    }
  }

  // ------------------------------------------------------------------------
  // LÓGICA DE CIERRE Y LIMPIEZA
  // ------------------------------------------------------------------------
  
  /// Ejecuta el proceso de cierre visual y lógico
  Future<void> _performLogoutAndExit(String message) async {
    if (mounted) {
      setState(() {
        _loadingMessage = message;
        _isChecking = true; // Asegura que el diálogo se muestre
      });
    }

    // Ejecutamos tareas en paralelo para optimizar tiempo
    await Future.wait([
        PrefUtils.clearSession(), // Borra datos de usuario
        _clearMemoryCache(),      // Borra imágenes de RAM
        Future.delayed(const Duration(seconds: 2)), // Tiempo de lectura UX
    ]);

    _lastTimePaused = null;
    
    // Procedemos a matar la app
    _closeApp();
  }

  /// 🧹 Limpieza profunda de recursos visuales
  Future<void> _clearMemoryCache() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint("Error limpiando memoria: $e");
    }
  }

  /// 💀 Cierre "Nuclear" para liberar RAM del dispositivo
  void _closeApp() {
    if (Platform.isAndroid) {
      try {
        // Cierre visual suave
        SystemNavigator.pop(animated: true);
        
        // ⚠️ Forzar liberación de RAM matando el proceso después de la animación
        Future.delayed(const Duration(milliseconds: 200), () {
          exit(0); 
        });
      } catch (e) {
        exit(0);
      }
    } else {
      // iOS no permite cierre programático elegante, usamos exit(0)
      exit(0); 
    }
  }

  // ------------------------------------------------------------------------
  // UI BUILD
  // ------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. DETECTOR DE TOQUES
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _resetTimer(),
          onPointerMove: (_) => _resetTimer(),
          onPointerUp: (_) => _resetTimer(),
          child: widget.child,
        ),

        // 2. OVERLAY DE CARGA / CIERRE
        if (_isChecking)
          Positioned.fill(
            child: DialogLoading(
              message: _loadingMessage,
            ),
          ),
      ],
    );
  }
}