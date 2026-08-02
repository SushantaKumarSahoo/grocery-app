import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    watch: {
      // This project lives inside a OneDrive-synced folder, which touches
      // file timestamps/metadata during background sync without any real
      // content change. Without debouncing, chokidar picks those up as
      // edits and Vite fires a full-page HMR reload — which is what shows
      // up as "the tab reloads every time I come back to it". Waiting for
      // the write to actually settle filters those spurious events out.
      awaitWriteFinish: { stabilityThreshold: 300, pollInterval: 100 },
    },
  },
})
