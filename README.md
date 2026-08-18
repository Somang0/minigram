# MiniGram v5.4 — Admin / Room Roles / Invite Link

전제: **v5.3 Rooms + Profile**까지 적용된 프로젝트에서 이어서 적용합니다.

## 이번 버전 핵심

- 로그인 후 글 작성 때 브라우저가 비로그인 글 비밀번호를 계정 비밀번호로 오인하지 않도록 수정
  - 로그인 상태에서는 guest 비밀번호 입력 비활성화
  - guest 글/댓글 비밀번호는 `one-time-code`/password-manager ignore 힌트로 계정 비밀번호와 분리
  - 로그인 성공 직후 로그인 비밀번호 input 값 제거
- PC 우측 고정 메뉴 추가
  - 홈 / 공동추억 / 타임캡슐 / 피드 / 내정보
  - 현재 방 이름, 인원, 내 등급 표시
  - PC에서는 우측 메뉴, 모바일에서는 기존 하단 탭 사용
- 프로필 사진 규격 통일
  - 업로드 시 중앙 정사각 크롭
  - 512×512 WEBP 저장
  - 모든 avatar에서 1:1 + object-fit: cover 적용
- 방 최대 인원
  - 방 생성 시 2~200명 설정
  - 방장/부방장이 현재 인원보다 작지 않은 범위에서 변경
  - 초대코드 참여 RPC에서 DB row lock 후 정원 검사
- 방 등급
  - 방장(owner)
  - 부방장(deputy)
  - 운영진(manager)
  - 멤버(member)
  - 방장만 등급 변경 및 방장 위임 가능
  - 부방장/운영진은 등급에 따라 하위 멤버 관리 가능
- 사이트 전체 어드민
  - 별도 `app_admins` 테이블
  - 모든 방, 모든 게시글, 잠긴 타임캡슐 내용, 댓글 조회 가능
  - 게시글/댓글/방 삭제 가능
  - 일반 사용자가 프론트에서 스스로 어드민이 될 수 없음
- 초대 링크
  - `https://.../minigram/?invite=XXXXXXXXXX` 형식으로 복사
  - 로그아웃 상태에서 링크 진입 → 로그인 안내
  - 로그인 완료 후 해당 방 자동 참여
  - 정원이 찼으면 DB에서 참여 거절

## 적용 순서

1. Supabase → SQL Editor
2. `migration_v5_4_admin_roles_invites.sql` 전체 실행
3. Success 확인
4. 사이트 전체 어드민을 사용할 계정이 있으면 `SET_APP_ADMIN.sql`을 열고 `v_email := 'YOUR_EMAIL@example.com'` 한 곳을 **본인 MiniGram 로그인 이메일**로 바꾼 뒤 실행
5. GitHub의 기존 `index.html`을 이 폴더의 `index.html`로 덮어쓰기
6. Commit / Push
7. GitHub Pages 새로고침
8. `TEST_CHECKLIST.md`대로 테스트

## 중요한 점

- `SET_APP_ADMIN.sql`은 사이트 운영자 계정에만 실행하세요.
- `service_role`, Secret Key, DB Password를 프론트에 넣지 않습니다.
- 사이트 어드민 여부는 `app_admins` + RLS/RPC로 검사합니다.
- v5.2/v5.3 SQL을 이미 실행했다면 다시 처음부터 실행하지 않습니다.
