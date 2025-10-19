import dynamic from "next/dynamic";

const SearchClient = dynamic(() => import("./SearchClient"), { ssr: false });

export default function SearchPage() {
  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold">Buscador Universal</h2>
      <SearchClient />
    </div>
  );
}
