import { SmoothScroll } from "@/components/layout/SmoothScroll";
import { Navbar } from "@/components/layout/Navbar";
import { HeroSection } from "@/components/sections/HeroSection";
import { ProblemSection } from "@/components/sections/ProblemSection";
import { SolutionSection } from "@/components/sections/SolutionSection";
import { FeedShowcase } from "@/components/sections/FeedShowcase";
import { DetailShowcase } from "@/components/sections/DetailShowcase";
import { ProgressShowcase } from "@/components/sections/ProgressShowcase";

import { SocialProofSection } from "@/components/sections/SocialProofSection";
import { FinalCTA } from "@/components/sections/FinalCTA";
import { Footer } from "@/components/sections/Footer";

export default function LandingPage() {
  return (
    <SmoothScroll>
      <Navbar />

      <main>
        <HeroSection />

        <ProblemSection />

        <SolutionSection />

        <FeedShowcase />

        <DetailShowcase />

        <ProgressShowcase />

        <SocialProofSection />

        <FinalCTA />
      </main>

      <Footer />
    </SmoothScroll>
  );
}
