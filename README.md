# MiniGram — GitHub Pages + Supabase

인스타그램 느낌의 간단한 커뮤니티 예제입니다.

## 들어간 기능

- 라이트 / 다크모드
- 반응형 모바일 UI
- 이메일 + 비밀번호 회원가입
- 로그인 / 로그아웃
- 유저별 닉네임 프로필
- 로그인한 사용자만 글 작성
- 작성자 닉네임과 작성 시간 표시
- 본인 글만 삭제
- Supabase Auth + PostgreSQL + RLS
- GitHub Pages에서 그대로 배포 가능

## 파일

- `index.html` : 웹사이트 전체
- `setup.sql` : Supabase DB / RLS / 회원가입 프로필 트리거 설정
- `README.md` : 이 안내서

---

## 1. Supabase 프로젝트 만들기

Supabase에서 새 프로젝트를 만듭니다.

## 2. DB 설정

Supabase Dashboard → **SQL Editor**로 이동한 뒤 `setup.sql`의 전체 내용을 붙여 넣고 실행하세요.

이 SQL이 생성하는 것:

- `profiles` : 유저 닉네임
- `posts` : 게시글
- 회원가입 시 프로필 자동 생성 trigger
- RLS 보안 정책

## 3. Auth 설정 확인

Supabase Dashboard의 Authentication 설정에서 Email/Password 로그인 방식이 활성화되어 있어야 합니다.

프로젝트 설정에 따라 회원가입 후 이메일 확인이 필요할 수 있습니다.
이 경우 가입 직후 로그인되지 않고, 인증 메일을 확인한 다음 로그인하면 됩니다.

## 4. URL / Key 넣기

`index.html`에서 아래 부분을 찾습니다.

```js
const SUPABASE_URL = "https://YOUR_PROJECT.supabase.co";
const SUPABASE_KEY = "YOUR_PUBLISHABLE_KEY";
```

본인 Supabase 프로젝트의 **Project URL**과 **Publishable Key**로 변경합니다.

중요:

- 브라우저에서는 Publishable Key(또는 프로젝트에 표시되는 anon public key)만 사용
- `service_role` / secret key는 절대 넣지 않기
- GitHub 공개 저장소에 secret key를 올리면 안 됨

RLS 정책이 실제 보안을 담당합니다.

## 5. GitHub Pages 배포

1. GitHub에서 새 repository 생성
2. ZIP을 푼 뒤 `index.html`, `setup.sql`, `README.md` 업로드
3. Repository → **Settings**
4. **Pages**
5. Source에서 **Deploy from a branch**
6. Branch `main`, folder `/(root)` 선택
7. Save

배포 후 보통 아래 같은 주소로 접속합니다.

```text
https://사용자명.github.io/저장소이름/
```

## 6. 테스트 순서

1. 사이트 접속
2. `시작하기` 또는 `로그인` 클릭
3. 회원가입 선택
4. 닉네임 / 이메일 / 비밀번호 입력
5. 이메일 인증이 켜져 있다면 인증
6. 로그인
7. 글 작성
8. 다른 브라우저에서 다른 계정을 만들어 글 작성
9. 서로의 글이 같은 피드에 표시되는지 확인
10. 자기 글에만 `삭제` 버튼이 나타나는지 확인

## 구조

```text
GitHub Pages
  index.html
      │
      ├── Supabase Auth
      │      └── 회원가입 / 로그인 / 세션
      │
      └── Supabase PostgreSQL
             ├── profiles
             └── posts
```

## 보안 구조

로그인 사용자가 브라우저에서 `posts`에 INSERT할 때:

```text
현재 로그인한 사용자 auth.uid()
        =
INSERT 하려는 posts.user_id
```

인 경우에만 RLS가 허용합니다.

삭제도 똑같이 본인의 `user_id`가 붙은 글만 허용됩니다.

## 현재 예제에서 일부러 뺀 기능

처음 배포해서 이해하기 쉽게 유지하기 위해 아래는 아직 넣지 않았습니다.

- 프로필 사진 업로드
- 좋아요
- 게시글 이미지 업로드
- 댓글 안의 대댓글
- 팔로우 / 팔로워
- DM
- 관리자 화면
- 비밀번호 재설정 UI

이 기능들도 Supabase Storage / DB 테이블을 추가해 확장할 수 있습니다.
