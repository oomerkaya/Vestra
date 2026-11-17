# Faz 2: Yerel veri

**Durum:** Bitti · **Tarih:** 2026-11-17

## Özet

Uygulamanın yerel veritabanı (Drift/SQLite) ve portföy feature'ının domain + data katmanları kuruldu. Portföy **işlem bazlı** tutulur. Eldeki miktar, ortalama maliyet ve gerçekleşen kâr/zarar her seferinde işlemlerden hesaplanır. Tema tercihi artık veritabanına yazılıyor ve uygulama yeniden açıldığında geri yükleniyor. UI ekranları Faz 4'te gelecek; bu fazda iş mantığı ve kalıcılık bitti.

## Alınan kararlar

| Karar | Alternatif | Gerekçe |
|---|---|---|
| **İşlem bazlı model** (her alım/satım ayrı satır) | Varlık başına tek kayıt (miktar + ortalama maliyet) | Kâr/zarar ve geçmiş mümkün. Tek kayıttan işlem bazlıya sonradan geçmek veri kaybı demek. UI'daki "varlık ekle" aslında bir alım işlemi oluşturur |
| **Ağırlıklı ortalama maliyet** yöntemi | FIFO | Türkiye'de bireysel takipte yaygın, anlaşılır. Satış, maliyeti o anki ortalamadan düşer |
| **Maliyet her zaman TL** | İşlem bazında para birimi | Tutarlı TL bazlı kâr/zarar, çevrim karmaşası yok |
| Alım fiyatı **isteğe bağlı** (`null` olabilir) | Zorunlu | Miras altın gibi maliyeti bilinmeyen varlıklar girilebilsin. Bu durumda maliyet ve kâr/zarar "bilinmiyor" (`null`) gösterilir |
| Desteklenen türler: döviz, altın (gram, çeyrek, yarım, tam, cumhuriyet), **gümüş**, hisse | Ons altın | Kullanıcı tercihi. `type` + `code` serbest metin olduğu için yeni tür eklemek şema değişikliği gerektirmez |
| Decimal → DB'de **TEXT** (`DecimalConverter`) | REAL, tam sayı | Hassasiyet kaybı sıfır. Bedeli: SQL'de `SUM` yapılamaz, tüm hesap Dart'ta |
| Enum'lar DB'de **TEXT (enum adı)** | INTEGER index | Enum sırası değişse bile veri bozulmaz, DB okunabilir kalır. Bir enum değerini yeniden adlandırmak migration gerektirir |
| `core/database` feature enum'larını bilmez; eşleme feature mapper'larında | Drift `textEnum<T>()` | `core` → `features` bağımlılığı oluşmasın |
| Satış, **o tarihte** eldeki miktarı aşamaz | Sadece güncel toplamı kontrol | Geriye tarihli bir satış veya bir alımın silinmesi geçmişte negatif bakiye yaratamaz |
| Tema provider'ı `core/theme` → `features/settings/presentation` taşındı | `core`'da bırakmak | Kalıcılık settings repository'sine bağlı; `core` bir feature'a bağımlı olmamalı |
| Migration: Drift `make-migrations` + `drift_schemas/` şema anlık görüntüleri | Elle migration | Her sürümün şeması git'te durur. Drift adım adım migration kodu ve testlerini otomatik üretir |

## Veritabanı şeması (v1)

Kaynak: [`lib/core/database/tables.dart`](../lib/core/database/tables.dart) · Anlık görüntü: [`drift_schemas/vestra/drift_schema_v1.json`](../drift_schemas/vestra/drift_schema_v1.json)

### `assets`

| Kolon | Tip | Not |
|---|---|---|
| `id` | INTEGER PK autoincrement | |
| `type` | TEXT | `currency` / `gold` / `silver` / `stock` |
| `code` | TEXT | `USD`, `EUR`, `GRAM`, `CEYREK`, `YARIM`, `TAM`, `CUMHURIYET`, `SILVER_GRAM`, `THYAO`… |
| `name` | TEXT | Görünen ad |
| `created_at` | DATETIME | varsayılan şimdi |

Tekil anahtar: `(type, code)`. Aynı varlık iki kez oluşmaz.

### `asset_transactions`

| Kolon | Tip | Not |
|---|---|---|
| `id` | INTEGER PK autoincrement | |
| `asset_id` | INTEGER FK → `assets.id` | `ON DELETE CASCADE` |
| `kind` | TEXT | `buy` / `sell` |
| `quantity` | TEXT (Decimal) | Her zaman pozitif |
| `unit_price_try` | TEXT (Decimal), nullable | Birim fiyat, TL |
| `date` | DATETIME | İşlem tarihi (kullanıcı girer) |
| `note` | TEXT nullable | |
| `created_at` | DATETIME | |

### `price_cache` (Faz 3'te doldurulacak)

| Kolon | Tip |
|---|---|
| `type`, `code` | TEXT, birleşik PK |
| `price_try` | TEXT (Decimal) |
| `source` | TEXT (ör. `frankfurter`, `burkut`) |
| `fetched_at` | DATETIME |

### `app_settings`

| Kolon | Tip |
|---|---|
| `key` | TEXT PK |
| `value` | TEXT |

Yalnızca gizli olmayan tercihler. API anahtarları burada **değil**, `flutter_secure_storage`'da tutulacak (Faz 3).

Bağlantı açılırken `PRAGMA foreign_keys = ON` çalışır. SQLite'ta bu varsayılan olarak kapalıdır; açılmazsa cascade çalışmaz.

## Yapılanlar

### `core`

| Dosya | İçerik |
|---|---|
| [`database/tables.dart`](../lib/core/database/tables.dart) | 4 tablo. Satır sınıfları `AssetRow`, `TransactionRow`, `PriceCacheRow`, `SettingRow` olarak adlandırıldı; domain'deki `Asset` ile çakışmasın |
| [`database/converters.dart`](../lib/core/database/converters.dart) | `DecimalConverter` (`Decimal` ↔ `String`) |
| [`database/app_database.dart`](../lib/core/database/app_database.dart) | `AppDatabase`, `schemaVersion = 1`, `MigrationStrategy` (onCreate, boş onUpgrade, beforeOpen'da foreign key) |
| `database/app_database.g.dart` | Drift tarafından üretildi (git'te) |
| [`di/database_provider.dart`](../lib/core/di/database_provider.dart) | `appDatabaseProvider`: `driftDatabase(name: 'vestra')`, dispose'da kapatır. Testlerde in-memory DB ile override edilir |
| [`error/failure.dart`](../lib/core/error/failure.dart) | `ValidationFailure` artık `final` değil; feature'lar tipli alt sınıf ekleyebiliyor |
| [`build.yaml`](../build.yaml) | Drift: veritabanı tanımı, `schema_dir: drift_schemas/`, `test_dir: test/drift/` |

### Portföy: domain (`lib/features/portfolio/domain/`)

Flutter, Drift ve dio import etmez.

| Dosya | İçerik |
|---|---|
| `entities/asset_type.dart` | `AssetType { currency, gold, silver, stock }`, `TransactionKind { buy, sell }` |
| `entities/asset.dart` | `Asset` (id, type, code, name), `AssetDraft` (id'siz) |
| `entities/asset_transaction.dart` | `AssetTransaction` (+ `copyWith`; nullable alanlar `() => value` ile set edilir), `TransactionDraft` |
| `entities/holding.dart` | `Holding` (quantity, totalCostTry?, averageCostTry?, realizedPnlTry?, transactionCount, isClosed), `AssetWithTransactions` |
| `entities/transaction_validation_failure.dart` | `TransactionValidationFailure(reason)`; reason: `nonPositiveQuantity`, `negativePrice`, `oversell`. UI bunu l10n mesajına çevirecek |
| `repositories/portfolio_repository.dart` | Arayüz: `watchPortfolio`, `getTransactions`, `findOrCreateAsset`, `insertTransaction`, `updateTransaction`, `deleteTransaction`, `deleteAsset`. Hepsi `Result` döner |
| `services/holding_calculator.dart` | Saf hesap: `calculate(asset, txs)`, `wouldOversell(txs)`, `sortChronologically` |
| `usecases/transaction_validator.dart` | Ortak alan + geçmiş doğrulaması |
| `usecases/add_transaction.dart` | Doğrula → varlığı bul/oluştur → geçmişe ekleyince oversell var mı → kaydet |
| `usecases/update_transaction.dart` | Doğrula → değiştirilmiş geçmişi kontrol et → kaydet |
| `usecases/delete_transaction.dart` | Silinmiş haliyle geçmişi kontrol et (sonraki satışı açıkta bırakan alım silinemez) → sil |
| `usecases/delete_asset.dart` | Varlık + tüm işlemleri |
| `usecases/watch_holdings.dart` | Canlı `Holding` listesi; DB değiştikçe yeniden hesaplar |
| `usecases/watch_asset_transactions.dart` | Bir varlığın işlemleri, yeniden eskiye |

#### Hesaplama kuralları (`HoldingCalculator`)

- İşlemler tarih, sonra id sırasıyla işlenir.
- **Alım:** miktar += q; fiyat varsa maliyet += q × fiyat, yoksa maliyet "bilinmiyor" olur.
- **Satış:** ortalama = maliyet / miktar; maliyet -= ortalama × q; miktar -= q; satış fiyatı ve maliyet biliniyorsa gerçekleşen K/Z += (fiyat − ortalama) × q.
- Pozisyon tamamen kapanınca (miktar = 0) maliyet sıfırlanır ve "bilinmiyor" durumu temizlenir; yeniden alımlar temiz başlar.
- Sonlanmayan bölmeler (100/3) 10 ondalık basamağa yuvarlanır (`divisionScale`).

Örnek: 100 USD @ 30 + 50 USD @ 36 → ortalama 32. 60 USD @ 40 satış → kalan 90 USD, maliyet 2880, gerçekleşen K/Z = (40 − 32) × 60 = 480.

### Portföy: data (`lib/features/portfolio/data/`)

| Dosya | İçerik |
|---|---|
| `datasources/portfolio_local_data_source.dart` | Ham Drift sorguları. `watchAssetsWithTransactions` tek `LEFT JOIN` sorgusu ile varlık + işlemleri reaktif izler. `findOrCreateAsset` bir DB transaction içinde çalışır |
| `mappers/portfolio_mappers.dart` | Row → entity, draft → companion. Enum ↔ TEXT `values.byName` ile |
| `repositories/portfolio_repository_impl.dart` | Tüm exception'ları yakalar, loglar, `StorageFailure` döner. Stream hataları da `Err` olarak akar. Var olmayan işlemi güncelleme hatadır |

### Portföy: DI

[`lib/features/portfolio/portfolio_providers.dart`](../lib/features/portfolio/portfolio_providers.dart): repository ve her use case için birer `Provider`. Presentation yalnızca bunları okur.

### Ayarlar feature'ı

| Dosya | İçerik |
|---|---|
| `domain/entities/theme_preference.dart` | `ThemePreference { system, light, dark }`, Flutter'ın `ThemeMode`'undan bağımsız |
| `domain/repositories/settings_repository.dart` | `getThemePreference`, `setThemePreference` |
| `data/datasources/settings_local_data_source.dart` | `app_settings` üzerinde `read` / `write` (upsert) |
| `data/repositories/settings_repository_impl.dart` | Kayıt yoksa veya bilinmeyen bir değer varsa `system` döner |
| `settings_providers.dart` | `settingsRepositoryProvider` |
| `presentation/theme_mode_provider.dart` | (`core/theme`'dan taşındı) Açılışta `system` ile başlar, kayıtlı değeri yükler. Kullanıcı yükleme bitmeden seçim yaparsa o seçim ezilmez. `setMode` hem state'i hem DB'yi günceller |

## Testler

Toplam **44 test**, hepsi geçti.

| Dosya | Kapsam |
|---|---|
| `test/core/database_test.dart` | `DecimalConverter` gidiş-dönüş (5 değer); DB'de foreign key'in açık olduğu |
| `test/features/portfolio/domain/holding_calculator_test.dart` | Boş geçmiş, ağırlıklı ortalama, satışta K/Z, tarih sırası, kesirli gram, 10 basamak yuvarlama, bilinmeyen maliyet, kapanan pozisyonun sıfırlanması, oversell tespiti (3 senaryo) |
| `test/features/portfolio/domain/transaction_usecases_test.dart` | mocktail ile: ilk alım varlık oluşturur, sıfır miktar/negatif fiyat reddi (repo'ya hiç gidilmez), fazla satış ve geriye tarihli satış reddi, tam miktar satışı, repo hatası iletimi, güncelleme ve silmede oversell koruması |
| `test/features/portfolio/data/portfolio_repository_impl_test.dart` | In-memory SQLite ile: `(type, code)` tekilliği, Decimal'in birebir saklanması, null fiyat, güncelleme/silme, olmayan kaydı güncelleme hatası, cascade silme, foreign key ihlali, `WatchHoldings` stream'inin değişiklikte yeniden yayın yapması |
| `test/features/settings/settings_repository_impl_test.dart` | Varsayılan `system`, kaydet/üzerine yaz, bilinmeyen değerde `system` |
| `test/app_test.dart` | Açılış ekranı; karanlık tema seçimi uygulanır **ve DB'ye yazılır**; kayıtlı tema açılışta geri yüklenir |

Yardımcılar: `test/helpers/test_database.dart` (her test için yeni in-memory DB), `test/helpers/fixtures.dart` (`d('1.5')`, `tx(...)`, `draft(...)`, örnek varlıklar).

## Migration stratejisi

1. `tables.dart`'ta değişikliği yap.
2. `app_database.dart`'ta `schemaVersion`'ı 1 artır.
3. `dart run build_runner build`
4. `dart run drift_dev make-migrations`. Bu komut:
   - `drift_schemas/vestra/drift_schema_vN.json` anlık görüntüsünü ekler,
   - `lib/core/database/app_database.steps.dart` dosyasını (`stepByStep`) üretir,
   - `test/drift/vestra/` altında migration testlerini üretir.
5. `onUpgrade`'i üretilen `stepByStep(from1To2: ...)` ile değiştir, adımı yaz.
6. `flutter test`: üretilen testler eski şemadan yenisine geçişi ve veri korunmasını doğrular.

Kural: Yayınlanmış bir şema sürümünün JSON dosyası **asla** silinmez veya değiştirilmez.

## Doğrulama

| Komut | Sonuç |
|---|---|
| `dart run build_runner build` | Başarılı (`app_database.g.dart`) |
| `dart run drift_dev make-migrations` | `drift_schema_v1.json` oluşturuldu |
| `flutter analyze` | No issues found |
| `flutter test` | 44/44 geçti |
| `flutter build apk --debug` | Başarılı (native SQLite Android'e paketleniyor) |

## Not: build_runner sürüm değişikliği

Kurulu `build_runner` sürümü `--delete-conflicting-outputs` bayrağını kaldırmış (uyarı verip yok sayıyor). Komut artık sadece `dart run build_runner build`. CLAUDE.md güncellendi.

## Bilinen eksikler / sonraki faza devredilenler

- **Altın ve gümüş fiyat kaynağı:** Frankfurter (ECB kurları) bildiğimiz kadarıyla XAU/XAG vermiyor. Faz 3'te doğrulanacak; gerekirse altın/gümüş için TCMB EVDS veya başka bir kaynak seçilecek. CLAUDE.md'deki "Frankfurter: döviz/altın" ifadesi bu karara göre düzeltilecek.
- **Sikke katsayıları:** Çeyrek/yarım/tam/cumhuriyet fiyatı gram fiyatından türetilecekse katsayılar (has altın gramı) Faz 3'te domain'e eklenecek, kaynağı belgelenecek.
- `price_cache` tablosu var ama henüz kullanılmıyor (Faz 3).
- Portföy UI'ı ve `TransactionValidationFailure` için Türkçe hata metinleri Faz 4'te.
- Varlık seçimi için sabit katalog (hangi `code` hangi ad) Faz 4'te.
