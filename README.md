# 민정스터디 v0.2
기능: 영단어/오답 학습 분리, 오답 과목별 학습 선택, 영단어 타이핑, 오답 사진(국어/영어/자료조직개론/정보봉사개론), 몰랐음/헷갈림/알았음 간격복습, 일일 학습량 변경, 연속학습일, 백업, Supabase 동기화, PWA.

## 배포
GitHub repository 최상단에 파일을 업로드한 뒤 Settings > Pages에서 main/root를 게시합니다.

## 동기화
Supabase 무료 프로젝트 생성 → SQL Editor에서 `supabase-setup.sql` 1회 실행 → Project URL, anon/publishable key, 개인 동기화 암호를 두 기기의 앱 설정에 동일하게 입력 → 지금 동기화.

주의: v0.2은 개인용 프로토타입입니다. 공개 서비스나 민감정보 저장용이 아닙니다. 오답 사진은 약 1400px JPEG로 줄여 JSON에 포함하므로 사진이 많이 쌓이면 다음 버전에서 Supabase Storage로 옮기는 편이 좋습니다.
