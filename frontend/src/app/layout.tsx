import type { Metadata } from "next";
import { Archivo, IBM_Plex_Mono } from "next/font/google";
import StoreHydration from "@/components/StoreHydration/StoreHydration";
import ServiceWorker from "@/components/ServiceWorker/ServiceWorker";
import "./globals.css";

const archivo = Archivo({
  subsets: ["latin"],
  variable: "--font-archivo",
  display: "swap",
});

const ibmPlexMono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: ["400", "500"],
  variable: "--font-ibm-plex-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: "60 Seconds",
  description: "Build speaking fluency through timed preparation and delivery.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" data-theme="light">
      <head>
        {/* Sync theme from localStorage before first paint to prevent flash */}
        <script dangerouslySetInnerHTML={{ __html: `try{var s=localStorage.getItem('60s-store');if(s){var t=JSON.parse(s).state?.theme;if(t)document.documentElement.setAttribute('data-theme',t)}}catch(e){}` }} />
      </head>
      <body className={`${archivo.variable} ${ibmPlexMono.variable}`}>
        <StoreHydration />
        <ServiceWorker />
        {children}
      </body>
    </html>
  );
}
