# MiniGram v5.3 Rooms & Profile

v5.2 UX Fix를 기반으로 친구 모임 단위 공유, 초대코드, 관리자, 개인 피드, 프로필 사진을 추가한 버전입니다.

## v5.3 핵심 변경

- 친구방 생성 / 초대코드 참여
- 현재 참여 방 전환
- 방 멤버 목록
- 관리자 모드
  - 방 이름 변경
  - 초대코드 재발급
  - 관리자 지정/해제(방장)
  - 멤버 내보내기
  - 방 나가기 / 방 삭제
  - 다른 멤버 게시물 관리자 삭제
- 방별 게시물/댓글 RLS
- 방 게시물 이미지는 `room-post-images` private bucket 사용
- 홈에 현재 방 최근 피드 표시
- 공동추억 폴더 선택 → `공동추억 추가` 시 추억 이름 자동 입력
- 공동추억 작성 시 기존 추억 이름 선택 또는 직접 입력
- 타임캡슐 이름 추가
- 캡슐 탭 `다음 공개`에 가장 빨리 열릴 캡슐 이름 + 시간 표시
- 댓글 표시를 `이름:` / `댓글:` 형태로 변경
- 내정보 탭에 프로필 사진 추가/변경/삭제
- 내정보 탭에 내가 쓴 글을 모은 개인 피드 추가
- 캐릭터 영역은 추후 확장용 자리만 마련
- 방 삭제 시 private Storage 파일을 먼저 정리하도록 처리
- 잠긴 다른 멤버 타임캡슐은 관리자에게도 본문을 노출하지 않고, 관리자 전용 삭제 RPC로만 삭제

## 적용 순서

> 전제: 기존 v5.2 SQL까지 이미 적용된 DB 기준입니다.

1. Supabase Dashboard → SQL Editor → New Query
2. `migration_v5_3_rooms_profile.sql` 전체 붙여넣기 후 실행
3. Success 확인
4. GitHub의 기존 `index.html`을 이 ZIP의 `index.html`로 교체
5. Commit / Push
6. GitHub Pages 새로고침 후 테스트

## 주의

- 기존 게시물은 삭제하지 않습니다. 기존 데이터의 `room_id`는 `NULL`인 레거시 데이터로 남습니다.
- 로그인 사용자의 v5.3 신규 게시물은 방을 선택해야 작성됩니다.
- 비로그인 레거시 글/댓글 기능은 기존 호환을 위해 유지되지만, 친구방에는 로그인 사용자만 참여합니다.
- `post-images` public bucket은 기존 글 호환용으로 유지합니다.
- 새 친구방 사진은 `room-post-images` private bucket에 저장합니다.
- 프로필 사진은 `profile-images` bucket을 사용합니다.
- Secret Key / service_role / DB password를 프론트 코드에 넣지 마세요.

## 파일

- `index.html` — v5.3 프론트
- `migration_v5_3_rooms_profile.sql` — v5.3 DB/RLS/RPC/Storage 마이그레이션
- `migration_v5_2_ux_fix.sql` — 이전 버전 참고용
- `TEST_CHECKLIST.md` — 배포 후 점검 목록
