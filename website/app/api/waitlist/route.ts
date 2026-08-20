import { NextResponse } from "next/server";

/**
 * Waitlist intake — validates and forwards to a Make.com webhook.
 * Configure WAITLIST_WEBHOOK_URL in Vercel env (Make scenario → Google
 * Sheet / testers CSV). Returns 503 when unconfigured so the client can
 * show a graceful fallback instead of silently dropping emails.
 */

const EMAIL_RE = /^[^\s@]{1,64}@[^\s@]{1,255}\.[^\s@]{2,}$/;

export async function POST(req: Request) {
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false, error: "bad_request" }, { status: 400 });
  }

  const { email, company } = (body ?? {}) as { email?: string; company?: string };

  // Honeypot field — bots fill it, humans never see it. Pretend success.
  if (company) return NextResponse.json({ ok: true });

  if (typeof email !== "string" || !EMAIL_RE.test(email.trim())) {
    return NextResponse.json({ ok: false, error: "invalid_email" }, { status: 400 });
  }

  const webhook = process.env.WAITLIST_WEBHOOK_URL;
  if (!webhook) {
    return NextResponse.json({ ok: false, error: "not_configured" }, { status: 503 });
  }

  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 5000);
    const res = await fetch(webhook, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: email.trim().toLowerCase(),
        source: "landing-waitlist",
        ts: new Date().toISOString(),
      }),
      signal: ctrl.signal,
    });
    clearTimeout(timer);
    if (!res.ok) throw new Error(`webhook responded ${res.status}`);
    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error("waitlist forward failed:", err);
    return NextResponse.json({ ok: false, error: "upstream" }, { status: 502 });
  }
}
