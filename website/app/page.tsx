import { SmoothScroll } from "@/components/layout/SmoothScroll";
import { Navbar } from "@/components/layout/Navbar";
import { Hero } from "@/components/sections/Hero";
import { Solution } from "@/components/sections/Solution";
import { HowItWorks } from "@/components/sections/HowItWorks";
import { Experience } from "@/components/sections/Experience";
import { WhatYouGet } from "@/components/sections/WhatYouGet";
import { Manifesto } from "@/components/sections/Manifesto";
import { Testimonials } from "@/components/sections/Testimonials";
import { WaitlistCTA } from "@/components/sections/WaitlistCTA";
import { Footer } from "@/components/layout/Footer";

export default function LandingPage() {
  return (
    <SmoothScroll>
      <Navbar />

      <main>
        <Hero />
        <Solution />
        <HowItWorks />
        <Experience />
        <WhatYouGet />
        <Manifesto />
        <Testimonials />
        <WaitlistCTA />
      </main>

      <Footer />
    </SmoothScroll>
  );
}
