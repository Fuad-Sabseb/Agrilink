import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        agrilink: {
          green: "#1B5E3A",
          "green-dark": "#0E2A1C",
          gold: "#C99A2E",
          success: "#2E9E5B",
          warning: "#D97706",
          error: "#C0392B",
        },
      },
      borderRadius: {
        card: "20px",
      },
    },
  },
  plugins: [],
};
export default config;
