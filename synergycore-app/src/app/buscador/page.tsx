"use client";

import { useEffect, useState } from "react";

type SearchResult = {
  id: string;
  tracking_id: string;
  status: string;
  serial_number: string | null;
  imei: string | null;
  created_at: string;
};

export default function SearchPage() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);

  async function runSearch(q: string) {
    if (!q) {
      setResults([]);
      return;
    }
    setLoading(true);
    try {
      const res = await fetch(`/api/search?q=${encodeURIComponent(q)}`);
      const json = await res.json();
      setResults(json.results ?? []);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    const t = setTimeout(() => runSearch(query), 350);
    return () => clearTimeout(t);
  }, [query]);

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Buscador Universal</h1>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Tracking, IMEI, Serie..."
        className="w-full max-w-xl border rounded-md px-3 py-2"
      />
      {loading && <p className="text-sm text-gray-500">Buscando...</p>}
      <ul className="divide-y rounded-md border bg-white">
        {results.map((r) => (
          <li key={r.id} className="p-3">
            <div className="text-sm font-medium">{r.tracking_id}</div>
            <div className="text-xs text-gray-600">
              Estado: {r.status} · IMEI: {r.imei ?? "-"} · Serie: {r.serial_number ?? "-"}
            </div>
          </li>
        ))}
        {!loading && results.length === 0 && query && (
          <li className="p-3 text-sm text-gray-500">Sin resultados</li>
        )}
      </ul>
    </div>
  );
}
