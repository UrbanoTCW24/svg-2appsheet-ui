# SynergyCore ERP

ERP modular para talleres y logística, conectado a Supabase.

## Requisitos
- Node 18+ (recomendado 20+)
- pnpm
- Cuenta y proyecto en Supabase

## Configuración
1. Copia `.env.example` a `.env.local` y completa:
```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
# Opcional para tareas de backend
SUPABASE_SERVICE_ROLE_KEY=...
```
2. Instala dependencias:
```bash
pnpm install
```
3. Ejecuta en desarrollo:
```bash
pnpm dev
```

## Autenticación
- Ruta de ingreso: `/signin`
- Rutas protegidas bajo `/dashboard` requieren sesión.

## Estructura de módulos
- `/dashboard/shipments` Envíos (Pre-Alertas)
- `/dashboard/backoffice` Backoffice y Logística
- `/dashboard/workshop` Taller (Diagnóstico, Reparación, QC)
- `/dashboard/inventory` Inventario
- `/dashboard/hr` Recursos Humanos
- `/dashboard/pos` Punto de Venta (Caja)
- `/dashboard/contacts` Contactos (CRM)
- `/dashboard/executive` Dashboard Ejecutivo (KPIs)
- `/dashboard/finance` Finanzas y Contabilidad
  - `/dashboard/finance/ocr` OCR de Facturas (stub)
- `/dashboard/reports` Reportes
- `/dashboard/search` Buscador Universal
- `/dashboard/settings` Ajustes (Maestros)
- `/dashboard/tools` Herramientas IA y de Desarrollador

## Supabase
- Migraciones SQL en `supabase/migrations`.
- Habilita RLS y políticas básicas incluidas como ejemplo.
- Ajusta las políticas según tu modelo de permisos real.

## Búsqueda Global
- Endpoint: `GET /api/search?q=texto`
- Busca en `work_orders`, `contacts`, `products`.

## Notas
- Tailwind CSS v4 ya incluido.
- Puedes desactivar Turbopack si prefieres el bundler estable.
