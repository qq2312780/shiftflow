/** @type {import('tailwindcss').Config} */
export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    container: {
      center: true,
    },
    extend: {
      colors: {
        claw: {
          DEFAULT: "#FF7A1A",
          50: "#FFF3E6",
          100: "#FFE4C7",
          200: "#FFC88A",
          300: "#FFAD4D",
          400: "#FF9326",
          500: "#FF7A1A",
          600: "#E55A00",
          700: "#B23F00",
        },
        teal: {
          DEFAULT: "#1AB6A8",
        },
        ink: {
          950: "#07080A",
          900: "#0B0D10",
          800: "#11141A",
          700: "#171B22",
          600: "#1F242D",
          500: "#2A303C",
          400: "#4A5563",
        },
        bone: {
          DEFAULT: "#F5F1EA",
          300: "#D9D2C4",
          500: "#A89E8A",
        },
      },
      fontFamily: {
        display: ['"Fraunces"', "ui-serif", "Georgia", "serif"],
        sans: ['"Space Grotesk"', "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ['"JetBrains Mono"', "ui-monospace", "SFMono-Regular", "monospace"],
      },
      boxShadow: {
        soft: "0 10px 30px -12px rgba(0, 0, 0, 0.6), 0 2px 6px rgba(0,0,0,0.25)",
        glow: "0 0 0 1px rgba(255, 122, 26, 0.4), 0 10px 30px -12px rgba(255,122,26,0.35)",
      },
      backgroundImage: {
        grain:
          "radial-gradient(rgba(255,255,255,0.03) 1px, transparent 1px)",
        panel:
          "linear-gradient(180deg, rgba(255,255,255,0.04) 0%, rgba(255,255,255,0.01) 100%)",
      },
      backgroundSize: {
        grain: "3px 3px",
      },
      keyframes: {
        "fade-in-up": {
          "0%": { opacity: "0", transform: "translateY(6px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "slide-in-right": {
          "0%": { transform: "translateX(100%)", opacity: "0" },
          "100%": { transform: "translateX(0)", opacity: "1" },
        },
        pulseDot: {
          "0%, 100%": { boxShadow: "0 0 0 0 rgba(255,122,26,0.6)" },
          "50%": { boxShadow: "0 0 0 6px rgba(255,122,26,0)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
      animation: {
        "fade-in-up": "fade-in-up 260ms cubic-bezier(0.2, 0.9, 0.3, 1) both",
        "slide-in-right":
          "slide-in-right 260ms cubic-bezier(0.2, 0.9, 0.3, 1) both",
        "pulse-dot": "pulseDot 1800ms ease-out infinite",
        shimmer: "shimmer 2200ms linear infinite",
      },
    },
  },
  plugins: [],
};
