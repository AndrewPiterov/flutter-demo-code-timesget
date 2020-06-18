# TimesGet

This repository for code demonstration purpose only!!!

## Description

This one app of many apps for <https://www.timesget.ru>

## Links to apps

<https://apps.apple.com/us/app/cross-fit-family/id1485788438?ls=1>
<https://play.google.com/store/apps/details?id=com.timesget.crossfitfamily>

## DEMO videos

### Admin website
<https://youtu.be/14fc_Rub_1U>

## Technical description

### Global State Management

Для Global State Management в проекте используются следующие механизмы: 
Singleton + RxDart + BehaviourSubject

Например UserService

![alt text](./assets/1.png?raw=true)
![alt text](./assets/2.png?raw=true)
![alt text](./assets/3.png?raw=true)

Firebase
InheritedWidget + Bloc (см. models/city_provider.dart models/city_block.dart) - там можете посмотреть на то как я использую Reactive programming в случае, когда нужно вывести badge с количеством обновлени


Сложные моменты которые предстояло реализовать:

Бейджи, которые показывали бы обновления в приложении, т.к. Новые карты, новые новости, подтвержденные или отклоненные записи (букинги)
Реализовано Push Notification
Реализован механизм и календарь записи на прием с учетом уже забронированных даты и времени в real-time  с помощью Fireabse
Real-time на UI такие как добавление нового комментария, обновление рейтинга и прочее

Анимации сложной и крутой нет. Есть простая в pages/splash_screen.dart

Весь проект писал сам. Бэкэнд на Firebase Database, Storage и Cloud functions. + Фронт - Angular 8 для админов и менеджеров.


