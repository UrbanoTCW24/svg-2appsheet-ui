-- Public read, authenticated write (example baseline) -- adjust to your needs

-- helper role checks
create or replace function sc.is_authenticated()
returns boolean language sql stable as $$
  select auth.role() = 'authenticated'
$$;

-- Contacts
create policy if not exists contacts_select on sc.contacts for select using (true);
create policy if not exists contacts_write on sc.contacts for insert with check (sc.is_authenticated());
create policy if not exists contacts_update on sc.contacts for update using (sc.is_authenticated());

-- Products
create policy if not exists products_select on sc.products for select using (true);
create policy if not exists products_write on sc.products for insert with check (sc.is_authenticated());
create policy if not exists products_update on sc.products for update using (sc.is_authenticated());

-- Inventory
create policy if not exists inventory_select on sc.inventory_items for select using (true);
create policy if not exists inventory_write on sc.inventory_items for insert with check (sc.is_authenticated());
create policy if not exists inventory_update on sc.inventory_items for update using (sc.is_authenticated());

-- Work orders
create policy if not exists work_orders_select on sc.work_orders for select using (true);
create policy if not exists work_orders_write on sc.work_orders for insert with check (sc.is_authenticated());
create policy if not exists work_orders_update on sc.work_orders for update using (sc.is_authenticated());

-- Work logs
create policy if not exists work_logs_select on sc.work_logs for select using (true);
create policy if not exists work_logs_write on sc.work_logs for insert with check (sc.is_authenticated());

-- Shipments
create policy if not exists shipments_select on sc.shipments for select using (true);
create policy if not exists shipments_write on sc.shipments for insert with check (sc.is_authenticated());

-- Payments (no public read in real systems; demo only)
create policy if not exists payments_select on sc.payments for select using (sc.is_authenticated());
create policy if not exists payments_write on sc.payments for insert with check (sc.is_authenticated());
