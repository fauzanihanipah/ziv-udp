# Skrip Manajemen Zivpn UDP

Selamat datang di Skrip Manajemen Zivpn UDP! Alat ini dirancang untuk menyederhanakan instalasi, konfigurasi, dan pengelolaan layanan Zivpn UDP di server Debian atau Ubuntu Anda.

## ✨ Fitur Utama

- **Instalasi Otomatis**: Cukup jalankan satu perintah untuk menginstal layanan Zivpn, dependensi, dan semua skrip manajemen.
- **Menu Interaktif**: Antarmuka berbasis menu yang mudah digunakan untuk mengelola pengguna, melihat informasi, dan lainnya.
- **Manajemen Pengguna Lengkap**: Tambah, hapus, dan lihat pengguna reguler dan percobaan langsung dari menu.
- **Pembersihan Otomatis**: Pengguna yang kedaluwarsa secara otomatis dihapus.
- **Penghapusan "Instan"**: Akun yang kedaluwarsa (baik reguler maupun trial) akan dihapus secara otomatis dalam satu menit setelah waktunya habis.
- **Uninstaller Lengkap**: Satu perintah untuk menghapus Zivpn dan semua komponennya dari sistem Anda.
- **Dukungan Multi-Arsitektur**: Bekerja pada server AMD64 (x86_64) dan ARM64.

## 🚀 Instalasi

Untuk menginstal, cukup salin dan jalankan perintah yang sesuai dengan arsitektur server Anda.

### AMD64 (x86_64)
```bash
sudo wget -O /usr/local/bin/zi.sh https://raw.githubusercontent.com/roodyzain99/udp-zivpn/main/zi.sh && sudo chmod +x /usr/local/bin/zi.sh && sudo zi.sh
```

### ARM64
```bash
sudo wget -O /usr/local/bin/zi2.sh https://raw.githubusercontent.com/roodyzain99/udp-zivpn/main/zi2.sh && sudo chmod +x /usr/local/bin/zi2.sh && sudo zi2.sh
```

## 🛠️ Penggunaan

Setelah instalasi selesai, Anda dapat mengakses menu manajemen kapan saja dengan menjalankan perintah berikut:

```bash
zivpn
```

Dari menu ini, Anda dapat mengelola semua aspek layanan Zivpn Anda.

## 🗑️ Uninstall

Jika Anda ingin menghapus Zivpn dari server Anda, Anda dapat melakukannya melalui menu atau dengan menjalankan perintah berikut secara langsung:

```bash
uninstall.sh
```

Skrip uninstal akan meminta konfirmasi sebelum menghapus semua file, layanan, dan aturan firewall yang terkait dengan Zivpn.
