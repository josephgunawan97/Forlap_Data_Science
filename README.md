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
  - `devtools` dengan perintah `install.packages("devtools")`
  - `XML` dengan perintah `install.packages("XML")`
  - `rvest` dengan perintah `install.packages("rvest")`
  - `dplyr` dengan perintah `install.packages("dplyr")`
  - `tidyr` dengan perintah `install.packages("tidyr")`
  - `shiny` dengan perintah `install.packages("shiny")`
  - `plotly` dengan perintah `install.packages("plotly")`
  - `ggplot2` dengan perintah `devtools::install_github('hadley/ggplot2')`
  - `RSelenium` dengan perintah  
  ```
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
Pemodelan dilakukan dengan cara merapikan data hasil _web-scraping_ terlebih dahulu menggunakan _library_ `tidyr`, kemudian melakukan prediksi untuk data jumlah mahasiswa per jurusan tiap perguruan tinggi tahun 2018.

Proses merapikan data ini dilakukan karena:
- Kolom semester dan tahun masih tergabung, padahal seharusnya dipisah.
- Masih banyak data numerik yang tersimpan sebagai tipe data _string_.
- Ada beberapa jurusan yang tutup di tengah jalan, sehingga tidak perlu dilakukan prediksi untuk jurusan-jurusan tersebut.

Sementara proses pemodelan dilakukan dengan:
- Mengambil nama semua jurusan dari tiap perguruan tinggi
- Membuat model dengan fungsi `lm()` untuk menentukan jumlah mahasiswa di tiap jurusan tersebut
  - Model yang digunakan adalah **regresi linier sederhana**, yang memprediksi hasil variabel terikat sebagai fungsi linier _(y = Ax + B)_ dari variabel kontrol. Variabel kontrol dari pemodelan ini adalah Universitas, Jurusan, Semester dan Tahun.
  - Fungsi ini menerima dua argumen, yakni formula pemodelan dan sumber data `lm(VariabelTerikat ~ VariabelBebas, data=SumberData)`
  - Model ini menerima jumlah mahasiswa per jurusan sebagai variabel terikat, dengan variabel bebasnya mengambil seluruh variabel yang ada di _dataframe_ hasil _web-scraping_ yang telah dirapikan di tahap sebelumnya `lm(BanyakMahasiswa ~ ., data = HasilScraping)`.
  - Hasil model linier disimpan ke dalam sebuah variabel `model` untuk digunakan dalam prediksi di tahap selanjutnya
- Melakukan prediksi dengan fungsi `predict()`
  - Fungsi ini berfungsi untuk memprediksi data sesuai dengan model yang telah dibuat, menggunakan data baru sebagai variabel bebas `predict(model, dataBaru)`
  - Model diambil dari hasil regresi linier dari tahap sebelumnya
  - Variabel bebasnya adalah informasi nama jurusan dan nama perguruan tinggi yang (diasumsikan) masih aktif pada tahun 2018.
  - Hasil prediksi yang didapatkan adalah jumlah mahasiswa untuk setiap jurusan pada tahun 2018.
  
Setelah pemodelan selesai, data hasil prediksi digabungkan dengan data yang sudah rapi untuk ditampilkan dalam aplikasi Shiny

### Perhitungan Prediksi dengan Model Regresi
Perhitungan untuk memprediksi jumlah mahasiswa pada Univ W, Jurusan X, pada Semester Y Tahun Z dengan pemodelan regresi dapat direpresentasikan oleh rumus matematis sebagai berikut: <br />
<p align="center"> <b> y = A<sub>1</sub>x<sub>1</sub> + A<sub>2</sub>x<sub>2</sub> + A<sub>3</sub>x<sub>3</sub> + A<sub>4</sub>x<sub>4</sub> + B </b> </p>
<p>
dimana, <br/>
    * y    : nilai prediksi jumlah mahasiswa pada Univ W, Jurusan X, pada Semester Y Tahun Z. <br/>
    * A<sub>1</sub> : Koefisien dari Univ W <br/>
    * x<sub>1</sub>  : Nilai dari Univ W (1 jika tersedia, 0 jika tidak tersedia) <br/>
    * A<sub>2</sub> : Koefisien dari Jurusan X <br/>
    * x<sub>2</sub>  : Nilai dari Jurusan X (1 jika tersedia, 0 jika tidak tersedia) <br />
    * A<sub>3</sub> : Koefisien dari Semester Y <br/>
    * x<sub>3</sub>  : Nilai dari Semester Y (1 jika tersedia, 0 jika tidak tersedia) <br />
    * A<sub>4</sub> : Koefisien dari Tahun Z <br/>
    * x<sub>4</sub>  : Nilai Z (x<sub>4</sub>=2018 jika memprediksi tahun 2018) <br />
    * B    : nilai intercept <br /> 
    </p>
        
Pada R, nilai koefisien diperoleh dari `model$coefficients` yang merupakan hasil dari data training.
Berikut merupakan contoh dari kasus prediksi terhadap jumlah mahasiswa UPH Teknik Informatika pada tahun ajaran Ganjil 2018: </br>
<p align="center"> <b> y = A<sub>1</sub>x<sub>1</sub> + A<sub>2</sub>x<sub>2</sub> + A<sub>3</sub>x<sub>3</sub> + A<sub>4</sub>x<sub>4</sub> + B </b></p>
<p align="center"> y = (464.2822717 * 1) + (103.8972457 * 1) + (0 * 1) + (1.3210840 * 2018) </p>
<p align="center"> y = 584.984111 </p>
Berdasarkan perhitungan tersebut, prediksi mahasiswa Teknik Informatika UPH pada Ganjil 2018 adalah 584.984111 mahasiswa -> 585 mahasiswa.

### Aplikasi Shiny
Untuk visualisasi data, aplikasi kami membutuhkan tiga masukan untuk menampilkan informasi. Pengguna dapat mengubah masukan sesuai dengan kebutuhan pada _sidebar_ yang tersedia. Informasi akan langsung berubah setiap ada satu masukan yang diubah. Ketiga masukan tersebut adalah:
- Nama perguruan tinggi (`namaPT`)
- Jurusan (`namaProdi`)
- Tahun (`tahun`)

Informasi ditampilkan di kolom utama, terbagi dalam tiga tab. Satu tab memuat satu diagram batang. Ketiga diagram tersebut adalah:
- _Jumlah mahasiswa (nama perguruan tinggi) per tahun_ pada tab _Overview Tahunan_. Tabel ini membandingkan jumlah total mahasiswa dari seluruh jurusan dalam `namaPT` dari tahun ke tahun.
- _Jumlah mahasiswa (nama perguruan tinggi) jurusan (jurusan) per tahun_ pada tab _Overview Jurusan_. Tabel ini membandingkan jumlah mahasiswa di `jurusan` dari tahun ke tahun.
- _Jumlah mahasiswa (nama perguruan tinggi) per jurusan pada tahun (tahun)_ pada tab _Overview Jurusan/Tahun_. Tabel ini membandingkan jumlah mahasiswa yang masuk ke setiap jurusan pada `tahun`.

Karena setiap perguruan tinggi harus memperbarui data mereka setiap semester, informasi untuk satu tahun dibagi menjadi semester ganjil dan genap. Data semester genap ditandai dengan warna hijau toska, sementara data semester ganjil ditandai dengan warna merah salem. Selain itu, untuk kejelasan informasi yang ditunjukkan, pengguna juga dapat mengarahkan kursor ke tiap batang pada diagram untuk melihat dengan jelas data tersebut berasal dari semester berapa, tahun berapa, dan jumlah mahasiswa yang diwakilkan oleh batang tersebut.

## Saran pengembangan
- Desain antarmuka Shiny yang lebih efektif untuk menunjukkan data.
- Jika ada data jurusan aktif dari sebelum tahun 2018 yang belum dilaporkan ke PDDIKTI, gunakan prediksi untuk mengisi data yang hilang tersebut.

## Disklaim
Data PDDIKTI berasal dari pelaporan data perguruan tinggi, dan hanya digunakan untuk kepentingan akademis semata.

Aplikasi Shiny ini dibuat oleh Jessica Sean, Joseph Gunawan, dan Livia Andriana Lohanda untuk memenuhi tugas mata kuliah _Frontier Technology_ jurusan Teknik Informatika Universitas Pelita Harapan semester Akselerasi 2017/2018.
