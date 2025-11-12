import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Allow the 'app' hostname from Docker network
    allowedHosts: ['app', 'localhost', 'todo-frontend-app'],
    port: 3000 // add this line to bind vite server to port 3000
  }
})
