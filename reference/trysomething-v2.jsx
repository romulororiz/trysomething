import { useState, useEffect, useRef } from "react";

// ═══════════════════════════════════════════════════════
//  SUNSET ANALOG PALETTE
// ═══════════════════════════════════════════════════════
const C = {
  // Light mode base
  cream: "#FFF9F5",
  warmWhite: "#FFFDFB",
  sand: "#F5EDE6",
  sandDark: "#E8DDD3",
  stone: "#D4C8BC",
  warmGray: "#A89B8E",
  driftwood: "#7A6E62",
  espresso: "#524840",
  darkBrown: "#3A322C",
  nearBlack: "#1E1A17",

  // Accent — Warm Coral (primary action)
  coral: "#E8734A",
  coralLight: "#F0956E",
  coralPale: "#FFF0EB",
  coralDeep: "#D45E35",

  // Accent — Golden Amber (secondary/highlight)
  amber: "#E5A630",
  amberLight: "#F0C060",
  amberPale: "#FFF8E8",
  amberDeep: "#C48B1A",

  // Accent — Soft Indigo (depth/sophistication)
  indigo: "#5B6AAF",
  indigoLight: "#7B88C4",
  indigoPale: "#ECEEF7",
  indigoDeep: "#444F8A",

  // Supporting
  sage: "#7EA47E",
  sagePale: "#EDF4ED",
  rose: "#C47878",
  rosePale: "#F7EDED",
  sky: "#6AA8C4",
  skyPale: "#EAF3F8",

  // Semantic
  success: "#5EA87E",
  warning: "#E5A630",
  error: "#C45858",

  // Category accents
  catCreative: "#C47878",
  catOutdoors: "#7EA47E",
  catFitness: "#E8734A",
  catMaker: "#E5A630",
  catMusic: "#5B6AAF",
  catFood: "#C48B1A",
  catCollecting: "#6AA8C4",
  catMind: "#5B6AAF",
  catSocial: "#E8734A",
};

const hobbies = [
  {
    id: "pottery", title: "Pottery",
    hook: "Get your hands dirty. Make something real.",
    category: "Creative", catIcon: "🎨", catColor: C.catCreative,
    img: "https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=600&h=800&fit=crop",
    tags: ["creative", "relaxing", "meditative"],
    cost: "CHF 40–120", time: "2h/week", diff: "Moderate",
    whyLove: "The tactile satisfaction is unmatched. You lose track of time, your phone stays in your pocket, and you walk away with something you made with your own hands.",
    diffExplain: "Centering clay on a wheel takes practice. Hand-building is much easier to start with and just as rewarding.",
    kit: [
      { name: "Air-dry clay (2kg)", desc: "No kiln needed. Perfect for first projects.", cost: 15, opt: false },
      { name: "Basic tool set", desc: "Wire cutter, rib, needle tool, sponge.", cost: 12, opt: false },
      { name: "Canvas work surface", desc: "Prevents sticking. A cutting board works too.", cost: 8, opt: true },
    ],
    pitfalls: [
      "Don't start with a wheel — try hand-building first.",
      "Air-dry clay cracks if too thin. Keep walls ≥5mm.",
      "Don't skip wedging. Air bubbles ruin your piece.",
    ],
    roadmap: [
      { id: "p1", title: "Make a pinch pot", desc: "The simplest form. Just a ball of clay and your thumbs.", min: 25, ms: null },
      { id: "p2", title: "Try coil building", desc: "Roll snakes of clay and stack them into a vessel.", min: 40, ms: null },
      { id: "p3", title: "Make a slab plate", desc: "Roll clay flat, cut a shape, add a foot ring.", min: 35, ms: "First functional piece" },
      { id: "p4", title: "Learn surface texture", desc: "Use stamps, fabric, or tools to add patterns.", min: 30, ms: null },
      { id: "p5", title: "Try a local class", desc: "Find a studio for wheel throwing.", min: 90, ms: "Wheel experience" },
    ],
  },
  {
    id: "bouldering", title: "Bouldering",
    hook: "Solve puzzles with your body.",
    category: "Fitness", catIcon: "💪", catColor: C.catFitness,
    img: "https://images.unsplash.com/photo-1522163182402-834f871fd851?w=600&h=800&fit=crop",
    tags: ["physical", "social", "competitive"],
    cost: "CHF 20–60", time: "3h/week", diff: "Moderate",
    whyLove: "It's social, physical, and mental all at once. You'll make friends at the gym and surprise yourself with what your body can do.",
    diffExplain: "Technique matters more than strength. Finger strength builds slowly — be patient with yourself.",
    kit: [
      { name: "Climbing shoes", desc: "Rent first. Buy after 3-4 sessions if you're hooked.", cost: 0, opt: false },
      { name: "Chalk bag + chalk", desc: "Keeps hands dry for better grip.", cost: 18, opt: true },
    ],
    pitfalls: [
      "Use your legs, not just your arms. Most beginners over-grip.",
      "Rest between problems. Tendons need time to adapt.",
      "Start on easy grades (V0–V1). Ego is the enemy.",
    ],
    roadmap: [
      { id: "b1", title: "Visit a gym", desc: "Just go, rent shoes, try the easiest walls.", min: 60, ms: null },
      { id: "b2", title: "Learn footwork", desc: "Watch your feet. Place them precisely.", min: 45, ms: null },
      { id: "b3", title: "Send your first V1", desc: "Complete a V1 top to bottom without falling.", min: 60, ms: "First send" },
    ],
  },
  {
    id: "sourdough", title: "Sourdough Baking",
    hook: "Flour, water, patience. Insanely rewarding.",
    category: "Food", catIcon: "🍞", catColor: C.catFood,
    img: "https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=600&h=800&fit=crop",
    tags: ["creative", "relaxing", "solo"],
    cost: "CHF 15–50", time: "2h/week", diff: "Moderate",
    whyLove: "The smell. The ritual. Pulling a golden loaf from your own oven. You'll never look at supermarket bread the same way again.",
    diffExplain: "Timing is everything. Your first few loaves may be flat — that's completely normal and part of the process.",
    kit: [
      { name: "Bread flour (1.5kg)", desc: "High protein for better gluten development.", cost: 5, opt: false },
      { name: "Kitchen scale", desc: "Baking is chemistry. Measure by weight, not volume.", cost: 15, opt: false },
      { name: "Dutch oven", desc: "Creates steam for crispy crust. Game changer.", cost: 30, opt: true },
    ],
    pitfalls: [
      "Don't rush fermentation. Cold overnight rise = more flavor.",
      "Your starter needs 7–10 days to mature. Be patient.",
      "Don't add too much flour. Wet dough = open crumb.",
    ],
    roadmap: [
      { id: "s1", title: "Create your starter", desc: "Mix flour + water. Feed daily for 7–10 days.", min: 10, ms: null },
      { id: "s2", title: "Bake your first loaf", desc: "Follow a simple recipe. Don't stress.", min: 30, ms: "First loaf" },
      { id: "s3", title: "Master stretch & fold", desc: "Build gluten without kneading.", min: 20, ms: null },
    ],
  },
];

const categories = [
  { id: "creative", name: "Creative", icon: "🎨", color: C.catCreative, count: 12 },
  { id: "outdoors", name: "Outdoors", icon: "🌿", color: C.catOutdoors, count: 8 },
  { id: "fitness", name: "Fitness", icon: "💪", color: C.catFitness, count: 9 },
  { id: "maker", name: "Maker/DIY", icon: "🔨", color: C.catMaker, count: 7 },
  { id: "music", name: "Music", icon: "🎵", color: C.catMusic, count: 6 },
  { id: "food", name: "Food", icon: "🍞", color: C.catFood, count: 11 },
  { id: "collecting", name: "Collecting", icon: "📦", color: C.catCollecting, count: 5 },
  { id: "mind", name: "Mind", icon: "🧩", color: C.catMind, count: 8 },
  { id: "social", name: "Social", icon: "👋", color: C.catSocial, count: 6 },
];

// ═══════════════════════════════════════════════════════
const Styles = () => (
  <style>{`
    @import url('https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=DM+Sans:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --serif: 'Source Serif 4', Georgia, serif;
      --sans: 'DM Sans', -apple-system, sans-serif;
      --mono: 'IBM Plex Mono', monospace;
    }
    .phone {
      width: 390px; height: 844px; background: ${C.cream};
      border-radius: 44px; overflow: hidden; position: relative;
      box-shadow: 0 0 0 1px ${C.sandDark}, 0 25px 60px rgba(30,26,23,0.18), 0 8px 24px rgba(30,26,23,0.10);
      font-family: var(--sans); color: ${C.nearBlack};
      -webkit-font-smoothing: antialiased;
    }
    .notch {
      position: absolute; top: 0; left: 50%; transform: translateX(-50%);
      width: 160px; height: 34px; background: ${C.nearBlack};
      border-radius: 0 0 20px 20px; z-index: 100;
    }
    .homebar {
      position: absolute; bottom: 8px; left: 50%; transform: translateX(-50%);
      width: 134px; height: 5px; background: ${C.stone};
      border-radius: 100px; z-index: 100;
    }
    .scr { width: 100%; height: 100%; overflow-y: auto; overflow-x: hidden; position: relative; scrollbar-width: none; }
    .scr::-webkit-scrollbar { display: none; }
    .fade { animation: fadeIn .35s ease-out; }
    .slup { animation: slUp .4s cubic-bezier(.16,1,.3,1); }
    .scin { animation: scIn .3s cubic-bezier(.34,1.56,.64,1); }
    @keyframes fadeIn { from { opacity:0 } to { opacity:1 } }
    @keyframes slUp { from { opacity:0; transform: translateY(16px) } to { opacity:1; transform: translateY(0) } }
    @keyframes scIn { from { opacity:0; transform: scale(.94) } to { opacity:1; transform: scale(1) } }
    @keyframes breathe { 0%,100% { box-shadow: 0 4px 16px rgba(232,115,74,0.25) } 50% { box-shadow: 0 4px 24px rgba(232,115,74,0.45) } }
    @keyframes fl1 { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-5px) } }
    @keyframes fl2 { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-3px) } }
    @keyframes fl3 { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-7px) } }
    @keyframes pop { 0% { transform: scale(0) } 60% { transform: scale(1.2) } 100% { transform: scale(1) } }

    .badge {
      display: inline-flex; align-items: center; gap: 4px;
      padding: 5px 10px; border-radius: 100px;
      font-family: var(--mono); font-size: 11px; font-weight: 600;
      white-space: nowrap; letter-spacing: -.2px;
    }
    .b-cost { background: ${C.coralPale}; color: ${C.coralDeep}; border: 1px solid #f0d0c4; }
    .b-time { background: ${C.amberPale}; color: ${C.amberDeep}; border: 1px solid #f0e0b0; }
    .b-diff { background: ${C.indigoPale}; color: ${C.indigoDeep}; border: 1px solid #ccd0e4; }

    .btn-main {
      width: 100%; height: 54px; border: none; border-radius: 14px;
      background: ${C.coral}; color: white; font-family: var(--sans);
      font-weight: 700; font-size: 14px; letter-spacing: .8px; cursor: pointer;
      display: flex; align-items: center; justify-content: center; gap: 8px;
      animation: breathe 2.5s ease-in-out infinite;
      transition: transform .12s, filter .12s;
    }
    .btn-main:active { transform: scale(.97); filter: brightness(1.08); }

    .btn-sec {
      width: 100%; height: 46px; border: 1.5px solid ${C.coral}40; border-radius: 14px;
      background: ${C.coralPale}; color: ${C.coral}; font-family: var(--sans);
      font-weight: 600; font-size: 13px; cursor: pointer;
      display: flex; align-items: center; justify-content: center; gap: 6px;
      transition: all .2s;
    }
    .btn-sec:active { background: ${C.coral}18; }

    .over { font-size: 11px; font-weight: 600; letter-spacing: 2px; color: ${C.warmGray}; text-transform: uppercase; }

    .bnav {
      position: absolute; bottom: 0; left: 0; right: 0; height: 82px;
      display: flex; align-items: flex-start; padding-top: 10px;
      justify-content: space-around; background: ${C.warmWhite};
      border-top: 1px solid ${C.sand}; z-index: 50;
    }
    .ni {
      display: flex; flex-direction: column; align-items: center; gap: 3px;
      cursor: pointer; padding: 4px 16px; border: none; background: none;
    }
    .ni span:last-child { font-size: 10px; font-weight: 600; letter-spacing: .2px; }
  `}</style>
);

// ═══════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ═══════════════════════════════════════════════════════
const Badges = ({ cost, time, diff, small }) => (
  <div style={{ display: "flex", gap: 5, flexWrap: "wrap" }}>
    <span className={`badge b-cost`} style={small ? { fontSize: 10, padding: "3px 8px" } : {}}>💰 {cost}</span>
    <span className={`badge b-time`} style={small ? { fontSize: 10, padding: "3px 8px" } : {}}>⏱ {time}</span>
    <span className={`badge b-diff`} style={small ? { fontSize: 10, padding: "3px 8px" } : {}}>📊 {diff}</span>
  </div>
);

const Sec = ({ title, right, children }) => (
  <div style={{ marginBottom: 28 }}>
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
      <h3 style={{ fontFamily: "var(--sans)", fontSize: 19, fontWeight: 700, color: C.nearBlack }}>{title}</h3>
      {right && <span style={{ fontFamily: "var(--mono)", fontSize: 12, color: C.warmGray }}>{right}</span>}
    </div>
    {children}
  </div>
);

// ═══════════════════════════════════════════════════════
//  ONBOARDING
// ═══════════════════════════════════════════════════════
const Onboarding = ({ onDone }) => {
  const [pg, setPg] = useState(0);
  const [hrs, setHrs] = useState(3);
  const [bud, setBud] = useState(1);
  const [solo, setSolo] = useState(false);
  const [vibes, setVibes] = useState(new Set());
  const tv = v => { const n = new Set(vibes); n.has(v) ? n.delete(v) : n.add(v); setVibes(n); };

  const pages = [
    // Welcome
    <div key="w" className="fade" style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", height: "100%", padding: "0 32px", textAlign: "center" }}>
      <div style={{ position: "relative", width: 200, height: 120, marginBottom: 44 }}>
        {[
          { e: "🎨", x: 10, y: 8, s: 46, a: "fl1", d: "0s" },
          { e: "🌿", x: 138, y: 2, s: 42, a: "fl2", d: ".4s" },
          { e: "🎵", x: 72, y: 58, s: 50, a: "fl3", d: ".7s" },
          { e: "💪", x: 28, y: 62, s: 38, a: "fl2", d: "1s" },
          { e: "🍞", x: 128, y: 54, s: 40, a: "fl1", d: "1.3s" },
        ].map((it, i) => (
          <div key={i} style={{
            position: "absolute", left: it.x, top: it.y, width: it.s, height: it.s,
            borderRadius: "50%", background: C.sand, border: `1px solid ${C.sandDark}`,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: it.s * .48, animation: `${it.a} 3.5s ease-in-out infinite`, animationDelay: it.d,
          }}>{it.e}</div>
        ))}
      </div>
      <h1 style={{ fontFamily: "var(--serif)", fontSize: 38, fontWeight: 700, lineHeight: 1.12, color: C.nearBlack, letterSpacing: -.3 }}>
        Find hobbies<br/>you'll actually do.
      </h1>
      <p style={{ marginTop: 14, fontSize: 15, lineHeight: 1.6, color: C.driftwood, maxWidth: 290 }}>
        We'll match you with activities that fit your life, budget, and vibe. No courses. No overwhelm.
      </p>
    </div>,

    // Preferences
    <div key="p" className="slup" style={{ padding: "56px 28px 100px", overflowY: "auto", height: "100%" }}>
      <h1 style={{ fontFamily: "var(--serif)", fontSize: 32, fontWeight: 700, lineHeight: 1.12, color: C.nearBlack, marginBottom: 4 }}>
        Tell us<br/>your vibe.
      </h1>
      <p style={{ fontSize: 15, color: C.driftwood, marginBottom: 32 }}>Quick picks. Takes 30 seconds.</p>

      <div className="over" style={{ marginBottom: 10 }}>TIME PER WEEK</div>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 28 }}>
        <input type="range" min={1} max={7} step={1} value={hrs} onChange={e => setHrs(+e.target.value)}
          style={{ flex: 1, accentColor: C.coral, height: 4 }} />
        <div style={{ padding: "6px 14px", background: C.coralPale, borderRadius: 10, border: `1px solid #f0d0c4`,
          fontFamily: "var(--mono)", fontSize: 18, fontWeight: 700, color: C.coral }}>{hrs}h</div>
      </div>

      <div className="over" style={{ marginBottom: 10 }}>BUDGET COMFORT</div>
      <div style={{ display: "flex", gap: 8, marginBottom: 28 }}>
        {[["Low", "< CHF 30"], ["Medium", "30–100"], ["High", "100+"]].map(([l, s], i) => (
          <button key={i} onClick={() => setBud(i)} style={{
            flex: 1, padding: "12px 8px", textAlign: "center", cursor: "pointer", borderRadius: 12,
            background: bud === i ? C.coralPale : C.sand,
            border: `1.5px solid ${bud === i ? C.coral + "50" : C.sandDark}`,
            transition: "all .2s",
          }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: bud === i ? C.coral : C.espresso }}>{l}</div>
            <div style={{ fontSize: 10, color: C.warmGray, marginTop: 2 }}>{s}</div>
          </button>
        ))}
      </div>

      <div className="over" style={{ marginBottom: 10 }}>SOCIAL PREFERENCE</div>
      <div style={{ display: "flex", gap: 8, marginBottom: 28 }}>
        {[["👤", "Solo", true], ["👥", "Social", false]].map(([ic, lb, vl]) => (
          <button key={lb} onClick={() => setSolo(vl)} style={{
            flex: 1, padding: 16, display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            borderRadius: 12, cursor: "pointer", transition: "all .2s",
            background: solo === vl ? C.coralPale : C.sand,
            border: `1.5px solid ${solo === vl ? C.coral + "50" : C.sandDark}`,
          }}>
            <span style={{ fontSize: 18 }}>{ic}</span>
            <span style={{ fontSize: 15, fontWeight: 600, color: solo === vl ? C.nearBlack : C.driftwood }}>{lb}</span>
          </button>
        ))}
      </div>

      <div className="over" style={{ marginBottom: 10 }}>WHAT EXCITES YOU?</div>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
        {["Creative", "Physical", "Relaxing", "Technical", "Outdoors", "Competitive"].map(v => (
          <button key={v} onClick={() => tv(v)} style={{
            padding: "10px 18px", borderRadius: 100, cursor: "pointer", transition: "all .2s",
            background: vibes.has(v) ? C.indigoPale : C.sand,
            border: `1.5px solid ${vibes.has(v) ? C.indigo + "50" : C.sandDark}`,
            color: vibes.has(v) ? C.indigo : C.driftwood, fontSize: 13, fontWeight: 600,
          }}>{v}</button>
        ))}
      </div>
    </div>,

    // Results
    <div key="r" className="scin" style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", height: "100%", padding: "0 32px", textAlign: "center" }}>
      <div style={{
        padding: "6px 20px", borderRadius: 100, fontSize: 11, fontWeight: 700, letterSpacing: 3,
        background: `linear-gradient(135deg, ${C.coral}, ${C.amber})`, color: "white", marginBottom: 22,
      }}>YOUR VIBE</div>
      <h1 style={{ fontFamily: "var(--serif)", fontSize: 38, fontWeight: 700, lineHeight: 1.1, color: C.nearBlack }}>Creative Explorer</h1>
      <p style={{ marginTop: 12, fontSize: 15, lineHeight: 1.55, color: C.driftwood, maxWidth: 280 }}>
        You like hands-on, creative activities that don't break the bank or the clock.
      </p>
      <p style={{ marginTop: 28, fontSize: 16, fontWeight: 700, color: C.coral }}>We found 12 hobbies for you</p>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 8, justifyContent: "center", marginTop: 14 }}>
        {["Pottery", "Sourdough", "Sketching", "Crochet", "Bouldering"].map(n => (
          <span key={n} style={{
            padding: "8px 14px", borderRadius: 100, fontSize: 13, fontWeight: 600,
            background: C.sand, border: `1px solid ${C.sandDark}`, color: C.espresso,
          }}>{n}</span>
        ))}
      </div>
    </div>,
  ];

  return (
    <div className="scr" style={{ display: "flex", flexDirection: "column" }}>
      <div style={{ display: "flex", gap: 8, padding: "52px 28px 0" }}>
        {[0,1,2].map(i => (
          <div key={i} style={{ flex: 1, height: 3, borderRadius: 100, transition: "background .3s",
            background: i <= pg ? C.coral : C.sandDark }} />
        ))}
      </div>
      <div style={{ flex: 1, overflow: pg === 1 ? "auto" : "hidden" }}>{pages[pg]}</div>
      <div style={{ padding: "0 28px 36px" }}>
        <button className="btn-main" onClick={() => pg < 2 ? setPg(pg + 1) : onDone()}>
          {pg === 0 ? "LET'S GO →" : pg === 1 ? "SEE MY PICKS →" : "START DISCOVERING →"}
        </button>
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  DISCOVER FEED
// ═══════════════════════════════════════════════════════
const Feed = ({ onTap }) => {
  const [idx, setIdx] = useState(0);
  const [saved, setSaved] = useState(new Set());
  const [cat, setCat] = useState(null);
  const h = hobbies[idx];

  return (
    <div className="scr" style={{ paddingBottom: 82 }}>
      <div style={{ padding: "52px 24px 10px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ fontFamily: "var(--serif)", fontSize: 26, fontWeight: 700, color: C.nearBlack }}>Discover</h1>
        <div style={{ width: 38, height: 38, borderRadius: "50%", background: C.sand, display: "flex",
          alignItems: "center", justifyContent: "center", fontSize: 16, border: `1px solid ${C.sandDark}`, cursor: "pointer" }}>✨</div>
      </div>

      {/* Category chips */}
      <div style={{ display: "flex", gap: 6, padding: "0 24px 10px", overflowX: "auto", scrollbarWidth: "none" }}>
        {categories.slice(0, 6).map(c => (
          <button key={c.id} onClick={() => setCat(cat === c.id ? null : c.id)} style={{
            padding: "6px 12px", borderRadius: 100, whiteSpace: "nowrap", cursor: "pointer",
            display: "flex", alignItems: "center", gap: 4, fontSize: 12, fontWeight: 600,
            background: cat === c.id ? `${c.color}15` : C.sand,
            border: `1px solid ${cat === c.id ? c.color + "40" : C.sandDark}`,
            color: cat === c.id ? c.color : C.driftwood, transition: "all .2s",
          }}><span style={{ fontSize: 13 }}>{c.icon}</span> {c.name}</button>
        ))}
      </div>

      {/* Card */}
      <div className="scin" key={h.id} style={{ padding: "6px 16px 0" }}>
        <div onClick={() => onTap(h)} style={{
          borderRadius: 22, overflow: "hidden", height: 480, position: "relative", cursor: "pointer",
          boxShadow: "0 8px 32px rgba(30,26,23,0.14), 0 2px 8px rgba(30,26,23,0.08)",
        }}>
          <img src={h.img} alt={h.title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
          <div style={{ position: "absolute", inset: 0,
            background: "linear-gradient(to bottom, transparent 30%, rgba(30,26,23,0.4) 55%, rgba(30,26,23,0.92) 100%)" }} />

          {/* Category */}
          <div style={{ position: "absolute", top: 14, left: 14, padding: "5px 12px", borderRadius: 100,
            background: "rgba(255,255,255,0.85)", backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)",
            display: "flex", alignItems: "center", gap: 5, fontSize: 10, fontWeight: 700, letterSpacing: 1.5, color: C.espresso,
          }}><span style={{ fontSize: 13 }}>{h.catIcon}</span>{h.category.toUpperCase()}</div>

          {/* Actions */}
          <div style={{ position: "absolute", top: 14, right: 14, display: "flex", flexDirection: "column", gap: 8 }}>
            {[{ ic: saved.has(h.id) ? "♥" : "♡", a: saved.has(h.id), fn: (e) => { e.stopPropagation(); const n = new Set(saved); n.has(h.id) ? n.delete(h.id) : n.add(h.id); setSaved(n); } },
              { ic: "↗", a: false, fn: (e) => e.stopPropagation() },
            ].map((b, i) => (
              <button key={i} onClick={b.fn} style={{
                width: 40, height: 40, borderRadius: "50%", fontSize: 18, cursor: "pointer",
                background: "rgba(255,255,255,0.8)", backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)",
                border: `1px solid rgba(255,255,255,0.6)`,
                color: b.a ? C.coral : C.espresso, display: "flex", alignItems: "center", justifyContent: "center",
                transition: "all .2s",
              }}>{b.ic}</button>
            ))}
          </div>

          {/* Bottom */}
          <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, padding: "20px 20px 22px" }}>
            <div style={{ display: "flex", gap: 8, marginBottom: 6 }}>
              {h.tags.map(t => <span key={t} style={{ fontSize: 12, fontWeight: 500, color: `${C.amberLight}` }}>#{t}</span>)}
            </div>
            <h2 style={{ fontFamily: "var(--serif)", fontSize: 30, fontWeight: 700, lineHeight: 1.1, color: "white", marginBottom: 4 }}>{h.title}</h2>
            <p style={{ fontSize: 14, color: "rgba(255,255,255,0.85)", lineHeight: 1.4, marginBottom: 14 }}>{h.hook}</p>
            <div style={{ display: "flex", gap: 5 }}>
              <span className="badge" style={{ background: "rgba(255,255,255,0.15)", color: "white", border: "1px solid rgba(255,255,255,0.2)", fontSize: 10, padding: "3px 8px" }}>💰 {h.cost}</span>
              <span className="badge" style={{ background: "rgba(255,255,255,0.15)", color: "white", border: "1px solid rgba(255,255,255,0.2)", fontSize: 10, padding: "3px 8px" }}>⏱ {h.time}</span>
              <span className="badge" style={{ background: "rgba(255,255,255,0.15)", color: "white", border: "1px solid rgba(255,255,255,0.2)", fontSize: 10, padding: "3px 8px" }}>📊 {h.diff}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Dots */}
      <div style={{ display: "flex", justifyContent: "center", gap: 6, padding: "14px 0" }}>
        {hobbies.map((_, i) => (
          <button key={i} onClick={() => setIdx(i)} style={{
            width: i === idx ? 22 : 7, height: 7, borderRadius: 100, border: "none", cursor: "pointer",
            background: i === idx ? C.coral : C.sandDark, transition: "all .25s",
          }} />
        ))}
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  HOBBY DETAIL
// ═══════════════════════════════════════════════════════
const Detail = ({ hobby: h, onBack, onStart }) => {
  const [done, setDone] = useState(new Set());
  const tog = id => { const n = new Set(done); n.has(id) ? n.delete(id) : n.add(id); setDone(n); };

  return (
    <div className="scr fade" style={{ paddingBottom: 90 }}>
      {/* Hero */}
      <div style={{ height: 350, position: "relative" }}>
        <img src={h.img} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        <div style={{ position: "absolute", inset: 0,
          background: `linear-gradient(to bottom, transparent 25%, ${C.cream}70 65%, ${C.cream} 100%)` }} />
        <button onClick={onBack} style={{
          position: "absolute", top: 52, left: 16, width: 40, height: 40, borderRadius: "50%",
          background: "rgba(255,255,255,0.85)", backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)",
          border: `1px solid ${C.sandDark}`, cursor: "pointer", color: C.nearBlack, fontSize: 18,
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>←</button>
        <div style={{ position: "absolute", bottom: 16, left: 24, right: 24 }}>
          <div style={{
            display: "inline-flex", alignItems: "center", gap: 5, padding: "4px 12px", borderRadius: 100,
            background: `${h.catColor}12`, border: `1px solid ${h.catColor}25`, marginBottom: 8,
          }}>
            <span style={{ fontSize: 12 }}>{h.catIcon}</span>
            <span style={{ fontSize: 10, fontWeight: 700, letterSpacing: 1.5, color: h.catColor }}>{h.category.toUpperCase()}</span>
          </div>
          <h1 style={{ fontFamily: "var(--serif)", fontSize: 36, fontWeight: 700, lineHeight: 1.05, color: C.nearBlack }}>{h.title}</h1>
          <p style={{ fontSize: 14, color: C.driftwood, marginTop: 4 }}>{h.hook}</p>
        </div>
      </div>

      {/* Spec bar */}
      <div style={{ margin: "0 24px 0", padding: "12px 16px", background: C.warmWhite, borderRadius: 14,
        border: `1px solid ${C.sandDark}`, display: "flex", justifyContent: "space-evenly",
        boxShadow: "0 2px 8px rgba(30,26,23,0.04)" }}>
        <Badges cost={h.cost} time={h.time} diff={h.diff} />
      </div>

      <div style={{ padding: "0 24px" }}>
        <Sec title="Why people love it">
          <p style={{ fontSize: 15, lineHeight: 1.65, color: C.espresso }}>{h.whyLove}</p>
        </Sec>

        <Sec title={`What makes it ${h.diff.toLowerCase()}`}>
          <p style={{ fontSize: 15, lineHeight: 1.65, color: C.espresso }}>{h.diffExplain}</p>
        </Sec>

        <Sec title="Starter Kit" right="Start small.">
          {h.kit.map((it, i) => (
            <div key={i} style={{
              padding: 14, marginBottom: 8, background: C.warmWhite, borderRadius: 12,
              border: `1px solid ${C.sandDark}`, display: "flex", gap: 12, alignItems: "flex-start",
            }}>
              <div style={{
                width: 34, height: 34, borderRadius: "50%", flexShrink: 0,
                background: it.opt ? C.sand : C.coralPale,
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 14, color: it.opt ? C.warmGray : C.coral,
              }}>{it.opt ? "+" : "✓"}</div>
              <div style={{ flex: 1 }}>
                <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                  <span style={{ fontSize: 14, fontWeight: 600, color: C.nearBlack }}>{it.name}</span>
                  {it.opt && <span style={{ fontSize: 9, fontWeight: 700, letterSpacing: 1.5, color: C.warmGray }}>OPTIONAL</span>}
                </div>
                <p style={{ fontSize: 13, color: C.driftwood, marginTop: 2 }}>{it.desc}</p>
              </div>
              {it.cost > 0 && <span style={{ fontFamily: "var(--mono)", fontSize: 13, fontWeight: 600, color: C.coral, whiteSpace: "nowrap" }}>~{it.cost}</span>}
            </div>
          ))}
        </Sec>

        <Sec title="Beginner Pitfalls">
          {h.pitfalls.map((p, i) => (
            <div key={i} style={{ display: "flex", gap: 12, marginBottom: 10, alignItems: "flex-start" }}>
              <div style={{ width: 6, height: 6, borderRadius: "50%", background: C.amber, flexShrink: 0, marginTop: 7 }} />
              <p style={{ fontSize: 14, lineHeight: 1.5, color: C.espresso }}>{p}</p>
            </div>
          ))}
        </Sec>

        <Sec title="Your Roadmap" right={`${h.roadmap.length} steps`}>
          {h.roadmap.map((st, i) => {
            const d = done.has(st.id);
            const cur = !d && (i === 0 || done.has(h.roadmap[i - 1].id));
            return (
              <div key={st.id} style={{
                padding: 14, marginBottom: 8, borderRadius: 12, transition: "all .25s",
                background: cur ? C.coralPale : C.warmWhite,
                border: `${cur ? 1.5 : 1}px solid ${cur ? C.coral + "35" : C.sandDark}`,
                display: "flex", gap: 12, alignItems: "flex-start",
              }}>
                <button onClick={() => tog(st.id)} style={{
                  width: 28, height: 28, borderRadius: "50%", flexShrink: 0, cursor: "pointer", marginTop: 1,
                  background: d ? C.coral : "transparent",
                  border: `${cur ? 2 : 1.5}px solid ${d ? C.coral : cur ? C.coral + "60" : C.stone}`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  transition: "all .2s", color: "white", fontSize: 14,
                }}>
                  {d ? <span style={{ animation: "pop .4s" }}>✓</span> :
                    <span style={{ fontFamily: "var(--mono)", fontSize: 11, color: cur ? C.coral : C.warmGray }}>{i + 1}</span>}
                </button>
                <div style={{ flex: 1 }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <span style={{ fontSize: 15, fontWeight: 600, color: d ? C.warmGray : C.nearBlack,
                      textDecoration: d ? "line-through" : "none", transition: "all .2s" }}>{st.title}</span>
                    <span style={{ padding: "2px 8px", borderRadius: 6, background: C.sand, fontFamily: "var(--mono)",
                      fontSize: 11, color: C.driftwood }}>{st.min}m</span>
                  </div>
                  <p style={{ fontSize: 13, color: d ? C.stone : C.driftwood, marginTop: 3, lineHeight: 1.4 }}>{st.desc}</p>
                  {st.ms && (
                    <div style={{ display: "inline-flex", alignItems: "center", gap: 4, marginTop: 8,
                      padding: "3px 10px", borderRadius: 100, fontSize: 10, fontWeight: 700, letterSpacing: .5,
                      background: C.amberPale, border: `1px solid ${C.amber}30`, color: C.amberDeep }}>🏆 {st.ms}</div>
                  )}
                </div>
              </div>
            );
          })}
        </Sec>
      </div>

      {/* CTA */}
      <div style={{ position: "sticky", bottom: 0, padding: "14px 24px 22px",
        background: `linear-gradient(to bottom, transparent, ${C.cream} 30%)` }}>
        <button className="btn-main" onClick={onStart}>▶ TRY THIS TODAY</button>
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  QUICKSTART
// ═══════════════════════════════════════════════════════
const Quickstart = ({ hobby: h, onBack }) => {
  const [done, setDone] = useState(new Set());
  const [on, setOn] = useState(false);
  const [sec, setSec] = useState(25 * 60);
  const ref = useRef(null);

  const steps = h.roadmap.slice(0, 3);
  const prog = steps.length ? done.size / steps.length : 0;

  const toggle = () => {
    if (on) { clearInterval(ref.current); setOn(false); }
    else { setOn(true); ref.current = setInterval(() => setSec(s => { if (s <= 1) { clearInterval(ref.current); return 0; } return s - 1; }), 1000); }
  };
  useEffect(() => () => clearInterval(ref.current), []);

  const fmt = `${String(Math.floor(sec / 60)).padStart(2, "0")}:${String(sec % 60).padStart(2, "0")}`;

  return (
    <div className="scr slup" style={{ padding: "0 24px 36px", display: "flex", flexDirection: "column", height: "100%" }}>
      <div style={{ padding: "52px 0 14px", display: "flex", alignItems: "center" }}>
        <button onClick={onBack} style={{ background: "none", border: "none", color: C.nearBlack, fontSize: 22, cursor: "pointer", padding: "4px 8px" }}>✕</button>
        <span style={{ flex: 1, textAlign: "center", fontSize: 15, fontWeight: 600, color: C.nearBlack }}>{h.title}</span>
        <div style={{ width: 36 }} />
      </div>

      <h1 style={{ fontFamily: "var(--serif)", fontSize: 32, fontWeight: 700, lineHeight: 1.1, color: C.nearBlack, marginBottom: 4 }}>
        First 30<br/>Minutes
      </h1>
      <p style={{ fontSize: 14, color: C.driftwood, marginBottom: 20 }}>Complete these steps to get started. No pressure.</p>

      {/* Timer */}
      <div style={{ padding: 18, borderRadius: 16, background: C.sand, border: `1px solid ${C.sandDark}`,
        display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 20 }}>
        <span style={{ fontFamily: "var(--mono)", fontSize: 40, fontWeight: 700,
          color: on ? C.coral : C.warmGray, letterSpacing: -1 }}>{fmt}</span>
        <button onClick={toggle} style={{
          width: 50, height: 50, borderRadius: "50%", cursor: "pointer",
          background: on ? C.coralPale : C.warmWhite,
          border: `1.5px solid ${on ? C.coral : C.sandDark}`,
          color: on ? C.coral : C.driftwood, fontSize: 20,
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>{on ? "⏸" : "▶"}</button>
      </div>

      {/* Progress */}
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
        <div style={{ flex: 1, height: 6, borderRadius: 100, background: C.sandDark, overflow: "hidden" }}>
          <div style={{ height: "100%", borderRadius: 100, background: C.coral,
            width: `${prog * 100}%`, transition: "width .4s cubic-bezier(.16,1,.3,1)" }} />
        </div>
        <span style={{ fontFamily: "var(--mono)", fontSize: 14, fontWeight: 600, color: C.coral }}>{done.size}/{steps.length}</span>
      </div>

      {/* Tasks */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 10 }}>
        {steps.map(st => {
          const d = done.has(st.id);
          return (
            <button key={st.id} onClick={() => { const n = new Set(done); n.has(st.id) ? n.delete(st.id) : n.add(st.id); setDone(n); }}
              style={{ padding: 14, borderRadius: 12, textAlign: "left", cursor: "pointer",
                background: d ? C.coralPale : C.warmWhite, border: `1px solid ${d ? C.coral + "35" : C.sandDark}`,
                display: "flex", alignItems: "center", gap: 14, transition: "all .25s" }}>
              <div style={{ width: 32, height: 32, borderRadius: "50%", flexShrink: 0,
                background: d ? C.coral : "transparent", border: `2px solid ${d ? C.coral : C.stone}`,
                display: "flex", alignItems: "center", justifyContent: "center",
                color: "white", fontSize: 16, fontWeight: 700, transition: "all .2s" }}>
                {d && <span style={{ animation: "pop .4s" }}>✓</span>}
              </div>
              <div>
                <div style={{ fontSize: 15, fontWeight: 600, color: d ? C.warmGray : C.nearBlack,
                  textDecoration: d ? "line-through" : "none", transition: "all .2s" }}>{st.title}</div>
                <div style={{ fontFamily: "var(--mono)", fontSize: 11, color: C.warmGray, marginTop: 2 }}>~{st.min} min</div>
              </div>
            </button>
          );
        })}
      </div>

      <div style={{ paddingTop: 14 }}>
        {done.size === steps.length ? <button className="btn-main">NEXT STEP →</button> :
          <button className="btn-sec" onClick={onBack}>Skip for now →</button>}
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  MY STUFF
// ═══════════════════════════════════════════════════════
const MyStuff = ({ onTap }) => {
  const [tab, setTab] = useState(0);
  const tabs = ["Saved", "Trying", "Active", "Done"];
  const data = [hobbies, hobbies.slice(0, 2), hobbies.slice(0, 1), []];

  return (
    <div className="scr" style={{ paddingBottom: 82 }}>
      <div style={{ padding: "52px 24px 10px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ fontFamily: "var(--serif)", fontSize: 26, fontWeight: 700, color: C.nearBlack }}>My Stuff</h1>
        <div style={{ width: 38, height: 38, borderRadius: "50%", background: C.sand, display: "flex",
          alignItems: "center", justifyContent: "center", fontSize: 16 }}>⚙️</div>
      </div>

      <div style={{ display: "flex", gap: 8, padding: "0 24px 16px" }}>
        {[{ v: "3", l: "Trying", c: C.coral }, { v: "1", l: "Active", c: C.sage },
          { v: "5", l: "Saved", c: C.indigo }].map(s => (
          <div key={s.l} style={{ flex: 1, padding: "11px 0", borderRadius: 12, textAlign: "center",
            background: `${s.c}10`, border: `1px solid ${s.c}22` }}>
            <div style={{ fontFamily: "var(--mono)", fontSize: 18, fontWeight: 700, color: s.c }}>{s.v}</div>
            <div style={{ fontSize: 11, color: C.warmGray, marginTop: 2 }}>{s.l}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "flex", borderBottom: `1px solid ${C.sandDark}`, margin: "0 24px" }}>
        {tabs.map((t, i) => (
          <button key={t} onClick={() => setTab(i)} style={{
            flex: 1, padding: "10px 0", background: "none", border: "none", cursor: "pointer",
            borderBottom: `2px solid ${tab === i ? C.coral : "transparent"}`,
            color: tab === i ? C.coral : C.warmGray, fontSize: 13, fontWeight: 600, transition: "all .2s",
          }}>{t}</button>
        ))}
      </div>

      <div style={{ padding: "14px 24px" }}>
        {data[tab].length === 0 ? (
          <div style={{ textAlign: "center", paddingTop: 56 }}>
            <div style={{ fontSize: 44, marginBottom: 14, opacity: .4 }}>🧭</div>
            <p style={{ color: C.warmGray, fontSize: 15 }}>Nothing here yet</p>
            <p style={{ color: C.coral, fontSize: 13, fontWeight: 600, marginTop: 10, cursor: "pointer" }}>Start discovering →</p>
          </div>
        ) : data[tab].map((h, i) => {
          const pr = (i + 1) / h.roadmap.length;
          return (
            <div key={h.id} onClick={() => onTap(h)} className="slup" style={{
              animationDelay: `${i * .06}s`, animationFillMode: "both",
              padding: 14, marginBottom: 8, background: C.warmWhite, borderRadius: 14,
              border: `1px solid ${C.sandDark}`, display: "flex", gap: 12, alignItems: "center", cursor: "pointer",
            }}>
              <img src={h.img} alt="" style={{ width: 50, height: 50, borderRadius: 10, objectFit: "cover" }} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600, color: C.nearBlack }}>{h.title}</div>
                {tab > 0 && tab < 3 ? (
                  <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 5 }}>
                    <div style={{ flex: 1, height: 4, borderRadius: 100, background: C.sandDark, overflow: "hidden" }}>
                      <div style={{ height: "100%", width: `${pr * 100}%`, background: C.coral, borderRadius: 100 }} />
                    </div>
                    <span style={{ fontFamily: "var(--mono)", fontSize: 11, color: C.coral }}>{Math.round(pr * 100)}%</span>
                  </div>
                ) : <span style={{ fontSize: 12, color: C.warmGray }}>{h.cost}</span>}
              </div>
              {tab > 0 && tab < 3 && (
                <div style={{ padding: "4px 8px", borderRadius: 8, fontSize: 11, fontFamily: "var(--mono)",
                  background: C.amberPale, color: C.amberDeep, border: `1px solid ${C.amber}20` }}>🔥 {i * 2 + 1}</div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  EXPLORE
// ═══════════════════════════════════════════════════════
const Explore = () => {
  const [filt, setFilt] = useState(false);
  const [mc, setMc] = useState(200);
  const [mt, setMt] = useState(5);

  return (
    <div className="scr" style={{ paddingBottom: 82 }}>
      <div style={{ padding: "52px 24px 0" }}>
        <h1 style={{ fontFamily: "var(--serif)", fontSize: 26, fontWeight: 700, color: C.nearBlack, marginBottom: 14 }}>Explore</h1>

        <div style={{ display: "flex", gap: 8, marginBottom: 10 }}>
          <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 8, padding: "0 14px",
            background: C.warmWhite, borderRadius: 12, border: `1px solid ${C.sandDark}`, height: 46 }}>
            <span style={{ fontSize: 15, opacity: .35 }}>🔍</span>
            <span style={{ fontSize: 14, color: C.warmGray }}>I want something relaxing...</span>
          </div>
          <button onClick={() => setFilt(!filt)} style={{
            width: 46, height: 46, borderRadius: 12, cursor: "pointer",
            background: filt ? C.coralPale : C.warmWhite,
            border: `1px solid ${filt ? C.coral + "40" : C.sandDark}`,
            color: filt ? C.coral : C.driftwood, fontSize: 16,
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>⚙</button>
        </div>

        {filt && (
          <div className="slup" style={{ padding: 14, background: C.warmWhite, borderRadius: 12,
            border: `1px solid ${C.sandDark}`, marginBottom: 10 }}>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: C.driftwood, marginBottom: 4 }}>
              <span>Max starter cost</span><span style={{ fontFamily: "var(--mono)", color: C.coral }}>CHF {mc}</span></div>
            <input type="range" min={0} max={500} step={50} value={mc} onChange={e => setMc(+e.target.value)}
              style={{ width: "100%", accentColor: C.coral, marginBottom: 10 }} />
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: C.driftwood, marginBottom: 4 }}>
              <span>Max hours/week</span><span style={{ fontFamily: "var(--mono)", color: C.amber }}>{mt}h</span></div>
            <input type="range" min={1} max={10} step={1} value={mt} onChange={e => setMt(+e.target.value)}
              style={{ width: "100%", accentColor: C.amber }} />
          </div>
        )}

        <div className="over" style={{ marginBottom: 10, marginTop: 6 }}>QUICK PICKS</div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginBottom: 24 }}>
          {["🧘 Relaxing", "👥 Social", "💰 Cheap", "⚡ Quick start", "🌿 Outdoors"].map(p => (
            <span key={p} style={{ padding: "8px 14px", borderRadius: 100, fontSize: 12, fontWeight: 600,
              background: C.sand, border: `1px solid ${C.sandDark}`, color: C.driftwood, cursor: "pointer" }}>{p}</span>
          ))}
        </div>

        <div className="over" style={{ marginBottom: 12 }}>CATEGORIES</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 28 }}>
          {categories.map(c => (
            <button key={c.id} className="slup" style={{
              padding: 18, borderRadius: 16, textAlign: "center", cursor: "pointer",
              background: C.warmWhite, border: `1px solid ${c.color}18`,
              display: "flex", flexDirection: "column", alignItems: "center", gap: 8,
            }}>
              <div style={{ width: 50, height: 50, borderRadius: "50%", background: `${c.color}12`,
                display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22 }}>{c.icon}</div>
              <span style={{ fontSize: 14, fontWeight: 600, color: C.nearBlack }}>{c.name}</span>
              <span style={{ fontSize: 11, color: C.warmGray }}>{c.count} hobbies</span>
            </button>
          ))}
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14 }}>
          <h3 style={{ fontSize: 19, fontWeight: 700, color: C.nearBlack }}>Curated Packs</h3>
          <span style={{ padding: "3px 10px", borderRadius: 100, fontSize: 9, fontWeight: 700, letterSpacing: 1,
            background: C.indigoPale, color: C.indigo }}>COMING SOON</span>
        </div>
        {[["📚", "10 Hobbies for Introverts"], ["💸", "Weekend Hobbies Under CHF 50"], ["🤝", "Hobbies That Build Community"]].map(([e, t]) => (
          <div key={t} style={{ padding: 14, marginBottom: 8, borderRadius: 14, background: C.warmWhite,
            border: `1px solid ${C.sandDark}`, display: "flex", alignItems: "center", gap: 12 }}>
            <span style={{ fontSize: 26 }}>{e}</span>
            <span style={{ flex: 1, fontSize: 15, fontWeight: 600, color: C.nearBlack }}>{t}</span>
            <span style={{ fontSize: 14, opacity: .2 }}>🔒</span>
          </div>
        ))}
        <div style={{ height: 32 }} />
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════
//  SEARCH
// ═══════════════════════════════════════════════════════
const Search = () => (
  <div className="scr" style={{ padding: "52px 24px 82px" }}>
    <h1 style={{ fontFamily: "var(--serif)", fontSize: 26, fontWeight: 700, color: C.nearBlack, marginBottom: 14 }}>Search</h1>
    <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "0 14px",
      background: C.warmWhite, borderRadius: 12, border: `1px solid ${C.sandDark}`, height: 46, marginBottom: 28 }}>
      <span style={{ fontSize: 15, opacity: .35 }}>🔍</span>
      <span style={{ fontSize: 14, color: C.warmGray }}>Search hobbies, categories...</span>
    </div>
    <div className="over" style={{ marginBottom: 12 }}>POPULAR SEARCHES</div>
    <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
      {["pottery", "bouldering", "sourdough", "chess", "skateboarding", "journaling", "archery", "calligraphy"].map(s => (
        <span key={s} style={{ padding: "8px 14px", borderRadius: 100, fontSize: 13, fontWeight: 500,
          background: C.sand, border: `1px solid ${C.sandDark}`, color: C.driftwood }}>{s}</span>
      ))}
    </div>
  </div>
);

// ═══════════════════════════════════════════════════════
//  APP ROOT
// ═══════════════════════════════════════════════════════
export default function App() {
  const [scr, setScr] = useState("onboard");
  const [tab, setTab] = useState(0);
  const [hobby, setHobby] = useState(null);

  const navs = [
    { ic: "🧭", label: "Discover" },
    { ic: "📱", label: "Explore" },
    { ic: "📂", label: "My Stuff" },
    { ic: "🔍", label: "Search" },
  ];

  const openDetail = h => { setHobby(h); setScr("detail"); };

  const render = () => {
    switch (scr) {
      case "onboard": return <Onboarding onDone={() => setScr("main")} />;
      case "detail": return <Detail hobby={hobby} onBack={() => setScr("main")} onStart={() => setScr("quick")} />;
      case "quick": return <Quickstart hobby={hobby} onBack={() => setScr("detail")} />;
      default: return (
        <>
          <div style={{ display: tab === 0 ? "block" : "none", height: "100%" }}><Feed onTap={openDetail} /></div>
          <div style={{ display: tab === 1 ? "block" : "none", height: "100%" }}><Explore /></div>
          <div style={{ display: tab === 2 ? "block" : "none", height: "100%" }}><MyStuff onTap={openDetail} /></div>
          <div style={{ display: tab === 3 ? "block" : "none", height: "100%" }}><Search /></div>
          <div className="bnav">
            {navs.map((n, i) => (
              <button key={i} className="ni" onClick={() => setTab(i)}>
                <span style={{ fontSize: 22, filter: tab === i ? "none" : "grayscale(1) opacity(.35)", transition: "all .2s" }}>{n.ic}</span>
                <span style={{ color: tab === i ? C.coral : C.warmGray, transition: "color .2s", fontFamily: "var(--sans)" }}>{n.label}</span>
              </button>
            ))}
          </div>
        </>
      );
    }
  };

  return (
    <div style={{
      width: "100%", minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center",
      padding: "40px 20px", fontFamily: "var(--sans)",
      background: `linear-gradient(145deg, ${C.sand} 0%, ${C.cream} 40%, #f0e8df 100%)`,
    }}>
      <Styles />
      <div style={{ display: "flex", gap: 56, alignItems: "center", flexWrap: "wrap", justifyContent: "center" }}>
        <div className="phone">
          <div className="notch" />
          <div className="homebar" />
          {render()}
        </div>

        {/* Side panel */}
        <div style={{ maxWidth: 300, color: C.espresso }}>
          <div style={{ fontFamily: "var(--mono)", fontSize: 10, fontWeight: 600, letterSpacing: 3,
            color: C.coral, marginBottom: 10, textTransform: "uppercase" }}>Interactive Prototype</div>
          <h2 style={{ fontFamily: "var(--serif)", fontSize: 30, fontWeight: 700, color: C.nearBlack, lineHeight: 1.15, marginBottom: 14 }}>
            TrySomething
          </h2>
          <p style={{ fontSize: 13, lineHeight: 1.6, color: C.driftwood, marginBottom: 24 }}>
            Sunset Analog palette — warm coral, golden amber, soft indigo on cream. Tap through onboarding, browse hobbies, explore the detail page, and try the quickstart flow.
          </p>

          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {[
              { l: "Onboarding", d: "3-page quiz flow", a: scr === "onboard" },
              { l: "Discover Feed", d: "Swipe hobby cards", a: scr === "main" && tab === 0 },
              { l: "Hobby Detail", d: "Conversion + roadmap", a: scr === "detail" },
              { l: "Quickstart", d: "First 30 minutes", a: scr === "quick" },
              { l: "My Stuff", d: "Saved / Trying / Active", a: scr === "main" && tab === 2 },
              { l: "Explore", d: "Categories + filters", a: scr === "main" && tab === 1 },
              { l: "Search", d: "Find any hobby", a: scr === "main" && tab === 3 },
            ].map(s => (
              <div key={s.l} style={{
                padding: "9px 12px", borderRadius: 10, display: "flex", alignItems: "center", gap: 10,
                background: s.a ? C.coralPale : "transparent",
                border: `1px solid ${s.a ? C.coral + "25" : "transparent"}`, transition: "all .2s",
              }}>
                <div style={{ width: 7, height: 7, borderRadius: "50%",
                  background: s.a ? C.coral : C.stone,
                  boxShadow: s.a ? `0 0 8px ${C.coral}40` : "none", transition: "all .3s" }} />
                <div>
                  <div style={{ fontSize: 13, fontWeight: 600, color: s.a ? C.nearBlack : C.driftwood }}>{s.l}</div>
                  <div style={{ fontSize: 11, color: C.warmGray }}>{s.d}</div>
                </div>
              </div>
            ))}
          </div>

          <div style={{ marginTop: 24, padding: "12px 14px", borderRadius: 14, background: C.warmWhite,
            border: `1px solid ${C.sandDark}` }}>
            <div style={{ fontFamily: "var(--mono)", fontSize: 10, letterSpacing: 2, color: C.warmGray, marginBottom: 8 }}>PALETTE</div>
            <div style={{ display: "flex", gap: 5 }}>
              {[C.coral, C.amber, C.indigo, C.sage, C.rose, C.sky].map(c => (
                <div key={c} style={{ width: 26, height: 26, borderRadius: 8, background: c }} />
              ))}
            </div>
            <div style={{ display: "flex", gap: 10, marginTop: 10, fontSize: 11, color: C.driftwood }}>
              <span style={{ fontFamily: "var(--serif)" }}>Source Serif 4</span>
              <span>DM Sans</span>
              <span style={{ fontFamily: "var(--mono)" }}>IBM Plex</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
