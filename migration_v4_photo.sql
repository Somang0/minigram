-- MiniGram v4: 게시물 사진 업로드
-- v3 적용 후 실행하세요.
-- 기존 데이터는 유지됩니다.
 
-- 1. posts에 사진 URL 컬럼 추가
alter table public.posts
  add column if not exists image_url text;

-- 기존 content 체크 제약조건이 있다면 "사진만 있는 글"을 위해 완화
alter table public.posts
  drop constraint if exists posts_content_check;

-- content는 빈 문자열 허용, 최대 500자
alter table public.posts
  add constraint posts_content_check
  check (char_length(content) between 0 and 500);

-- 글에는 텍스트 또는 사진 중 하나는 있어야 함
alter table public.posts
  drop constraint if exists posts_content_or_image_check;

alter table public.posts
  add constraint posts_content_or_image_check
  check (
    char_length(trim(content)) > 0
    or image_url is not null
  );

-- 로그인 사용자 insert에 image_url 권한 추가
revoke insert on table public.posts from authenticated;
grant insert (user_id, guest_name, content, image_url)
on public.posts
to authenticated;

-- image_url 읽기 권한
grant select (image_url)
on public.posts
to anon, authenticated;


-- 2. v3 비로그인 글 작성 RPC를 사진 URL까지 받도록 교체
drop function if exists public.create_guest_post(text, text, text);

create or replace function public.create_guest_post(
  p_guest_name text,
  p_password text,
  p_content text,
  p_image_url text default null
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id bigint;
begin
  p_guest_name := trim(p_guest_name);
  p_content := coalesce(trim(p_content), '');

  if char_length(p_guest_name) < 2 or char_length(p_guest_name) > 20 then
    raise exception '닉네임은 2~20자여야 합니다.';
  end if;

  if char_length(p_password) < 4 or char_length(p_password) > 50 then
    raise exception '비밀번호는 4~50자여야 합니다.';
  end if;

  if char_length(p_content) > 500 then
    raise exception '글은 최대 500자입니다.';
  end if;

  if char_length(p_content) = 0 and p_image_url is null then
    raise exception '글 내용이나 사진 중 하나는 있어야 합니다.';
  end if;

  insert into public.posts (
    user_id,
    guest_name,
    guest_password_hash,
    content,
    image_url
  )
  values (
    null,
    p_guest_name,
    extensions.crypt(p_password, extensions.gen_salt('bf', 10)),
    p_content,
    p_image_url
  )
  returning id into v_id;

  return v_id;
end;
$$;

revoke all on function public.create_guest_post(text, text, text, text) from public;

grant execute on function public.create_guest_post(text, text, text, text)
to anon, authenticated;


-- 3. Storage RLS 정책
-- IMPORTANT:
-- 아래 SQL 전에 Supabase Dashboard > Storage에서
-- `post-images`라는 PUBLIC bucket을 먼저 만드세요.
--
-- 권장 설정:
-- Public bucket: ON
-- File size limit: 5 MB
-- Allowed MIME types:
-- image/jpeg
-- image/png
-- image/webp
-- image/gif

drop policy if exists "MiniGram anyone can upload post images"
on storage.objects;

create policy "MiniGram anyone can upload post images"
on storage.objects
for insert
to anon, authenticated
with check (
  bucket_id = 'post-images'
  and lower(storage.extension(name)) in ('jpg', 'jpeg', 'png', 'webp', 'gif')
);

-- public bucket이므로 읽기는 공개 URL로 처리.
-- storage.objects SELECT 권한은 이미지 표시 자체에는 필요하지 않음.

notify pgrst, 'reload schema';
