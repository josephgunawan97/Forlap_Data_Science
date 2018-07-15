# Data Mahasiswa Seluruh Kopertis Wilayah III

Repo ini berisi aplikasi Shiny untuk menunjukkan data mahasiswa di seluruh perguruan tinggi yang bernaung di bawah Koordinasi Perguruan Tinggi Swasta (Kopertis) wilayah III (DKI Jakarta dan sekitarnya) berdasarkan data yang tersedia di [Pangkalan Data Pendidikan Tinggi (PDDIKTI)](https://forlap.ristekdikti.go.id/).

Selain itu, aplikasi ini dapat **memprediksi** data mahasiswa angkatan tahun 2018, yang pada saat repo ini dibuat, belum didaftarkan ke dalam PDDIKTI.

## Dependensi
- R versi 3.5+
- Google Chrome

## Instalasi
- Kloning repo ini, lalu `cd` ke direktori tempat repo ini dikloning
- Jalankan R (disarankan menggunakan RStudio)
- Instal beberapa _package_ yang dibutuhkan berikut:
  - `devtools` dengan perintah `install.packages("devtools")`
  - `binman` dengan perintah `devtools::install_github("johndharrison/binman")`
  - `wdman` dengan perintah `devtools::install_github("johndharrison/wdman")`
  - `RSelenium` dengan perintah `devtools::install_github("ropensci/RSelenium")`
  - 
- Jalankan skrip `WebScrap_Script.r` untuk melakukan _scraping_ pada situs web PDDIKTI sebagai sumber data. Hasilnya adalah sebuah CSV berjudul "MyData.csv".
- Jalankan skrip `Model_Script.r` untuk melatih data sehingga dapat memprediksi data mahasiswa tahun 2018 menggunakan data CSV yang didapatkan dari _scraping_.
- Jalankan app Shiny dari `RShiny_Script.r`.

## Cara kerja _scraping_
PDDIKTI tidak menyediakan API untuk mengambil data mahasiswa di dalamnya, sehingga kami harus melakukan _web scraping_ menggunakan R. Tahap yang dilakukan adalah
- Menjalankan perintah automatisasi peramban Google Chrome menggunakan RSelenium untuk mengambil data dari PDDIKTI.
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