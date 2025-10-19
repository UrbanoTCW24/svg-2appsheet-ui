import { cookies } from "next/headers";
import { createServerClient, type SupabaseClient } from "@supabase/ssr";
import { env } from "@/lib/env";

export function createSupabaseServerClient(): SupabaseClient {
  const cookieStore = cookies();
  return createServerClient(env.supabaseUrl(), env.supabaseAnonKey(), {
    cookies: {
      get(name: string) {
        return cookieStore.get(name)?.value;
      },
      set(name: string, value: string, options: any) {
        try {
          cookieStore.set({ name, value, ...options });
        } catch (_) {
          // Setting cookies is not allowed in some RSC contexts.
        }
      },
      remove(name: string, options: any) {
        try {
          cookieStore.set({ name, value: "", ...options, maxAge: 0 });
        } catch (_) {
          // Ignore when not allowed in current context.
        }
      },
    },
  });
}
