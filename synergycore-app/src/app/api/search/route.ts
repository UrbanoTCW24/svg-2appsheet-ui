import { NextRequest, NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const q = (searchParams.get("q") || "").trim();

  if (!q) {
    return NextResponse.json({ results: [] });
  }

  const supabase = createSupabaseServerClient();

  // Simple OR search over key fields; optional limit
  const { data, error } = await supabase
    .from("service_orders")
    .select("id, tracking_id, status, serial_number, imei, created_at")
    .or(
      `tracking_id.ilike.%${q}%,serial_number.ilike.%${q}%,imei.ilike.%${q}%`
    )
    .order("created_at", { ascending: false })
    .limit(50);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ results: data });
}
