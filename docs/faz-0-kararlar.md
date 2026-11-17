# Faz 0: Kararlar

**Durum:** Bitti · **Tarih:** 2026-11-17

## Özet

Kod yazmadan önce projenin kapsamı, dağıtım modeli ve teknoloji yığını netleştirildi. Kararların kalıcı hali [`CLAUDE.md`](../CLAUDE.md)'de durur; bu dosya kararların **gerekçesini** kayda geçirir.

## Alınan kararlar

### Ürün ve dağıtım

| Karar | Seçim | Gerekçe |
|---|---|---|
| Uygulama adı | **Vestra** | Kullanıcı tercihi |
| Android paket adı | `com.vestra.vestra` | `flutter create --org com.vestra --project-name vestra` sonucu. Mağazaya çıkılmayacağı için sonradan değiştirmek sorun değil |
| Kullanım | Kişisel, ücretsiz | Mağaza ürünü değil; yatırım tavsiyesi vermez |
| Dağıtım | GitHub (kaynak kod + Releases'ta APK) | Herkes kendi cihazına derler/kurar |
| İlk platform | Android | iOS sonra |
| Veri saklama | Yalnızca cihazda (SQLite) | Sunucu yok, gizlilik ve maliyet |
| Hisse verisi | Bürküt API, kullanıcı başına kendi anahtarı | Ücretsiz plan kotası kullanıcıya ait olur; anahtar uygulamaya gömülmez |
| Döviz/altın verisi | Frankfurter (anahtarsız), isteğe bağlı TCMB EVDS | Anahtarsız birincil kaynak ile kurulum kolay |

### Teknoloji yığını

| Konu | Seçim | Neden |
|---|---|---|
| State management | Riverpod | Test edilebilir, `BuildContext`'ten bağımsız DI |
| Yerel DB | Drift (SQLite) | Tip güvenli sorgular, migration desteği, reaktif stream'ler |
| Navigasyon | go_router | Resmi destekli, `StatefulShellRoute` ile sekme durumu korunur |
| HTTP | dio | Interceptor (backoff, hata eşleme) kolaylığı |
| Gizli veri | flutter_secure_storage | API anahtarı Android Keystore ile şifreli saklanır |
| Lint | very_good_analysis | Katı kurallar, tutarlı kod |
| Test | flutter_test + mocktail | Codegen gerektirmeyen mock |

### MVP kapsamı

İlk sürümde olacak özellikler:

1. Varlık ekleme / düzenleme / silme (döviz, altın, hisse)
2. Portföy özeti (toplam TL değer, dağılım)
3. Fiyat güncelleme (polling, son güncelleme göstergesi, offline cache)
4. Ayarlar (Bürküt API anahtarı, **tema: Sistem / Aydınlık / Karanlık**, yasal uyarı)

### Para ve miktar tipi: `Decimal`

| Seçenek | Artı | Eksi |
|---|---|---|
| **`Decimal` (seçildi)** | Kesirli gram altın, hisse adedi ve çok basamaklı kurlar doğal ifade edilir; yuvarlama hatası yok | Ek paket (`decimal`), DB'de TEXT saklama gerekir |
| Tam sayı (minor unit) | Paket yok, hızlı | Kur ve kesirli miktarlarda her alan için ayrı ölçek yönetmek zahmetli |
| `double` | — | Para hesabında yuvarlama hatası; **yasak** |

Uygulama: Drift'te TEXT kolon + `TypeConverter<Decimal, String>` (Faz 2'de yazılacak).

## Bilinen eksikler / sonraki faza devredilenler

- Varlık modeli (tek kayıt + ortalama maliyet mi, işlem bazlı mı?) Faz 2 başında karara bağlanacak.
- Bürküt endpoint yolları ve ücretsiz plan limitleri Faz 3'te geliştirici portalından doğrulanacak.
