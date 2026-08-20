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
  metadataBase: new URL("https://trysomething.io"),
  title: "TrySomething — Find a Hobby You’ll Actually Start",
  description:
    "Stop scrolling. Start something. TrySomething matches you with one perfect hobby, gives you everything to begin today.",
  alternates: { canonical: "/" },
  openGraph: {
    title: "TrySomething — Find a Hobby You’ll Actually Start",
    description:
      "One hobby, matched to your life. Everything to start. A coach to keep you going.",
    url: "/",
    siteName: "TrySomething",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "TrySomething — Find a Hobby You’ll Actually Start",
    description:
      "One hobby, matched to your life. Everything to start. A coach to keep you going.",
  },
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "MobileApplication",
  name: "TrySomething",
  description:
    "TrySomething matches you with one hobby that fits your time, budget, and energy — then walks you through your first 30 days with a step-by-step roadmap and an AI coach.",
  operatingSystem: "iOS, Android",
  applicationCategory: "LifestyleApplication",
  offers: { "@type": "Offer", price: "0", priceCurrency: "CHF" },
  url: "https://trysomething.io",
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
      <body>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {children}
      </body>
    </html>
  );
}
