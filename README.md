Bu projede, görme engelli bireylerin günlük yaşamlarında karşılaştıkları parasal işlemlerde bağımsız hareket edebilmelerini sağlamak amacıyla "Para Ayırt Etme Uygulaması" geliştirilmiştir. Uygulama; mobil cihazlar aracılığıyla kağıt para birimlerinin otomatik olarak tanınması, etiketlenmesi ve sesli olarak bildirilmesi işlevlerini yerine getirmektedir.

Projeye ilk olarak veri seti oluşturma süreci ile başlanmıştır. TL-USD-EURO gibi farklı birimlerin baknotları farklı açılardan ve ışık koşullarında görüntülenmiş, ardından Roboflow platformu kullanılarak bu görüntüler detaylı şekilde etiketlenmiştir. Veriler, YOLOv8 mimarisi için uygun formatta dışa aktarılmıştır.

YOLOv8 modeli, oluşturulan veri setiyle eğitilmiş ve yüksek doğruluk oranına sahip bir para tanıma modeli elde edilmiştir. Eğitim sürecinde modelin loss değerleri, doğruluk oranı ve sınıflandırma başarımı sürekli izlenmiş ve optimize edilmiştir. 
 <img width="1400" height="600" alt="4" src="https://github.com/user-attachments/assets/f4273050-8076-40b5-88b6-8c2b741cc199" />
      
Şekil 1. eğitim doğruluk grafiği
Elde edilen modelin mobil uygulamayla iletişim kurabilmesi için Flask tabanlı bir web sunucu API’si geliştirilmiştir. Bu sunucu, Flutter uygulamasından gelen görüntüleri YOLOv8 modeliyle analiz eder ve tespit edilen para birimini hem metin hem de sesli çıktı olarak kullanıcıya geri döner. Sesli çıktı, gTTS (Google Text-to-Speech) kütüphanesi ile oluşturulmuş ve ses verisi base64 formatında mobil cihaza aktarılmıştır.

Elde edilen modelin mobil uygulamayla iletişim kurabilmesi için Flask tabanlı bir web sunucu API’si geliştirilmiştir. Bu sunucu, Flutter uygulamasından gelen görüntüleri YOLOv8 modeliyle analiz eder ve tespit edilen para birimini hem metin hem de sesli çıktı olarak kullanıcıya geri döner. Sesli çıktı, gTTS (Google Text-to-Speech) kütüphanesi ile oluşturulmuş ve ses verisi base64 formatında mobil cihaza aktarılmıştır. Uygulamada, kullanıcının tercihlerine göre Türkçe veya İngilizce olmak üzere iki farklı dilde sesli bildirim seçeneği sunulmaktadır. Bu özellik sayesinde uygulama, farklı dilde kullanıcılar tarafından da erişilebilir hale getirilmiş ve kapsayıcılığı artırılmıştır.
<img width="560" height="245" alt="3" src="https://github.com/user-attachments/assets/0ede2cd1-c7d9-46c0-ab9b-ae196f6a7862" />

   Şekil 2. Uygulama Akış Şeması

       
Uygulamadan örnek görüntüler:

![2](https://github.com/user-attachments/assets/ca554c4e-cb38-4812-b2ba-2c57477a8b11)
<img width="436" height="814" alt="1" src="https://github.com/user-attachments/assets/0aaedeeb-dc34-4639-a3b4-2e0d48aac934" />

Uygulamanın genel mimarisi; kamera, HTTP veri alışverişi, ses sentezi ve ses oynatma gibi farklı teknolojilerin uyum içinde çalıştığı, entegre ve erişilebilir bir sistemdir. Uygulama, herhangi bir manuel giriş gerektirmeden çalışarak özellikle görme engelli bireyler için erişilebilirliği ön plana çıkarmaktadır. 
 
Uygulama, gerçek zamanlı olarak kamera görüntülerini işleyerek para birimlerini tanımlar. Aynı para tekrar tekrar algılanıp sesli olarak tekrar edilmesin diye, sistem geçici olarak tanımayı durdurur ve sesli geri bildirim tamamlandığında yeniden aktif hale gelir. Bu özellik, kullanıcıyı rahatsız edecek tekrarların önüne geçerek daha kontrollü ve verimli bir deneyim sunar. Ayrıca sesli bildirim tamamlandığında kullanıcıya tanımanın durdurulduğu bilgisi ekranda görsel olarak da iletilir.

KAYNAK ARAŞTIRMASI
Projenin geliştirme sürecine başlamadan önce, kullanılacak tüm teknolojiler hakkında kapsamlı bir literatür ve sektör araştırması gerçekleştirilmiştir. Araştırmaların temel amacı, projenin hem teknik olarak sürdürülebilir hem de kullanıcı açısından erişilebilir bir yapıya kavuşmasını sağlamaktır.

1. Görme Engelliler İçin Dijital Destek Sistemleri
Öncelikli olarak, görme engellilere yönelik geliştirilen mevcut dijital uygulamalar incelenmiştir. Microsoft tarafından geliştirilen Seeing AI uygulaması, kamera ile çevreyi tanıyıp sesli olarak anlatabilen öncü çözümlerden biri olarak detaylıca analiz edilmiştir. Ayrıca Türkiye'deki akademik yayınlar ve konferans bildirileri taranarak, görme engellilerin dijitalleşen dünyada karşılaştıkları temel zorluklar tespit edilmiştir.
Kaynaklar:
•	Microsoft. Seeing AI: Talking camera app for the blind community, 2024.
•	Akın, A. & Koca, M. (2020). Görme engelliler için mobil tabanlı günlük yaşam destek uygulamaları, Engelsiz Bilişim Konferansı.
•	Yılmaz, F. & Aydın, I. (2019). Görüntü işleme ile Türk Lirası banknot tanıma sistemi, ELECO.

2. YOLOv8 ile Nesne Tanıma
Para tanıma işlemi için hızlı ve doğru çalışan bir algoritma gereklidir. Bu bağlamda YOLO (You Only Look Once) ailesinin en güncel sürümü olan YOLOv8, yapılan karşılaştırmalı çalışmalar sonucunda tercih edilmiştir. YOLOv8’in yüksek doğruluk oranı, düşük gecikme süresi ve Python entegrasyonu sayesinde mobil sistemlerle hızlıca entegre olabilme avantajı öne çıkmıştır.
Kaynaklar:
•	Jocher, G. et al. (2023). YOLOv8: Ultralytics Object Detection Framework, GitHub.
•	Çetin, A. & Yıldız, T. (2021). Derin öğrenme tabanlı nesne tanıma uygulamaları: YOLO mimarisi üzerine bir inceleme, Yapay Zeka ve Veri Bilimi Dergisi.

3. Veri Etiketleme ve Model Eğitimi – Roboflow
Veri etiketleme ve model eğitimi aşamalarında Roboflow platformu kullanılmıştır. Roboflow’un kullanıcı dostu etiketleme arayüzü, görüntü arttırma (augmentation) seçenekleri ve doğrudan YOLOv8 formatına veri aktarabilme yetenekleri, proje geliştirme sürecini hızlandırmıştır.
Kaynak:
•	Roboflow Documentation (2025), https://roboflow.com


4. Sesli Bildirim için gTTS (Google Text-to-Speech)
Görme engelli bireylerin bilgilendirilmesi için sesli geri bildirimin kaliteli ve gecikmesiz olması hayati önem taşımaktadır. Bu nedenle Google tarafından geliştirilen gTTS (Google Text-to-Speech) kütüphanesi kullanılmıştır. Bulut tabanlı çalışan bu servis, Türkçe ve İngilizce başta olmak üzere birçok dili desteklemesi, net ses kalitesi ve kolay entegrasyonu ile tercih sebebi olmuştur.
Kaynak:
•	gTTS Python Library Documentation, https://pypi.org/project/gTTS/
________________________________________
5. API Sunucusu – Flask Framework
Modelin uzaktan çalıştırılması için Python tabanlı Flask framework’ü kullanılmıştır. Flask, hafif yapısı sayesinde mobil istemcilerden gelen veri taleplerine hızlı yanıt verebilmekte ve API geliştirme açısından büyük esneklik sunmaktadır. Ayrıca Flask-CORS desteği sayesinde Flutter uygulamasıyla sorunsuz veri alışverişi sağlanmıştır.
Kaynak:
•	Flask Documentation (2025), https://flask.palletsprojects.com
________________________________________
6. Mobil Arayüz Geliştirme – Flutter
Mobil uygulamanın geliştirilmesinde Flutter framework tercih edilmiştir. Flutter, hem Android hem de iOS platformları için tek kod tabanı ile uygulama geliştirmeye olanak tanımakta, yüksek performansı ve kamera, HTTP, ses gibi modül destekleri ile uygulama ihtiyaçlarını eksiksiz karşılamaktadır. Ayrıca açık kaynak yapısı ve geniş geliştirici topluluğu sayesinde gelişime açıktır.
Kaynak:
•	Flutter Documentation (2025), https://flutter.dev
•	Sarı, M. (2022). Mobil uygulama geliştirmede Flutter framework’ünün performans analizi, Bilgisayar Bilimleri ve Teknolojileri Dergisi.
________________________________________
7. Ek Teknik Kaynaklar ve Forumlar
Geliştirme süreci boyunca karşılaşılan teknik problemler için StackOverflow ve GitHub toplulukları etkin olarak kullanılmış, YOLOv8 ve Flutter-Flask entegrasyonlarına dair örnekler incelenmiştir.
Kaynak:
•	StackOverflow, YOLOv8 ve Flutter/Flask entegrasyon konuları.
•	GitHub – Ultralytics ve Flutter örnek projeleri.


MATERYAL VE METOT
1. Kullanılan Yazılım Araçları ve Kütüphaneler
Projenin gerçekleştirilmesi için aşağıdaki yazılım teknolojileri ve kütüphaneler entegre olarak kullanılmıştır:
•	YOLOv8 (Ultralytics):
Para tanıma işlemi için nesne tanıma modeli olarak kullanılmıştır. Roboflow üzerinden oluşturulan veri setiyle eğitilmiştir.
🔧 Kullanım: model = YOLO('best.pt')
•	Roboflow:
Görsellerin etiketlenmesi, eğitim için augment edilmesi ve YOLOv8 uyumlu veri setine dönüştürülmesi amacıyla kullanılmıştır.
•	Flask:
Modelin uzaktan çağrılabilmesi için RESTful API sunucusu olarak görev yapmıştır. Flutter uygulamasından gelen görüntüleri işleyerek tahminleri mobil tarafa geri döndürür.
•	gTTS (Google Text-to-Speech):
Para değeri tespit edildikten sonra, sesli geri bildirim oluşturmak için kullanılmıştır. BytesIO ile ses verisi base64 formatında cihazlara iletilmiştir.
•	Flutter:
Mobil kullanıcı arayüzü geliştirme framework’üdür. Android cihazlarda çalışan uygulama; kamera, HTTP, ses gibi modülleri desteklemektedir.
•	Flutter Paketleri:
o	camera: Arka kameradan canlı görüntü alımı.
o	http: Flask API’ye görüntü gönderimi.
o	audioplayers: Base64 ile dönen sesin oynatılması.
o	path_provider: Ses verisinin cihazda geçici olarak saklanması.



2. Uygulamanın İşleyiş Adımları
Aşağıda, mobil cihazdan başlayarak para tanımanın sesli bildirime kadar olan süreci adım adım açıklanmaktadır:
1.	Kamera Başlatma:
Kullanıcı uygulamayı açtığında arka kamera otomatik olarak başlatılır.
2.	Görüntü Yakalama:
Belirli aralıklarla (örneğin her 2 saniyede bir), kameradan kare alınır ve geçici belleğe aktarılır.
3.	Görüntünün API’ye Gönderilmesi:
Alınan kare, HTTP POST isteği ile Flask sunucusuna gönderilir. Sunucu /detect uç noktası üzerinden veriyi alır.
4.	YOLOv8 ile Para Tanıma:
Görüntü, sunucuda YOLOv8 modeli ile işlenir. Model, banknotun sınıfını (örneğin “50_try”) ve güven skoru ile birlikte tespit eder.
5.	Etiketleme ve Anlamlandırma:
Sınıf etiketleri, Türkçe ve İngilizce anlamlarına çevrilir. (örn: “50_try” → “Elli Türk Lirası” / “Fifty Turkish Lira”).
6.	Sesli Geri Bildirim (gTTS):
Etiket, gTTS aracılığıyla sese dönüştürülür. Oluşan ses base64 formatına çevrilerek JSON cevabına eklenir.
7.	Mobil Tarafta Ses Oynatma:
Flutter uygulaması gelen yanıtı çözümler, base64 ses verisini cihazda geçici dosyaya yazar ve oynatır.
8.	Tekrarları Engellemek için Tanımanın Durdurulması:
Aynı para tekrar tekrar algılanmasın diye, sesli çıktı süresince sistem tanımayı durdurur. Bu işlem tamamlandığında yeniden aktif hale gelir.








