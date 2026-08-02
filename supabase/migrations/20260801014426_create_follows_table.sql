-- Follows table: tracks who follows whom
create table if not exists public.follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  constraint follows_not_self check (follower_id <> following_id)
);

create index if not exists follows_follower_idx on public.follows (follower_id);
create index if not exists follows_following_idx on public.follows (following_id);

alter table public.follows enable row level security;

create policy "Users can read all follows"
  on public.follows for select
  to authenticated
  using (true);

-- No direct insert/update/delete policies — all writes go through the RPC below.

-- Atomic follow/unfollow RPC: toggles the relationship and updates counts
create or replace function public.toggle_follow(p_target_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_follower_id uuid := auth.uid();
  v_is_following boolean;
begin
  if v_follower_id is null then
    raise exception 'Authentication required';
  end if;

  if p_target_user_id = v_follower_id then
    raise exception 'Cannot follow yourself';
  end if;

  select exists(
    select 1 from public.follows
    where follower_id = v_follower_id and following_id = p_target_user_id
  ) into v_is_following;

  if v_is_following then
    delete from public.follows
    where follower_id = v_follower_id and following_id = p_target_user_id;

    update public.app_profiles
    set following_count = greatest(coalesce(following_count, 0) - 1, 0)
    where id = v_follower_id;

    update public.app_profiles
    set follower_count = greatest(coalesce(follower_count, 0) - 1, 0)
    where id = p_target_user_id;

    return false;
  else
    insert into public.follows (follower_id, following_id)
    values (v_follower_id, p_target_user_id);

    update public.app_profiles
    set following_count = coalesce(following_count, 0) + 1
    where id = v_follower_id;

    update public.app_profiles
    set follower_count = coalesce(follower_count, 0) + 1
    where id = p_target_user_id;

    return true;
  end if;
end;
$$;

revoke execute on function public.toggle_follow(uuid) from public, anon;
grant execute on function public.toggle_follow(uuid) to authenticated;
