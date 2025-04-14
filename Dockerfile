# Menggunakan Node.js versi 14 sebagai image dasar
FROM node:14

# Menetapkan direktori kerja di dalam container menjadi /app
WORKDIR /app

# Menyalin semua kode sumber ke direktori kerja
COPY . .

# Mengatur variabel lingkungan untuk mode produksi dan host database
ENV NODE_ENV=production DB_HOST=item-db

# Menginstal dependensi untuk produksi dan membangun aplikasi
RUN npm install --production --unsafe-perm && npm run build

# Memberitahu Docker bahwa aplikasi akan menggunakan port 8080
EXPOSE 8080

# Perintah untuk menjalankan server saat container diluncurkan
CMD ["npm", "start"]