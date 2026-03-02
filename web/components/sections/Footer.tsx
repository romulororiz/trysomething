import { Github, Twitter } from "lucide-react";

const links = [
  { label: "About", href: "#" },
  { label: "Privacy", href: "#" },
  { label: "Terms", href: "#" },
  { label: "Contact", href: "#" },
];

export function Footer() {
  return (
    <footer className="relative border-t border-sand-dark/40">
      {/* Animated gradient top border */}
      <div
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background: "linear-gradient(90deg, #FF6B6B, #7C3AED, #06D6A0, #FF6B6B)",
          backgroundSize: "200% 100%",
          animation: "gradient-shift 8s linear infinite",
        }}
      />

      <div className="max-w-7xl mx-auto px-6 md:px-12 py-12">
        <div className="flex flex-col items-center text-center gap-6">
          {/* Logo + tagline */}
          <div>
            <span className="font-serif text-xl font-bold text-near-black">
              TrySomething
            </span>
            <p className="font-sans text-sm text-driftwood mt-1">
              Helps you actually start.
            </p>
          </div>

          {/* Links */}
          <nav className="flex flex-wrap justify-center gap-6">
            {links.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="font-sans text-sm text-driftwood hover:text-coral transition-colors cursor-pointer relative group"
                style={{ transitionDuration: "200ms" }}
              >
                {link.label}
                <span className="absolute -bottom-0.5 left-1/2 -translate-x-1/2 w-0 h-px bg-coral transition-all group-hover:w-full" style={{ transitionDuration: "250ms" }} />
              </a>
            ))}
          </nav>

          {/* Social */}
          <div className="flex items-center gap-4">
            <a
              href="#"
              className="text-driftwood hover:text-coral transition-colors cursor-pointer p-2"
              style={{ transitionDuration: "200ms" }}
              aria-label="GitHub"
            >
              <Github size={20} />
            </a>
            <a
              href="#"
              className="text-driftwood hover:text-coral transition-colors cursor-pointer p-2"
              style={{ transitionDuration: "200ms" }}
              aria-label="Twitter"
            >
              <Twitter size={20} />
            </a>
          </div>
        </div>

        {/* Divider + Copyright */}
        <div className="mt-8 pt-6 border-t border-sand-dark/30 text-center">
          <p className="font-sans text-xs text-warm-gray">
            &copy; 2026 TrySomething. Made with curiosity.
          </p>
        </div>
      </div>
    </footer>
  );
}
