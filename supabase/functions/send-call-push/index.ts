import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

function base64url(input: ArrayBuffer | string): string {
  const bytes = typeof input === "string" ? new TextEncoder().encode(input) : new Uint8Array(input);
  let str = "";
  for (const b of bytes) str += String.fromCharCode(b);
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function getAccessToken(clientEmail: string, privateKeyPem: string): Promise<string> {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };
  const encHeader = base64url(JSON.stringify(header));
  const encClaim = base64url(JSON.stringify(claim));
  const signInput = `${encHeader}.${encClaim}`;

  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signInput),
  );

  const jwt = `${signInput}.${base64url(signature)}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`Token exchange failed: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

Deno.serve(async (req) => {
  try {
    const { recipient_id, caller_name, caller_id, is_video, call_id } = await req.json();

    if (!recipient_id || !caller_id) {
      return new Response(JSON.stringify({ error: "recipient_id and caller_id are required" }), { status: 400 });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: profile, error } = await supabaseAdmin
      .from("app_profiles")
      .select("device_token")
      .eq("id", recipient_id)
      .maybeSingle();

    if (error || !profile?.device_token) {
      return new Response(JSON.stringify({ error: "No device token for recipient" }), { status: 404 });
    }

    const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
    const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY")!.replace(/\\n/g, "\n");
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;

    const accessToken = await getAccessToken(clientEmail, privateKey);

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: profile.device_token,
            data: {
              type: "call",
              call_id: call_id ?? crypto.randomUUID(),
              caller_id: String(caller_id),
              caller_name: caller_name ?? "Unknown",
              is_video: String(!!is_video),
            },
            android: { priority: "high" },
            apns: { headers: { "apns-priority": "10", "apns-push-type": "background" }, payload: { aps: { "content-available": 1 } } },
          },
        }),
      },
    );

    const fcmData = await fcmRes.json();
    return new Response(JSON.stringify({ success: fcmRes.ok, fcm: fcmData }), {
      status: fcmRes.ok ? 200 : 500,
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
