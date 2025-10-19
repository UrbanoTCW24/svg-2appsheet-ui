export default function Home() {
  return (
    <div className="grid grid-rows-2 items-center justify-items-center min-h-[60svh] p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-6 row-start-2 items-center sm:items-start">
        <h1 className="text-4xl font-bold tracking-tight">SynergyCore ERP</h1>
        <p className="text-gray-600 max-w-prose">
          Plataforma modular conectada a Supabase para gestionar logística, taller, inventario,
          finanzas, RRHH y más, con un dashboard ejecutivo en tiempo real.
        </p>
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-4 text-sm">
          {[
            "Pre-Alertas",
            "Backoffice",
            "Taller",
            "Inventario",
            "RRHH",
            "Caja",
            "Contactos",
            "Dashboard",
            "Finanzas",
            "Reportes",
            "Buscador",
            "Ajustes",
          ].map((m) => (
            <span
              key={m}
              className="rounded-md border px-3 py-2 bg-white/50 shadow-sm"
            >
              {m}
            </span>
          ))}
        </div>
      </main>
    </div>
  );
}
