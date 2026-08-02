/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#16A34A',
          hover: '#15803d',
          light: '#dcfce7',
        },
        secondary: {
          DEFAULT: '#1E3A8A',
          hover: '#1e40af',
        },
        accent: {
          DEFAULT: '#F59E0B',
          hover: '#d97706',
        },
        bg: {
          main: '#F8FAFC',
          card: '#FFFFFF',
          hover: '#f1f5f9',
        },
        text: {
          main: '#0f172a',
          muted: '#64748b',
        },
        success: {
          DEFAULT: '#10b981',
          bg: '#d1fae5',
        },
        warning: {
          DEFAULT: '#f59e0b',
          bg: '#fef3c7',
        },
        error: {
          DEFAULT: '#ef4444',
          bg: '#fee2e2',
        },
        border: '#e2e8f0',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
        md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
        lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
        card: '0 4px 20px rgba(0, 0, 0, 0.03)',
      },
      borderRadius: {
        sm: '8px',
        md: '12px',
        lg: '16px',
        full: '9999px',
      },
      transitionProperty: {
        fast: '150ms ease-in-out',
        normal: '250ms ease-in-out',
      }
    },
  },
  plugins: [],
}
