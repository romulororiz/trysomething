import { SmoothScroll } from "@/components/layout/SmoothScroll";
import { Navbar } from "@/components/layout/Navbar";
import { Hero } from "@/components/sections/Hero";
import { Problem } from "@/components/sections/Problem";
import { Solution } from "@/components/sections/Solution";
import { ProductShowcase } from "@/components/sections/ProductShowcase";
import { HowItWorks } from "@/components/sections/HowItWorks";
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
        <Problem />
        <Solution />
        <ProductShowcase />
        <HowItWorks />
        <Manifesto />
        <Testimonials />
        <WaitlistCTA />
      </main>

      <Footer />
    </SmoothScroll>
  );
}
