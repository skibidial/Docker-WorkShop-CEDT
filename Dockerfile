# syntax=docker/dockerfile:1.7

# Stage 1: Builder
# TODO(step-4a): ใช้ node:20.11-slim และตั้งชื่อ stage ว่า builder
FROM node:20.11-slim AS builder
WORKDIR /app

# TODO(step-4b): ก๊อปปี้ package.json จาก app/ และรัน npm ci
COPY app/package*.json ./
RUN npm ci --omit=dev

# TODO(step-4c): ก๊อปปี้ไฟล์โค้ดทั้งหมดจาก app/ เข้ามาใน /app ของ container
COPY app/ ./

# Stage 2: Runtime
# TODO(step-4d): ใช้ base image ตัวเดียวกับข้างบน
FROM node:20.11-slim
WORKDIR /app

# TODO(step-4e): ก๊อปปี้ผลลัพธ์จาก stage builder มาที่ stage ปัจจุบัน
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

# TODO(step-4f): ใส่ HEALTHCHECK โดยใช้ Node one-liner (เพราะ slim ไม่มี curl)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

# TODO(step-4g): คำสั่งรันแอป (อ้างอิงตาม README: app/src/index.js)
CMD ["node", "src/index.js"]