"use client";

export function Footer() {
  const currentYear = new Date().getFullYear();

  const scrollTo = (href: string) => {
    const el = document.querySelector(href);
    el?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <footer className="relative border-t border-glass-border">
      {/* Gradient top border accent */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-coral/40 to-transparent" />

      <div className="max-w-6xl mx-auto px-6 py-16">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-12 md:gap-8">
          {/* Brand column */}
          <div className="md:col-span-2">
            <div className="flex items-center gap-0.5 mb-4">
              <span className="text-xl font-bold text-text-primary tracking-tight">
                Try
              </span>
              <span className="text-xl font-bold text-coral tracking-tight">
                Something
              </span>
              <span className="inline-block w-1.5 h-1.5 rounded-full bg-coral ml-0.5 mb-3" />
            </div>
            <p className="text-text-secondary text-sm leading-relaxed max-w-xs">
              The best app for helping overwhelmed adults choose one hobby and
              actually stick with it for 30 days.
            </p>
            <p className="text-text-muted text-xs mt-6">
              Coming soon to iPhone and Android.
            </p>
          </div>

          {/* Nav column */}
          <div>
            <h4 className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-4">
              Navigate
            </h4>
            <ul className="space-y-3">
              {[
                { label: "How It Works", href: "#how-it-works" },
                { label: "Product", href: "#product" },
                { label: "Testimonials", href: "#testimonials" },
                { label: "Get Early Access", href: "#waitlist" },
              ].map((link) => (
                <li key={link.href}>
                  <button
                    onClick={() => scrollTo(link.href)}
                    className="text-sm text-text-secondary hover:text-text-primary transition-colors duration-200 cursor-pointer"
                  >
                    {link.label}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal column */}
          <div>
            <h4 className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-4">
              Legal
            </h4>
            <ul className="space-y-3">
              {[
                { label: "Privacy Policy", href: "#" },
                { label: "Terms of Service", href: "#" },
                { label: "Contact", href: "mailto:hello@trysomething.app" },
              ].map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    className="text-sm text-text-secondary hover:text-text-primary transition-colors duration-200"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="mt-16 pt-8 border-t border-glass-border flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-xs text-text-whisper">
            &copy; {currentYear} TrySomething. All rights reserved.
          </p>
          <p className="text-xs text-text-whisper">
            Made with care in Switzerland.
          </p>
        </div>
      </div>
    </footer>
  );
}
