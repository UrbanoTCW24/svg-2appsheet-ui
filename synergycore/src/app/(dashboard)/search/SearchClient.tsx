"use client";

import { useEffect, useState } from "react";

export default function SearchClient() {
  const [q, setQ] = useState("");
  const [results, setResults] = useState<any>(null);

  useEffect(() => {
    const timeout = setTimeout(async () => {
      if (!q) {
        setResults(null);
        return;
      }
      const res = await fetch(`/api/search?q=${encodeURIComponent(q)}`);
      setResults(await res.json());
    }, 250);
    return () => clearTimeout(timeout);
  }, [q]);

  return (
    <div className="space-y-4">
      <input
        value={q}
        onChange={(e) => setQ(e.target.value)}
        placeholder="Buscar órdenes, contactos o productos..."
        className="w-full h-10 px-3 rounded border border-gray-300 dark:border-gray-700 bg-white text-black dark:bg-black dark:text-white"
      />
      {results && (
        <div className="grid gap-6 md:grid-cols-3">
          <div>
            <h3 className="font-semibold mb-2">Órdenes</h3>
            <ul className="space-y-1 text-sm">
              {(results.orders || []).map((o: any) => (
                <li key={o.id} className="truncate">#{o.tracking_id} — {o.status}</li>
              ))}
            </ul>
          </div>
          <div>
            <h3 className="font-semibold mb-2">Contactos</h3>
            <ul className="space-y-1 text-sm">
              {(results.contacts || []).map((c: any) => (
                <li key={c.id} className="truncate">{c.name} — {c.email || c.phone || '—'}</li>
              ))}
            </ul>
          </div>
          <div>
            <h3 className="font-semibold mb-2">Productos</h3>
            <ul className="space-y-1 text-sm">
              {(results.products || []).map((p: any) => (
                <li key={p.id} className="truncate">{p.sku || '—'} — {p.name}</li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
