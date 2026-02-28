import { useState, useEffect, useRef } from "react";

// ═══════════════════════════════════════════════════════
//  PALETTE (Sunset Analog)
// ═══════════════════════════════════════════════════════
const C = {
  cream: "#FFF9F5", warmWhite: "#FFFDFB", sand: "#F5EDE6", sandDark: "#E8DDD3",
  stone: "#D4C8BC", warmGray: "#A89B8E", driftwood: "#7A6E62", espresso: "#524840",
  darkBrown: "#3A322C", nearBlack: "#1E1A17",
  coral: "#E8734A", coralLight: "#F0956E", coralPale: "#FFF0EB", coralDeep: "#D45E35",
  amber: "#E5A630", amberLight: "#F0C060", amberPale: "#FFF8E8", amberDeep: "#C48B1A",
  indigo: "#5B6AAF", indigoLight: "#7B88C4", indigoPale: "#ECEEF7", indigoDeep: "#444F8A",
  sage: "#7EA47E", sagePale: "#EDF4ED", rose: "#C47878", rosePale: "#F7EDED",
  sky: "#6AA8C4", skyPale: "#EAF3F8", success: "#5EA87E", warning: "#E5A630", error: "#C45858",
};

// ═══════════════════════════════════════════════════════
//  STYLES
// ═══════════════════════════════════════════════════════
const Styles = () => (
  <style>{`
    @import url('https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=DM+Sans:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    :root { --serif: 'Source Serif 4', Georgia, serif; --sans: 'DM Sans', sans-serif; --mono: 'IBM Plex Mono', monospace; }
    body { background: ${C.cream}; }

    .phone {
      width: 360px; height: 720px; background: ${C.cream}; border-radius: 40px;
      overflow: hidden; position: relative; flex-shrink: 0;
      box-shadow: 0 0 0 1px ${C.sandDark}, 0 20px 50px rgba(30,26,23,0.14);
      font-family: var(--sans); color: ${C.nearBlack}; -webkit-font-smoothing: antialiased;
    }
    .notch { position: absolute; top: 0; left: 50%; transform: translateX(-50%);
      width: 140px; height: 30px; background: ${C.nearBlack}; border-radius: 0 0 18px 18px; z-index: 100; }
    .hbar { position: absolute; bottom: 6px; left: 50%; transform: translateX(-50%);
      width: 120px; height: 4px; background: ${C.stone}; border-radius: 100px; z-index: 100; }
    .scr { width: 100%; height: 100%; overflow-y: auto; overflow-x: hidden; scrollbar-width: none; }
    .scr::-webkit-scrollbar { display: none; }

    .fade { animation: fadeIn .3s ease-out; }
    .slup { animation: slUp .35s cubic-bezier(.16,1,.3,1); }
    @keyframes fadeIn { from { opacity: 0 } to { opacity: 1 } }
    @keyframes slUp { from { opacity: 0; transform: translateY(12px) } to { opacity: 1; transform: translateY(0) } }
    @keyframes pop { 0% { transform: scale(0) } 60% { transform: scale(1.15) } 100% { transform: scale(1) } }
    @keyframes pulse { 0%,100% { opacity: 1 } 50% { opacity: .5 } }
    @keyframes breathe { 0%,100% { box-shadow: 0 4px 14px rgba(232,115,74,0.2) } 50% { box-shadow: 0 4px 22px rgba(232,115,74,0.4) } }
    @keyframes fl1 { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-4px) } }

    .badge { display: inline-flex; align-items: center; gap: 3px; padding: 4px 9px; border-radius: 100px;
      font-family: var(--mono); font-size: 10px; font-weight: 600; white-space: nowrap; }
    .bc { background: ${C.coralPale}; color: ${C.coralDeep}; border: 1px solid #f0d0c4; }
    .bt { background: ${C.amberPale}; color: ${C.amberDeep}; border: 1px solid #f0e0b0; }
    .bd { background: ${C.indigoPale}; color: ${C.indigoDeep}; border: 1px solid #ccd0e4; }

    .btn-m { width: 100%; height: 50px; border: none; border-radius: 14px; background: ${C.coral};
      color: white; font-family: var(--sans); font-weight: 700; font-size: 13px; letter-spacing: .6px;
      cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px;
      animation: breathe 2.5s ease-in-out infinite; transition: transform .12s; }
    .btn-m:active { transform: scale(.97); }
    .btn-s { height: 42px; border: 1.5px solid ${C.coral}40; border-radius: 12px; background: ${C.coralPale};
      color: ${C.coral}; font-family: var(--sans); font-weight: 600; font-size: 12px; cursor: pointer;
      display: flex; align-items: center; justify-content: center; gap: 5px; padding: 0 16px; }
    .over { font-size: 10px; font-weight: 700; letter-spacing: 2px; color: ${C.warmGray}; text-transform: uppercase; }
  `}</style>
);

// ═══════════════════════════════════════════════════════
//  FEATURE DATA
// ═══════════════════════════════════════════════════════
const currentFeatures = [
  { cat: "Discovery", icon: "🧭", features: [
    { name: "Discovery Feed", desc: "Vertical swipe cards with hobby previews, cost/time/difficulty badges", status: "v1" },
    { name: "Explore Categories", desc: "9 category grid — creative, outdoors, fitness, maker, music, food, collecting, mind, social", status: "v1" },
    { name: "Intent Prompts", desc: "Quick filters like 'something relaxing', 'something cheap', 'get me outside'", status: "v1" },
    { name: "Search", desc: "Search hobbies by name, popular searches", status: "v1" },
    { name: "Save / Shortlist", desc: "Bookmark hobbies to 'Try Later' list", status: "v1" },
    { name: "Category Filtering", desc: "Filter feed by category chips", status: "v1" },
  ]},
  { cat: "Hobby Detail", icon: "📋", features: [
    { name: "Spec Bar", desc: "Cost range, time commitment, difficulty — always visible", status: "v1" },
    { name: "Why People Love It", desc: "Emotional hook — what makes this hobby special", status: "v1" },
    { name: "Starter Kit", desc: "Minimal gear list with costs and optional items", status: "v1" },
    { name: "Beginner Pitfalls", desc: "Common mistakes to avoid — super valuable content", status: "v1" },
    { name: "Roadmap", desc: "5-12 step progression with milestones", status: "v1" },
    { name: "Difficulty Explanation", desc: "What specifically makes it hard", status: "v1" },
    { name: "Related Hobbies", desc: "Carousel of similar hobbies", status: "v1" },
  ]},
  { cat: "Progress", icon: "📈", features: [
    { name: "First 30 Minutes", desc: "Quickstart checklist — 3-5 tasks to do right now", status: "v1" },
    { name: "Roadmap Steps", desc: "Progressive steps with checkboxes", status: "v1" },
    { name: "Milestones", desc: "Named achievement points in the roadmap", status: "v1" },
    { name: "Progress Tracking", desc: "Percentage complete per hobby", status: "v1" },
    { name: "Soft Streaks", desc: "Day count without aggressive gamification", status: "v1" },
    { name: "25-min Timer", desc: "Optional focus timer for quickstart sessions", status: "v1" },
  ]},
  { cat: "Personalization", icon: "🎯", features: [
    { name: "Onboarding Quiz", desc: "Time, budget, solo/social, vibe preferences", status: "v1" },
    { name: "Vibe Matching", desc: "Recommendations based on quiz answers", status: "v1" },
    { name: "My Stuff Tabs", desc: "Saved / Trying / Active / Completed organization", status: "v1" },
  ]},
  { cat: "Sharing", icon: "📤", features: [
    { name: "Hobby Card Share", desc: "'I'm trying pottery this week' shareable image", status: "v1" },
    { name: "Milestone Card Share", desc: "Share roadmap completion cards", status: "v1" },
  ]},
  { cat: "Monetization", icon: "💰", features: [
    { name: "Affiliate Starter Kits", desc: "Amazon/partner links from hobby detail page", status: "v1" },
    { name: "Curated Packs", desc: "'10 hobbies for introverts' — premium content", status: "v1.5" },
    { name: "Partner Referrals", desc: "Local classes, workshops, studios", status: "v1.5" },
  ]},
];

const newFeatures = [
  { cat: "Social & Community", icon: "👥", priority: "High", features: [
    { id: "buddy", name: "Buddy Mode", desc: "Invite a friend to try a hobby together. Shared progress, gentle nudges, celebrate milestones together. Lower dropout rate.", mockup: "buddy" },
    { id: "journal", name: "Hobby Journal", desc: "Photo + text entries per hobby. 'My first pinch pot looked terrible but I loved it.' Private by default, shareable by choice.", mockup: "journal" },
    { id: "local", name: "Local Discovery", desc: "Find people trying the same hobby near you. Not a social network — just 'Sarah in Zürich also started pottery this week'. Opt-in.", mockup: "local" },
    { id: "stories", name: "Community Stories", desc: "Short stories from real people: 'I started bouldering 6 months ago, here's what changed.' Curated, not UGC chaos.", mockup: "stories" },
  ]},
  { cat: "Smart Recommendations", icon: "🧠", priority: "High", features: [
    { id: "combo", name: "Hobby Combos", desc: "'People who love pottery also try sketching.' Suggest complementary hobbies that share skills or vibes.", mockup: "combo" },
    { id: "seasonal", name: "Seasonal Picks", desc: "Context-aware suggestions: outdoor hobbies in spring, indoor crafts in winter, holiday-themed activities in December.", mockup: "seasonal" },
    { id: "mood", name: "Mood Match", desc: "'I'm feeling stressed' → relaxing hobbies. 'I'm bored' → high-energy options. Emotional entry point instead of category browsing.", mockup: "mood" },
    { id: "reonboard", name: "Re-engagement Quiz", desc: "After 2 weeks inactive: 'Has anything changed? Update your vibe.' Re-personalize without starting over.", mockup: null },
  ]},
  { cat: "Deeper Content", icon: "📚", priority: "Medium", features: [
    { id: "cost-calc", name: "Cost Calculator", desc: "Interactive breakdown: starter vs 3-month vs 1-year costs. 'Sourdough costs CHF 5/month after initial setup.' Comparison view across hobbies.", mockup: "costcalc" },
    { id: "video-tips", name: "60-Second Tips", desc: "Short curated video clips for each roadmap step. Not courses — just 'watch this before you try step 3.' Sourced from YouTube creators with permission.", mockup: "videotips" },
    { id: "gear-alt", name: "Budget Alternatives", desc: "For each starter kit item: DIY option, budget option, premium option. 'Dutch oven alternative: any oven-safe pot with a lid.'", mockup: "gearalt" },
    { id: "faq", name: "Beginner FAQ", desc: "Community-sourced Q&A per hobby. 'Can I use regular flour for sourdough?' Upvoted answers, no noise.", mockup: "faq" },
    { id: "creator-roadmaps", name: "Creator Roadmaps", desc: "Let experienced hobbyists publish their own roadmaps. 'My pottery journey: wheel-throwing focus.' Verified quality.", mockup: null },
  ]},
  { cat: "Gamification (Tasteful)", icon: "🏆", priority: "Medium", features: [
    { id: "identity", name: "Identity Badges", desc: "'I'm becoming a potter.' Evolving identity label that changes as you progress. Not achievement spam — a single evolving title.", mockup: "identity" },
    { id: "challenge", name: "Weekly Challenge", desc: "One micro-challenge per week: 'Try a new hobby for 15 minutes.' Or 'Complete 2 roadmap steps.' Opt-in, low pressure.", mockup: "challenge" },
    { id: "year-review", name: "Year in Hobbies", desc: "Annual recap: hobbies tried, hours spent, milestones hit, money invested. Shareable Spotify-Wrapped style.", mockup: "yearreview" },
    { id: "collect", name: "Hobby Passport", desc: "Stamp-style collection page. Each hobby you try gets a stamp. Visual, tactile, satisfying to fill.", mockup: "passport" },
  ]},
  { cat: "Utility & Tools", icon: "🔧", priority: "Medium", features: [
    { id: "schedule", name: "Hobby Scheduler", desc: "Block time in your calendar for hobby sessions. 'Tuesday 7pm: Pottery — Step 3: Slab plate.' Integrates with Google/Apple Calendar.", mockup: "schedule" },
    { id: "shopping", name: "Shopping List", desc: "Aggregate starter kit items across saved hobbies into one shopping list. Checkable, with price estimates and links.", mockup: "shopping" },
    { id: "compare", name: "Compare Mode", desc: "Side-by-side comparison of 2-3 hobbies. Cost, time, difficulty, vibe overlap. For the 'I can't decide' moments.", mockup: "compare" },
    { id: "notes", name: "Personal Notes", desc: "Add private notes to any roadmap step. 'Used brand X clay, worked great.' Your knowledge base grows with you.", mockup: "notes" },
  ]},
  { cat: "AI Features", icon: "✨", priority: "Low (v2+)", features: [
    { id: "ai-roadmap", name: "AI Roadmap Generator", desc: "Generate personalized roadmaps based on your skill level, time, and goals. 'I have 1h/week and want to make a mug in 30 days.'", mockup: "airoadmap" },
    { id: "ai-tips", name: "AI Beginner Coach", desc: "Chat with an AI that knows your hobby progress. 'My sourdough is too dense, what am I doing wrong?' Context-aware advice.", mockup: "aicoach" },
    { id: "ai-summary", name: "Smart Summaries", desc: "AI-generated hobby summaries personalized to your preferences. 'Based on your love of relaxing solo activities, here's why you'll love calligraphy.'", mockup: null },
    { id: "ai-image", name: "Progress Vision", desc: "Upload a photo of your work, AI gives encouraging feedback and suggests next steps. Not judging — coaching.", mockup: null },
  ]},
];

// ═══════════════════════════════════════════════════════
//  PHONE MOCKUP SCREENS
// ═══════════════════════════════════════════════════════

const BuddyMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Buddy Mode</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 16 }}>Try hobbies together with a friend</p>
    <div style={{ padding: 14, borderRadius: 14, background: C.coralPale, border: `1px solid ${C.coral}20`, marginBottom: 12 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
        <div style={{ display: "flex" }}>
          <div style={{ width: 36, height: 36, borderRadius: "50%", background: C.coral, color: "white", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14, fontWeight: 700 }}>R</div>
          <div style={{ width: 36, height: 36, borderRadius: "50%", background: C.indigo, color: "white", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14, fontWeight: 700, marginLeft: -10, border: `2px solid ${C.coralPale}` }}>M</div>
        </div>
        <div>
          <div style={{ fontSize: 14, fontWeight: 700 }}>You & Marco</div>
          <div style={{ fontSize: 11, color: C.coral }}>Trying Pottery together</div>
        </div>
      </div>
      <div style={{ display: "flex", gap: 8 }}>
        <div style={{ flex: 1, padding: 10, borderRadius: 10, background: C.warmWhite, textAlign: "center" }}>
          <div style={{ fontSize: 10, color: C.warmGray, marginBottom: 2 }}>You</div>
          <div style={{ fontFamily: "var(--mono)", fontSize: 16, fontWeight: 700, color: C.coral }}>3/5</div>
          <div style={{ fontSize: 10, color: C.driftwood }}>steps done</div>
        </div>
        <div style={{ flex: 1, padding: 10, borderRadius: 10, background: C.warmWhite, textAlign: "center" }}>
          <div style={{ fontSize: 10, color: C.warmGray, marginBottom: 2 }}>Marco</div>
          <div style={{ fontFamily: "var(--mono)", fontSize: 16, fontWeight: 700, color: C.indigo }}>2/5</div>
          <div style={{ fontSize: 10, color: C.driftwood }}>steps done</div>
        </div>
      </div>
    </div>
    <div style={{ padding: 12, borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}`, marginBottom: 8 }}>
      <div style={{ fontSize: 12, fontWeight: 600, marginBottom: 6 }}>💬 Activity</div>
      {["Marco completed 'Make a pinch pot' 🎉", "You completed 'Try coil building'", "Marco saved a photo of his first pot"].map((m,i) => (
        <div key={i} style={{ fontSize: 11, color: C.driftwood, padding: "6px 0", borderTop: i ? `1px solid ${C.sand}` : "none" }}>{m}</div>
      ))}
    </div>
    <button className="btn-s" style={{ width: "100%", marginTop: 8 }}>📩 Nudge Marco — "Let's do step 3!"</button>
    <button className="btn-s" style={{ width: "100%", marginTop: 8, borderColor: C.indigo + "40", background: C.indigoPale, color: C.indigo }}>+ Invite another friend</button>
  </div>
);

const JournalMockup = () => {
  const [entries] = useState([
    { date: "Today", text: "My first pinch pot! Walls are uneven but I love it", img: true, hobby: "Pottery" },
    { date: "Yesterday", text: "Tried coil building. Harder than expected but relaxing.", img: false, hobby: "Pottery" },
    { date: "3 days ago", text: "First time at the bouldering gym. Arms are dead.", img: true, hobby: "Bouldering" },
  ]);
  return (
    <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
        <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700 }}>Journal</h2>
        <button style={{ width: 36, height: 36, borderRadius: "50%", background: C.coral, color: "white", border: "none", fontSize: 18, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>+</button>
      </div>
      {entries.map((e, i) => (
        <div key={i} className="slup" style={{ animationDelay: `${i * .08}s`, animationFillMode: "both",
          padding: 14, marginBottom: 10, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <span style={{ fontSize: 10, fontWeight: 700, letterSpacing: 1, color: C.warmGray }}>{e.date.toUpperCase()}</span>
            <span style={{ fontSize: 10, padding: "2px 8px", borderRadius: 100, background: C.sand, color: C.driftwood, fontWeight: 600 }}>{e.hobby}</span>
          </div>
          {e.img && <div style={{ height: 100, borderRadius: 10, background: `linear-gradient(135deg, ${C.sand}, ${C.sandDark})`, marginBottom: 8, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 28, opacity: .4 }}>📷</div>}
          <p style={{ fontSize: 13, lineHeight: 1.5, color: C.espresso }}>{e.text}</p>
        </div>
      ))}
    </div>
  );
};

const LocalMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Near You</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 16 }}>People trying hobbies in Zürich</p>
    <div style={{ height: 140, borderRadius: 14, background: `linear-gradient(135deg, ${C.sagePale}, ${C.skyPale})`, marginBottom: 14, display: "flex", alignItems: "center", justifyContent: "center", position: "relative", overflow: "hidden" }}>
      <span style={{ fontSize: 40, opacity: .3 }}>🗺️</span>
      {[{x:60,y:30,c:C.coral},{x:180,y:60,c:C.indigo},{x:120,y:90,c:C.sage},{x:250,y:40,c:C.amber}].map((p,i) => (
        <div key={i} style={{ position: "absolute", left: p.x, top: p.y, width: 12, height: 12, borderRadius: "50%", background: p.c, border: "2px solid white", boxShadow: `0 0 8px ${p.c}40` }} />
      ))}
    </div>
    {[
      { name: "Sarah K.", hobby: "Pottery", when: "Started this week", dist: "2.3 km" },
      { name: "Alex M.", hobby: "Bouldering", when: "3 weeks in", dist: "0.8 km" },
      { name: "Priya T.", hobby: "Sourdough", when: "Started yesterday", dist: "4.1 km" },
    ].map((p, i) => (
      <div key={i} style={{ padding: 12, marginBottom: 8, borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}`, display: "flex", gap: 10, alignItems: "center" }}>
        <div style={{ width: 40, height: 40, borderRadius: "50%", background: C.sand, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, fontWeight: 700, color: C.driftwood }}>{p.name[0]}</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14, fontWeight: 600 }}>{p.name}</div>
          <div style={{ fontSize: 11, color: C.driftwood }}>{p.hobby} · {p.when}</div>
        </div>
        <span style={{ fontSize: 10, color: C.warmGray, fontFamily: "var(--mono)" }}>{p.dist}</span>
      </div>
    ))}
    <div style={{ padding: 10, borderRadius: 10, background: C.amberPale, border: `1px solid ${C.amber}20`, marginTop: 8 }}>
      <p style={{ fontSize: 11, color: C.amberDeep, textAlign: "center" }}>🔒 Your location is never shared. You only see first names and distance.</p>
    </div>
  </div>
);

const StoriesMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 14 }}>Stories</h2>
    <div style={{ display: "flex", gap: 10, marginBottom: 16, overflowX: "auto", scrollbarWidth: "none" }}>
      {["🎨","💪","🍞","🎵","🧩"].map((e, i) => (
        <div key={i} style={{ width: 60, height: 60, borderRadius: "50%", flexShrink: 0, background: C.sand, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 24, border: i < 2 ? `2px solid ${C.coral}` : `2px solid ${C.sandDark}` }}>{e}</div>
      ))}
    </div>
    <div style={{ borderRadius: 16, overflow: "hidden", background: C.warmWhite, border: `1px solid ${C.sandDark}`, marginBottom: 12 }}>
      <div style={{ height: 160, background: `linear-gradient(135deg, ${C.rosePale}, ${C.coralPale})`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 48, opacity: .3 }}>🏺</div>
      <div style={{ padding: 14 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
          <div style={{ width: 28, height: 28, borderRadius: "50%", background: C.coral, color: "white", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: 700 }}>J</div>
          <div><span style={{ fontSize: 13, fontWeight: 600 }}>Julia</span><span style={{ fontSize: 11, color: C.warmGray }}> · 6 months into pottery</span></div>
        </div>
        <p style={{ fontSize: 13, lineHeight: 1.5, color: C.espresso }}>"I started with zero artistic skills. Now I've made mugs for everyone in my family. The best part? It's the one time my brain actually shuts up."</p>
        <div style={{ display: "flex", gap: 8, marginTop: 10 }}>
          <span style={{ fontSize: 11, padding: "3px 10px", borderRadius: 100, background: C.sand, color: C.driftwood }}>❤️ 142</span>
          <span style={{ fontSize: 11, padding: "3px 10px", borderRadius: 100, background: C.sand, color: C.driftwood }}>🔖 Save</span>
        </div>
      </div>
    </div>
  </div>
);

const ComboMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Hobby Combos</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 16 }}>Hobbies that pair well together</p>
    {[
      { a: "Pottery", b: "Sketching", why: "Both build hand-eye coordination and spatial awareness", overlap: ["creative", "relaxing"] },
      { a: "Bouldering", b: "Yoga", why: "Climbing benefits from flexibility. Yoga aids recovery.", overlap: ["physical", "meditative"] },
    ].map((c, i) => (
      <div key={i} style={{ padding: 14, marginBottom: 10, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
          <span style={{ padding: "6px 12px", borderRadius: 10, background: C.coralPale, fontSize: 13, fontWeight: 600, color: C.coral }}>{c.a}</span>
          <span style={{ fontSize: 16, color: C.stone }}>+</span>
          <span style={{ padding: "6px 12px", borderRadius: 10, background: C.indigoPale, fontSize: 13, fontWeight: 600, color: C.indigo }}>{c.b}</span>
        </div>
        <p style={{ fontSize: 12, color: C.driftwood, lineHeight: 1.5, marginBottom: 8 }}>{c.why}</p>
        <div style={{ display: "flex", gap: 4 }}>
          {c.overlap.map(t => <span key={t} style={{ fontSize: 10, padding: "2px 8px", borderRadius: 100, background: C.sagePale, color: C.sage, fontWeight: 600 }}>#{t}</span>)}
        </div>
      </div>
    ))}
  </div>
);

const SeasonalMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Seasonal Picks</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 16 }}>Perfect for right now — February</p>
    <div style={{ padding: 16, borderRadius: 16, background: `linear-gradient(135deg, ${C.indigoPale}, ${C.skyPale})`, marginBottom: 14 }}>
      <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.indigo, marginBottom: 8 }}>❄️ WINTER WARMERS</div>
      {["Sourdough Baking", "Pottery", "Candle Making", "Journaling"].map((h, i) => (
        <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 0", borderTop: i ? `1px solid ${C.indigo}15` : "none" }}>
          <div style={{ width: 8, height: 8, borderRadius: "50%", background: C.indigo }} />
          <span style={{ fontSize: 13, fontWeight: 500, color: C.indigoDeep }}>{h}</span>
        </div>
      ))}
    </div>
    <div style={{ padding: 16, borderRadius: 16, background: `linear-gradient(135deg, ${C.amberPale}, ${C.coralPale})` }}>
      <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.amber, marginBottom: 8 }}>🎯 COMING IN SPRING</div>
      {["Urban Sketching", "Bouldering", "Gardening", "Trail Running"].map((h, i) => (
        <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 0", borderTop: i ? `1px solid ${C.amber}15` : "none" }}>
          <div style={{ width: 8, height: 8, borderRadius: "50%", background: C.amber }} />
          <span style={{ fontSize: 13, fontWeight: 500, color: C.amberDeep }}>{h}</span>
        </div>
      ))}
    </div>
  </div>
);

const MoodMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 24, fontWeight: 700, marginBottom: 4 }}>How are you feeling?</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 20 }}>We'll find something that fits your energy</p>
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
      {[
        { mood: "Stressed", emoji: "😮‍💨", bg: C.sagePale, c: C.sage, desc: "Calming activities" },
        { mood: "Bored", emoji: "🥱", bg: C.coralPale, c: C.coral, desc: "High-energy fun" },
        { mood: "Lonely", emoji: "🫂", bg: C.indigoPale, c: C.indigo, desc: "Social hobbies" },
        { mood: "Creative", emoji: "✨", bg: C.amberPale, c: C.amber, desc: "Make something" },
        { mood: "Restless", emoji: "⚡", bg: C.rosePale, c: C.rose, desc: "Get moving" },
        { mood: "Curious", emoji: "🤔", bg: C.skyPale, c: C.sky, desc: "Learn new things" },
      ].map(m => (
        <button key={m.mood} style={{
          padding: 16, borderRadius: 16, textAlign: "center", cursor: "pointer",
          background: m.bg, border: `1px solid ${m.c}20`, transition: "all .2s",
          display: "flex", flexDirection: "column", alignItems: "center", gap: 6,
        }}>
          <span style={{ fontSize: 28 }}>{m.emoji}</span>
          <span style={{ fontSize: 14, fontWeight: 700, color: m.c }}>{m.mood}</span>
          <span style={{ fontSize: 10, color: C.driftwood }}>{m.desc}</span>
        </button>
      ))}
    </div>
  </div>
);

const CostCalcMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 14 }}>Cost Calculator</h2>
    <div style={{ padding: 14, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}`, marginBottom: 12 }}>
      <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 10 }}>🏺 Pottery</div>
      {[
        { label: "Starter", cost: "CHF 35", bar: 20, c: C.coral },
        { label: "First 3 months", cost: "CHF 125", bar: 50, c: C.amber },
        { label: "First year", cost: "CHF 380", bar: 85, c: C.indigo },
      ].map((r, i) => (
        <div key={i} style={{ marginBottom: 10 }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 12, marginBottom: 4 }}>
            <span style={{ color: C.driftwood }}>{r.label}</span>
            <span style={{ fontFamily: "var(--mono)", fontWeight: 600, color: r.c }}>{r.cost}</span>
          </div>
          <div style={{ height: 6, borderRadius: 100, background: C.sand }}>
            <div style={{ height: "100%", width: `${r.bar}%`, borderRadius: 100, background: r.c, transition: "width .5s" }} />
          </div>
        </div>
      ))}
    </div>
    <div style={{ padding: 10, borderRadius: 10, background: C.sagePale, border: `1px solid ${C.sage}20` }}>
      <p style={{ fontSize: 11, color: C.sage, textAlign: "center" }}>💡 Pottery costs less than a Netflix + gym combo after month 3</p>
    </div>
  </div>
);

const IdentityMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px", textAlign: "center" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 20 }}>Your Identity</h2>
    <div style={{ width: 120, height: 120, borderRadius: "50%", background: `linear-gradient(135deg, ${C.coralPale}, ${C.amberPale})`, margin: "0 auto 16px", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 48, border: `3px solid ${C.coral}30` }}>🏺</div>
    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.coral, marginBottom: 6 }}>LEVEL 2</div>
    <h3 style={{ fontFamily: "var(--serif)", fontSize: 26, fontWeight: 700, marginBottom: 4 }}>Curious Maker</h3>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 20 }}>You're exploring hands-on creative hobbies</p>
    <div style={{ display: "flex", gap: 8, justifyContent: "center", marginBottom: 20 }}>
      {["🏺 Potter", "🧗 Climber", "🍞 Baker"].map((b, i) => (
        <span key={i} style={{ padding: "6px 12px", borderRadius: 100, fontSize: 11, fontWeight: 600,
          background: i === 0 ? C.coralPale : C.sand, color: i === 0 ? C.coral : C.driftwood,
          border: `1px solid ${i === 0 ? C.coral + "30" : C.sandDark}` }}>{b}</span>
      ))}
    </div>
    <div style={{ textAlign: "left", padding: 14, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
      <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.warmGray, marginBottom: 8 }}>NEXT EVOLUTION</div>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <div style={{ flex: 1, height: 6, borderRadius: 100, background: C.sand }}>
          <div style={{ height: "100%", width: "65%", borderRadius: 100, background: C.coral }} />
        </div>
        <span style={{ fontFamily: "var(--mono)", fontSize: 11, color: C.coral }}>65%</span>
      </div>
      <p style={{ fontSize: 11, color: C.driftwood, marginTop: 6 }}>Complete 2 more roadmap steps to become <strong style={{ color: C.coral }}>Dedicated Maker</strong></p>
    </div>
  </div>
);

const ChallengeMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
      <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700 }}>Weekly Challenge</h2>
      <span style={{ fontSize: 10, fontFamily: "var(--mono)", color: C.coral, fontWeight: 600 }}>3d left</span>
    </div>
    <div style={{ padding: 18, borderRadius: 16, background: `linear-gradient(135deg, ${C.coralPale}, ${C.amberPale})`, border: `1px solid ${C.coral}15`, marginBottom: 14 }}>
      <div style={{ fontSize: 32, marginBottom: 8 }}>🎯</div>
      <h3 style={{ fontSize: 18, fontWeight: 700, marginBottom: 4, color: C.nearBlack }}>Try Something New</h3>
      <p style={{ fontSize: 13, color: C.espresso, lineHeight: 1.5 }}>Spend 15 minutes on a hobby you haven't tried before this week.</p>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 12 }}>
        <div style={{ flex: 1, height: 6, borderRadius: 100, background: "rgba(255,255,255,.5)" }}>
          <div style={{ height: "100%", width: "0%", borderRadius: 100, background: C.coral }} />
        </div>
        <span style={{ fontFamily: "var(--mono)", fontSize: 11, color: C.coral }}>0/1</span>
      </div>
    </div>
    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.warmGray, marginBottom: 10 }}>PAST CHALLENGES</div>
    {["Complete 2 roadmap steps", "Journal your hobby session", "Share a hobby card with a friend"].map((ch, i) => (
      <div key={i} style={{ padding: 12, marginBottom: 6, borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}`, display: "flex", alignItems: "center", gap: 10 }}>
        <div style={{ width: 24, height: 24, borderRadius: "50%", background: C.sage, color: "white", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12 }}>✓</div>
        <span style={{ fontSize: 12, color: C.espresso }}>{ch}</span>
      </div>
    ))}
  </div>
);

const PassportMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>Hobby Passport</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 16 }}>3 of 50 stamps collected</p>
    <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 8 }}>
      {[
        { e: "🏺", n: "Pottery", done: true },
        { e: "🧗", n: "Bouldering", done: true },
        { e: "🍞", n: "Sourdough", done: true },
        { e: "✏️", n: "Sketching", done: false },
        { e: "🧶", n: "Crochet", done: false },
        { e: "🎸", n: "Guitar", done: false },
        { e: "🧘", n: "Yoga", done: false },
        { e: "📷", n: "Photo", done: false },
      ].map((s, i) => (
        <div key={i} style={{
          aspectRatio: "1", borderRadius: 14, display: "flex", flexDirection: "column",
          alignItems: "center", justifyContent: "center", gap: 4,
          background: s.done ? C.coralPale : C.sand,
          border: `1.5px ${s.done ? "solid" : "dashed"} ${s.done ? C.coral + "40" : C.sandDark}`,
          opacity: s.done ? 1 : 0.45,
        }}>
          <span style={{ fontSize: 24 }}>{s.e}</span>
          <span style={{ fontSize: 9, fontWeight: 600, color: s.done ? C.coral : C.warmGray }}>{s.n}</span>
        </div>
      ))}
    </div>
  </div>
);

const ScheduleMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 14 }}>Schedule</h2>
    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.warmGray, marginBottom: 10 }}>THIS WEEK</div>
    {[
      { day: "Tue", time: "7:00 PM", hobby: "Pottery", step: "Step 3: Slab plate", c: C.coral },
      { day: "Thu", time: "6:30 PM", hobby: "Bouldering", step: "Gym session", c: C.indigo },
      { day: "Sat", time: "9:00 AM", hobby: "Sourdough", step: "Bake day!", c: C.amber },
    ].map((s, i) => (
      <div key={i} style={{ display: "flex", gap: 12, marginBottom: 10, alignItems: "stretch" }}>
        <div style={{ width: 52, textAlign: "center", paddingTop: 10 }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: C.nearBlack }}>{s.day}</div>
          <div style={{ fontSize: 10, color: C.warmGray, fontFamily: "var(--mono)" }}>{s.time}</div>
        </div>
        <div style={{ width: 3, borderRadius: 100, background: s.c }} />
        <div style={{ flex: 1, padding: 12, borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
          <div style={{ fontSize: 14, fontWeight: 600, color: C.nearBlack }}>{s.hobby}</div>
          <div style={{ fontSize: 11, color: C.driftwood, marginTop: 2 }}>{s.step}</div>
        </div>
      </div>
    ))}
    <button className="btn-s" style={{ width: "100%", marginTop: 8 }}>📅 Add to Calendar</button>
  </div>
);

const ShoppingMockup = () => {
  const [checked, setChecked] = useState(new Set());
  const items = [
    { name: "Air-dry clay (2kg)", hobby: "Pottery", cost: 15 },
    { name: "Basic tool set", hobby: "Pottery", cost: 12 },
    { name: "Bread flour (1.5kg)", hobby: "Sourdough", cost: 5 },
    { name: "Kitchen scale", hobby: "Sourdough", cost: 15 },
  ];
  const total = items.filter((_,i) => !checked.has(i)).reduce((s,it) => s + it.cost, 0);
  return (
    <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
        <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700 }}>Shopping List</h2>
        <span style={{ fontFamily: "var(--mono)", fontSize: 14, fontWeight: 700, color: C.coral }}>~CHF {total}</span>
      </div>
      {items.map((it, i) => (
        <button key={i} onClick={() => { const n = new Set(checked); n.has(i) ? n.delete(i) : n.add(i); setChecked(n); }}
          style={{ display: "flex", alignItems: "center", gap: 10, padding: 12, marginBottom: 6, width: "100%",
            borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}`, cursor: "pointer", textAlign: "left" }}>
          <div style={{ width: 24, height: 24, borderRadius: "50%", border: `2px solid ${checked.has(i) ? C.sage : C.stone}`,
            background: checked.has(i) ? C.sage : "transparent", display: "flex", alignItems: "center", justifyContent: "center",
            color: "white", fontSize: 12, transition: "all .2s" }}>{checked.has(i) && "✓"}</div>
          <div style={{ flex: 1 }}>
            <span style={{ fontSize: 13, fontWeight: 600, color: checked.has(i) ? C.warmGray : C.nearBlack,
              textDecoration: checked.has(i) ? "line-through" : "none" }}>{it.name}</span>
            <div style={{ fontSize: 10, color: C.warmGray }}>{it.hobby}</div>
          </div>
          <span style={{ fontFamily: "var(--mono)", fontSize: 12, color: C.coral }}>CHF {it.cost}</span>
        </button>
      ))}
    </div>
  );
};

const CompareMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 14 }}>Compare</h2>
    <div style={{ display: "grid", gridTemplateColumns: "80px 1fr 1fr", gap: 0, fontSize: 12 }}>
      {[
        ["", "Pottery", "Bouldering"],
        ["Cost", "CHF 40–120", "CHF 20–60"],
        ["Time", "2h/week", "3h/week"],
        ["Difficulty", "Moderate", "Moderate"],
        ["Social?", "Solo", "Very social"],
        ["Indoor?", "Both", "Indoor + Out"],
        ["Physical?", "Low", "High"],
      ].map((row, ri) => (
        row.map((cell, ci) => (
          <div key={`${ri}-${ci}`} style={{
            padding: "10px 8px", borderBottom: `1px solid ${C.sandDark}`,
            fontWeight: ri === 0 || ci === 0 ? 600 : 400,
            color: ri === 0 ? C.nearBlack : ci === 0 ? C.warmGray : C.espresso,
            background: ri === 0 ? C.sand : ci === 1 ? C.coralPale + "80" : ci === 2 ? C.indigoPale + "80" : "transparent",
            fontFamily: ri > 0 && ci > 0 ? "var(--mono)" : "var(--sans)",
            fontSize: ri === 0 ? 13 : ci === 0 ? 10 : 11,
          }}>{cell}</div>
        ))
      ))}
    </div>
  </div>
);

const AIRoadmapMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>AI Roadmap</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 14 }}>Personalized to your goals</p>
    <div style={{ padding: 14, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}`, marginBottom: 12 }}>
      <div style={{ fontSize: 12, color: C.indigo, fontWeight: 600, marginBottom: 6 }}>✨ Your request</div>
      <p style={{ fontSize: 13, color: C.espresso, fontStyle: "italic", lineHeight: 1.4 }}>"I have 1h/week and want to make a mug I can actually drink from in 30 days."</p>
    </div>
    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.warmGray, marginBottom: 10 }}>GENERATED PLAN</div>
    {[
      { w: "Week 1", title: "Pinch pot fundamentals", min: 45 },
      { w: "Week 2", title: "Cylinder form practice", min: 50 },
      { w: "Week 3", title: "Add a handle", min: 55 },
      { w: "Week 4", title: "Refine & finish your mug", min: 60 },
    ].map((s, i) => (
      <div key={i} style={{ display: "flex", gap: 10, marginBottom: 8, alignItems: "center" }}>
        <div style={{ width: 44, textAlign: "center", fontSize: 10, fontWeight: 700, color: C.coral, fontFamily: "var(--mono)" }}>{s.w}</div>
        <div style={{ flex: 1, padding: 10, borderRadius: 10, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
          <div style={{ fontSize: 13, fontWeight: 600 }}>{s.title}</div>
          <div style={{ fontSize: 10, color: C.warmGray, fontFamily: "var(--mono)" }}>~{s.min} min</div>
        </div>
      </div>
    ))}
    <button className="btn-m" style={{ marginTop: 10 }}>✨ Use This Roadmap</button>
  </div>
);

const AICoachMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px", display: "flex", flexDirection: "column", height: "100%" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 14 }}>Hobby Coach</h2>
    <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 10, overflow: "auto" }}>
      <div style={{ alignSelf: "flex-end", maxWidth: "80%", padding: "10px 14px", borderRadius: "14px 14px 4px 14px", background: C.coralPale, fontSize: 13, color: C.espresso, lineHeight: 1.4 }}>
        My sourdough is really dense. What am I doing wrong?
      </div>
      <div style={{ alignSelf: "flex-start", maxWidth: "85%", padding: "10px 14px", borderRadius: "14px 14px 14px 4px", background: C.warmWhite, border: `1px solid ${C.sandDark}`, fontSize: 13, color: C.espresso, lineHeight: 1.5 }}>
        <div style={{ fontSize: 10, color: C.indigo, fontWeight: 600, marginBottom: 4 }}>✨ Coach</div>
        Since you're on Step 2 of sourdough, density usually comes from one of two things: under-fermentation or too much flour during shaping. Is your starter passing the float test before you use it?
      </div>
      <div style={{ alignSelf: "flex-end", maxWidth: "80%", padding: "10px 14px", borderRadius: "14px 14px 4px 14px", background: C.coralPale, fontSize: 13, color: C.espresso }}>
        I'm not sure, what's the float test?
      </div>
      <div style={{ alignSelf: "flex-start", maxWidth: "85%", padding: "10px 14px", borderRadius: "14px 14px 14px 4px", background: C.warmWhite, border: `1px solid ${C.sandDark}`, fontSize: 13, color: C.espresso, lineHeight: 1.5 }}>
        <div style={{ fontSize: 10, color: C.indigo, fontWeight: 600, marginBottom: 4 }}>✨ Coach</div>
        Drop a spoonful of starter into water. If it floats, it's ready. If it sinks, feed it and wait 4-6 more hours. This makes a big difference in rise! 🍞
      </div>
    </div>
    <div style={{ display: "flex", gap: 8, paddingTop: 12 }}>
      <div style={{ flex: 1, padding: "10px 14px", borderRadius: 12, background: C.warmWhite, border: `1px solid ${C.sandDark}`, fontSize: 13, color: C.warmGray }}>Ask about your hobby...</div>
      <button style={{ width: 42, height: 42, borderRadius: 12, background: C.coral, border: "none", color: "white", fontSize: 16, cursor: "pointer" }}>↑</button>
    </div>
  </div>
);

const VideoTipsMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px" }}>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 22, fontWeight: 700, marginBottom: 4 }}>60-Second Tips</h2>
    <p style={{ fontSize: 12, color: C.driftwood, marginBottom: 14 }}>Watch before each step</p>
    {[
      { title: "How to wedge clay properly", step: "Before Step 1", dur: "0:58", views: "12K" },
      { title: "Perfect coil technique", step: "Before Step 2", dur: "1:02", views: "8K" },
      { title: "Smooth slab edges", step: "Before Step 3", dur: "0:45", views: "5K" },
    ].map((v, i) => (
      <div key={i} style={{ display: "flex", gap: 12, marginBottom: 10, alignItems: "center" }}>
        <div style={{ width: 80, height: 56, borderRadius: 10, background: `linear-gradient(135deg, ${C.sand}, ${C.sandDark})`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, position: "relative" }}>
          <span style={{ fontSize: 20 }}>▶</span>
          <span style={{ position: "absolute", bottom: 3, right: 5, fontSize: 9, fontFamily: "var(--mono)", color: C.driftwood, background: "rgba(255,255,255,.7)", padding: "1px 4px", borderRadius: 3 }}>{v.dur}</span>
        </div>
        <div>
          <div style={{ fontSize: 13, fontWeight: 600, color: C.nearBlack }}>{v.title}</div>
          <div style={{ fontSize: 10, color: C.warmGray, marginTop: 2 }}>{v.step} · {v.views} views</div>
        </div>
      </div>
    ))}
  </div>
);

const YearReviewMockup = () => (
  <div className="scr fade" style={{ padding: "44px 20px 20px", textAlign: "center" }}>
    <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 3, color: C.coral, marginBottom: 8 }}>YOUR 2026</div>
    <h2 style={{ fontFamily: "var(--serif)", fontSize: 28, fontWeight: 700, marginBottom: 20 }}>Year in Hobbies</h2>
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 16 }}>
      {[
        { v: "7", l: "Hobbies tried", c: C.coral },
        { v: "128h", l: "Time invested", c: C.amber },
        { v: "23", l: "Steps completed", c: C.indigo },
        { v: "CHF 340", l: "Total spent", c: C.sage },
      ].map(s => (
        <div key={s.l} style={{ padding: 14, borderRadius: 14, background: `${s.c}10`, border: `1px solid ${s.c}18` }}>
          <div style={{ fontFamily: "var(--mono)", fontSize: 22, fontWeight: 700, color: s.c }}>{s.v}</div>
          <div style={{ fontSize: 11, color: C.driftwood, marginTop: 2 }}>{s.l}</div>
        </div>
      ))}
    </div>
    <div style={{ textAlign: "left", padding: 14, borderRadius: 14, background: C.warmWhite, border: `1px solid ${C.sandDark}` }}>
      <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 2, color: C.warmGray, marginBottom: 8 }}>TOP HOBBY</div>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <span style={{ fontSize: 28 }}>🏺</span>
        <div>
          <div style={{ fontSize: 15, fontWeight: 700 }}>Pottery</div>
          <div style={{ fontSize: 11, color: C.driftwood }}>52 hours · 5/5 steps complete</div>
        </div>
      </div>
    </div>
    <button className="btn-m" style={{ marginTop: 16 }}>📤 Share My Year</button>
  </div>
);

// Map mockup IDs to components
const mockupMap = {
  buddy: BuddyMockup, journal: JournalMockup, local: LocalMockup, stories: StoriesMockup,
  combo: ComboMockup, seasonal: SeasonalMockup, mood: MoodMockup, costcalc: CostCalcMockup,
  identity: IdentityMockup, challenge: ChallengeMockup, passport: PassportMockup,
  schedule: ScheduleMockup, shopping: ShoppingMockup, compare: CompareMockup,
  airoadmap: AIRoadmapMockup, aicoach: AICoachMockup, videotips: VideoTipsMockup,
  yearreview: YearReviewMockup, gearalt: CostCalcMockup, faq: StoriesMockup,
  notes: JournalMockup,
};

// ═══════════════════════════════════════════════════════
//  MAIN APP
// ═══════════════════════════════════════════════════════
export default function App() {
  const [view, setView] = useState("current"); // current | new
  const [activeMockup, setActiveMockup] = useState(null);
  const [expandedCat, setExpandedCat] = useState(null);

  const MockupComponent = activeMockup ? mockupMap[activeMockup] : null;

  return (
    <div style={{ width: "100%", minHeight: "100vh", fontFamily: "var(--sans)", color: C.nearBlack,
      background: `linear-gradient(170deg, ${C.cream} 0%, #f0e8df 100%)`, padding: "32px 20px" }}>
      <Styles />

      {/* Header */}
      <div style={{ maxWidth: 1100, margin: "0 auto 32px", textAlign: "center" }}>
        <div style={{ fontFamily: "var(--mono)", fontSize: 10, fontWeight: 600, letterSpacing: 3, color: C.coral, marginBottom: 8 }}>TRYSOMETHING</div>
        <h1 style={{ fontFamily: "var(--serif)", fontSize: 36, fontWeight: 700, lineHeight: 1.15, marginBottom: 8 }}>Feature Catalog</h1>
        <p style={{ fontSize: 14, color: C.driftwood, maxWidth: 500, margin: "0 auto" }}>
          Everything the app does today + 22 new features with interactive UI mockups
        </p>
      </div>

      {/* Tabs */}
      <div style={{ maxWidth: 1100, margin: "0 auto 24px", display: "flex", gap: 8, justifyContent: "center" }}>
        {[["current", `Current Features (${currentFeatures.reduce((s, c) => s + c.features.length, 0)})`],
          ["new", `New Ideas (${newFeatures.reduce((s, c) => s + c.features.length, 0)})`]].map(([k, l]) => (
          <button key={k} onClick={() => { setView(k); setActiveMockup(null); }} style={{
            padding: "10px 24px", borderRadius: 100, cursor: "pointer", fontSize: 13, fontWeight: 600,
            background: view === k ? C.coral : C.warmWhite, color: view === k ? "white" : C.driftwood,
            border: `1px solid ${view === k ? C.coral : C.sandDark}`, transition: "all .2s",
          }}>{l}</button>
        ))}
      </div>

      <div style={{ maxWidth: 1100, margin: "0 auto", display: "flex", gap: 32, alignItems: "flex-start", flexWrap: "wrap", justifyContent: "center" }}>
        {/* Feature List */}
        <div style={{ flex: "1 1 580px", minWidth: 320 }}>
          {view === "current" ? (
            currentFeatures.map((cat) => (
              <div key={cat.cat} style={{ marginBottom: 20 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
                  <span style={{ fontSize: 20 }}>{cat.icon}</span>
                  <h3 style={{ fontSize: 17, fontWeight: 700 }}>{cat.cat}</h3>
                  <span style={{ fontFamily: "var(--mono)", fontSize: 11, color: C.warmGray }}>{cat.features.length}</span>
                </div>
                {cat.features.map((f) => (
                  <div key={f.name} style={{
                    padding: "12px 14px", marginBottom: 6, borderRadius: 12,
                    background: C.warmWhite, border: `1px solid ${C.sandDark}`,
                    display: "flex", gap: 10, alignItems: "flex-start",
                  }}>
                    <div style={{
                      padding: "3px 8px", borderRadius: 6, fontSize: 9, fontWeight: 700, letterSpacing: 1, flexShrink: 0, marginTop: 2,
                      background: f.status === "v1" ? C.sagePale : C.amberPale,
                      color: f.status === "v1" ? C.sage : C.amberDeep,
                    }}>{f.status.toUpperCase()}</div>
                    <div>
                      <div style={{ fontSize: 14, fontWeight: 600 }}>{f.name}</div>
                      <div style={{ fontSize: 12, color: C.driftwood, marginTop: 2, lineHeight: 1.45 }}>{f.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            ))
          ) : (
            newFeatures.map((cat) => (
              <div key={cat.cat} style={{ marginBottom: 20 }}>
                <button onClick={() => setExpandedCat(expandedCat === cat.cat ? null : cat.cat)}
                  style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10, cursor: "pointer", background: "none", border: "none", width: "100%", textAlign: "left" }}>
                  <span style={{ fontSize: 20 }}>{cat.icon}</span>
                  <h3 style={{ fontSize: 17, fontWeight: 700, flex: 1 }}>{cat.cat}</h3>
                  <span style={{ padding: "3px 10px", borderRadius: 100, fontSize: 10, fontWeight: 700,
                    background: cat.priority.includes("High") ? C.coralPale : cat.priority.includes("Medium") ? C.amberPale : C.indigoPale,
                    color: cat.priority.includes("High") ? C.coral : cat.priority.includes("Medium") ? C.amberDeep : C.indigo,
                  }}>{cat.priority}</span>
                  <span style={{ fontSize: 11, color: C.warmGray, fontFamily: "var(--mono)" }}>{cat.features.length}</span>
                  <span style={{ fontSize: 16, color: C.stone, transition: "transform .2s",
                    transform: expandedCat === cat.cat ? "rotate(90deg)" : "rotate(0)" }}>›</span>
                </button>
                {(expandedCat === cat.cat || expandedCat === null) && cat.features.map((f) => (
                  <div key={f.name} onClick={() => f.mockup && setActiveMockup(f.mockup)} className="slup" style={{
                    padding: "12px 14px", marginBottom: 6, borderRadius: 12,
                    background: activeMockup === f.mockup ? C.coralPale : C.warmWhite,
                    border: `1px solid ${activeMockup === f.mockup ? C.coral + "30" : C.sandDark}`,
                    cursor: f.mockup ? "pointer" : "default", transition: "all .2s",
                  }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <span style={{ fontSize: 14, fontWeight: 600 }}>{f.name}</span>
                      {f.mockup && <span style={{ fontSize: 10, padding: "2px 8px", borderRadius: 100,
                        background: activeMockup === f.mockup ? C.coral : C.sand,
                        color: activeMockup === f.mockup ? "white" : C.driftwood, fontWeight: 600 }}>
                        {activeMockup === f.mockup ? "◉ Viewing" : "Preview →"}
                      </span>}
                    </div>
                    <div style={{ fontSize: 12, color: C.driftwood, marginTop: 4, lineHeight: 1.5 }}>{f.desc}</div>
                  </div>
                ))}
              </div>
            ))
          )}
        </div>

        {/* Phone Preview — only on new features tab */}
        {view === "new" && (
          <div style={{ position: "sticky", top: 32, flexShrink: 0 }}>
            <div className="phone">
              <div className="notch" />
              <div className="hbar" />
              {MockupComponent ? <MockupComponent /> : (
                <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", height: "100%", padding: 32, textAlign: "center" }}>
                  <span style={{ fontSize: 48, marginBottom: 16, opacity: .3 }}>👈</span>
                  <p style={{ fontSize: 14, color: C.warmGray, lineHeight: 1.5 }}>Tap a feature with a "Preview →" badge to see its UI mockup here</p>
                </div>
              )}
            </div>
            <div style={{ textAlign: "center", marginTop: 10, fontSize: 11, color: C.warmGray }}>
              {activeMockup ? "Interactive mockup" : "Select a feature to preview"}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
