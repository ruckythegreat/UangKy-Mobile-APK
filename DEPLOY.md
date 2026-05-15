# Deploy UangKy (GitHub + Vercel + APK Google Drive)

Panduan singkat supaya repo bisa dipush ke **GitHub**, lalu **Vercel** menayangkan **Flutter Web**, dengan tombol unduh **APK lewat Google Drive** (bukan Play Store).

---

## 1. Yang sudah disiapkan di kode

| Bagian | Isi |
|--------|-----|
| `lib/config/download_urls.dart` | ID file Drive & URL unduhan langsung + halaman view. |
| `lib/app.dart` | `openUangKyApkDirectDownload()` dan `openUangKyApkInDrive()`. |
| Banner web & Pengaturan (web) | Tombol **Unduh APK** / **Drive** mengarah ke Drive. |
| `vercel.json` | Rewrite SPA agar refresh di path Flutter tidak 404. |
| `.github/workflows/deploy-vercel.yml` | Build `flutter build web` lalu deploy folder `build/web` ke Vercel production. |

Ganti file APK di Drive? **Upload file baru**, lalu ganti **`_apkDriveFileId`** di `download_urls.dart` dengan ID file yang baru (dari URL `.../file/d/ID_AKHIR/...`).

---

## 2. Push ke GitHub

1. Buat repo kosong di GitHub (mis. `uangky`).
2. Di folder project lokal:

```bash
git init
git remote add origin https://github.com/USERNAME/uangky.git
git add .
git commit -m "Initial UangKy web + deploy"
git branch -M main
git push -u origin main
```

(Sesuaikan URL remote dan nama branch `main` / `master` — workflow mendukung keduanya.)

---

## 3. Akun & project Vercel

1. Login di [vercel.com](https://vercel.com) (bisa pakai akun GitHub).
2. **Buat project baru** (Add New → Project).  
   - Boleh **tanpa** import GitHub untuk auto-build Flutter (kita pakai GitHub Actions, bukan build di dashboard Vercel).
3. Setelah project ada, buka **Settings → General**:
   - salin **Project ID**
4. Buka **Settings → Team** (atau URL tim): salin **Team ID** (dipakai sebagai `VERCEL_ORG_ID` di GitHub — nama field Vercel memang membingungkan, isinya ID tim/proyek dari dashboard).

5. Buat **token deploy**:
   - [Vercel Account → Tokens](https://vercel.com/account/tokens) → Create → salin **VERCEL_TOKEN**.

---

## 4. Secrets di GitHub (wajib untuk workflow)

Di repo GitHub: **Settings → Secrets and variables → Actions → New repository secret**

| Nama secret | Isi |
|--------------|-----|
| `VERCEL_TOKEN` | Token dari langkah 3.5 |
| `VERCEL_ORG_ID` | Team ID (dari Settings tim / `.vercel/project.json` setelah `vercel link`) |
| `VERCEL_PROJECT_ID` | Project ID dari halaman project |

Tanpa ketiga secret ini, workflow **Deploy Web to Vercel** akan gagal.

---

## 5. Cara kerja deploy

- Setiap **push** ke branch **`main`** atau **`master`**, workflow:
  1. `flutter pub get`
  2. `flutter build web --release`
  3. Menyalin `vercel.json` ke `build/web/`
  4. Deploy `build/web` ke Vercel **production** (`--prod`).

Domain production mengikuti pengaturan project di Vercel (mis. `uangky.vercel.app` atau custom domain).

---

## 6. Deploy manual (tanpa Actions)

Jika belum mau pakai GitHub Actions:

```bash
flutter pub get
flutter build web --release
cp vercel.json build/web/vercel.json
cd build/web
npx vercel login
npx vercel link    # pilih tim & project yang sama dengan secrets di atas
npx vercel --prod
```

---

## 7. APK Google Drive & pengguna

- Tombol **Unduh APK** memakai link `uc?export=download&id=...`.  
- Untuk file besar, Google kadang menampilkan **peringatan virus scan** — user bisa pakai tombol **Drive** lalu unduh dari halaman Drive.
- Pastikan file Drive **“Anyone with the link”** bisa **Viewer** minimal (agar unduhan tidak ditolak untuk publik).

---

## 8. Opsional: hubungkan domain sendiri

Di Vercel project → **Settings → Domains** → tambah domain kamu → ikuti instruksi DNS dari Vercel.

---

## 9. Troubleshooting

| Gejala | Cek |
|--------|-----|
| Workflow gagal “secret not found” | Pastikan nama secret persis `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`. |
| Web putih / 404 setelah refresh | Pastikan `vercel.json` ikut ter-copy ke `build/web` (sudah di workflow). |
| Unduh APK tidak jalan | Cek sharing file Drive & ID file di `download_urls.dart`. |

---

## 10. Catatan README lama

Beberapa bagian README mungkin menyebut **IndexedStack** untuk tab — implementasi terbaru memakai **satu tab aktif** (lebih ringan). Abaikan referensi IndexedStack jika masih terlihat di dokumentasi lama.
