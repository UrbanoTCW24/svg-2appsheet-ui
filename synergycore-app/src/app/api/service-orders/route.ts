import { NextRequest, NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

function toInt(value: string | null, fallback: number) {
  if (!value) return fallback;
  const n = Number.parseInt(value, 10);
  return Number.isFinite(n) ? n : fallback;
}

function clamp(n: number, min: number, max: number) {
  return Math.min(max, Math.max(min, n));
}

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const limit = clamp(toInt(searchParams.get("limit"), 100), 1, 500);
  const page = clamp(toInt(searchParams.get("page"), 1), 1, 1_000_000);
  const from = (page - 1) * limit;
  const to = from + limit - 1;

  const supabase = createSupabaseServerClient();
  const { data, error, count } = await supabase
    .from("service_orders")
    .select("id, tracking_id, status, created_at", { count: "exact" })
    .order("created_at", { ascending: false })
    .range(from, to);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({
    data: data ?? [],
    page,
    limit,
    count: count ?? null,
  });
}

export async function POST(req: NextRequest) {
  const body = await req.json();
  const supabase = createSupabaseServerClient();
  const { data, error } = await supabase.from("service_orders").insert(body).select();
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json(data?.[0] ?? null, { status: 201 });
}
