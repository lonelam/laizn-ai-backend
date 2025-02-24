# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install pnpm globally
RUN npm install -g pnpm

# Create and set working directory
WORKDIR /app

# Copy package manifest and lock file
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including dev)
RUN pnpm install

# Copy the rest of the source code
COPY . .

# Build the NestJS application
RUN pnpm build

# Stage 2: Production image
FROM node:18-alpine

# Install pnpm globally
RUN npm install -g pnpm

# Set the NODE_ENV to production
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package files and install only production dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod

# Copy the built application from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the application port (adjust if necessary)
EXPOSE 3000

# Start the application
CMD ["node", "dist/main.js"]
