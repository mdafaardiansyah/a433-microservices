# Menggunakan Node.js versi 14
FROM node:14

WORKDIR /app

COPY . .

ENV NODE_ENV=production DB_HOST=item-db

RUN npm install --production --unsafe-perm && npm run build

# Memberitahu Docker bahwa aplikasi akan menggunakan port 8080
EXPOSE 8080

# Perintah untuk menjalankan server saat container diluncurkan
CMD ["npm", "start"]