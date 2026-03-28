import type { Metadata } from "next";
import { Manrope, Instrument_Serif } from "next/font/google";
import "./globals.css";

const manrope = Manrope({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "800"],
  variable: "--font-manrope",
  display: "swap",
});

const instrumentSerif = Instrument_Serif({
  subsets: ["latin"],
  weight: ["400"],
  style: ["normal", "italic"],
  variable: "--font-instrument-serif",
  display: "swap",
});

export const metadata: Metadata = {
  title: "TrySomething — Find a Hobby You\u2019ll Actually Start",
  description:
    "Stop scrolling. Start something. TrySomething matches you with one perfect hobby, gives you everything to begin today.",
  keywords: [
    "hobby app",
    "start a hobby",
    "hobby discovery",
    "beginner guide",
    "try new things",
    "hobby tracker",
  ],
  openGraph: {
    title: "TrySomething — Find a Hobby You\u2019ll Actually Start",
    description:
      "One hobby, matched to your life. Everything to start. A coach to keep you going.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "TrySomething — Find a Hobby You\u2019ll Actually Start",
    description:
      "One hobby, matched to your life. Everything to start. A coach to keep you going.",
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
      className={`${manrope.variable} ${instrumentSerif.variable}`}
    >
      <body>{children}</body>
    </html>
  );
}
