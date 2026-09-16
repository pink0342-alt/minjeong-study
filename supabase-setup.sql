create table if not exists public.study_sync (sync_key text primary key,payload jsonb not null default '{}'::jsonb,updated_at timestamptz not null default now());
alter table public.study_sync enable row level security;
create policy "personal_read" on public.study_sync for select to anon using (true);
create policy "personal_insert" on public.study_sync for insert to anon with check (true);
create policy "personal_update" on public.study_sync for update to anon using (true) with check (true);
