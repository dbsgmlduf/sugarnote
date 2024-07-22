# 혈당 관리 애플리케이션 (SugarNote) 📱

혈당 관리 애플리케이션은 사용자가 혈당, 운동 및 인슐린 데이터를 쉽게 기록하고 관리할 수 있도록 도와주는 헬스케어 관리 시스템입니다. 이 애플리케이션은 사용자의 건강 데이터를 체계적으로 관리하고, 이를 바탕으로 건강 상태를 개선할 수 있도록 설계되었습니다.

## 목차
1. [팀원 소개](#팀원-소개-🧑‍🤝‍🧑)
2. [기능](#기능-🔧)
3. [기술 스택](#기술-스택-🛠)
4. [사용 방법](#사용-방법-📋)
5. [결론](#결론-🔚)

## 팀원 소개 🧑‍🤝‍🧑

- **Frontend, DB**: [윤희열](https://github.com/dbsgmlduf)
- **Backend, DB**: [권도형](https://github.com/dessinn01)

## 기능 🔧

### 사용자 인증 🔐
- **회원가입 및 로그인 절차**: 사용자는 애플리케이션을 통해 이름, 나이, 키, 몸무게, 아이디, 비밀번호를 입력하여 회원가입을 할 수 있습니다. 로그인 화면에서 아이디와 비밀번호를 입력하여 로그인할 수 있습니다.
- **사용자 정보 저장 및 관리**: 사용자 정보는 로컬 데이터베이스에 저장되며, 사용자는 언제든지 자신의 정보를 수정할 수 있습니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/bf38a527-316a-46e6-b8b4-0c9762177658" width="150">
  <img src="https://github.com/user-attachments/assets/32864e8f-9bb9-4be4-8e85-e168e6b94382" width="150">
</p>

### 혈당 관리 🩸
- **혈당 수치 입력 및 기록**: 사용자는 아침 공복, 아침 식후, 점심 공복, 점심 식후, 저녁 공복, 취침 전의 혈당 수치를 입력할 수 있습니다.
- **날짜별 혈당 수치 조회**: 특정 날짜를 선택하면 해당 날짜의 혈당 수치를 조회할 수 있습니다.
- **혈당 수치의 시각적 표시**: 정상 수치는 하늘색, 기준치 초과 수치는 빨간색, 측정하지 않은 수치는 회색으로 표시됩니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/024620de-c642-497f-b07c-88cfd28448b3" width="150">
  <img src="https://github.com/user-attachments/assets/aabd619b-f716-4337-91df-58bab01c4075" width="150">
</p>

### 인슐린 데이터 관리 💉
- **인슐린 주입 기록 및 상태 확인**: 사용자는 인슐린 주입 날짜와 상태를 기록할 수 있습니다. 주입 완료 여부에 따라 버튼 색상이 변경됩니다.
- **월별 인슐린 주입 데이터 조회**: 특정 연도와 월을 선택하여 해당 월의 인슐린 주입 기록을 조회할 수 있습니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9a49db5f-9932-4d36-932f-6253d2de995f" width="150">
  <img src="https://github.com/user-attachments/assets/08ec02bb-6195-48fb-ad52-ca0b7dd19630" width="150">
</p>

### 운동 추적 🏋️‍♀️
- **운동 종류 및 소모 칼로리 기록**: 사용자는 운동 종류(사이클, 수영, 맨몸운동, 웨이트, 달리기, 축구)를 선택하고, 운동 시간을 입력하여 소모 칼로리를 기록할 수 있습니다.
- **날짜별 운동 기록 조회**: 특정 날짜의 운동 기록을 조회하고, 총 소모 칼로리를 확인할 수 있습니다.
- **운동 종류별 아이콘 표시**: 각 운동 종류에 해당하는 아이콘이 표시됩니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c9c4c136-b75a-4811-a00b-b30f4e3e7c83" width="150">
  <img src="https://github.com/user-attachments/assets/5a640f22-8404-4820-a92b-a69502e5e83c" width="150">
</p>

### 과거 데이터 조회 📅
- **과거 혈당 기록 조회**: 사용자는 설정 페이지에서 과거 혈당 데이터를 조회할 수 있습니다. 특정 날짜를 선택하여 해당 날짜의 혈당 기록을 확인할 수 있습니다.
- **과거 운동 기록 조회**: 사용자는 설정 페이지에서 과거 운동 데이터를 조회할 수 있습니다. 특정 날짜를 선택하여 해당 날짜의 운동 기록을 확인할 수 있습니다.
- **과거 인슐린 주입 기록 조회**: 사용자는 설정 페이지에서 과거 인슐린 주입 데이터를 조회할 수 있습니다. 특정 연도와 월을 선택하여 해당 월의 인슐린 주입 기록을 확인할 수 있습니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/3157b2d2-f49f-4e24-a927-d5f498fdc5d0" width="150">
  <img src="https://github.com/user-attachments/assets/f343b097-796e-4653-b1fc-e9cbf2e177f5" width="150">
</p>

### 자동 상담 기능 🤖
- **GPT API를 활용한 건강 상담**: 사용자가 별도의 질문을 입력하지 않아도 전날의 혈당 및 운동 데이터를 바탕으로 자동으로 건강 상담을 제공합니다.
- **상담 내용 자동 출력**: 사용자가 상담 페이지에 들어가면 서버에서 자동으로 상담 내용을 받아와 화면에 출력합니다.

<p align="center">
  <img src="https://github.com/user-attachments/assets/96d5c590-5ee9-4214-9d9a-d35cd4a9d399" width="150">
</p>

## 기술 스택 🛠

### Environment
<p align="left">
  <img src="https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white"/> 
  <img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white"/>
  <img src="https://img.shields.io/badge/android%20studio-346ac1?style=for-the-badge&logo=android%20studio&logoColor=white"/>
</p>

### Frontend
<p align="left">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
  <img src ="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white"/>
</p>

### Backend
<p align="left">
  <img src="https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white"/>
  <img src="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54"/>
  <img src="https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white"/>
</p>

### Database
<p align="left">
  <img src="https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white"/>
</p>

## 사용 방법 📋

### 사용자 인증
1. 앱 실행 후 회원가입 화면에서 필요한 정보를 입력합니다.
2. 로그인 화면에서 가입한 아이디와 비밀번호를 입력하여 로그인합니다.
3. 설정 화면에서 로그아웃 버튼을 눌러 로그아웃할 수 있습니다.

### 혈당 관리
1. 혈당 관리 화면에서 혈당 수치를 입력합니다.
2. 특정 날짜를 선택하여 해당 날짜의 혈당 수치를 조회합니다.
3. 시각적으로 표시된 혈당 수치를 확인하여 건강 상태를 파악합니다.

### 인슐린 데이터 관리
1. 인슐린 관리 화면에서 주입 기록을 입력합니다.
2. 특정 연도와 월을 선택하여 해당 월의 인슐린 주입 데이터를 조회합니다.
3. 주입 완료 여부에 따라 버튼 색상을 확인합니다.

### 운동 추적
1. 운동 기록 추가 화면에서 운동 종류와 시간을 입력합니다.
2. 특정 날짜를 선택하여 해당 날짜의 운동 기록을 조회합니다.
3. 각 운동에 대한 소모 칼로리를 확인합니다.

### 과거 데이터 조회
1. 설정 페이지에서 과거 데이터를 조회할 카테고리를 선택합니다.
2. 특정 날짜나 연도와 월을 선택하여 해당 데이터 기록을 확인합니다.

### 자동 상담 기능
1. 상담 페이지에 접속하면 자동으로 상담 내용이 출력됩니다.
2. 전날의 건강 데이터를 바탕으로 한 상담 내용을 확인합니다.

## 결론 🔚

헬스케어 관리 시스템은 사용자가 건강 상태를 효과적으로 관리할 수 있도록 돕는 중요한 도구입니다. 사용자 인증, 혈당 관리, 운동 추적, 인슐린 데이터 관리와 같은 기능들을 통해 사용자는 자신의 건강 데이터를 체계적으로 관리하고, 이를 바탕으로 건강을 개선할 수 있습니다. 이 시스템이 많은 사람들의 건강 관리에 도움이 되기를 기대합니다.

---

이 프로젝트와 관련된 질문이나 이슈가 있다면 [Issues](https://github.com/dbsgmlduf/sugarnote/issues) 탭에 작성해주세요.
