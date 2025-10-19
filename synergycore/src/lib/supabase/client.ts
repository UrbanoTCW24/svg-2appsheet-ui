"use client";

import { createBrowserClient, type SupabaseClient } from "@supabase/ssr";
import { env } from "@/lib/env";

export function createSupabaseBrowserClient(): SupabaseClient {
  return createBrowserClient(env.supabaseUrl(), env.supabaseAnonKey());
}
