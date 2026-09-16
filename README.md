# 민정스터디 v0.3
기능: 영단어/오답 학습 분리, 오답 과목별 학습, 간격복습, 일일 학습량, 연속학습일, 백업, Supabase 동기화, PWA.

## v0.3 동기화 보안 변경
`study_sync` 테이블은 anon/authenticated 역할에서 직접 읽고 쓸 수 없습니다. 동기화는 SECURITY DEFINER RPC를 통해서만 수행하고, 동기화 코드는 SHA-256 해시 형태로만 테이블에 저장합니다. 앱의 `코드 생성` 버튼으로 긴 랜덤 코드를 만들어 두 기기에 동일하게 사용하세요. 이 코드는 데이터 접근 열쇠이므로 공유하지 마세요.

## 동기화 설정
1. Supabase SQL Editor에서 `supabase-setup.sql` 전체를 1회 실행합니다.
2. 앱 설정에 Project URL과 publishable/anon key를 입력합니다. Secret/service_role key는 사용하지 않습니다.
3. `코드 생성`으로 동기화 코드를 만들고 연결 정보를 저장합니다.
4. 다른 기기에도 같은 URL, publishable/anon key, 동기화 코드를 입력한 뒤 `지금 동기화`를 누릅니다.

주의: 개인용 프로토타입입니다. 오답 사진은 약 1400px JPEG로 줄여 JSON에 포함하므로 사진이 많이 쌓이면 Supabase Storage 방식으로 이전하는 편이 좋습니다.
