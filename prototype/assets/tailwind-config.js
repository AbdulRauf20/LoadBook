/* Shared Tailwind theme for the LoadBook prototype design system.
   Utility classes handle layout/spacing/typography; the matching
   custom component classes (lb-card, lb-btn-*, lb-status-*, etc. in
   style.css) handle the reusable design-system widgets. */
tailwind.config = {
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#1d5fd1', dark: '#164ba6', bg: '#eaf1fd' },
        success: { DEFAULT: '#16a34a', bg: '#e9f8ee', border: '#bfe8cd' },
        warning: { DEFAULT: '#b45309', bg: '#fef3e0', border: '#f7ddaa' },
        danger: { DEFAULT: '#dc2626', bg: '#fdecec', border: '#f6c6c6' },
        ink: { DEFAULT: '#17202a', soft: '#51606e', faint: '#8a97a3' },
        surface: { DEFAULT: '#ffffff', alt: '#f0f2f5' },
        line: '#e3e7eb',
        appbg: '#f5f6f8',
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Arial', 'sans-serif'],
      },
      borderRadius: {
        xl: '14px',
        '2xl': '20px',
      },
    },
  },
};
