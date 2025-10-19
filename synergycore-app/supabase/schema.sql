-- Supabase SQL schema for SynergyCore ERP
-- Run this file in Supabase SQL Editor or via migration tooling

-- Extensions
create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";

-- Core master catalogs (Ajustes/Maestros)
create table if not exists brands (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists product_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists colors (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  hex text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists operators (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists models (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references brands(id) on delete restrict,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(brand_id, name)
);

create table if not exists diagnostic_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists repair_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Contacts (clientes, proveedores, empleados)
create type contact_kind as enum ('customer','supplier','employee');

create table if not exists contacts (
  id uuid primary key default gen_random_uuid(),
  kind contact_kind not null,
  name text not null,
  email text,
  phone text,
  document_id text,
  address text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists contacts_name_trgm on contacts using gin (name gin_trgm_ops);
create index if not exists contacts_email_trgm on contacts using gin (email gin_trgm_ops);

-- Inventory
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  sku text unique,
  name text not null,
  description text,
  product_type_id uuid references product_types(id) on delete set null,
  brand_id uuid references brands(id) on delete set null,
  model_id uuid references models(id) on delete set null,
  color_id uuid references colors(id) on delete set null,
  unit_cost numeric(12,2) default 0,
  price numeric(12,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists products_name_trgm on products using gin (name gin_trgm_ops);

create table if not exists inventory_locations (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists inventory_stock (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  location_id uuid not null references inventory_locations(id) on delete cascade,
  quantity numeric(14,3) not null default 0,
  updated_at timestamptz not null default now(),
  unique(product_id, location_id)
);

create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  from_location_id uuid references inventory_locations(id) on delete set null,
  to_location_id uuid references inventory_locations(id) on delete set null,
  quantity numeric(14,3) not null,
  reason text,
  reference_type text,
  reference_id uuid,
  created_at timestamptz not null default now()
);
create index if not exists stock_movements_product_idx on stock_movements(product_id);

-- Workshop / Service Orders
create type warranty_status as enum ('in_warranty','out_of_warranty','unknown');
create type order_status as enum (
  'prealerted','in_transit','received','diagnosis','quotation','awaiting_approval','repairing','qc','ready_to_dispatch','dispatched','delivered','irreparable','cancelled'
);

create table if not exists service_orders (
  id uuid primary key default gen_random_uuid(),
  tracking_id text not null unique,
  customer_id uuid references contacts(id) on delete set null,
  status order_status not null default 'prealerted',
  product_type_id uuid references product_types(id) on delete set null,
  brand_id uuid references brands(id) on delete set null,
  model_id uuid references models(id) on delete set null,
  color_id uuid references colors(id) on delete set null,
  operator_id uuid references operators(id) on delete set null,
  serial_number text,
  imei text,
  warranty warranty_status not null default 'unknown',
  failure_description text,
  priority integer default 0,
  assigned_technician_id uuid references contacts(id) on delete set null,
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists service_orders_tracking_idx on service_orders(tracking_id);
create index if not exists service_orders_status_idx on service_orders(status);
create index if not exists service_orders_imei_idx on service_orders(imei);

create table if not exists service_diagnoses (
  id uuid primary key default gen_random_uuid(),
  service_order_id uuid not null references service_orders(id) on delete cascade,
  technician_id uuid references contacts(id) on delete set null,
  diagnostic_code_id uuid references diagnostic_codes(id) on delete set null,
  warranty_valid boolean,
  outcome text check (outcome in ('proceed','needs_quote','irreparable')),
  notes text,
  created_at timestamptz not null default now()
);
create index if not exists service_diagnoses_order_idx on service_diagnoses(service_order_id);

create table if not exists service_repairs (
  id uuid primary key default gen_random_uuid(),
  service_order_id uuid not null references service_orders(id) on delete cascade,
  repair_code_id uuid references repair_codes(id) on delete set null,
  technician_id uuid references contacts(id) on delete set null,
  started_at timestamptz,
  completed_at timestamptz,
  notes text
);

create table if not exists service_repair_parts (
  id uuid primary key default gen_random_uuid(),
  repair_id uuid not null references service_repairs(id) on delete cascade,
  part_product_id uuid not null references products(id) on delete restrict,
  quantity numeric(12,3) not null,
  unit_cost numeric(12,2) not null default 0
);
create index if not exists service_repair_parts_repair_idx on service_repair_parts(repair_id);

create table if not exists qc_checks (
  id uuid primary key default gen_random_uuid(),
  service_order_id uuid not null references service_orders(id) on delete cascade,
  inspector_id uuid references contacts(id) on delete set null,
  passed boolean not null,
  notes text,
  checked_at timestamptz not null default now()
);

-- Logistics / Dispatch
create type dispatch_status as enum ('pending','in_transit','delivered','returned');

create table if not exists couriers (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references contacts(id) on delete set null,
  name text,
  created_at timestamptz not null default now()
);

create table if not exists dispatch_manifests (
  id uuid primary key default gen_random_uuid(),
  courier_id uuid references couriers(id) on delete set null,
  from_location_id uuid references inventory_locations(id) on delete set null,
  to_location_id uuid references inventory_locations(id) on delete set null,
  scheduled_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists shipments (
  id uuid primary key default gen_random_uuid(),
  manifest_id uuid references dispatch_manifests(id) on delete set null,
  service_order_id uuid not null references service_orders(id) on delete cascade,
  status dispatch_status not null default 'pending',
  dispatched_at timestamptz,
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists shipments_order_idx on shipments(service_order_id);

-- POS Payments (Caja)
create type payment_method as enum ('cash','card','transfer','other');

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  service_order_id uuid references service_orders(id) on delete set null,
  amount numeric(12,2) not null,
  currency text not null default 'USD',
  method payment_method not null,
  reference text,
  cashier_id uuid references contacts(id) on delete set null,
  paid_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists payments_order_idx on payments(service_order_id);

-- HR (RRHH)
create table if not exists employees (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid unique references contacts(id) on delete cascade,
  position text,
  salary numeric(12,2),
  hire_date date,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists payroll_records (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references employees(id) on delete cascade,
  period_start date not null,
  period_end date not null,
  gross numeric(12,2) not null default 0,
  deductions numeric(12,2) not null default 0,
  net numeric(12,2) not null default 0,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

-- Finance & Accounting
create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references contacts(id) on delete set null,
  amount numeric(12,2) not null,
  currency text not null default 'USD',
  invoice_number text,
  invoice_date date,
  due_date date,
  status text check (status in ('draft','approved','paid','cancelled')) not null default 'draft',
  ocr_document_url text,
  ocr_text text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists expenses_supplier_idx on expenses(supplier_id);

-- Views for KPIs (simplified examples)
create or replace view v_kpis as
select
  (select count(*) from service_orders where status in ('repairing','diagnosis')) as active_orders,
  (select count(*) from service_orders where status = 'ready_to_dispatch') as ready_for_dispatch,
  (select coalesce(sum(amount),0) from payments where date_trunc('month', paid_at) = date_trunc('month', now())) as month_revenue,
  (select count(*) from service_orders where date_trunc('day', created_at) = date_trunc('day', now())) as today_new_orders;

-- Universal search index (materialized view)
create materialized view if not exists mv_search_index as
select
  so.id,
  so.tracking_id,
  so.serial_number,
  so.imei,
  so.status,
  coalesce(c.name, '') as customer_name,
  so.created_at
from service_orders so
left join contacts c on c.id = so.customer_id;

create index if not exists mv_search_index_tracking_trgm on mv_search_index using gin (tracking_id gin_trgm_ops);
create index if not exists mv_search_index_imei_trgm on mv_search_index using gin (imei gin_trgm_ops);

-- Helper to refresh search index
create or replace function refresh_mv_search_index()
returns void language sql as $$
  refresh materialized view concurrently mv_search_index;
$$;
