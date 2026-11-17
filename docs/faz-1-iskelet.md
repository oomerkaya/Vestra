# Faz 1: İskelet

**Durum:** Bitti · **Tarih:** 2026-11-17

## Özet

Derlenebilir, test edilebilir ve lint kurallarına uyan boş bir uygulama kabuğu kuruldu. Sonuç: alt navigasyonlu üç sekmeli (Portföy / Piyasa / Ayarlar) bir Android uygulaması; Ayarlar'da çalışan tema seçimi; temiz `flutter analyze`; geçen 4 test; çalışan CI.

## Ortam

| Araç | Sürüm |
|---|---|
| Flutter | 3.44.6 (stable) |
| Dart | 3.12.2 |
| Android SDK | 36.1.0 (derleme sırasında Platform 35 otomatik kuruldu) |
| IDE | Android Studio |

Kurulum için tek ek adım: `flutter doctor --android-licenses` ile lisansları kabul etmek.

## Alınan kararlar

| Karar | Gerekçe |
|---|---|
| Üretilen dosyalar (`lib/core/l10n/generated/`, ileride Drift `*.g.dart`) **git'e dahil** | Projeyi klonlayan kişi `build_runner` çalıştırmadan doğrudan Android Studio'dan derleyebilsin |
| Logger için paket eklenmedi, `dart:developer` kullanıldı | Gereksiz bağımlılıktan kaçınmak; yalnızca debug derlemede log yazar |
| Riverpod codegen (`riverpod_generator`) kullanılmadı | Şimdilik elle yazılan provider'lar yeterli, build süresi kısa kalır |
| `Result` alt tipleri `Success` / `Err` | `Failure` adı hata sınıfı için ayrıldı, isim çakışması olmasın |
| Tema tercihi şimdilik bellekte | Kalıcı saklama için ayarlar tablosu Faz 2'de gelecek |
| `public_member_api_docs` lint kuralı kapalı | Uygulama kodu, kütüphane değil; her public üyeye doc zorunluluğu gürültü yaratır |

## Yapılanlar

### 1. Proje oluşturma

```
flutter create --org com.vestra --project-name vestra --platforms android .
```

- `android/app/src/main/AndroidManifest.xml`:
  - `android:label="Vestra"` (launcher'da görünen ad)
  - `<uses-permission android:name="android.permission.INTERNET" />` eklendi. Debug derlemede otomatik var ama release APK'da açıkça gerekir.
- Varsayılan `test/widget_test.dart` silindi.

### 2. Paketler (`pubspec.yaml`)

| Paket | Tür | Amaç |
|---|---|---|
| `flutter_riverpod` | runtime | State management, DI |
| `go_router` | runtime | Navigasyon |
| `dio` | runtime | HTTP |
| `drift`, `drift_flutter` | runtime | SQLite ORM ve Flutter bağlantısı |
| `flutter_secure_storage` | runtime | API anahtarı |
| `decimal` | runtime | Para/miktar tipi |
| `intl`, `flutter_localizations` | runtime | l10n, sayı/tarih biçimleme |
| `very_good_analysis` | dev | Lint |
| `mocktail` | dev | Mock |
| `drift_dev`, `build_runner` | dev | Drift kod üretimi |

`flutter_lints` kaldırıldı (yerine `very_good_analysis`). Bağımlılıklar alfabetik sıralı (`sort_pub_dependencies` kuralı). `flutter: generate: true` l10n üretimi için açıldı.

### 3. Lint (`analysis_options.yaml`)

```yaml
include: package:very_good_analysis/analysis_options.yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "lib/core/l10n/generated/**"
linter:
  rules:
    public_member_api_docs: false
```

### 4. `.gitignore` eklemeleri

`.env`, `.env.*`, `*.env`, `secrets.json`, `*.keystore`, `*.jks`, `android/key.properties`, `android/local.properties`. Amaç: API anahtarı, imzalama anahtarı ve makineye özel yolların repoya girmemesi.

### 5. Klasör yapısı

```
lib/
  main.dart                  # ProviderScope + VestraApp
  app.dart                   # MaterialApp.router: tema, l10n, router
  core/
    di/                      # (boş) ileride ortak provider'lar
    error/
      failure.dart           # sealed Failure hiyerarşisi
      result.dart            # sealed Result<T>: Success / Err
    l10n/
      arb/app_tr.arb         # Türkçe metinler (kaynak)
      generated/             # gen-l10n çıktısı (git'te)
      l10n.dart              # context.l10n kısayolu
    network/                 # (boş) Faz 3: dio istemcisi
    router/
      app_router.dart        # GoRouter + rota sabitleri
      app_shell.dart         # NavigationBar'lı kabuk
    theme/
      app_theme.dart         # Material 3 açık/koyu tema
      theme_mode_provider.dart
    utils/
      app_logger.dart
    widgets/
      empty_state.dart
  features/
    portfolio/{data,domain,presentation}/
    market/{data,domain,presentation}/
    settings/{data,domain,presentation}/
```

Boş klasörler git'te kalsın diye `.gitkeep` dosyaları var.

### 6. `core` bileşenleri

**`Failure`** ([failure.dart](../lib/core/error/failure.dart)): `sealed class`. Alt tipler: `NetworkFailure`, `ServerFailure(statusCode)`, `RateLimitFailure(retryAfter)`, `AuthFailure`, `StorageFailure`, `ValidationFailure`, `UnexpectedFailure`. `message` alanı yalnızca geliştirici içindir, kullanıcıya gösterilmez, sır içermez. UI, `switch` ile alt tipi yakalayıp l10n mesajı gösterecek.

**`Result<T>`** ([result.dart](../lib/core/error/result.dart)): `Success(value)` / `Err(failure)`. Yardımcılar: `isSuccess`, `isFailure`, `valueOrNull`, `fold`, `map`. Exception'lar data katmanında yakalanır ve `Err`'e çevrilir; domain ve presentation exception görmez.

**`AppLogger`** ([app_logger.dart](../lib/core/utils/app_logger.dart)): `debug/info/warning/error`. `kDebugMode` değilse hiçbir şey yazmaz. API anahtarı veya anahtar içeren URL loglanmaz.

**Tema** ([app_theme.dart](../lib/core/theme/app_theme.dart)): `ColorScheme.fromSeed(0xFF1B6B5A)` ile Material 3 açık/koyu. `themeModeProvider` (`Notifier<ThemeMode>`), varsayılan `ThemeMode.system`.

**l10n**: `l10n.yaml` ile `gen-l10n`; şablon `app_tr.arb`, çıktı sınıfı `AppLocalizations`, `nullable-getter: false`. Kullanım: `context.l10n.navPortfolio`. Uygulama `locale: Locale('tr')` ile sabit.

**`EmptyState`** ([empty_state.dart](../lib/core/widgets/empty_state.dart)): ikon + başlık + mesaj + isteğe bağlı aksiyon.

### 7. Uygulama kabuğu

- `appRouterProvider`: `GoRouter`, başlangıç `/portfolio`. `StatefulShellRoute.indexedStack` ile üç dal: `/portfolio`, `/market`, `/settings`. Sekme değişince her sekmenin kendi durumu korunur. Aynı sekmeye tekrar basınca o sekmenin köküne döner.
- `AppShell`: `NavigationBar` (Material 3).
- Ekranlar:
  - `PortfolioScreen`, `MarketScreen`: boş durum gösterir.
  - `SettingsScreen`: tema için `SegmentedButton` (Sistem / Aydınlık / Karanlık) ve yasal uyarı ("Vestra yatırım tavsiyesi vermez...").

### 8. Testler

| Dosya | Test |
|---|---|
| `test/core/result_test.dart` | `Success` değer ve `map`; `Err` hatayı `map`/`fold` boyunca korur |
| `test/app_test.dart` | Uygulama Portföy sekmesinde boş durumla açılır; Ayarlar → Karanlık seçince tema koyu olur |

### 9. CI (`.github/workflows/ci.yml`)

`main`'e push ve her PR'da, Ubuntu üzerinde: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`.

### 10. Git

`git init -b main`. Satır sonu tutarlılığı için `.gitattributes` (`* text=auto eol=lf`) eklendi; Windows'ta CRLF farkları CI'daki format kontrolünü bozmasın.

## Doğrulama

| Komut | Sonuç |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | 4/4 geçti |
| `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` üretildi (ilk derleme ~6 dk) |

## Android Studio'da çalıştırma

1. `flutter doctor --android-licenses` (bir kere)
2. Android Studio → File → Open → proje kök klasörü
3. Flutter/Dart eklentileri kurulu olmalı
4. Emülatör ya da USB hata ayıklamalı cihaz seç → Run

## Bilinen eksikler / sonraki faza devredilenler

- Tema tercihi uygulama kapanınca sıfırlanıyor → Faz 2'de ayarlar tablosuna yazılacak.
- 28 paketin daha yeni ama uyumsuz sürümü var (`flutter pub outdated`); şimdilik dokunulmadı.
- Uygulama ikonu Flutter varsayılanı → Faz 5.
- `README.md` hâlâ `flutter create` şablonu → Faz 5'te yazılacak (kurulum, API anahtarı, veri kaynağı, yasal uyarı).
