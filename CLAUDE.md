# CLAUDE.md

Bu dosya, projede çalışan Claude Code oturumları için kalıcı bağlamdır. Kodlamadan önce oku. Yol haritası için `ROADMAP.md`'ye bak.

## Proje

Flutter ile yazılmış **kişisel portföy takip uygulaması**: **Vestra** (`com.vestra.vestra`). Kullanıcı elindeki döviz, altın ve hisseleri **kendisi elle girer**; uygulama güncel değerleri gösterir.

- Mağaza ürünü değil: kaynak kod GitHub'da durur, herkes kendi telefonuna kendi derler/kurar. İlk hedef **Android**, iOS sonra.
- Ücretsiz ve kişisel kullanım. Yatırım tavsiyesi vermez; ayarlarda ve README'de bu uyarı bulunur.
- Tüm kullanıcı verisi **cihazdaki yerel veritabanında** tutulur. Sunucu yoktur.

## Teknoloji kararları

| Konu | Seçim |
|---|---|
| State management | Riverpod |
| Yerel veritabanı | Drift (SQLite) |
| Navigasyon | go_router |
| HTTP | dio |
| Gizli veri | flutter_secure_storage (API anahtarı) |
| Lint | very_good_analysis |
| Test | flutter_test + mocktail |
| Para tipi | decimal |
| l10n | flutter_localizations + gen-l10n (`lib/core/l10n/arb/app_tr.arb`) |
| Hata modeli | Kendi `sealed class Result<T>` (Success / Failure), exception'lar data katmanında yakalanır |

Yeni bir paket eklemeden önce neden gerektiğini kullanıcıya söyle.

## Mimari

Feature-first + katmanlı (clean architecture):

```
lib/
  core/            # ortak: error, network, theme, l10n, utils, di
  features/
    <feature>/
      data/          # datasource (local/remote), DTO, repository implementasyonu
      domain/        # entity, repository arayüzü, use case (Flutter'a bağımlı DEĞİL)
      presentation/  # ekran, widget, Riverpod provider/notifier
  main.dart
```

Kurallar:
- Bağımlılık yönü: `presentation -> domain <- data`. `domain` katmanı Flutter, Drift veya dio import etmez.
- UI doğrudan repository/datasource çağırmaz; use case veya notifier üzerinden gider.
- DTO ve entity ayrıdır. Dönüşüm data katmanındaki mapper'larda yapılır.
- Bir dosyada tek sorumluluk. Widget'lar küçük tutulur, iş mantığı widget içinde olmaz.
- Para ve miktar hesaplarında `double` kullanma; `Decimal` (`decimal` paketi) kullan. Drift'te TEXT kolon + TypeConverter ile saklanır.

## Veri kaynakları

Dış veri erişimi **her zaman bir arayüz arkasında** olur; sağlayıcı değişirse yalnızca data katmanı değişir.

- `StockPriceProvider` (hisse): ilk implementasyon **Bürküt API** (ücretsiz plan, BIST verisi **15 dk gecikmeli**). Her kullanıcı kendi API anahtarını ayarlardan girer. Endpoint yollarını ve ücretsiz plan limitlerini Bürküt geliştirici portalından doğrula; tahmin etme.
- `FxRateProvider` (döviz/altın): birincil **Frankfurter** (anahtarsız, günlük kur). İsteğe bağlı ikinci kaynak **TCMB EVDS** (kullanıcıya ait EVDS anahtarı gerekir; kaynak göstermek zorunlu).
- Bürküt resmi lisanslı veri dağıtıcısı değildir; README'de veri kaynağı ve gecikme açıkça yazılır.

Güncelleme kuralları:
- Polling yalnızca uygulama açıkken, hafta içi 10:00-18:00 (Europe/Istanbul) arasında, 15 dakikada bir. Arka plan servisi yok.
- Uygulama öne geldiğinde cache 15 dakikadan eskiyse yenile; pull-to-refresh ile elle yenileme var.
- Resmi tatil/yarım gün takvimi kodda gömülü değil, güncellenebilir bir JSON asset'inden okunur.
- Yalnızca portföyde bulunan semboller istenir; mümkünse toplu istek.
- 429 gelirse exponential backoff. Kota aşılmaz.
- Piyasa kapalıyken cache'teki son fiyat ve "son güncelleme" zamanı gösterilir.
- Çekilen fiyatlar yerel DB'ye yazılır; internet yoksa uygulama son bilinen değerle çalışır.

## Derleme

- Kullanıcı Android Studio ile derler. Üretilen dosyalar (Drift `*.g.dart`, `lib/core/l10n/generated/`) git'e dahil edilir; klonlayan kişi `build_runner` çalıştırmadan derleyebilmeli.
- Drift şeması değişince: `dart run build_runner build --delete-conflicting-outputs`.

## Güvenlik

- API anahtarları asla kodda, loglarda, testlerde, README'de veya git geçmişinde bulunmaz. `flutter_secure_storage` dışında saklanmaz.
- Testlerde gerçek anahtar yerine sahte değer ve sahte HTTP yanıtları kullan.
- `.gitignore` anahtar/ortam dosyalarını kapsar.

## Çalışma kuralları

- Her değişiklikten sonra `flutter analyze` ve ilgili `flutter test` çalıştır; hata varsa düzelt.
- Domain ve data katmanları için birim testi yaz (use case, repository, mapper, polling zamanlama mantığı).
- Küçük, odaklı değişiklikler yap; bir özelliği dikey dilim halinde (domain -> data -> presentation) bitir.
- Kullanıcıya görünen metinler Türkçe, kod, değişken ve commit mesajları İngilizce. Metinler l10n üzerinden gelir.
- Emin olmadığın karar (paket seçimi, şema değişikliği, kapsam) için önce sor.
- Her faz bitiminde `docs/faz-<n>-<ad>.md` dosyasını yaz (şablon: `docs/README.md`): alınan kararlar ve gerekçeleri, dosya dosya yapılanlar, doğrulama komutları/sonuçları, sonraki faza devredilenler. `docs/README.md` tablosunu ve `ROADMAP.md` işaretlerini güncelle.
