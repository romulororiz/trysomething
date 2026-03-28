import crypto from "crypto";
import { Resend } from "resend";

const CODE_EXPIRY_MS = 10 * 60 * 1000; // 10 minutes
const RESEND_COOLDOWN_MS = 60 * 1000; // 60 seconds

let _resend: Resend | null = null;
function getResend(): Resend {
  if (!_resend) {
    _resend = new Resend(process.env.RESEND_API_KEY);
  }
  return _resend;
}

export function generateVerificationCode(): string {
  return crypto.randomInt(100000, 999999).toString();
}

export function codeExpiresAt(): Date {
  return new Date(Date.now() + CODE_EXPIRY_MS);
}

export function isWithinCooldown(lastCodeSentAt: Date | null): {
  blocked: boolean;
  retryAfter: number;
} {
  if (!lastCodeSentAt) return { blocked: false, retryAfter: 0 };
  const elapsed = Date.now() - lastCodeSentAt.getTime();
  if (elapsed < RESEND_COOLDOWN_MS) {
    return {
      blocked: true,
      retryAfter: Math.ceil((RESEND_COOLDOWN_MS - elapsed) / 1000),
    };
  }
  return { blocked: false, retryAfter: 0 };
}

export async function sendVerificationEmail(
  email: string,
  code: string,
  displayName: string
): Promise<void> {
  const resend = getResend();

  // Split code into individual digits for the card-style display
  const digits = code.split("").map(
    (d) => `<td style="width:44px;height:52px;background:#111116;border:1px solid #222228;border-radius:10px;text-align:center;vertical-align:middle;font-family:'SF Mono','IBM Plex Mono','Fira Code',monospace;font-size:28px;font-weight:700;color:#F5F0EB;letter-spacing:0;">${d}</td>`
  ).join(`<td style="width:6px;"></td>`);

  await resend.emails.send({
    from: "TrySomething <onboarding@resend.dev>",
    to: email,
    subject: `${code} is your TrySomething verification code`,
    html: `
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"></head>
<body style="margin:0;padding:0;background:#06060A;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#06060A;">
    <tr><td align="center" style="padding:40px 16px 48px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:440px;">

        <!-- Brand: icon centered on top, name below -->
        <tr><td align="center" style="padding:0 0 36px;">
          <table role="presentation" cellpadding="0" cellspacing="0">
            <tr><td align="center" style="padding-bottom:14px;">
              <img src="https://res.cloudinary.com/dduhb4jtj/image/upload/v1774699533/jelwijieo87nvqs2isxb.png" width="56" height="56" alt="TrySomething" style="display:block;border:0;border-radius:14px;" />
            </td></tr>
            <tr><td align="center" style="font-family:-apple-system,BlinkMacSystemFont,sans-serif;font-size:19px;font-weight:700;color:#F5F0EB;letter-spacing:-0.3px;">
              <span style="color:#FF6B6B;">Try</span>Something
            </td></tr>
          </table>
        </td></tr>

        <!-- Card -->
        <tr><td style="background:#0A0A0F;border-radius:20px;border:1px solid #1A1A20;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">

            <!-- Greeting -->
            <tr><td style="padding:36px 32px 0;">
              <p style="margin:0;font-size:24px;font-weight:700;color:#F5F0EB;line-height:1.3;">Hey ${displayName} &#128075;</p>
            </td></tr>

            <!-- Message -->
            <tr><td style="padding:12px 32px 0;">
              <p style="margin:0;font-size:15px;color:#B0A89E;line-height:1.6;">
                Welcome to TrySomething! Enter this code to verify your email and start discovering hobbies you'll love.
              </p>
            </td></tr>

            <!-- Code -->
            <tr><td align="center" style="padding:28px 32px;">
              <table role="presentation" cellpadding="0" cellspacing="0">
                <tr>${digits}</tr>
              </table>
            </td></tr>

            <!-- Expiry -->
            <tr><td align="center" style="padding:0 32px 32px;">
              <table role="presentation" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="background:rgba(255,107,107,0.08);border-radius:8px;padding:8px 16px;">
                    <span style="font-size:12px;color:#FF6B6B;font-weight:600;">Expires in 10 minutes</span>
                  </td>
                </tr>
              </table>
            </td></tr>

          </table>
        </td></tr>

        <!-- Footer -->
        <tr><td align="center" style="padding:28px 0 0;">
          <p style="margin:0;font-size:12px;color:#3D3835;line-height:1.5;">
            If you didn't create a TrySomething account, ignore this email.
          </p>
          <p style="margin:8px 0 0;font-size:11px;color:#2A2825;">
            TrySomething &middot; Discover hobbies, build habits
          </p>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
    `,
  });
}
