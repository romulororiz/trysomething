"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { testimonials } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { TestimonialColumns } from "@/components/ui/TestimonialColumns";

export function Testimonials() {
  const { ref, inView } = useInView({ threshold: 0.1 });

  return (
    <section
      id="testimonials"
      ref={ref}
      className="relative py-32 md:py-40"
    >
      {/* Atmospheric bloom */}
      <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bloom-burgundy opacity-15 -translate-x-1/3 translate-y-1/4 pointer-events-none" />
      <div className="absolute top-0 right-0 w-[400px] h-[400px] bloom-teal opacity-10 translate-x-1/3 -translate-y-1/4 pointer-events-none" />

      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <div className="text-center mb-16">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            Real people, real starts
          </motion.p>

          <StaggeredText
            text="They kept saying someday. Then someday arrived."
            as="h2"
            className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight max-w-3xl mx-auto"
            highlightWords={["someday"]}
            stagger={0.06}
          />

          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-6 text-lg text-text-secondary max-w-md mx-auto"
          >
            From overwhelmed to week 4 and counting.
          </motion.p>
        </div>

        {/* Auto-scrolling testimonial wall */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.3 }}
        >
          <TestimonialColumns testimonials={testimonials} />
        </motion.div>
      </div>
    </section>
  );
}
