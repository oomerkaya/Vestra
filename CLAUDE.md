# CLAUDE.md

Bu dosya, projede çalışan Claude Code oturumları için kalıcı bağlamdır. Kodlamadan önce oku. Yol haritası için `ROADMAP.md`'ye bak.

## Proje

Flutter ile yazılmış **kişisel portföy takip uygulaması**: **Capira** (`io.github.oomerkaya.capira`). 2026-11-19'a kadar adı Vestra'ydı (`com.vestra.vestra`); eski Faz 0-4 dokümanlarında o isim geçer, eski yedek dosyaları (`"app": "vestra"`) hâlâ okunur. Kullanıcı elindeki döviz, altın ve hisseleri **kendisi elle girer**; uygulama güncel değerleri gösterir.

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
| Bağlantı / paylaşım / dosya | url_launcher (KAP linkleri), share_plus (yedek paylaşımı), file_picker (yedek seçme) |
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
- Portföy işlem bazlıdır (alım/satım satırları); miktar ve ortalama maliyet `HoldingCalculator` ile türetilir, ağırlıklı ortalama yöntemi. Maliyet her zaman TL.
- DTO ve entity ayrıdır. Dönüşüm data katmanındaki mapper'larda yapılır.
- Bir dosyada tek sorumluluk. Widget'lar küçük tutulur, iş mantığı widget içinde olmaz.
- Para ve miktar hesaplarında `double` kullanma; `Decimal` (`decimal` paketi) kullan. Drift'te TEXT kolon + TypeConverter ile saklanır.

## Tasarım

Sade fintech tarzı, Inter yazı tipi. Ayrıntı: `docs/tasarim-sistemi.md`.
- Renk/boşluk/köşe için `AppPalette` yerine tema + `context.capiraColors`, `AppSpacing`, `AppRadius` tokenlarını kullan; çıplak sayı yazma.
- Yeşil/kırmızı yalnızca kâr/zarar için (`ChangeChip`, `capiraColors.gain/loss`).
- Tutarlar `MoneyText` / `Formatters` ile gösterilir; `double` ile biçimlendirme yok.
- Ortak bileşenler `lib/core/widgets/`'ta (`AppCard`, `SectionHeader`, `MoneyText`, `ChangeChip`, `ChoiceTiles`, `EmptyState`, `DonutChart`, `InstrumentAvatar`, `confirmDestructive`).
- Bildirim için `ScaffoldMessenger.of(context).showMessage(...)` kullan (sıraya girmez); doğrudan `showSnackBar` çağırma.
- Arayüzde **Bürküt adı yalnızca Ayarlar → API anahtarı bölümünde** geçer (anahtarın nereden alınacağı ve "resmi Bürküt uygulaması değildir" notu). Diğer yerlerde kaynak adı yazılmaz; gecikme için yalnızca "Veriler gecikmelidir". Metinler kısa ve öz.
- Kullanıcıdan sayı alırken `parseDecimalInput` (Türkçe `12,5` / `1.250,75`) ve `formatDecimalInput` kullan.
- Liste satırlarının sağındaki tutar + değişim çipi `TrailingFigures` içinde olur (büyük yazıda taşmasın). `test/accessibility_test.dart` (1,8× yazı, dokunma alanı, etiket, WCAG kontrast) her zaman geçmeli; ikincil metin rengi `#636A77`'den açık olamaz.
- Kişisel tutarlar `AmountDisplay.of(context)` (`money`, `signedMoney`, `private`) ya da `MoneyText` ile gösterilir; böylece seçili para birimi (₺/$/€, güncel kurla) ve gizlilik modu her yerde geçerli olur. Maliyet/işlem fiyatları `convert: false` (TL). Piyasa fiyatları bunlardan geçmez.
- Değer geçmişi ve özet, cihazdaki günlük kayıtlardan (`portfolio_snapshots`, `asset_snapshots`, şema v4) gelir; hiç istek atmaz. Kayıt `SnapshotRecorder` ile, gün başına tek satır (İstanbul günü).
- Veritabanı okunamazsa ekran `ErrorState` gösterir; ağ hatası bu ekranı açmaz (son fiyatlar kalır).
- Yedek dosyası (`BackupCodec`, biçim 1) yalnızca varlık ve işlemleri içerir; API anahtarı ve fiyatlar asla girmez. Biçim değişirse `format` artırılır ve eski biçim okunmaya devam eder.
- Widget testlerinde Drift akışları kapanırken zamanlayıcı bırakır; testin sonunda uygulamayı kaldır (`pumpWidget(SizedBox())` + `pump(1 sn)`).

## Veri kaynakları

Dış veri erişimi **her zaman bir arayüz arkasında** olur (`FxRateProvider`, `MetalPriceProvider`, `StockPriceProvider`, `FundPriceProvider`, `DisclosureProvider`); sağlayıcı değişirse yalnızca data katmanı değişir.

Kaynaklar (ayrıntı ve araştırma: `docs/faz-3-piyasa-verisi.md`):
- **Bürküt** (tek kaynak; döviz, altın, gümüş, BIST hisseleri, TEFAS fonları; Frankfurter 2026-11-19'da kaldırıldı, anahtar yoksa hiç fiyat gelmez): `https://api.burkutportfoy.com/api/public/v1`, başlık `X-API-Key`. Ücretsiz plan **ayda 1.000 istek, dakikada 10 istek**. Sunucu kalan aylık kotayı `X-Quota-Remaining` başlığında bildirir; uygulama sayacı buna eşitler. Ayrıca **`/quota` kota harcamaz** (`quotaCheckConsumesCredit: false`): fiyat kontrolünde en fazla 10 dakikada bir ve Ayarlar açılınca çağrılır, sayaç sunucunun sayısıyla değiştirilir, sıfırlanma tarihi (`resetAt`) ayarlarda gösterilir. Alan adları uç noktaya göre değişir ve Bürküt'ün kendi belgeleriyle uyuşmaz (`/forex` canlıda `buyRate`/`rate`, `/gold` `buying`, `/stocks` `price`); `BurkutPriceDto` hepsini okur. Gerçek yanıtlar `test/fixtures/burkut/`'ta; format değişirse önce oraya bak. Her kullanıcı kendi anahtarını ayarlardan girer. BIST verisi en az 15 dk gecikmeli. Bürküt lisanslı veri dağıtıcısı değildir; README'de yazılır. **Bürküt'ün yazılı izni (2026-11-19, geliştirici Samet'in e-postası):** her kullanıcının kendi anahtarını girdiği açık kaynak paylaşım uygundur; şartları: (1) rate limit kurallarına uyup gereksiz sık istek atmamak, (2) repo açıklamasında/README'de bunun **resmi Bürküt uygulaması olmadığını, topluluk tarafından geliştirilen bağımsız bir istemci olduğunu** belirtmek. Repo paylaşılınca kendisine iletilecek.
- Döviz ve madenlerde değerleme için **alış (`buying`)** fiyatı kullanılır.
- **KAP bildirimleri** (kurallar `DisclosurePolicy`, akış `KapRefreshController`): **günde tek istek**: genel akış `/kap?size=500` (tüm şirketler, son 500 bildirim ≈ 29 saat, ~190 KB), İstanbul günü başına bir kez, 08:00'den sonra (hiç çekilmemişse hemen), **yalnızca uygulama açıkken**. Hisse bazında istek, eski sayfa okuma, arka plan görevi **yok**; uygulamanın açılmadığı günler boşluk kalır (kullanıcı kararı). Gelen **tüm** bildirimler (portföyde olmayan şirketler dahil) **30 gün** saklanır; detay ekranı ("Yakın zamanda yapılan KAP bildirimleri") ve KAP sayfası yalnızca bu kayıtları okur, **hiç istek atmaz**. KAP'ın kendi kota eşiği yok (günde 1 istek); yalnızca kota dolunca durur. `symbol` "GARAN, TGB" gibi birden çok şirket içerebilir (her şirkete ayrı satır, id `<id>:<SEMBOL>`); boş sembollü duyurular atlanır. Yorum yok. Portföy ekranının sağ üstündeki ikon (görülmemiş sayısı rozeti) ayrı sayfayı açar; son 24 saatte bildirimi olan hissede "KAP" etiketi. Linkler yalnızca `https://kap.org.tr` ise `url_launcher` ile açılır. Saklama: `kap_disclosures` (şema v3); `app_settings` → `kap_feed_at`, `kap_seen_at`.

Güncelleme kuralları (`RefreshPolicy`):
- Her kategori (döviz, maden, hisse) **ayrı** takip edilir ve son başarılı güncellemesinden en az **60 dakika** sonra istenir (2026-11-19'da kota için 30'dan 60'a çıkarıldı). Yalnızca uygulama açıkken; arka plan servisi yok.
- **Döviz ve madenler**: her gün, her saat (60 dk kuralıyla).
- **Hisseler**: yalnızca hafta içi 10:00-18:00 (Europe/Istanbul, sabit UTC+3), yarım günlerde 12:30'a kadar, tatillerde hiç. Hisseler her zaman **tüm BIST piyasası** olarak tek istekle çekilir; portföye eklenen hissenin fiyatı son anlık görüntüden hazırdır, ayrıca istek atılmaz.
- **İlk çekme**: bir kategori hiç çekilmemişse seans/saat fark etmeksizin hemen bir kez çekilir. Hisselerde "çekildi" sayılması için **tüm piyasa** anlık görüntüsü gerekir; zamanı `app_settings` → `stocks_snapshot_at`'te tutulur (eski sürümlerin sadece portföy hisselerini içeren önbelleği sayılmaz).
- **Pull-to-refresh kuralları ATLAMAZ** (60 dk ve seans saati geçerli); yalnızca başarısız bir denemeden sonra beklemeden tekrar denemeye izin verir. Bir şey istenmediyse kullanıcıya "Veriler güncel · sonraki güncelleme HH:mm" / "Borsa şu an kapalı" gösterilir.
- Tatil/yarım gün takvimi `assets/data/market_holidays.json`'dan okunur.
- `/forex`, `/gold`, `/stocks`, `/funds` hepsi tek istekte tüm listeyi döner (634 hisse, ~280 KB). Bir kategori = bir istek; en fazla 4 Bürküt isteği. Endeks (BIST 30/100) verisi Bürküt'te yok ve elle tutulan listeler eskidiği için kullanılmıyor.
- **Fonlar** (`/funds`, 2.441 TEFAS yatırım/emeklilik fonu, ~1,9 MB): İşlem günü başına **bir kez** (TEFAS fiyatları günlük), hisseler gibi **yalnızca seans içinde** (hafta içi 10:00-18:00, tatilde yok); ayda ~22 istek.
- Madenler: gram, çeyrek, yarım, tam, cumhuriyet, ata altın ve gram gümüş (hepsi TL). Ons altın (`XAUUSD`, USD) kullanıcı isteğiyle **kullanılmıyor**.
- Anahtar yoksa ya da kota doluysa Bürküt'e istek **gönderilmez**. Uygulama aylık istek sayacı tutar (`app_settings` → `burkut_quota`).
- 429 dakikalık limit → exponential backoff (1-30 dk, `Retry-After` öncelikli). 429 aylık kota → o ay Bürküt'e istek yok.
- Çekilen fiyatlar `price_cache`'e yazılır; internet yoksa son bilinen değer ve "son güncelleme" zamanı gösterilir.

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
