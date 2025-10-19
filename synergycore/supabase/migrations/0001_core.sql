-- Core tables for SynergyCore ERP
create schema if not exists sc;

-- Contacts (CRM)
create table if not exists sc.contacts (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('customer','supplier','employee')),
  name text not null,
  email text,
  phone text,
  created_at timestamptz not null default now()
);

-- Products (for inventory and workshop)
create table if not exists sc.products (
  id uuid primary key default gen_random_uuid(),
  sku text unique,
  name text not null,
  description text,
  brand text,
  model text,
  product_type text,
  created_at timestamptz not null default now()
);

-- Inventory items
create table if not exists sc.inventory_items (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references sc.products(id) on delete cascade,
  location text not null,
  quantity integer not null default 0,
  cost numeric(12,2),
  updated_at timestamptz not null default now()
);

-- Work orders
create table if not exists sc.work_orders (
  id uuid primary key default gen_random_uuid(),
  tracking_id text unique not null,
  customer_id uuid references sc.contacts(id),
  device_brand text,
  device_model text,
  color text,
  operator text,
  status text not null default 'prealert' check (status in ('prealert','in_transit','diagnosis','quote','repair','qc','completed','irreparable','returned')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Workshop logs (diagnosis/repair/qc)
create table if not exists sc.work_logs (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid not null references sc.work_orders(id) on delete cascade,
  phase text not null check (phase in ('diagnosis','repair','qc')),
  note text,
  technician_id uuid references sc.contacts(id),
  created_at timestamptz not null default now()
);

-- Shipments / manifests
create table if not exists sc.shipments (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references sc.work_orders(id) on delete set null,
  from_agency text,
  to_agency text,
  courier text,
  status text not null default 'created' check (status in ('created','in_transit','received','dispatched','delivered')),
  created_at timestamptz not null default now()
);

-- POS payments
create table if not exists sc.payments (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references sc.work_orders(id),
  amount numeric(12,2) not null,
  method text not null check (method in ('cash','card','transfer')),
  created_at timestamptz not null default now()
);

-- Basic RLS enablement
alter table sc.contacts enable row level security;
alter table sc.products enable row level security;
alter table sc.inventory_items enable row level security;
alter table sc.work_orders enable row level security;
alter table sc.work_logs enable row level security;
alter table sc.shipments enable row level security;
alter table sc.payments enable row level security;
