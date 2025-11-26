import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/dropfoff_location/dropoff_location.dart';
import '../screens/waste_category_guideline/waste_category_guide.dart';
import 'detection_controller.dart';

class ScanSortCameraController extends GetxController with WidgetsBindingObserver {
  // Camera state
  final _availableCameras = <CameraDescription>[].obs;
  final _cameraController = Rxn<CameraController>();
  final _isInitialized = false.obs;
  final _isCapturing = false.obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final _flashMode = FlashMode.off.obs;
  final _errorMessage = ''.obs;

  // Zoom state
  final _currentZoom = 1.0.obs;
  final _minZoom = 1.0.obs;
  final _maxZoom = 8.0.obs;
  final _baseScale = 1.0.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // 新增：跟踪是否正在选择图片
  final _isPickingImage = false.obs;

  // Getters
  List<CameraDescription> get cameras => _availableCameras;
  CameraController? get controller => _cameraController.value;
  bool get isInitialized => _isInitialized.value;
  bool get isCapturing => _isCapturing.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  FlashMode get flashMode => _flashMode.value;
  String get errorMessage => _errorMessage.value;
  double get currentZoom => _currentZoom.value;
  double get minZoom => _minZoom.value;
  double get maxZoom => _maxZoom.value;
  bool get isPickingImage => _isPickingImage.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当正在选择图片时，完全忽略生命周期变化
    if (_isPickingImage.value) {
      return;
    }

    // 只在应用完全暂停时才释放相机
    if (state == AppLifecycleState.paused) {
      _disposeController();
    }
  }

  // 页面进入时初始化相机
  void initializeCameraForPage() {
    if (!_isInitialized.value && !_isLoading.value) {
      _initializeCamera();
    }
  }

  // 页面离开时释放相机
  void disposeCameraForPage() {
    _disposeController();
  }

  void _disposeController() {
    _cameraController.value?.dispose();
    _cameraController.value = null;
    _isInitialized.value = false;
  }

  Future<bool> _checkPermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (!cameraStatus.isGranted) {
        _errorMessage.value = 'Camera permission is required to use this feature';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage.value = 'Permission check failed: $e';
      return false;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _hasError.value = true;
        _isLoading.value = false;
        return;
      }

      try {
        _availableCameras.value = await availableCameras();
      } catch (e) {
        _hasError.value = true;
        _errorMessage.value = 'Failed to access camera: $e';
        _isLoading.value = false;
        return;
      }

      if (_availableCameras.isEmpty) {
        _hasError.value = true;
        _errorMessage.value = 'No cameras available on this device';
        _isLoading.value = false;
        return;
      }

      CameraDescription selectedCamera;
      try {
        selectedCamera = _availableCameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
        );
      } catch (e) {
        selectedCamera = _availableCameras.first;
      }

      _disposeController();

      _cameraController.value = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.value!.initialize();

      // Get zoom limits
      _minZoom.value = await _cameraController.value!.getMinZoomLevel();
      _maxZoom.value = await _cameraController.value!.getMaxZoomLevel();
      _currentZoom.value = _minZoom.value;

      await _setFlashMode(_flashMode.value);

      _isInitialized.value = true;
      _isLoading.value = false;
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to initialize camera: $e';
      _isLoading.value = false;
    }
  }

  Future<void> _setFlashMode(FlashMode mode) async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    try {
      await currentController.setFlashMode(mode);
      _flashMode.value = mode;
    } on CameraException catch (e) {
      print('Failed to set flash mode: ${e.description}');
    }
  }

  void _handleCameraError(CameraException e) {
    String errorMessage;
    switch (e.code) {
      case 'CameraAccessDenied':
        errorMessage = 'Camera access was denied. Please grant camera permission.';
        break;
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        errorMessage = 'Camera access is restricted on this device.';
        break;
      default:
        errorMessage = 'Camera error: ${e.description ?? e.code}';
        break;
    }

    _hasError.value = true;
    _errorMessage.value = errorMessage;
    _isLoading.value = false;
  }

  // Capture photo
  Future<File?> capturePhoto() async {
    final currentController = _cameraController.value;
    if (currentController == null ||
        !currentController.value.isInitialized ||
        _isCapturing.value) {
      print('❌ Cannot capture: controller=$currentController, initialized=${currentController?.value.isInitialized}, capturing=${_isCapturing.value}');
      return null;
    }

    try {
      print('📸 Starting photo capture...');
      _isCapturing.value = true;

      final XFile image = await currentController.takePicture();
      print('✅ Photo captured: ${image.path}');

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/scan_$timestamp.jpg';
      final imageFile = File(image.path);
      final savedFile = await imageFile.copy(imagePath);

      print('✅ Photo saved: $imagePath');
      _isCapturing.value = false;

      return savedFile;
    } on CameraException catch (e) {
      print('❌ Camera exception: ${e.description ?? e.code}');
      _isCapturing.value = false;
      Get.snackbar(
        'Error',
        'Failed to capture photo: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      print('❌ Capture error: $e');
      _isCapturing.value = false;
      Get.snackbar(
        'Error',
        'Failed to capture photo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      print('🖼️ Opening gallery picker...');
      _isPickingImage.value = true;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      _isPickingImage.value = false;

      if (image != null) {
        print('✅ Gallery image selected: ${image.path}');
        return File(image.path);
      }

      print('⚠️ Gallery picker cancelled');
      return null;
    } catch (e) {
      print('❌ Gallery picker error: $e');
      _isPickingImage.value = false;

      if (e.toString().contains('cancel') || e.toString().contains('permission')) {
        return null;
      }

      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Process captured image for detection
  Future<void> processCapturedImage(File imageFile) async {
    try {
      print('🔍 Starting image processing: ${imageFile.path}');
      print('📂 File exists: ${await imageFile.exists()}');
      print('📏 File size: ${await imageFile.length()} bytes');

      // Get or initialize detection controller
      DetectionController detectionController;
      if (Get.isRegistered<DetectionController>()) {
        print('✅ Using existing DetectionController');
        detectionController = Get.find<DetectionController>();
      } else {
        print('⚠️ Creating new DetectionController');
        detectionController = Get.put(DetectionController());

        // Wait for initialization
        if (detectionController.isInitializing.value) {
          print('⏳ Waiting for model initialization...');
          Get.snackbar(
            'Please Wait',
            'Model is initializing...',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );

          // Wait for initialization to complete
          int attempts = 0;
          while (detectionController.isInitializing.value && attempts < 30) {
            await Future.delayed(const Duration(milliseconds: 500));
            attempts++;
          }

          if (detectionController.isInitializing.value) {
            print('❌ Model initialization timeout');
            Get.snackbar(
              'Error',
              'Model initialization timeout. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }
      }

      print('🚀 Running detection...');
      // Run detection and show results
      await detectionController.detectAndShowResults(imageFile);
      print('✅ Detection complete');

    } catch (e, stackTrace) {
      print('❌ Failed to process image: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to process image: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Toggle flash
  Future<void> toggleFlash() async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    FlashMode newMode = _flashMode.value == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;

    await _setFlashMode(newMode);
  }

  // Zoom controls
  void onScaleStart(ScaleStartDetails details) {
    _baseScale.value = _currentZoom.value;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    double scale = (_baseScale.value * details.scale).clamp(_minZoom.value, _maxZoom.value);
    _setZoomLevel(scale);
  }

  Future<void> _setZoomLevel(double zoom) async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    try {
      await currentController.setZoomLevel(zoom);
      _currentZoom.value = zoom;
    } catch (e) {
      print('Failed to set zoom level: $e');
    }
  }

  Future<void> zoomIn() async {
    double newZoom = (_currentZoom.value + 0.5).clamp(_minZoom.value, _maxZoom.value);
    await _setZoomLevel(newZoom);
  }

  Future<void> zoomOut() async {
    double newZoom = (_currentZoom.value - 0.5).clamp(_minZoom.value, _maxZoom.value);
    await _setZoomLevel(newZoom);
  }

  Future<void> retryInitialize() async {
    await _initializeCamera();
  }

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot open settings: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool get isFlashOn => _flashMode.value == FlashMode.torch;

  String get zoomText => '${_currentZoom.value.toStringAsFixed(1)}x';

  // Navigation functions
  void navigateToDropOff() {
    disposeCameraForPage();
    Get.to(() => DropoffLocationsScreen())?.then((_) {
      if (!_isInitialized.value && !_isLoading.value) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _initializeCamera();
        });
      }
    });
  }

  void navigateToCategories() {
    disposeCameraForPage();
    Get.to(() => WasteCategoryGuideScreen())?.then((_) {
      if (!_isInitialized.value && !_isLoading.value) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _initializeCamera();
        });
      }
    });
  }
}