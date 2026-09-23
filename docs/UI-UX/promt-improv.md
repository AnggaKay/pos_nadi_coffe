UI/UX STRUCTURAL BLUEPRINT: SPATIAL POINT OF SALE

1. Canvas & Viewport (Base Layer)

Background: Gunakan warna solid cool gray (#F4F5F7) sebagai base canvas. Jangan gunakan putih murni. Layar ini akan menjadi "meja" tempat komponen UI mengambang.

Layout Wrapper: Set padding: 24px di seluruh sisi layar (Top, Right, Bottom, Left). Tidak ada elemen UI yang boleh menyentuh ujung layar secara langsung.

2. Floating Navigation Dock (Menggantikan Left Sidebar)

Structure: Alih-alih sidebar setinggi layar penuh, buat sebuah vertical pill container yang mengambang di sisi kiri.

Dimensions: Width: 80px, Height: fit-content (hanya setinggi jumlah menu), diletakkan dengan align-items: center secara vertikal di tengah layar (vertical center).

Styling: Background putih (#FFFFFF), border-radius: 40px, dengan soft shadow (blur: 24px, Y: 8px, opacity: 4%).

Interactions: Hapus teks label pada default state. Gunakan icon-only dengan Tooltip yang muncul pada Hover state. Active state menggunakan circular background fill dengan warna kontras gelap (misal: #1A1A1A).

3. Asymmetric Main Content (Area Tengah)

Container: Buat satu surface container besar dengan border-radius: 24px, background putih (#FFFFFF), membentang dari sebelah Navigation Dock hingga ke batas Cart Pane.

Header Section (Inside Container): Hapus top bar yang membentang dari ujung ke ujung. Ganti dengan inline header di dalam container utama.

Greeting ("Kasir") diletakkan di kiri atas dengan ukuran teks Heading/H3.

Category Filter tidak lagi berupa outline button. Gunakan Segmented Control bergaya iOS atau pill tabs dengan sliding animation background saat berpindah kategori.

Grid Layout: Terapkan CSS Grid atau Figma Auto Layout (Wrap). Kurangi padding internal card produk. Fokuskan pada thumbnail gambar yang lebih besar (porsi 70% gambar, 30% teks harga/nama) tanpa border sama sekali (borderless cards), hanya mengandalkan proximity dan whitespace.

4. Detached Cart Pane (Area Kanan)

Structure: Lepaskan keranjang dari sisi kanan layar. Buat menjadi Floating Side-Panel.

Dimensions: Lebar statis 360px, tinggi 100% dikurangi padding layar (calc(100vh - 48px)).

Styling: Terapkan efek Glassmorphism halus (background putih dengan opacity 90% dan backdrop-filter: blur(16px)). border-radius: 24px. Berikan border 1px solid putih transparan untuk efek glossy edge.

Top Action: Pindahkan indikator "Online" dan "Profile Avatar" ke dalam panel kanan ini di bagian paling atas, menjadi satu grup dengan judul "Pesanan Baru".

Order List Area: Gunakan scrollable area tanpa scrollbar visual.

Bottom Action (Checkout): Jangan gunakan garis divider biasa. Buat Floating Action Bar di bagian paling bawah panel ini. Total harga diletakkan sejajar secara horizontal (menggunakan justify-content: space-between) dengan tombol Checkout yang berbentuk kapsul (border-radius: 99px), berwarna dark solid (hitam atau charcoal).