# Faz 4: Özellikler

**Durum:** Bitti · **Tarih:** 2026-11-18

## Özet

Uygulama artık uçtan uca kullanılabilir. Kullanıcı:
- döviz, altın/gümüş ve BIST hissesi ekleyebilir; alım/satım işlemlerini düzenleyip silebilir,
- portföyünün toplam değerini, kâr/zararını, günlük değişimini ve kategori dağılımını (halka grafik) görebilir,
- her varlığın detayını ve işlem geçmişini inceleyebilir.

Fiyat güncelleme ekranı ve "son güncelleme" göstergesi Faz 3'te tamamlanmıştı (Piyasa sekmesi).

| Portföy (aydınlık) | Portföy (karanlık) | Varlık detayı | Varlık ekleme |
|---|---|---|---|
| ![](images/faz4_light_portfolio.png) | ![](images/faz4_dark_portfolio.png) | ![](images/faz4_light_detail.png) | ![](images/faz4_light_add.png) |

Ekran görüntülerindeki portföy ve fiyatlar **örnek veridir**.

## Alınan kararlar

| Karar | Alternatif | Gerekçe |
|---|---|---|
| BIST hissesi **arama listesinden** seçilir | Sembolü elle yazmak | Kullanıcı tercihi. Yanlış sembol girilemez, şirket adı görünür. Liste yoksa (anahtar yok) sembol elle yazılabilir |
| Hisse listesi Bürküt `/stocks` (tüm piyasa, **1 istek**) ile alınır, `app_settings`'te JSON olarak (~25 KB) **7 gün** önbelleklenir | Her açılışta çekmek; ayrı tablo | Kota korunur; ayrı tablo için migration gerekmez. Yenileme başarısızsa eski liste kullanılır |
| Alım formunda fiyat, tarih **bugünse** önbellekteki güncel fiyatla dolu gelir | Hep boş | Kullanıcı tercihi. Geçmiş tarih seçilince otomatik doldurulan fiyat temizlenir; kullanıcı fiyatı değiştirirse dokunulmaz |
| Dağılım **halka grafik**, kendi `CustomPainter`'ımızla | Grafik paketi (fl_chart vb.) | Kullanıcı tercihi; paket eklemeye gerek yok. Yüzdeler `Decimal` ile hesaplanır, `double`'a yalnızca çizim için çevrilir |
| Değerleme: miktar × önbellekteki fiyat. Fiyatı olmayan varlık listede "Fiyat yok" olarak durur, **toplamlara katılmaz**, altta not düşülür | Son alış fiyatıyla değerlemek | Uydurma değer göstermemek |
| Kâr/zarar toplamı yalnızca **fiyatı ve maliyeti bilinen** varlıklardan | Bilinmeyen maliyeti 0 saymak | Yüzde bozulmasın (miras altın gibi) |
| Günlük değişim: önceki kapanış = fiyat / (1 + %/100) | Ayrı API çağrısı | Ek istek yok; Bürküt günlük yüzdeyi zaten veriyor |
| Hisselerde başlık **sembol** (THYAO); şirket adı detayda | Şirket adı | Bürküt adları uzun ve büyük harf ("TURK HAVA YOLLARI A.O."); listede kesiliyordu |
| Ekleme ve düzenleme **tek form** (`TransactionFormScreen.add/.edit`) | İki ayrı ekran | Tek kaynak; doğrulama use case'lerde |
| Form ve detay ekranları **kök navigator'da** (alt menünün üstünde) | Sekme içinde | Tam ekran form, geri tuşu doğal çalışır |
| Türkçe sayı girişi: `12,5` · `1.250,75` · `1250.75` · `1.250` (= 1250) | Yalnızca nokta | Türk kullanıcı alışkanlığı (`parseDecimalInput`) |
| Bildirimler (snackbar) **sıraya girmez**, öncekinin yerine geçer | Varsayılan kuyruk | Testte bulundu: "Varlık silindi" mesajı önceki "İşlem kaydedildi"nin arkasında saniyelerce bekliyordu |

## Yapılanlar

### Domain

| Dosya | İçerik |
|---|---|
| `portfolio/domain/services/portfolio_valuator.dart` | Saf değerleme: açık varlıklar, toplam değer, kategori dağılımı, gerçekleşmemiş K/Z (₺ ve %), günlük değişim, fiyatı olmayan sayısı. Sıralama: değere göre azalan, fiyatsızlar sonda |
| `portfolio/domain/entities/portfolio_summary.dart` | `ValuedHolding`, `PortfolioSummary` |
| `portfolio/domain/instrument_catalog.dart` | Seçilebilir dövizler (Bürküt'ün canlıda verdiği 21 kur) ve madenler (gram, çeyrek, yarım, tam, cumhuriyet, ata, gram gümüş) |
| `market/domain/entities/stock_listing.dart` | Sembol + şirket adı |
| `market/domain/providers/price_providers.dart` | Yeni `StockListingProvider` arayüzü |
| `market/domain/repositories/stock_directory_repository.dart` | Önbellekli hisse listesi arayüzü |

### Data

| Dosya | İçerik |
|---|---|
| `burkut_remote_data_source.dart` | `getAllStocks` (`/stocks`, parametresiz) |
| `burkut_price_provider.dart` | `StockListingProvider` uygulaması; `_call` genel tipe çevrildi (anahtar/kota kontrolleri aynen geçerli) |
| `stock_listing_local_data_source.dart` | `app_settings` → `bist_listings` JSON |
| `stock_directory_repository_impl.dart` | 7 gün taze; değilse çek, başarısızsa eski liste; hiç yoksa hata |

### Core

| Dosya | İçerik |
|---|---|
| `utils/decimal_input.dart` | `parseDecimalInput`, `formatDecimalInput` |
| `widgets/donut_chart.dart` | Halka grafik (dilimler arası boşluk, arka iz) |
| `widgets/confirm_dialog.dart` | Silme onayı |
| `widgets/messages.dart` | `ScaffoldMessengerState.showMessage`, kuyruksuz bildirim |
| `router/app_routes.dart` | Rota sabitleri ve yardımcıları (`assetDetail`, `editTransaction`, `addTransactionFor`) |
| `router/app_router.dart` | Kök navigator anahtarı; `/portfolio/add`, `/portfolio/asset/:id`, `/portfolio/asset/:id/transaction/:tx` |

### Sunum (`portfolio/presentation/`)

| Dosya | İçerik |
|---|---|
| `portfolio_screen.dart` | Özet kartı, dağılım, varlık listesi, "Varlık ekle" butonu, fiyatı olmayanlar notu |
| `widgets/portfolio_summary_card.dart` | Toplam değer (kuruş küçük), K/Z ve bugün hapları |
| `widgets/allocation_card.dart` | Halka grafik ve açıklama (Döviz / Madenler / Borsa) |
| `widgets/holding_tile.dart` | Ad, "25 gram · ort. ₺4.200,00", değer, K/Z % |
| `widgets/instrument_picker_sheet.dart` | Kategoriye göre liste (güncel fiyatlarla); hisselerde arama (sembol veya ad, Türkçe büyük harf), listede yoksa elle sembol |
| `screens/transaction_form_screen.dart` | Tür, varlık, alım/satım, miktar (birimli), birim fiyat (otomatik doldurma), tarih, not; düzenlemede silme |
| `screens/asset_detail_screen.dart` | Değer, K/Z, miktar, ortalama maliyet, gerçekleşen K/Z; Alım/Satış ekle; işlem listesi; varlığı silme |
| `screens/edit_transaction_route.dart` | Rota parametrelerinden varlık ve işlemi yükler |
| `portfolio_labels.dart` | Kategori adı ve rengi, görünen ad, birim (USD / gram / adet), hata mesajları |
| `portfolio_providers.dart` | `holdingsProvider`, `portfolioSummaryProvider`, `assetTransactionsProvider(assetId)` |

### Metinler

`app_tr.arb`'ye yaklaşık 50 yeni metin eklendi: form, detay, onaylar, hatalar, seçici. Fazla satış uyarısı şöyle: "Bu tarihte elindeki miktardan fazla satamazsın; önceki bir alım silinirse ya da azalırsa da olmaz".

## Testler

Toplam **153 test**, hepsi geçti (Faz 3 sonunda 127, +26).

| Dosya | Kapsam |
|---|---|
| `test/features/portfolio/domain/portfolio_valuator_test.dart` | Toplam, maliyet, K/Z %, kategori dağılımı, sıralama; fiyatsız varlığın hariç tutulması; bilinmeyen maliyet; günlük değişim (+%25 → önceki 400, şimdi 500); kapalı pozisyon |
| `test/core/decimal_input_test.dart` | 10 Türkçe ve İngilizce biçim; geçersiz girişler; biçimle → ayrıştır gidiş-dönüşü |
| `test/features/market/data/stock_directory_repository_impl_test.dart` | İlk çekme ve sıralama; 6 gün istek yok; 7. gün yenileme; hata → eski liste; liste ve anahtar yok → hata |
| `test/features/portfolio/presentation/portfolio_flow_test.dart` | **Uçtan uca arayüz:** dolar ekle (fiyat otomatik dolu) → portföyde ₺4.210,00 ve dağılım; fazla satış uyarısı; detaydan işlemi düzenle (100 → 200 USD); varlığı sil → boş portföy |
| `test/app_test.dart` | Drift akışlarının kapanış zamanlayıcıları için her testin sonunda uygulama kaldırılıyor |

## Doğrulama

| Komut | Sonuç |
|---|---|
| `dart format --set-exit-if-changed lib test` | Temiz |
| `flutter analyze` | No issues found |
| `flutter test` | 153/153 |
| `flutter build apk --debug` | Başarılı |
| Görsel önizleme (geçici golden test, Inter fontu ile) | Portföy (aydınlık/karanlık), detay, ekleme formu; iki düzeltme yapıldı (hisse başlığı sembol, "Madenler" etiketi) |

## Faz 4 sonrası değişiklikler (2026-11-18)

Kullanıcı geri bildirimleriyle sırayla yapıldı; son durum aşağıda.

### 1. Piyasa: "Portföyümde / Tümü" bölümleri

- Her piyasa sekmesinde iki açılır-kapanır bölüm var (`CollapsibleSection`):
  - **Portföyümde:** O kategoride elde tutulan enstrümanlar ve sayısı.
  - **Tümü:** Kategorideki her şey.
- Açık/kapalı durumu sekme değişince korunuyor (`PageStorage`). Portföyde o kategoriden bir şey yoksa "Tümü" açık başlıyor.
- **İstek sayısı artmadı:**
  - `/forex` ve `/gold` zaten tüm listeyi veriyordu.
  - `/stocks` parametresiz tüm piyasayı (634 hisse) yine **tek istekte** döndürüyor. Hisselerde düzenli güncelleme artık tüm piyasa.
- **Borsa "Tümü":** Arama kutusu var (sembol veya şirket adı, Türkçe büyük harf). Liste 50'şer satır açılıyor ("50 hisse daha göster"). Hisse satırında başlık sembol, alt yazı şirket adı.

| Döviz | Borsa |
|---|---|
| ![](images/market_sections_fx.png) | ![](images/market_sections_borsa.png) |

### 2. BIST 30 / BIST 100 denendi ve kaldırıldı

- **Endeks verisi Bürküt'te yok.** Kullanıcının anahtarıyla denendi:
  - `/indices` → 404.
  - `/stocks?index=XU030` → parametre yok sayıldı.
- **Denenen çözüm:** Endeks üyeleri bir JSON dosyasında (2026 4. çeyrek listesi) tutuldu.
- **Kaldırıldı:** Endeks listesi 3 ayda bir değişiyor ve elle güncelleme gerektiriyor; kullanıcı bu güncellik sorunu nedeniyle istemedi. Dosya, entity, provider'lar ve testleri kaldırıldı; yerine Borsa'da "Tümü" bölümü geldi.

### 3. Seans kapalıyken eklenen hisse

- **İlk sorun:** Hisseler yalnızca seans içinde çekildiği için seans kapalıyken eklenen hisse "Fiyat yok" kalıyordu.
- **Geçici çözüm:** Önce "fiyatı olmayan hisse için tek istek" kuralı eklendi.
- **Son çözüm:** Hisseler tüm piyasa olarak çekildiğinden yeni eklenen hissenin fiyatı son anlık görüntüde zaten var, ayrı istek gerekmiyor. Bu yüzden ayrı istek kuralı (`isMissingStocksDue`, `WatchHeldStockSymbols`) **kaldırıldı**.
- **Tek kural:** Bir kategori **hiç çekilmemişse** (boş önbellek) seans fark etmeksizin hemen bir kez çekilir. Uygulama ilk kez gece ya da hafta sonu açılsa da hisse fiyatları gelir. Sonrasında hisseler yalnızca seans içinde 30 dakikada bir güncellenir.
- **Kalıcı düzeltme:** Ara adımda testler bir açık yakaladı: başarısız normal istekten hemen sonra tekrar deneniyordu. Bu düzeltme kalıcı; otomatik yeniden deneme 30 dakika bekliyor.

### 4. Ons altın eklendi, sonra kaldırıldı

- Bürküt'ün canlı `/gold` listesindeki ons altın (`XAUUSD`, USD/ons) bir süre USD/TRY ile TL'ye çevrilerek eklendi.
- Kullanıcı istemediği için **kaldırıldı**; çevirme kodu da silindi.
- Madenler: gram, çeyrek, yarım, tam, cumhuriyet, ata altın ve gram gümüş.

### 4b. "Tümü"de yalnızca portföy hisseleri görünmesi (düzeltildi)

- **Sorun:** Telefonun önbelleğinde eski sürümün çektiği, yalnızca portföydeki hisseler vardı. Denetleyici bu yüzden "hisse verisi var" sayıyor ve tüm piyasayı ancak sonraki seansta çekiyordu; o zamana kadar "Tümü" listesinde sadece portföy hisseleri görünüyordu.
- **Çözüm:** Tüm piyasanın en son başarıyla çekildiği zaman ayrıca tutuluyor (`app_settings` → `stocks_snapshot_at`, `MarketRepository.stocksSnapshotAt`). Hisseler için "son güncelleme" artık bu değer. Değer hiç yoksa tüm piyasa seans kapalı olsa bile hemen bir kez çekiliyor.
- **Testler:** Tüm piyasa çekilince zaman kaydediliyor; yalnızca bazı semboller çekilince kaydedilmiyor; eski önbellekle gece açılışta tüm piyasa çekiliyor.

**Not (geliştirme sırasında görülen hata):** Bir asset dosyası silindikten sonra Android Studio'da Hot Reload/Restart "Could not update files on device: PathNotFoundException … bist_indices.json" hatası verdi. Bu kod hatası değil: çalışan oturum silinen dosyayı göndermeye çalışıyor. Asset ekleyip silen değişikliklerden sonra uygulama Stop → Run ile yeniden başlatılmalı.

### 5. Portföy: dağılım açılır-kapanır

"Dağılım" bölümü artık `CollapsibleSection` içinde (`AllocationChart`).

### Testler

161 test. Kapsananlar:
- İlk çekmenin her saatte izinli olması.
- Sonrasında hisselerin seansı beklemesi.
- Ons'un aynı yenilemedeki ya da önbellekteki kurla TL'ye çevrilmesi, kur yoksa atlanması.
- Gerçek `/gold` cevabından 8 enstrüman çıkması.
- Yeni tutulan hisse için ek istek gitmemesi.

## Bilinen eksikler / sonraki faza devredilenler

- **ABD borsası:** Finnhub'dan yazılı onay bekleniyor (Faz 3 dokümanı).
- **Hisse listesi:** Bürküt anahtarı girilince kendiliğinden yenilenmiyor; ekleme ekranı ilk açıldığında çekiliyor.
- **Tarih:** Yalnızca gün olarak saklanıyor. Aynı güne ait işlemler kayıt sırasına göre işleniyor.
- **Faz 5'e kalanlar:** hata ekranları ve boş durum cilası, erişilebilirlik taraması, yedekleme/dışa aktarma, README, APK yayını.
