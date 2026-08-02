-- Atomic save/unsave RPC using the existing video_saves table
create or replace function public.toggle_video_save(p_video_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_key text := auth.uid()::text;
  v_is_saved boolean;
begin
  if v_user_key is null then
    raise exception 'Authentication required';
  end if;

  select exists(
    select 1 from public.video_saves
    where video_id = p_video_id and user_key = v_user_key
  ) into v_is_saved;

  if v_is_saved then
    delete from public.video_saves
    where video_id = p_video_id and user_key = v_user_key;
    return false;
  else
    insert into public.video_saves (video_id, user_key)
    values (p_video_id, v_user_key);
    return true;
  end if;
end;
$$;

revoke execute on function public.toggle_video_save(uuid) from public, anon;
grant execute on function public.toggle_video_save(uuid) to authenticated;
