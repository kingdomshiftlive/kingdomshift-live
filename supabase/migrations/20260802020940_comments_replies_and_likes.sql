-- Add reply support to existing comments table
alter table public.comments
  add column if not exists parent_comment_id uuid references public.comments(id) on delete cascade;

create index if not exists comments_parent_idx on public.comments (parent_comment_id);
create index if not exists comments_video_idx on public.comments (video_id);

-- Comment likes table
create table if not exists public.comment_likes (
  id uuid primary key default gen_random_uuid(),
  comment_id uuid not null references public.comments(id) on delete cascade,
  user_key text not null,
  created_at timestamptz not null default now(),
  unique (comment_id, user_key)
);

create index if not exists comment_likes_comment_idx on public.comment_likes (comment_id);

alter table public.comment_likes enable row level security;

create policy "Users can read all comment likes"
  on public.comment_likes for select
  to authenticated
  using (true);

-- RLS for comments table (in case not already set)
alter table public.comments enable row level security;

drop policy if exists "Users can read all comments" on public.comments;
create policy "Users can read all comments"
  on public.comments for select
  to authenticated
  using (true);

drop policy if exists "Users can insert own comments" on public.comments;
create policy "Users can insert own comments"
  on public.comments for insert
  to authenticated
  with check (auth.uid()::text = user_id);

drop policy if exists "Users can delete own comments" on public.comments;
create policy "Users can delete own comments"
  on public.comments for delete
  to authenticated
  using (auth.uid()::text = user_id);

-- Atomic toggle for comment likes
create or replace function public.toggle_comment_like(p_comment_id uuid)
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
    select 1 from public.comment_likes
    where comment_id = p_comment_id and user_key = v_user_key
  ) into v_is_liked;

  if v_is_liked then
    delete from public.comment_likes
    where comment_id = p_comment_id and user_key = v_user_key;
    return false;
  else
    insert into public.comment_likes (comment_id, user_key)
    values (p_comment_id, v_user_key);
    return true;
  end if;
end;
$$;

revoke execute on function public.toggle_comment_like(uuid) from public, anon;
grant execute on function public.toggle_comment_like(uuid) to authenticated;
