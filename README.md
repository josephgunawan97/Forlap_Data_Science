# Data Mahasiswa Seluruh Kopertis Wilayah III Tahun 2009-2018

Repositori ini berisi aplikasi Shiny untuk menunjukkan data mahasiswa di seluruh perguruan tinggi yang bernaung di bawah Koordinasi Perguruan Tinggi Swasta (Kopertis) wilayah III (DKI Jakarta dan sekitarnya) pada tahun 2009-2017 berdasarkan data yang tersedia di [Pangkalan Data Pendidikan Tinggi (PDDIKTI)](https://forlap.ristekdikti.go.id/).

Selain itu, aplikasi ini dapat **memprediksi** data mahasiswa angkatan tahun 2018, yang pada saat repo ini dibuat, belum didaftarkan ke dalam PDDIKTI.

## Dependensi
- R versi 3.4+
- Google Chrome
- Java versi 8+

## Instalasi
- Kloning repo ini, lalu `cd` ke direktori tempat repo ini dikloning
- Jalankan R (disarankan menggunakan RStudio)
- Instal beberapa _package_ yang dibutuhkan berikut:
  - `XML` dengan perintah `install.packages("XML")`
  - `rvest` dengan perintah `install.packages("rvest")`
  - `dplyr` dengan perintah `install.packages("dplyr")`
  - `tidyr` dengan perintah `install.packages("tidyr")`
  - `shiny` dengan perintah `install.packages("shiny")`
  - `ggplot2` dengan perintah `install.packages("ggplot2")`
  - `RSelenium` dengan perintah  
  ```
  install.packages("devtools")
  devtools::install_github("johndharrison/binman")
  devtools::install_github("johndharrison/wdman")
  devtools::install_github("ropensci/RSelenium")
  ```
- Jalankan skrip `WebScrap_Script.r` untuk melakukan _scraping_ pada situs web PDDIKTI sebagai sumber data. Hasilnya adalah sebuah CSV berjudul "MyData.csv".
- Jalankan skrip `Model_Script.r` untuk melatih data sehingga dapat memprediksi data mahasiswa tahun 2018 menggunakan data CSV yang didapatkan dari _scraping_.
- Jalankan app Shiny dari `RShiny_Script.r`.

## _Troubleshoot_
Jika skrip `WebScrap_Script.r` mengalami problem, atau data CSV tidak dapat diproses, gunakan dokumen `MyData.csv` yang terdapat pada repo ini sebagai masukan untuk pemodelan.  

## Cara kerja

### _Web scraping_
PDDIKTI tidak menyediakan API untuk mengambil data mahasiswa di dalamnya, sehingga kami harus melakukan _web scraping_ menggunakan R.

_Library_ yang digunakan adalah:
- RSelenium untuk otomatisasi peramban
- rvest dan XML untuk _web-scraping_
- dplyr untuk mengolah data ke dalam _data frame_.

Tahap yang dilakukan adalah:
- Menjalankan perintah otomatisasi peramban Google Chrome menggunakan RSelenium untuk mengambil data dari PDDIKTI.
- Membuka situs [Pencarian Data Perguruan Tinggi](https://forlap.ristekdikti.go.id/perguruantinggi) melalui RSelenium.
- Memulai pencarian
  - Memilih lingkup koordinasi Kopertis Wilayah III agar data yang didapat hanya berasal dari universitas di bawah Kopertis Wilayah III saja.
  - Mengisi _captcha_ (penjumlahan antar dua angka) untuk membuka pengaman
- Mengambil daftar perguruan tinggi
  - Mengambil jumlah laman yang menampilkan daftar perguruan tinggi
  - Mengambil seluruh tautan menuju laman informasi tiap perguruan tinggi
  - Menyimpan informasi tiap perguruan tinggi ke dalam _data frame_
- Mengambil daftar program studi (prodi) tiap perguruan tinggi
  - Membuka laman informasi tiap perguruan tinggi
  - Mengambil seluruh tautan menuju informasi tiap prodi dalam perguruan tinggi yang bersangkutan
  - Mengambil data jumlah mahasiswa tiap prodi tiap semester
- Mengolah data yang telah diambil ke dalam dokumen berformat CSV

### Pemodelan
Pemodelan dilakukan dengan cara merapikan data hasil _web-scraping_ terlebih dahulu menggunakan _library_ `tidyr`, kemudian melakukan prediksi untuk data tahun 2018.

Proses merapikan data ini dilakukan karena:
- Kolom semester dan tahun masih tergabung, padahal seharusnya dipisah.
- Masih banyak data numerik yang tersimpan sebagai tipe data _string_. - - Ada beberapa jurusan yang tutup di tengah jalan, sehingga tidak perlu dilakukan prediksi untuk jurusan-jurusan tersebut.

Sementara proses pemodelan dilakukan dengan:
- Mengambil nama semua jurusan dari tiap perguruan tinggi
- Membuat model linier dengan fungsi `lm()` untuk menentukan jumlah mahasiswa di tiap jurusan
- Melakukan prediksi dengan fungsi `predict()`

Setelah pemodelan selesai, data hasil prediksi digabungkan dengan data yang sudah rapi untuk ditampilkan dalam aplikasi Shiny

### Aplikasi Shiny

## Disklaim
Data PDDIKTI berasal dari pelaporan data perguruan tinggi, dan hanya digunakan untuk kepentingan akademis semata.

Aplikasi Shiny ini dibuat oleh Jessica Sean, Joseph Gunawan, dan Livia Andriana Lohanda untuk memenuhi tugas mata kuliah _Frontier Technology_ jurusan Teknik Informatika Universitas Pelita Harapan semester Akselerasi 2017/2018.