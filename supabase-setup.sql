create extension if not exists pgcrypto;

create table if not exists public.study_sync (
  sync_key_hash text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.study_sync enable row level security;
revoke all on table public.study_sync from anon, authenticated;

create or replace function public.study_sync_pull(p_sync_key text)
returns table(payload jsonb, updated_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select s.payload, s.updated_at
  from public.study_sync s
  where s.sync_key_hash = encode(digest(p_sync_key, 'sha256'), 'hex');
$$;

create or replace function public.study_sync_push(p_sync_key text, p_payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.study_sync(sync_key_hash, payload, updated_at)
  values (encode(digest(p_sync_key, 'sha256'), 'hex'), p_payload, now())
  on conflict (sync_key_hash) do update
    set payload = excluded.payload, updated_at = now();
end;
$$;

revoke all on function public.study_sync_pull(text) from public;
revoke all on function public.study_sync_push(text, jsonb) from public;
grant execute on function public.study_sync_pull(text) to anon, authenticated;
grant execute on function public.study_sync_push(text, jsonb) to anon, authenticated;
