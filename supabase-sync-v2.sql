-- Run once in Supabase SQL Editor. Keeps the original study_sync table unchanged.
create extension if not exists pgcrypto with schema extensions;
create table if not exists public.study_sync_items (
  sync_key_hash text not null,
  kind text not null check (kind in ('words','wrong','keywords','logs')),
  item_id text not null,
  payload jsonb not null,
  version bigint not null default 0,
  primary key (sync_key_hash, kind, item_id)
);
alter table public.study_sync_items enable row level security;
revoke all on public.study_sync_items from anon, authenticated;

create or replace function public.study_sync_pull_items(
  p_sync_key text, p_kind text, p_offset integer default 0, p_limit integer default 5
) returns table(payload jsonb)
language sql security definer set search_path = public, extensions
as $$
  select s.payload from public.study_sync_items s
  where s.sync_key_hash = encode(extensions.digest(p_sync_key, 'sha256'),'hex')
    and s.kind = p_kind
  order by s.item_id
  limit least(greatest(p_limit,1),10) offset greatest(p_offset,0);
$$;

create or replace function public.study_sync_push_items(p_sync_key text, p_items jsonb)
returns void language plpgsql security definer set search_path = public, extensions
as $$
declare item jsonb; h text;
begin
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) > 5 then
    raise exception 'Invalid batch';
  end if;
  h := encode(extensions.digest(p_sync_key,'sha256'),'hex');
  for item in select value from jsonb_array_elements(p_items) loop
    if item->>'kind' not in ('words','wrong','keywords','logs')
      or nullif(item->>'id','') is null
      or item->'payload'->>'id' is distinct from item->>'id' then
      raise exception 'Invalid item';
    end if;
    insert into public.study_sync_items(sync_key_hash,kind,item_id,payload,version)
    values(h,item->>'kind',item->>'id',item->'payload',coalesce((item->>'version')::bigint,0))
    on conflict(sync_key_hash,kind,item_id) do update
      set payload=excluded.payload,version=excluded.version
      where public.study_sync_items.version <= excluded.version;
  end loop;
end;
$$;
revoke all on function public.study_sync_pull_items(text,text,integer,integer) from public;
revoke all on function public.study_sync_push_items(text,jsonb) from public;
grant execute on function public.study_sync_pull_items(text,text,integer,integer) to anon,authenticated;
grant execute on function public.study_sync_push_items(text,jsonb) to anon,authenticated;
