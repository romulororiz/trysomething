import { SmoothScroll } from "@/components/layout/SmoothScroll";
import { Navbar } from "@/components/layout/Navbar";
import { Hero } from "@/components/sections/Hero";
import { Solution } from "@/components/sections/Solution";
import { HowItWorks } from "@/components/sections/HowItWorks";
import { WhatYouGet } from "@/components/sections/WhatYouGet";
import { Manifesto } from "@/components/sections/Manifesto";
import { Proof } from "@/components/sections/Proof";
import { WaitlistCTA } from "@/components/sections/WaitlistCTA";
import { Footer } from "@/components/layout/Footer";
import { MobileAmbientIcons } from "@/components/layout/MobileAmbientIcons";

export default function LandingPage() {
  return (
    <SmoothScroll>
      <Navbar />
      <MobileAmbientIcons />

      <main className="relative z-10">
        <Hero />
        <Solution />
        <HowItWorks />
        <WhatYouGet />
        <Manifesto />
        <Proof />
        <WaitlistCTA />
      </main>

      <Footer />
    </SmoothScroll>
  );
}

