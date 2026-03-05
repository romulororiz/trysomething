import type { Metadata } from "next";
import { Source_Serif_4, DM_Sans, IBM_Plex_Mono } from "next/font/google";
import "./globals.css";

const sourceSerif = Source_Serif_4({
  subsets: ["latin"],
  weight: ["700"],
  variable: "--font-source-serif",
  display: "swap",
});

const dmSans = DM_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-dm-sans",
  display: "swap",
});

const ibmPlexMono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-ibm-plex-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: "TrySomething — Helps You Actually Start",
  description:
    "Discover 72+ hobbies, get beginner-friendly guidance, and track your journey from 'maybe' to mastery. TrySomething helps you actually start.",
  keywords: [
    "hobby discovery",
    "try new hobbies",
    "beginner guide",
    "hobby tracker",
    "start a hobby",
  ],
  openGraph: {
    title: "TrySomething — Helps You Actually Start",
    description:
      "Discover 72+ hobbies with beginner-friendly guides. From pottery to parkour — find what excites you.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "TrySomething — Helps You Actually Start",
    description:
      "Discover 72+ hobbies with beginner-friendly guides. Find what excites you.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${sourceSerif.variable} ${dmSans.variable} ${ibmPlexMono.variable}`}
    >
      <body>{children}</body>
    </html>
  );
}
