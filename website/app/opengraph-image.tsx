import { ImageResponse } from "next/og";

export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt =
  "TrySomething — Discover the hobby you were made for. Stop scrolling. Start something.";

/** Fetch a Google Font subset for exactly the glyphs we render. */
async function loadGoogleFont(family: string, text: string) {
  const url = `https://fonts.googleapis.com/css2?family=${family}&text=${encodeURIComponent(text)}`;
  const css = await (await fetch(url)).text();
  const resource = css.match(
    /src: url\((.+?)\) format\('(opentype|truetype)'\)/
  );
  if (resource) {
    const res = await fetch(resource[1]);
    if (res.status === 200) return await res.arrayBuffer();
  }
  throw new Error(`failed to load font: ${family}`);
}

export default async function OpengraphImage() {
  const headlineSans = "Discover the you were made for. TrySomething";
  const headlineSerif = "hobby";
  const tagline = "Stop scrolling. Start something.";

  const [manrope, manropeBold, instrument] = await Promise.all([
    loadGoogleFont("Manrope:wght@500", tagline + " Free · iPhone & Android"),
    loadGoogleFont("Manrope:wght@800", headlineSans),
    loadGoogleFont("Instrument+Serif:ital@1", headlineSerif),
  ]);

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          backgroundColor: "#050508",
          backgroundImage:
            "radial-gradient(ellipse 900px 500px at 75% 85%, rgba(255,107,107,0.16), transparent 65%), radial-gradient(ellipse 700px 400px at 15% 10%, rgba(13,148,136,0.10), transparent 70%)",
          padding: "64px 72px",
          fontFamily: "Manrope",
        }}
      >
        {/* Wordmark */}
        <div style={{ display: "flex", fontSize: 34, fontWeight: 800 }}>
          <span style={{ color: "#FF6B6B" }}>Try</span>
          <span style={{ color: "#F0EBE3" }}>Something</span>
        </div>

        {/* Headline */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            gap: 0,
          }}
        >
          <div
            style={{
              display: "flex",
              fontSize: 92,
              fontWeight: 800,
              color: "#FAFAFA",
              letterSpacing: "-3px",
              lineHeight: 1.06,
            }}
          >
            <span>Discover the&nbsp;</span>
            <span
              style={{
                fontFamily: "Instrument Serif",
                fontStyle: "italic",
                fontWeight: 400,
                color: "#FF6B6B",
                letterSpacing: "-1px",
              }}
            >
              hobby
            </span>
          </div>
          <div
            style={{
              display: "flex",
              fontSize: 92,
              fontWeight: 800,
              color: "#FAFAFA",
              letterSpacing: "-3px",
              lineHeight: 1.06,
            }}
          >
            you were made for.
          </div>
        </div>

        {/* Footer line */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            fontSize: 26,
            color: "#A09890",
          }}
        >
          <span>{tagline}</span>
          <span style={{ color: "#5C5550" }}>Free · iPhone &amp; Android</span>
        </div>
      </div>
    ),
    {
      ...size,
      fonts: [
        { name: "Manrope", data: manrope, weight: 500, style: "normal" },
        { name: "Manrope", data: manropeBold, weight: 800, style: "normal" },
        {
          name: "Instrument Serif",
          data: instrument,
          weight: 400,
          style: "italic",
        },
      ],
    }
  );
}
