import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const q = String(searchParams.get("q") || "").trim();
  if (!q) {
    return NextResponse.json({ results: [] });
  }

  const supabase = createSupabaseServerClient();

  const [orders, contacts, products] = await Promise.all([
    supabase.from("sc.work_orders").select("id, tracking_id, status").ilike("tracking_id", `%${q}%`).limit(10),
    supabase.from("sc.contacts").select("id, name, email, phone").ilike("name", `%${q}%`).limit(10),
    supabase.from("sc.products").select("id, sku, name, brand, model").or(
      `sku.ilike.%${q}%,name.ilike.%${q}%`
    ).limit(10),
  ]);

  return NextResponse.json({
    orders: orders.data ?? [],
    contacts: contacts.data ?? [],
    products: products.data ?? [],
  });
}
