# POS Modern UI/UX Direction

## Tujuan

Membuat layar kasir tablet yang cepat dipindai, mudah disentuh, dan terlihat seperti produk operasional modern, bukan dashboard generik.

Prioritas desain:

1. Kecepatan memilih menu.
2. Keranjang selalu terlihat.
3. Aksi pembayaran mudah ditemukan.
4. Informasi penting memiliki kontras jelas.
5. Tampilan tetap tenang saat antrean ramai.

## Referensi Riset

Referensi dibaca pada 22 September 2026:

- Material 3 Navigation Rail: https://m3.material.io/components/navigation-rail/overview
- Material 3 Cards: https://m3.material.io/components/cards/overview
- Figma Community search untuk pola POS: https://www.figma.com/community/search?query=pos%20ui
- Square POS product patterns: https://squareup.com/us/en/point-of-sale
- Shopify POS product patterns: https://www.shopify.com/pos
- Lightspeed POS product patterns: https://www.lightspeedhq.com/pos/

Beberapa halaman vendor memakai JavaScript atau membatasi crawling. Referensi digunakan untuk pola interaksi dan struktur produk, bukan menyalin aset atau layout.

## Pola yang Diambil

### 1. Katalog sebagai pusat layar

POS modern menempatkan product catalog sebagai area kerja utama. Search, kategori, dan menu populer berada di area yang sama sehingga kasir tidak berpindah halaman.

### 2. Cart sebagai checkout rail

Cart dipertahankan di sisi kanan pada tablet landscape. Total dan tombol pembayaran berada di footer panel yang stabil.

### 3. Navigation rail ringkas

Navigation rail memakai icon line yang konsisten. Label tidak menjadi fokus utama. State aktif menggunakan surface solid dengan warna aksen agar mudah ditemukan.

### 4. Hierarki surface rendah

Gunakan canvas netral, surface putih, border tipis, dan shadow sangat ringan. Hindari banyak kartu bertumpuk yang membuat layar seperti template dashboard.

### 5. Touch target besar

Target sentuh minimum 44-48 px. Tombol tambah produk tidak tersembunyi pada hover karena tablet tidak memiliki hover yang dapat diandalkan.

### 6. Status operasional ringkas

Status online, kasir aktif, dan jumlah item ditampilkan sebagai metadata kecil. Status tidak boleh mengambil perhatian dari order.

## Arah Visual

### Warna

```text
Canvas       #F6F6F3
Surface      #FFFFFF
Ink          #24221F
Muted        #77736D
Line         #E6E4DF
Espresso     #3B2A22
Espresso 2   #65483A
Sage         #4E8163
Sage Soft    #E7F0E9
Warm Soft    #F1EEE8
Danger       #B94A43
```

Espresso hanya digunakan untuk selected navigation, primary action, dan emphasis. Sage hanya digunakan untuk status sehat/online. Jangan memberi warna berbeda pada setiap kategori menu.

### Tipografi

- Header: 24 px, weight 700.
- Section title: 19 px, weight 700.
- Product name: 14-15 px, weight 700.
- Product price: 13 px, weight 600.
- Metadata: 12 px, weight 500-600.

Gunakan satu sans-serif system font. Konsistensi hierarchy lebih penting daripada menambah font eksternal.

### Spacing

Gunakan kelipatan 4 dengan ritme utama 8:

```text
4   micro gap
8   icon/text gap
12  compact control
16  card gap
24  panel padding
32  page padding
```

## Layout Tablet

```text
┌────────┬─────────────────────────────────────────┬───────────────┐
│ Rail   │ Header                                  │               │
│  92px  ├─────────────────────────────────────────┤               │
│        │ Search                                  │               │
│        │ Category tabs                           │ Cart 356px     │
│        │ Product grid                            │ fixed pane     │
│        │                                         │               │
└────────┴─────────────────────────────────────────┴───────────────┘
```

Main content memakai grid adaptif. Cart tidak ikut menyusut menjadi kartu kecil karena cart adalah bagian dari alur pembayaran.

## Product Card

Struktur:

```text
┌──────────────────┐
│                  │
│  product visual  │  4:3, muted warm surface
│              (+) │  explicit add action
├──────────────────┤
│ Product name     │
│ Rp price         │
└──────────────────┘
```

Emoji hanya placeholder tahap awal. Asset produk nyata sebaiknya memakai foto konsisten dengan rasio yang sama.

## Cart Panel

Empty state harus menjelaskan tindakan berikutnya, bukan hanya menyatakan kosong.

Populated state:

- Nama item dan total baris.
- Stepper quantity inline.
- Hapus seluruh cart melalui icon.
- Total selalu berada di bawah.
- CTA pembayaran full width dengan tinggi minimal 56 px.

## Iconography

Gunakan Material Symbols/Icons outlined untuk navigasi dan aksi:

```text
point_of_sale_outlined
receipt_long_outlined
inventory_2_outlined
bar_chart_outlined
settings_outlined
search
tune
add
delete_outline
shopping_bag_outlined
wifi
```

Icon tidak digunakan sebagai dekorasi tanpa fungsi. Setiap icon action memiliki tooltip atau label yang dapat dipahami.

## Responsiveness

- Target utama: Huawei Pad landscape.
- Preview desktop: layout penuh.
- Lebar sempit: cart dapat berubah menjadi bottom sheet pada fase berikutnya.
- Jangan memaksa layout tablet ke mobile tanpa aturan breakpoint.

## Yang Sengaja Dihindari

- Gradient dekoratif.
- Banyak warna aksen.
- Glassmorphism.
- Kartu statistik di layar kasir.
- Icon filled bercampur dengan icon outlined.
- Tombol primary kecil.
- Placeholder text tanpa instruksi.
- Search field yang tampil tetapi tidak memiliki rencana integrasi.

## Acceptance Criteria Visual

1. Kasir dapat menemukan menu populer tanpa scroll vertikal panjang.
2. Cart tetap terlihat saat katalog digulir.
3. Tombol tambah dapat disentuh tanpa target presisi kecil.
4. Active category dan navigation terlihat jelas tanpa checkmark tambahan.
5. Total dan pembayaran menjadi area paling kuat di cart.
6. UI tidak bergantung pada hover.
7. Empty state membantu kasir melanjutkan tindakan.
8. Warna, radius, spacing, dan icon konsisten di semua layar kasir.
