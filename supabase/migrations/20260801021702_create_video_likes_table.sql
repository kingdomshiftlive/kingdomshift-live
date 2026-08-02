-- Video likes table: tracks who liked which video
create table if not exists public.video_likes (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null references public.videos(id) on delete cascade,
  user_key text not null,
  created_at timestamptz not null default now(),
  unique (video_id, user_key)
);

create index if not exists video_likes_video_idx on public.video_likes (video_id);
create index if not exists video_likes_user_idx on public.video_likes (user_key);

alter table public.video_likes enable row level security;

create policy "Users can read all video likes"
  on public.video_likes for select
  to authenticated
  using (true);

-- No direct insert/update/delete policies — all writes go through the RPC below.

-- Atomic like/unlike RPC: toggles the like and updates the videos.likes_count
create or replace function public.toggle_video_like(p_video_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_key text := auth.uid()::text;
  v_is_liked boolean;
begin
  if v_user_key is null then
    raise exception 'Authentication required';
  end if;

  select exists(
    select 1 from public.video_likes
    where video_id = p_video_id and user_key = v_user_key
  ) into v_is_liked;

  if v_is_liked then
    delete from public.video_likes
    where video_id = p_video_id and user_key = v_user_key;

    update public.videos
    set likes_count = greatest(coalesce(likes_count, 0) - 1, 0)
    where id = p_video_id;

    return false;
  else
    insert into public.video_likes (video_id, user_key)
    values (p_video_id, v_user_key);

    update public.videos
    set likes_count = coalesce(likes_count, 0) + 1
    where id = p_video_id;

    return true;
  end if;
end;
$$;

revoke execute on function public.toggle_video_like(uuid) from public, anon;
grant execute on function public.toggle_video_like(uuid) to authenticated;
