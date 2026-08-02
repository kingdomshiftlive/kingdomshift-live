-- Fetch comments for a video, shaped to match the app's existing Comment.fromJson keys
create or replace function public.get_video_comments(p_video_id uuid)
returns jsonb
language sql
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(row_to_json(c)), '[]'::jsonb)
  from (
    select
      cm.id,
      cm.video_id as post_id,
      cm.user_id,
      cm.content as comment,
      cm.created_at,
      cm.created_at as updated_at,
      coalesce((select count(*) from public.comment_likes cl where cl.comment_id = cm.id), 0) as likes,
      coalesce((select count(*) from public.comments r where r.parent_comment_id = cm.id), 0) as replies_count,
      exists(
        select 1 from public.comment_likes cl
        where cl.comment_id = cm.id and cl.user_key = auth.uid()::text
      ) as is_liked,
      jsonb_build_object(
        'id', p.id,
        'username', p.username,
        'fullname', p.full_name,
        'profile', p.avatar_url
      ) as "user"
    from public.comments cm
    left join public.app_profiles p on p.id = cm.user_id
    where cm.video_id = p_video_id
      and cm.parent_comment_id is null
    order by cm.created_at desc
  ) c;
$$;

revoke execute on function public.get_video_comments(uuid) from public, anon;
grant execute on function public.get_video_comments(uuid) to authenticated;

-- Add a comment (top-level or reply) and return it shaped for Comment.fromJson
create or replace function public.add_video_comment(
  p_video_id uuid,
  p_content text,
  p_parent_comment_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id text := auth.uid()::text;
  v_new_id uuid;
  v_created_at timestamptz;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if p_content is null or length(trim(p_content)) = 0 then
    raise exception 'Comment cannot be empty';
  end if;

  insert into public.comments (video_id, user_id, content, parent_comment_id)
  values (p_video_id, v_user_id, p_content, p_parent_comment_id)
  returning id, created_at into v_new_id, v_created_at;

  return jsonb_build_object(
    'id', v_new_id,
    'post_id', p_video_id,
    'user_id', v_user_id,
    'comment', p_content,
    'created_at', v_created_at,
    'updated_at', v_created_at,
    'likes', 0,
    'replies_count', 0,
    'is_liked', false
  );
end;
$$;

revoke execute on function public.add_video_comment(uuid, text, uuid) from public, anon;
grant execute on function public.add_video_comment(uuid, text, uuid) to authenticated;

-- Delete own comment
create or replace function public.delete_video_comment(p_comment_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id text := auth.uid()::text;
begin
  delete from public.comments
  where id = p_comment_id and user_id = v_user_id;
  return found;
end;
$$;

revoke execute on function public.delete_video_comment(uuid) from public, anon;
grant execute on function public.delete_video_comment(uuid) to authenticated;
