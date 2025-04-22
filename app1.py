from flask_cors import CORS
from flask import Flask, request, jsonify
from ultralytics import YOLO
from gtts import gTTS
import pygame
import cv2 as cv
import time
from io import BytesIO
import base64
import numpy as np  # np.frombuffer için gerekli

app = Flask(__name__)
CORS(app)
# YOLO modelini yükle
model_path = r"best.pt"
model = YOLO(model_path)


# Türkçe etiketler
turkce_etiketler = {
    "5TL": "Beş Türk Lirası",
    "10TL": "On Türk Lirası",
    "20TL": "Yirmi Türk Lirası",
    "50TL": "Elli Türk Lirası",
    "100TL": "Yüz Türk Lirası",
    "200TL": "İki Yüz Türk Lirası"
}

# Doğruluk oranı eşiği
guven_esigi = 0.76  # %76 doğruluk sınırı

# Seslendirme fonksiyonu


def seslendir(metin):
    print(f"Seslendirilecek metin: {metin}")
    try:
        tts = gTTS(text=metin, lang='tr')
        ses_bellek = BytesIO()
        tts.write_to_fp(ses_bellek)
        ses_bellek.seek(0)
        ses_veri = ses_bellek.read()
        print(f"Ses verisi oluşturuldu: {len(ses_veri)} bytes")
        base64_veri = base64.b64encode(ses_veri).decode('utf-8')
        return base64_veri
    except Exception as e:
        print(f"Seslendirme hatası: {str(e)}")
        return ""


@app.route('/detect', methods=['POST'])
def detect_objects():
    print("İstek alındı - Endpoint: /detect")
    
    # 'file' veya 'image' adıyla gelen dosyayı kabul et
    file = request.files.get('file') or request.files.get('image')
    
    if not file:
        print("HATA: 'file' veya 'image' anahtarı bulunamadı")
        print("Mevcut dosyalar:", request.files)
        return jsonify({"error": "No file or image provided"}), 400

    print(f"Dosya alındı: {file.filename}, boyut: {file.content_length}")
    
    try:
        image = cv.imdecode(np.frombuffer(file.read(), np.uint8), cv.IMREAD_COLOR)
        if image is None:
            print("HATA: Görüntü okunamadı veya boş")
            return jsonify({"error": "Invalid image data"}), 400

        print(f"Görüntü başarıyla yüklendi, boyut: {image.shape}")

        # Model çalıştırma
        print("Model yürütülüyor...")
        results = model(image)
        print(f"Model sonuçları alındı: {len(results)} sonuç")

        detections = []
        for result in results[0].boxes.data.tolist():
            x1, y1, x2, y2, confidence, class_id = result
            if confidence >= guven_esigi:
                label = model.names[int(class_id)]
                türkçe_etiket = turkce_etiketler.get(label, label)
                print(f"Tespit edildi: {label}, güven: {confidence:.2f}")
                detections.append({
                    "label": label,
                    "türkçe_etiket": türkçe_etiket,
                    "confidence": float(confidence),
                    # Seslendirme verisini base64 olarak ekle
                    "audio": seslendir(türkçe_etiket)
                })

        print(f"İşlem tamamlandı, {len(detections)} nesne tespit edildi")
        return jsonify(detections)

    except Exception as e:
        print(f"HATA: İşlem sırasında bir istisna oluştu: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": f"Processing error: {str(e)}"}), 500
    


# Uygulama başlatma kısmına IP gösterme ekleyin
if __name__ == '__main__':
    import socket
    hostname = socket.gethostname()
    try:
        # Yerel IP adresini al
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
    except:
        local_ip = "127.0.0.1"

    print(f"\n============================================")
    print(f"API şu adreste çalışıyor: http://{local_ip}:5000")
    print(f"Bu IP adresini Flutter uygulamanızda kullanın!")
    print(f"============================================\n")

    app.run(host='0.0.0.0', debug=True)
