# SportSpace

![alt text](image.png)


SportSpace adalah platform yang mempermudah penyewaan lapangan padel secara online. Awalnya berupa website, SportSpace kini dikembangkan menjadi aplikasi mobile agar pengguna dapat mencari dan memesan lapangan dengan lebih cepat dan praktis langsung dari smartphone.

Melalui aplikasi ini, pengguna dapat menelusuri berbagai lapangan padel di Jakarta tanpa perlu menghubungi pengelola secara manual. Aplikasi terhubung dengan web backend melalui API, sehingga informasi seperti daftar venue, fasilitas, harga, foto, dan jadwal ketersediaan selalu diperbarui secara real-time. Pengguna dapat melihat lokasi lapangan, mengecek jadwal yang tersedia, dan membaca detail venue sebelum melakukan pemesanan.

Setelah menemukan lapangan yang sesuai, pengguna cukup memilih tanggal dan waktu bermain, kemudian melakukan konfirmasi pemesanan. Pemesanan yang dilakukan akan tercatat dalam sistem dan dapat dikelola lebih lanjut oleh pengelola lapangan.

Pemilik lapangan tetap mengatur venue melalui dashboard web, mulai dari pembaruan jadwal hingga pengelolaan informasi venue. Admin bertugas memastikan seluruh data pengguna, venue, dan pemesanan tetap valid sehingga sistem berjalan dengan lancar.

Dengan hadirnya aplikasi mobile yang terhubung ke backend web, SportSpace membuat proses pencarian dan pemesanan lapangan padel menjadi lebih mudah, cepat, dan terorganisir. Platform ini diharapkan dapat turut mendorong perkembangan minat masyarakat terhadap olahraga padel yang semakin populer di Indonesia.

---


## Nama Anggota kelompok:
| NPM         | Nama Lengkap                              |
|-------------|-------------------------------------------|
| 2406401792  | Sean Marcello Maheron                     |
| 2406495426  | Philo Pradipta Adhi Satriya               |
| 2406351005  | Tasya Nabila Anggita Saragih              |
| 2406358636  | Fidel Akilah                              |
| 2406358794  | I Gusti Ngurah Agung Airlangga Putra      |

---

## Daftar modul yang diimplementasikan
- **Autentikasi dan Profil**  
  Dikerjakan oleh Sean Marcello Maheron.
  
  Modul ini menangani proses registrasi, login, dan manajemen akun pengguna. Pengguna dapat memperbarui profil seperti nama, foto, dan informasi kontak. Sistem juga mengatur hak akses berdasarkan jenis pengguna (admin, penyewa, pemilik venue). Selain pengaturan identitas dasar, modul ini juga memungkinkan pengguna untuk menambahkan teman serta saling mengirim pesan, sehingga interaksi antar pengguna dapat terjalin langsung melalui platform.

- **Panel Admin**  
  Dikerjakan oleh Sean Marcello Maheron.

  Modul Panel Admin menyediakan dashboard terpusat yang digunakan admin untuk mengelola seluruh data dalam sistem. Melalui panel ini, admin dapat memverifikasi akun pemilik venue serta memonitor aktivitas pada platform melalui tampilan yang ringkas dan informatif. Setiap fungsi disajikan dalam bentuk kontrol dan menu yang memudahkan admin meninjau data, melakukan penyesuaian, serta memastikan seluruh proses dalam platform berjalan dengan baik. Modul ini menjadi pusat kendali utama yang memberikan gambaran menyeluruh mengenai kondisi aplikasi.

- **Booking dan Jadwal**  
  Dikerjakan oleh I Gusti Ngurah Agung Airlangga Putra.

  Modul ini memungkinkan pengguna melakukan pemesanan lapangan berdasarkan tanggal dan waktu yang tersedia. Sistem akan menolak jadwal yang bentrok dan menampilkan status pemesanan (aktif, selesai, atau dibatalkan).

- **Review**  
  Dikerjakan oleh Tasya Nabila Anggita Saragih.

  Modul ini memungkinkan pengguna memberikan ulasan dan rating setelah bermain di lapangan padel. Ulasan ini dapat membantu pengguna lain dalam memilih venue terbaik.

- **Lapangan & Halaman Utama**  
    Dikerjakan oleh Fidel Akilah.

    Modul ini menampilkan daftar lapangan padel berdasarkan daerah yang dipilih pengguna. Lokasi lapangan ditampilkan melalui integrasi Google Maps API untuk memberikan gambaran posisi venue secara visual. Setiap lapangan terhubung langsung dengan fitur booking dan review, sehingga pengguna dapat melihat ketersediaan jadwal serta ulasan dari pemain lain sebelum melakukan pemesanan. Data lapangan dikelola oleh pemilik melalui dashboard web, termasuk pembaruan harga, fasilitas, dan foto, yang kemudian tersinkron otomatis ke aplikasi.

- **Matchmaking**
 
    Dikerjakan oleh Philo Pradipta Adhi Satriya.

    Modul matchmaking memungkinkan pengguna membuat sebuah match yang terbuka untuk diikuti pemain lain. Pengguna dapat menentukan jenis permainan seperti 1v1, 2v2, atau 4v4, kemudian pemain lain dapat melihat match yang tersedia dan bergabung sesuai kebutuhan slot. Setiap match menampilkan informasi dasar seperti daerah dan format permainan, sehingga pengguna dapat memilih match yang sesuai sebelum bergabung. Modul ini berfungsi sebagai wadah untuk mempertemukan pemain padel yang ingin bermain bersama dalam format yang mereka inginkan.
---

## Timeline Pengerjaan SportSpace Mobile App

### Pekan 1 (17–24 November 2025)
- **I Gusti**: Menyelesaikan design authentication dan booking system pada Figma  
- **Tasya**: Menginisiasi Flutter project, membuat design fitur review  
- **Fidel**: Membuat deskripsi GitHub  
- **Sean**: Membuat design dashboard admin dan profile pada Figma  
- **Philo**: Menyelesaikan forms dan input elements  

### Pekan 2 (24 November – 1 Desember 2025)
- **I Gusti**: Mengimplementasikan Flutter design untuk booking system  
- **Tasya**: Membuat API untuk fitur review  
- **Fidel**: Membuat API untuk fitur lapangan  
- **Sean**: Membuat API untuk fitur autentikasi, admin, dan profile  
- **Philo**: Membuat API untuk fitur matchmaking  

### Pekan 3 (1–7 Desember 2025)
- **I Gusti**: Membuat API untuk booking system  
- **Tasya**: Membuat halaman My Review pada Flutter dan mengintegrasikannya dengan Django  
- **Fidel**: Membuat halaman utama pada Flutter  
- **Sean**: Membuat halaman dashboard admin dan halaman profile  
- **Philo**: Membuat halaman matchmaking pada Flutter  

### Pekan 4 (7–14 Desember 2025)
- **I Gusti**: Integrasi Django dengan Flutter untuk fitur booking  
- **Tasya**: Membuat halaman review lapangan pada Flutter dan mengintegrasikannya dengan Django  
- **Fidel**: Integrasi Django dengan Flutter untuk fitur lapangan  
- **Sean**: Integrasi Django dengan Flutter untuk fitur autentikasi, admin, dan profile  
- **Philo**: Integrasi Django dengan Flutter untuk fitur matchmaking  

### Pekan 5 (14–21 Desember 2025)
- **I Gusti**: Finalisasi dan unit testing  
- **Tasya**: Unit testing untuk fitur review  
- **Fidel**: Unit testing untuk fitur lapangan  
- **Sean**: Unit testing untuk autentikasi, admin, dan profile  
- **Philo**: Unit testing untuk fitur matchmaking  

---
## Jenis Pengguna dan Perannya

Website penyewaan lapangan padel ini memiliki tiga jenis pengguna utama: **Admin**, **Penyewa (User)**.  

### 1. **Admin**
**Peran:**  
Admin bertanggung jawab atas pengelolaan dan pengawasan seluruh aktivitas di dalam sistem. Mereka memiliki akses penuh untuk memantau data pengguna, venue, dan aktivitas booking.

**Tugas dan Hak Akses:**
- Mengelola data pengguna (menonaktifkan atau menghapus akun).  
- Mengelola aktivitas penyewaan.  
- Mengelola semua venua yang terdaftar di aplikasi.  

### 2. **Penyewa (User)**
**Peran:**  
Penyewa adalah pengguna umum yang menggunakan website untuk mencari dan menyewa lapangan padel.

**Tugas dan Hak Akses:** 
- Melihat detail venue (lokasi, harga, dan jadwal ketersediaan).  
- Melakukan pemesanan (booking).
- Melihat status serta riwayat pemesanan.  
- Memberikan ulasan dan rating setelah bermain.  
- Membuat match yang bisa diikuti pengguna lain.
- Mengubah profile dan menambahkan teman.

---

## Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web: 
Aplikasi mobile SportSpace terhubung dengan backend Django melalui pertukaran data JSON menggunakan protokol HTTP. Berikut adalah mekanisme utamanya:

REST API pada Django: Kami membuat endpoint URL khusus di Django yang mengembalikan data dalam format JSON (bukan HTML) agar dapat dibaca oleh aplikasi mobile.

Model & Fetch Data (GET): Flutter mengambil data dari endpoint tersebut menggunakan request HTTP secara asynchronous, lalu melakukan parsing dari format JSON menjadi objek Model Dart untuk ditampilkan di antarmuka.

Pengiriman Data (POST): Input pengguna (seperti login, register, atau booking lapangan) dikirim dari Flutter ke server Django menggunakan method POST untuk diproses dan disimpan ke database.

Autentikasi: Kami memanfaatkan package pbp_django_auth untuk menangani manajemen sesi, cookie, dan keamanan akses pengguna antara aplikasi mobile dan server.

## Link Figma:
https://www.figma.com/design/l9BHzrt0pbzk2A2LmNuljg/SportSpace?node-id=36-8&p=f&t=gkVS2c8acblkHXDI-0

password = sportshopiscool
