import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { AuthProvider } from "../lib/auth/AuthContext";
import { I18nProvider } from "../lib/i18n/I18nContext";
import { OfflineBanner } from "../components/ui/OfflineBanner";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  title: "AgriLink — Godina Jimmaa",
  description:
    "Market intelligence, buyers, and logistics for Jimma Zone farmers.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="om">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-agrilink-green-dark min-h-screen flex flex-col text-white`}
      >
        <I18nProvider>
          <AuthProvider>
            <OfflineBanner />
            <main className="flex-1">{children}</main>
          </AuthProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
