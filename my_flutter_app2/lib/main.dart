import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // Önce mevcut kameraları al
  final cameras = await availableCameras();
  
  // Uygulama başlangıcında kameraları geçir
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 145, 95, 148),
      )),
      home: ObjectDetectionApp(cameras: cameras),
    );
  }
}

class ObjectDetectionApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const ObjectDetectionApp({Key? key, required this.cameras}) : super(key: key);

  @override
  _ObjectDetectionAppState createState() => _ObjectDetectionAppState();
}

class _ObjectDetectionAppState extends State<ObjectDetectionApp> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  List<dynamic> _detections = [];
  bool _isCameraInitialized = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Kamerayı uygulama başlar başlamaz başlat
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Arka kamerayı kullan (varsa)
    final CameraDescription cameraDescription = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => widget.cameras.first,
    );
    
    // Kamera kontrolcüsünü başlat
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium, // Performans ve kalite dengesi
      enableAudio: false, // Sadece görüntü için
    );

    try {
      // Kamerayı başlat
      await _cameraController.initialize();
      
      // Otomatik odaklama ve pozlama ayarla
      if (_cameraController.value.isInitialized) {
        await _cameraController.setFocusMode(FocusMode.auto);
        await _cameraController.setExposureMode(ExposureMode.auto);
      }
      
      // State'i güncelle
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        
        // Algılama işlemini başlat
        _startDetection();
      }
    } catch (e) {
      print("Kamera başlatma hatası: $e");
    }
  }

  void _startDetection() {
    if (!_isDetecting) {
      _isDetecting = true;
      // Hemen algılamaya başla
      _captureAndDetect();
    }
  }

  Future<void> _captureAndDetect() async {
    if (!_isDetecting || !_cameraController.value.isInitialized) {
      return;
    }
    
    try {
      // Kameradan fotoğraf çek
      final XFile imageFile = await _cameraController.takePicture();
      
      // Sunucuya gönder
      await _sendToServer(File(imageFile.path));
    } catch (e) {
      print("Fotoğraf çekme veya işleme hatası: $e");
    }
    
    // İşlem devam ediyorsa, 1 saniye sonra tekrar al
    if (_isDetecting) {
      Future.delayed(Duration(milliseconds: 500), _captureAndDetect);
    }
  }

  Future<void> _sendToServer(File image) async {
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('http://127.0.0.1:5000/detect')
    );
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    
    try {
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        
        if (mounted) {
          setState(() {
            _detections = jsonResponse['detections'];
          });
        }
        
        // Ses çal
        if (jsonResponse.containsKey('audio') && jsonResponse['audio'] != null) {
          _playAudio(jsonResponse['audio']);
        }
      } else {
        print("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("Sunucu iletişim hatası: $e");
    }
  }

  void _playAudio(String base64Audio) async {
    if (base64Audio.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(base64Audio);
        await _audioPlayer.play(BytesSource(bytes));
      } catch (e) {
        print("Ses çalma hatası: $e");
      }
    }
  }

  @override
  void dispose() {
    // Kaynakları temizle
    _isDetecting = false;
    _cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerçek Zamanlı Para Algılama'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Kamera önizleme alanı
          Expanded(
            flex: 3,
            child: _isCameraInitialized
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    margin: EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CameraPreview(_cameraController),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          
          // Algılama sonuçları
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _detections.isEmpty
                  ? Center(
                      child: Text(
                        "Para algılanmadı",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _detections.length,
                      padding: EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final detection = _detections[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.monetization_on, color: Colors.blue),
                            title: Text(
                              "${detection['label']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "%${(detection['confidence'] * 100).toStringAsFixed(1)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}