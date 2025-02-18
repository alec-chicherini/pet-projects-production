# pet-projects-production
Тут я буду собирать все пет проекты чтобы захостить их на repotest.ru 

<!--Пет проекты-->
## Список проектов
| github | repotest.ru | комментарий |
|-|-|-|
|[server-http](https://github.com/alec-chicherini/server-http)|-|HTTP сервер для repotest.ru|
|[site-repotest-ru](https://github.com/alec-chicherini/site-repotest-ru)|[https://repotest.ru/index.html](https://repotest.ru/index.html)|Главная страница repotest.ru|
|[wordle-client-qt](https://github.com/alec-chicherini/wordle-client-qt)|[https://wordle-client-qt.repotest.ru/index.html](https://repotest.ru/index.html)|Клиент wordle для linux desktop и wasm|
|[wordle-server-iam](https://github.com/alec-chicherini/wordle-server-iam)|TODO|IAM сервис для wordle|
|[wordle-server-stat](https://github.com/alec-chicherini/wordle-server-stat)|TODO|Сервис статистики для wordle|
|[wordle-client-bash](https://github.com/alec-chicherini/wordle-client-bash)|TODO|Клиент для wordle в bash|
|[pet-game-cpp-backend](https://github.com/alec-chicherini/pet-game-cpp-backend)|TODO|Учебный проект backend сервера. Результат курса Яндекс Практикум|

<!--План развития проекта-->
## План развития проекта:
| What | Platform | Stack | State | Comment |
|-|-|-|-|-|
|Desktop application|Ubuntu 20.04|C++, Qt5|Done|wordle-client-qt Собирается в Ubuntu 20.04. Работает в Ubuntu 20.04|
|Web application|Web browsers|C++, Qt Latest, Web Assembly|Done|wordle-client-qt для Web Assembly, работает в Google Chrome|
|Backend|Ubuntu 24.04|C++, userver|Done|server-http для запуска клиента в wasm в поддомене www.wordle-task.repotest.ru.|
|Backend|Ubuntu 24.04|C++, userver|Done|Добавить tls https, чтобы каждый сервер в handler-subdomain-static подписывался. |
|Frontend|Web browser|c++, html|Done|Сделать главную страницу для repotest.ru со ссылками на мои проекты в github|
|Backend|Ubuntu 24.04|C++, userver|In Progress|server-http вынести в отдельный проект|
|Frontend|Web browser|C++, html|In Progress| site-repotest-ru вынести в отдельный проект|
|Back+Front|c++, javascript|In Progress|Добавить pet-game-cpp-backend на repotest.ru|
|Backend|Ubuntu 24.04|C++, userver, postgres|Planning|IAM Service|
|Backend|Ubuntu 24.04|C++, userver, redis|Planning|Сервер статистики|
|Desktop application|Linux|C++, Qt 6|Planning|Сделать консольную версию. Чтобы всё работало в bash с минимальным интерфейсом вроде dialog.|
|Web Application|Telegramm App|C++, TDLib|Planning|Можно поиграть в официальных приложениях Telegramm Desktop и Telegramm Android|
|Web Application|VK Mini Apps|????|Planning|Можно поиграть в VK|
|GUI|Ubuntu|C++, Qt 6|Planning|Использовать Qt Virtual Keyboard|
|Desktop application|Ubuntu|C++, Qt6 latest|Planning|Сделать новый таргет сборки в Docker где Qt latest, сборка на ubuntu:25.04. Qt собирается из latest исходников или из репозитория. Сборка статическая где всё вкомпилено в бинарник и Qt и системные либы. |

# Сборка
<!--Подготовить хост-->
## Подготовить хост для сборки.

Установить docker 
```bash
source <(curl https://raw.githubusercontent.com/alec-chicherini/development-scripts/refs/heads/main/docker/install_docker.sh)
```

<!--Собрать все зависимости -->
## Собрать все завсимости
### wordle-client-qt
```bash
git clone https://github.com/alec-chicherini/wordle-client-qt.git
cd wordle-client-qt
git submodule init
git submodule update
docker build --target=qt_wasm_build_from_source . -t wordle-client-qt-build-wasm
cd ~
```

### site-repotest-ru
```bash
git clone https://github.com/alec-chicherini/site-repotest-ru.git
cd site-repotest-ru
git submodule init
git submodule update
docker build --target=site_repotest_ru_build . -t site-repotest-ru-build
cd ~
```

### server-http
```bash
git clone https://github.com/alec-chicherini/server-http.git
cd server-http
git submodule init
git submodule update
docker build --target=server_http_build . -t server-http-build
cd ~
```

### pet-projects-production
Добавить секреты.
```bash
docker swarm init
docker secret create repotest_ru_certificate_full_chain certificate_full_chain.pem
docker secret create repotest_ru_private_key private_key.pem
```

Скопировать артифакты всех зависимостей в образ для запуска
```bash
git clone https://github.com/alec-chicherini/pet-projects-production.git
cd pet-projects-production
docker build --target=i_am_production . -t i-am-production
docker service create \
--name i-am-production \
--secret source=repotest_ru_certificate_full_chain,target=/etc/ssl/certs/repotest_ru_certificate_full_chain.pem,mode=0400 \
--secret source=repotest_ru_private_key,target=/etc/ssl/certs/repotest_ru_private_key.pem,mode=0400 -p 443:8080 i-am-production
#docker service rm i-am-production
```