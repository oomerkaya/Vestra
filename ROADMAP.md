# Yol Haritası

Durum: `[ ]` bekliyor, `[x]` bitti. Kararlar için `CLAUDE.md`'ye bak.

## Faz 0: Kararlar
- [x] Kişisel kullanım, GitHub dağıtımı, kullanıcı başına Bürküt anahtarı
- [x] Riverpod, Drift, go_router, dio
- [x] İlk hedef Android
- [x] MVP kapsamı: varlık ekleme/düzenleme/silme, portföy özeti, fiyat güncelleme, ayarlar (tema: sistem/aydınlık/karanlık dahil)
- [x] Para/miktar tipi: `Decimal` (`decimal` paketi), DB'de TEXT olarak saklanır
- [x] Uygulama adı: Vestra, applicationId `com.vestra.vestra`

## Faz 1: İskelet
1. [x] `flutter create` (org adı, Android only), Git deposu, `.gitignore`
2. [x] `very_good_analysis` kur, `flutter analyze` temiz
3. [x] Klasör yapısı: `core/`, `features/` (boş feature şablonu)
4. [x] Paketler: riverpod, go_router, dio, drift, flutter_secure_storage, mocktail
5. [x] `core`: `Result` tipi, hata sınıfları, logger
6. [x] `core`: tema (açık/koyu), l10n (TR), ortak widget'lar
7. [x] Uygulama kabuğu: `MaterialApp.router`, boş ekranlarla alt navigasyon
8. [x] İlk widget testi + GitHub Actions (analyze + test)

## Faz 2: Yerel veri
- [x] Drift şeması: varlıklar, işlemler (işlem bazlı), fiyat cache'i, ayarlar (tema tercihi kalıcı)
- [x] Migration stratejisi (drift `make-migrations`, `drift_schemas/`)
- [x] Portföy feature'ı: entity, repository arayüzü, use case'ler, testler

## Faz 3: Piyasa verisi
- [x] Kaynak araştırması: Frankfurter altın/gümüş vermiyor → Bürküt birincil, Frankfurter döviz yedeği
- [x] `FxRateProvider`, `MetalPriceProvider`, `StockPriceProvider` (Bürküt + Frankfurter)
- [x] Ayarlar ekranı: API anahtarı gir, doğrula, güvenli sakla; aylık kota göstergesi
- [x] Polling zamanlayıcı (seans saatleri, tatil takvimi, backoff, 30 dk) + testler
- [x] Cache ve offline davranışı (şema v2 migration)
- [x] Gerçek Bürküt anahtarıyla sembol/alan doğrulaması (docs/faz-3 "Canlı doğrulama")
- [x] Piyasa ekranı sekmeli: Döviz / Madenler / Borsa (BIST)

## Faz 4: Özellikler (dikey dilimler)
- [ ] (Bekliyor) ABD borsası: Finnhub'dan yazılı onay gelirse. Ayrıntı: docs/faz-3 "ABD borsası değerlendirmesi"
- [x] Varlık ekleme/düzenleme/silme (BIST arama listesi, güncel fiyatla otomatik doldurma)
- [x] Portföy özeti ve toplam değer (K/Z, günlük değişim, halka grafik dağılım)
- [x] Fiyat güncelleme ekranı ve "son güncelleme" göstergesi (Faz 3'te)

## Sıradaki (Faz 5'ten önce, 2026-11-20)
- [ ] Frankfurter'ı tamamen kaldır; uygulama yalnızca Bürküt API ile çalışsın (yedek kaynak kodu, testleri, ayarlar/piyasa metinleri, CLAUDE.md ve dokümanlar)
- [ ] Kullanıcının belirteceği diğer güncellemeler ve genel kontroller
- [ ] Ardından Faz 5

## Faz 5: Cila ve yayın
- [ ] Flutter yükseltmesi + `material.dart` → `material_ui` geçişi (CI sürümüyle birlikte)
- [ ] Hata ekranları, boş durumlar, erişilebilirlik
- [ ] Yedekleme/dışa aktarma (veri yerelde olduğu için)
- [ ] README: kurulum, kendi API anahtarını alma, veri kaynağı ve gecikme uyarısı, yatırım tavsiyesi değildir notu
- [ ] GitHub Releases ile APK
