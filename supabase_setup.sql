
-- SHADOW FILES / Supabase setup
-- Run the complete script in Supabase > SQL Editor > New query > Run.
create extension if not exists pgcrypto;

create table if not exists public.sf_rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  host_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'active' check (status in ('active','closed')),
  game_state jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sf_room_members (
  room_id uuid not null references public.sf_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null default 'محقق',
  joined_at timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  primary key(room_id,user_id)
);

alter table public.sf_rooms enable row level security;
alter table public.sf_room_members enable row level security;

-- SECURITY DEFINER helper avoids recursive RLS checks on sf_room_members.
create or replace function public.sf_is_room_member(target_room uuid)
returns boolean language sql stable security definer
set search_path = public
as $$ select exists(select 1 from public.sf_room_members m where m.room_id=target_room and m.user_id=auth.uid()) $$;
revoke all on function public.sf_is_room_member(uuid) from public;
grant execute on function public.sf_is_room_member(uuid) to authenticated;

drop policy if exists "members can read rooms" on public.sf_rooms;
create policy "members can read rooms" on public.sf_rooms for select to authenticated
using (public.sf_is_room_member(id) or host_id=auth.uid());

drop policy if exists "authenticated users create rooms" on public.sf_rooms;
create policy "authenticated users create rooms" on public.sf_rooms for insert to authenticated
with check (host_id=auth.uid());

drop policy if exists "members update room state" on public.sf_rooms;
create policy "members update room state" on public.sf_rooms for update to authenticated
using (public.sf_is_room_member(id))
with check (public.sf_is_room_member(id));

drop policy if exists "members read room members" on public.sf_room_members;
create policy "members read room members" on public.sf_room_members for select to authenticated
using (public.sf_is_room_member(room_id) or user_id=auth.uid());

drop policy if exists "users join as themselves" on public.sf_room_members;
create policy "users join as themselves" on public.sf_room_members for insert to authenticated
with check (user_id=auth.uid());

drop policy if exists "users update own presence" on public.sf_room_members;
create policy "users update own presence" on public.sf_room_members for update to authenticated
using (user_id=auth.uid()) with check (user_id=auth.uid());

drop policy if exists "users leave own membership" on public.sf_room_members;
create policy "users leave own membership" on public.sf_room_members for delete to authenticated
using (user_id=auth.uid());

-- Enable realtime updates for room state.
do $$ begin
  alter publication supabase_realtime add table public.sf_rooms;
exception when duplicate_object then null;
when undefined_object then null;
end $$;
