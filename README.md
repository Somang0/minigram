# MiniGram v4 — 사진 게시물

v3에 게시물 사진 업로드를 추가한 버전입니다.

## 추가 기능

- 로그인 사용자 사진 게시물
- 비로그인 사용자 사진 게시물
- 글 + 사진 또는 사진만 게시 가능
- 업로드 전 미리보기
- 사진 선택 취소
- 이미지 1장
- 최대 5MB
- jpg / jpeg / png / webp / gif
- 피드 이미지 lazy loading

## 적용 순서

### 1. Storage bucket 만들기

Supabase Dashboard → Storage → New bucket

Bucket name:

`post-images`

설정:

- **Public bucket: ON**
- File size limit: **5 MB**
- Allowed MIME types:
  - `image/jpeg`
  - `image/png`
  - `image/webp`
  - `image/gif`

사진은 공개 피드용이므로 public bucket을 사용합니다.

### 2. SQL 실행

Supabase SQL Editor에서:

`migration_v4_photo.sql`

전체 실행.

기존 회원/글/댓글은 유지됩니다.

### 3. index.html 교체

GitHub `Somang0/minigram`의 기존 `index.html`을
ZIP 안의 새 `index.html`로 교체하고 Commit + Push.

### 4. 테스트

- 로그아웃 → 닉네임 + 비밀번호 + 사진 → 게시
- 로그인 → 사진 게시
- 사진만 선택하고 본문 없이 게시
- 사진 + 본문 게시
- 5MB 초과 파일 선택 시 차단 확인

## 구조

브라우저
→ Supabase Storage `post-images`
→ public URL 생성
→ `posts.image_url` 저장
→ 피드에서 `<img>`로 표시

## 보안/운영 메모

현재 비로그인 사용자도 사진 업로드가 가능하므로
공개 URL이 널리 퍼질 경우 Storage가 스팸 업로드 대상이 될 수 있습니다.

친구들끼리 쓰는 동안에는 간단하게 운영할 수 있지만,
외부 공개 시에는 CAPTCHA, 초대코드, 업로드 rate limit 등을 추가하는 편이 좋습니다.

현재 버전은 게시글 삭제 시 Storage 파일을 자동 삭제하지 않습니다.
즉 글을 지워도 이미지 파일이 Storage에 남을 수 있습니다.
다음 버전에서 이미지 경로 저장 + 안전한 Storage 삭제까지 추가할 수 있습니다.
