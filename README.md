## Identitas Mahawiswa

| Info | Detail |
| --- | --- |
| Nama | Maria Euhrasia Ardynati |
| NIM | 1123150050 |
| Kelas | TISE23M |
| Mata Kuliah | KB1154 - Aplikasi Mobile Lanjutan |

## 📱 Dompet Digital
*MUU Wallet* adalah aplikasi dompet digital yang dirancang untuk memberikan kemudahan dalam melakukan berbagai transaksi pembayaran secara aman dan efisien. Aplikasi ini memungkinkan pengguna melakukan pengisian saldo (Top Up), transfer saldo antar pengguna, serta pembayaran transaksi pada aplikasi e-commerce penjualan tas dengan proses yang cepat dan praktis.

Untuk meningkatkan keamanan setiap transaksi, MOO Wallet dilengkapi dengan fitur Autentikasi Dua Langkah (2FA) menggunakan Google Authenticator (TOTP). Selain itu, aplikasi ini juga mendukung integrasi Deep Link, sehingga proses pembayaran dari aplikasi e-commerce dapat dilakukan secara langsung tanpa perlu berpindah aplikasi secara manual, memberikan pengalaman transaksi yang lebih nyaman dan efisien.


## 📱 Bag Store
*BagStore* adalah aplikasi e-commerce yang dirancang untuk memudahkan pengguna dalam berbelanja berbagai koleksi tas secara online dengan tampilan antarmuka yang modern, menarik, dan mudah digunakan. Aplikasi ini memungkinkan pengguna untuk menjelajahi katalog produk, melihat detail tas, menambahkan produk ke keranjang, mengelola pesanan, hingga melakukan pembayaran dengan proses yang cepat dan praktis.

Aplikasi ini telah terintegrasi dengan MUU Wallet melalui fitur *Deep Link Payment*, sehingga pengguna dapat melakukan pembayaran secara langsung menggunakan dompet digital tanpa harus memasukkan data pembayaran secara manual. Dengan desain UI yang responsif dan pengalaman pengguna yang intuitif, BagStore memberikan proses berbelanja yang lebih mudah, aman, dan nyaman.

---

## 🔗 Project Terkait

Berikut merupakan repository yang saling terhubung dalam pengembangan sistem, mulai dari backend hingga aplikasi mobile.

| **Project**             | **Repository GitHub**                                      |
| ----------------------- | ---------------------------------------------------------- |
| Backend E-Commerce Tas  | https://github.com/Mariariaardyanti/mycatalog-be.git |
| Aplikasi E-Commerce Tas | https://github.com/Mariariaardyanti/UAS_SEM6.git  |
| Backend MOO Wallet      | https://github.com/Mariariaardyanti/be-emoney.git      |
| Aplikasi MOO Wallet     | https://github.com/Mariariaardyanti/dompet_digital.git   |

---

## 🏗️ Arsitektur Aplikasi Dompet Muu
Aplikasi ini dikembangkan menggunakan pendekatan **Clean Architecture** untuk menghasilkan struktur kode yang lebih terorganisir, mudah dipelihara, dan fleksibel ketika dilakukan pengembangan fitur baru. Arsitektur aplikasi dibagi menjadi tiga lapisan utama yang memiliki tanggung jawab masing-masing.

1. **Domain Layer (`lib/domain/`)**
   Merupakan lapisan inti yang berisi aturan bisnis utama (*business logic*) dan tidak bergantung pada framework maupun library eksternal.
    - **Entities** → Merepresentasikan objek atau model bisnis utama, seperti `UserEntity` dan `AccountEntity`.
    - **Repository Interface** → Mendefinisikan kontrak yang akan diimplementasikan pada Data Layer.
    - **Use Cases** → Berisi logika bisnis aplikasi, seperti `TopUpUseCase`, `TransferUseCase`, dan `DeepLinkPaymentUseCase`.

2. **Data Layer (`lib/data/`)**
   Layer ini bertugas mengelola seluruh sumber data yang digunakan aplikasi, baik yang berasal dari API maupun penyimpanan lokal.
    - **Data Sources** → Menghubungkan aplikasi dengan REST API menggunakan **Dio**, serta mengelola penyimpanan lokal menggunakan **FlutterSecureStorage** dan **SharedPreferences**.
    - **Repository Implementation** → Implementasi dari repository yang telah didefinisikan pada Domain Layer.


3. **Presentation Layer (`lib/presentation/`)**
   Layer yang bertanggung jawab terhadap tampilan aplikasi serta interaksi pengguna.
    - **BLoC** → Digunakan sebagai *state management* untuk mengatur alur data dan logika tampilan, seperti `AuthBloc` dan `PaymentBloc`.
    - **Pages** → Berisi halaman-halaman utama yang ditampilkan kepada pengguna.
    - **Widgets** → Kumpulan komponen antarmuka (*reusable widgets*) yang dapat digunakan kembali pada berbagai halaman.


## 🏗️ Arsitektur Aplikasi Bag Store

Aplikasi **BagStore** dikembangkan menggunakan pendekatan **Feature-Based Architecture** yang dipadukan dengan pemisahan modul pada setiap fitur. Struktur ini bertujuan agar pengembangan aplikasi menjadi lebih terorganisir, mudah dipelihara, serta memudahkan penambahan fitur baru di masa mendatang.

### Core (`lib/core/`)

Folder **Core** berisi berbagai komponen yang digunakan secara global oleh seluruh fitur dalam aplikasi.

Beberapa modul yang terdapat pada folder ini antara lain:

- **Constants (`core/constants/`)**
  - Menyimpan konstanta aplikasi seperti konfigurasi API, warna aplikasi, dan kumpulan string.

- **Providers (`core/providers/`)**
  - Berisi provider global, seperti pengaturan tema aplikasi (`ThemeProvider`).

- **Routes (`core/routes/`)**
  - Mengatur navigasi antar halaman menggunakan **Go Router**.

- **Services (`core/services/`)**
  - Menangani berbagai layanan aplikasi, seperti:
    - Komunikasi dengan REST API menggunakan **Dio**
    - Penyimpanan data menggunakan **Secure Storage**
    - Layanan notifikasi
    - Autentikasi biometrik
    - Integrasi layanan pembayaran

- **Theme (`core/theme/`)**
  - Mengelola tema, warna, dan tampilan visual aplikasi.

- **Widgets (`core/widgets/`)**
  - Berisi kumpulan widget yang dapat digunakan kembali pada berbagai halaman aplikasi.

---

### Features (`lib/features/`)

Seluruh fitur utama aplikasi dikelompokkan ke dalam folder **Features** sehingga setiap modul memiliki tanggung jawab yang jelas dan lebih mudah dikembangkan.

Fitur yang tersedia meliputi:

- **Auth**
  - Mengelola proses autentikasi pengguna, seperti login, registrasi, dan verifikasi akun.

- **Dashboard**
  - Menampilkan halaman utama yang berisi katalog produk, promo, serta informasi penting lainnya.

- **Cart**
  - Mengelola keranjang belanja, mulai dari menambah, mengubah jumlah, hingga menghapus produk.

- **Favorite**
  - Menyimpan daftar produk favorit agar mudah diakses kembali oleh pengguna.

- **Order**
  - Mengelola proses checkout, pembayaran, serta riwayat transaksi pembelian.

- **Profile**
  - Menampilkan informasi pengguna serta pengaturan akun.

---

### Teknologi yang Digunakan

Beberapa teknologi yang digunakan dalam pengembangan aplikasi antara lain:

- **Flutter** sebagai framework utama.
- **Go Router** untuk navigasi halaman.
- **Provider** sebagai state management global.
- **Dio** untuk komunikasi dengan REST API.
- **Flutter Secure Storage** untuk menyimpan data sensitif.
- **Biometric Authentication** untuk meningkatkan keamanan pengguna.
- **Firebase Cloud Messaging (FCM)** untuk layanan notifikasi.
- **Deep Link** untuk mendukung proses pembayaran yang terintegrasi dengan aplikasi dompet digital.

