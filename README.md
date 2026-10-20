# agentic-class

Материалы курса «Агентская разработка: как быстро создавать большие качественные
проекты и не сойти с ума»: слайды лекции, раздатка, интерактивный тренажёр цикла
агента и домашнее задание со стартером и проверкой.

Веб-версия: <https://olonho.github.io/agentic-class/>

## Структура

| Путь | Что это |
|---|---|
| `lecture/` | Исходники колоды лекции и раздатки на ArkTS (копии из пакета preso) |
| `docs/lecture/exports/` | Экспортированные PDF: `agentic-lecture.pdf` (29 слайдов), `homework-handout.pdf` (19 слайдов) |
| `homework/start/` | Стартер для студента: доска задач на React + TypeScript с issue #7, унаследованной пустой строкой и неверным счётчиком |
| `homework/teacher/` | **Только локально:** `hidden.test.ts` (скрытый приёмочный набор) и `evaluate.sh` (проверка одной папки работы) |
| `homework/runs/` | **Только локально:** свидетельства реальных прогонов агента: SPEC, тесты, красные прогоны, отчёты, рефлексии |
| `agent-loop-lab/` | Клиентское приложение на Vite: открытый, почти закрытый и закрытый циклы агента |
| `docs/` | Сайт GitHub Pages: главная, веб-версия задания и собранный тренажёр в `docs/loop/` |

`homework/teacher/` и `homework/runs/` намеренно не публикуются: открытый скрытый набор
тестов или чужие решения обесценивают задание. Держите их вне публичного репозитория.

## Проверка работ

Скрипт `evaluate.sh` и скрытый набор `hidden.test.ts` в публичный репозиторий не входят —
они есть только в локальной копии преподавателя. Гейты: собственные тесты студента,
скрытая приёмка, пять артефактов и три помеченных блока красного прогона.

В локальной копии зависимости прогонов подключаются симлинком
`homework/runs/sN/node_modules → ../../start/node_modules` или `npm install` в `homework/start/`.

## Запустить тренажёр

```bash
cd agentic-class/agent-loop-lab
npm install
npm run dev
```

Пересобрать опубликованную копию после изменений:

```bash
npm run build
rm -rf ../docs/loop/* && cp -R dist/* ../docs/loop/
```

## Пересобрать PDF

Исходники колод лежат в `../arkui3/arktsx/preso/demo/`. Из пакета preso:

```bash
cd arkui3/arktsx/preso
npm run compile:demo && npm run hooks:headless
CLI_ARGS="--export-pdf build/agentic-lecture.pdf" \
  npm exec -- arkts run demo/agentic-lecture.ets --no-build --tag headless
CLI_ARGS="--export-pdf build/homework.pdf" \
  npm exec -- arkts run demo/homework.ets --no-build --tag headless
cp build/agentic-lecture.pdf ../agentic-class/docs/lecture/exports/
cp build/homework.pdf ../agentic-class/docs/lecture/exports/homework-handout.pdf
```

## Публикация

Корень GitHub Pages — `docs/`. В настройках репозитория выберите
**Settings → Pages → Source: GitHub Actions**; workflow
`.github/workflows/static.yml` публикует `docs/` при каждом пуше в `main`.
