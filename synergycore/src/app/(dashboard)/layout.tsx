import type { ReactNode } from "react";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const modules = [
  { href: "/dashboard/shipments", label: "Envíos" },
  { href: "/dashboard/backoffice", label: "Backoffice" },
  { href: "/dashboard/workshop", label: "Taller" },
  { href: "/dashboard/inventory", label: "Inventario" },
  { href: "/dashboard/hr", label: "RRHH" },
  { href: "/dashboard/pos", label: "Caja" },
  { href: "/dashboard/contacts", label: "Contactos" },
  { href: "/dashboard/executive", label: "Dashboard" },
  { href: "/dashboard/finance", label: "Finanzas" },
  { href: "/dashboard/reports", label: "Reportes" },
  { href: "/dashboard/search", label: "Buscador" },
  { href: "/dashboard/settings", label: "Ajustes" },
  { href: "/dashboard/tools", label: "Herramientas" },
];

export default async function DashboardLayout({ children }: { children: ReactNode }) {
  const supabase = createSupabaseServerClient();
  const { data } = await supabase.auth.getUser();
  if (!data?.user) {
    redirect("/signin");
  }

  return (
    <div className="min-h-screen grid grid-cols-[240px_1fr]">
      <aside className="border-r border-gray-200 dark:border-gray-800 p-4 space-y-4">
        <div className="font-semibold">SynergyCore</div>
        <nav className="space-y-1">
          {modules.map((m) => (
            <Link key={m.href} href={m.href} className="block px-2 py-1 rounded hover:bg-gray-100 dark:hover:bg-gray-900">
              {m.label}
            </Link>
          ))}
        </nav>
        <form action={async () => {
          'use server';
          const s = createSupabaseServerClient();
          await s.auth.signOut();
          redirect('/signin');
        }}>
          <button type="submit" className="text-sm text-red-600">Salir</button>
        </form>
      </aside>
      <main className="p-6">{children}</main>
    </div>
  );
}
