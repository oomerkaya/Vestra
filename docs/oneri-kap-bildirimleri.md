# Taslak öneri: Portföydeki hisseler için KAP bildirimleri

**Durum:** ✅ Karar verildi ve uygulandı (2026-11-19) · **Tarih:** 2026-11-19

> **Karar:** Seçenek D, üst sınır **5 hisse** (portföydeki değeri en yüksek). `url_launcher` eklendi; bildirimler KAP'ta tarayıcıda açılıyor. Güncelleme aralığı ayrıca 60 dakikaya çıkarıldı ve fonlar seansa bağlandı. Ayrıntı: `docs/faz-4-ozellikler.md` bölüm 9. Bu sınırla KAP ayda en fazla ~150 istek.

## İstek

Portföydeki hisselerin KAP (Kamuyu Aydınlatma Platformu) bildirimlerini almak ve ekranda kısaca göstermek. Bu dokümanın sorusu şu: bunun aylık istek limitine (ücretsiz plan: **1.000 istek/ay**, 10 istek/dakika) etkisi ne olur, hangi seçenek mantıklı?

## Canlı araştırma (kullanıcının anahtarıyla, 2 istek)

| Deneme | Sonuç |
|---|---|
| `GET /kap?symbol=THYAO&size=5` | ✅ 200. Sembol filtresi çalışıyor. ~1,5 KB. Zarf `{"data": {"content": [...], "totalElements", "totalPages", ...}}` (sayfalı) |
| `GET /kap?symbol=THYAO,ASELS&size=20` | ❌ 0 sonuç. **Birden fazla sembol tek istekte desteklenmiyor** |
| THYAO için toplam kayıt | `totalElements: 9`. API her şirket için yalnızca yakın dönemi tutuyor gibi; cevaplar küçük |

Bildirim alanları: `id`, `symbol`, `title` (ör. "Özel Durum Açıklaması (Genel)"), `summary` (ör. "Ekim 2026 Trafik Sonuçları"; bazen boş), `short_description` (KAP'taki asıl bildirimin linki dahil), `publishDate`. Belgedeki yapay zekâ `sentiment` alanı bu cevaplarda yoktu.

**Sonuç: tutulan her hisse için ayrı 1 istek gerekiyor.**

## Mevcut istek bütçesi (KAP olmadan)

Kurallar (2026-11-19'dan beri): döviz ve madenler **saatte bir**, hisseler seans içinde saatte bir, fonlar günde bir; yalnızca uygulama açıkken. Önceki 30 dakikalık değerler parantez içinde.

| Kullanım | Döviz | Madenler | Hisseler | Fonlar | **Toplam / ay** |
|---|---|---|---|---|---|
| Hafif (günde 2-3 kez kısa açılış) | ~75 | ~75 | ~30 | ~30 | **~210** (210) |
| Orta (günde ~6 açılış, 2'si seans içinde) | ~150 | ~150 | ~40 | ~30 | **~370** (435) |
| Yoğun (iş saatlerinde 8 saat açık bırakılan) | ~240 | ~240 | ~176 | ~30 | **~690** (1.340) |

> ✅ **Çözüldü:** 30 dakikalık aralıkla yoğun kullanım KAP olmadan da kotayı aşıyordu (~1.340). Aralık tüm kategorilerde 60 dakikaya çıkarıldı; yoğun kullanım ~690'a indi. Kota dolarsa uygulama yine bozulmaz, son fiyatları gösterir.

## Seçenekler

N = portföydeki farklı hisse sayısı.

### A) Her gün bir kez, tüm tutulan hisseler

- Günün ilk açılışında her hisse için `GET /kap?symbol=X&size=5` atılır (N istek). Hızlı olsun diye istekler sırayla gider, dakikada 10 istek sınırına takılmamak için gerekirse beklenir.
- Portföy ekranında açılır-kapanır bir **"Son bildirimler"** bölümü olur: son 7 günün bildirimleri, her satırda sembol, başlık/özet ve tarih. Dokununca KAP'taki asıl bildirim tarayıcıda açılır.
- **Maliyet: N × 30 istek/ay.**

| N | Ek istek / ay | Orta kullanımla toplam | Yoğun kullanımla toplam |
|---|---|---|---|
| 3 | 90 | ~460 | ~780 |
| 5 | 150 | ~520 | ~840 |
| 10 | 300 | ~670 | ~990 ⚠️ |
| 20 | 600 | ~970 ⚠️ | ~1.290 ⚠️ |

### B) Yalnızca detay ekranı açılınca (tembel)

- Hisseye ait bildirimler, o hissenin **detay ekranı açıldığında** çekilir ve 24 saat önbellekte tutulur.
- Portföy ekranında özet yok; bildirimler sadece detayda görünür.
- **Maliyet:** Günde detayına bakılan farklı hisse sayısı kadar. Gerçekçi olarak ayda 20-60 istek.

### C) Genel KAP akışı (önerilmez)

- `GET /kap?size=50` ile tüm bildirimler sayfa sayfa çekilip istemcide portföye süzülür.
- KAP'a günde yüzlerce bildirim düşüyor; portföydeki hisseleri yakalamak için çok sayfa gerekir. **Hem pahalı hem güvenilmez.**

### D) Karma: A, üst sınırla (önerim)

- **A gibi:** günde bir kez, portföy ekranında "Son bildirimler" özeti.
- **Üst sınır:** Günlük en fazla **10 hisse**; portföyde daha fazlası varsa **değeri en yüksek 10** hisse. Diğerlerinin bildirimleri, B'deki gibi detay ekranı açılınca çekilir.
- **Kota koruması:** Ay içinde kalan kota %20'nin altına düşerse KAP otomatik olarak sadece detay ekranında çalışır (B'ye geçer). Fiyat güncellemeleri her zaman önceliklidir.
- **Zamanlama:** Günün ilk açılışında, ama en erken 08:00'den sonra; şirketler bildirimlerini çoğunlukla seans öncesi ve sırasında yapıyor.
- **Maliyet: en fazla 300 istek/ay** (10 hisse × 30 gün). Tipik portföy (3-5 hisse) için 90-150.

## Ekranda nasıl görünür (taslak)

```
SON BİLDİRİMLER (KAP)                      3  ˄
──────────────────────────────────────────────
THYAO · Özel Durum Açıklaması      09.11.2026
Ekim 2026 Trafik Sonuçları                   ↗
──────────────────────────────────────────────
ASELS · Yeni İş İlişkisi           08.11.2026
Savunma sanayii sözleşmesi imzalandı         ↗
──────────────────────────────────────────────
Kaynak: KAP, Bürküt üzerinden · Günde bir kez güncellenir
```

- Varlık detay ekranında da o hissenin son 5 bildirimi gösterilir.
- Bildirimin tamamı için KAP linki tarayıcıda açılır. Link açmak için `url_launcher` paketi gerekir; bu **yeni bir paket**.

## Kurallar ve riskler

- **Yorum yok:** Bildirimler olduğu gibi gösterilir. "Olumlu/olumsuz" etiketi ya da yapay zekâ yorumu **kullanılmaz**, yatırım tavsiyesi sayılmaması için.
- **Saklama:** Bildirimler yerel veritabanında tutulur. Yeni bir tablo (`kap_disclosures`) ve **şema v3 migration** gerekir; şema değişikliği olduğu için onay gerekiyor.
- **Bürküt'ün şartı:** Seçenek D, gereksiz sık istek atmama şartına uyar (günde bir, sınırlı).
- **Belirsizlik:** `/kap` cevabının alan adları ve `summary`'nin ne sıklıkla boş geldiği zamanla değişebilir. Gerçek cevap örnekleri test verisi olarak tutulacak.
- **Fonlar:** Bu öneri sadece hisseler için. Fonların KAP bildirimleri de var (`kapLink` alanı), ama ayrı bir uç nokta gerekiyor ve kapsam dışı.

## Karar verilecekler

1. **Seçenek:** A, B, C ya da D (önerilen: D)?
2. **Üst sınır:** Günlük kaç hisse (önerilen: 10)?
3. **Link açma:** KAP linkleri için `url_launcher` paketi eklensin mi, yoksa bildirim metni sadece uygulama içinde mi gösterilsin?
4. ~~**Ayrı iyileştirme:** döviz ve madenler 60 dakikada bir mi?~~ **Karar verildi (2026-11-19):** tüm kategoriler 60 dakika.
