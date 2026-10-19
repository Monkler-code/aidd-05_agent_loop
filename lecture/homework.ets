/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { SvgIcons } from "arktsx.ui"
import { DeckConfig, runDataDeck } from "../lib/index"

// Homework 1 for the "Agentic development" lecture. An assignment sheet, not a
// syllabus: a named task in a named starter, five named SPEC sections, the exact
// agent prompt, the exact commands, the exact files handed in, and the points.
//
// Mirrors ASSIGNMENT.md and the web version one-to-one: same paths, same three
// red-run breaks, same U+200B change, same grading and gates.

const deck: DeckConfig = {
    title: "ДЗ 1: управление агентом",
    theme: "light",
    transition: "fade",
    slides: [
        {
            kind: "custom",
            kicker: "Домашнее задание 1 · 90 минут",
            title: "Управление агентом",
            subtitle: "Сдаётся ссылкой на ваш клон репозитория; дедлайн — начало следующего занятия",
            nodes: [
                { type: "callout", tone: "accent", icon: SvgIcons.Info, title: "Задача",
                  text: "Исправить реальный баг issue #7: задача с названием из одних пробелов остаётся в списке. Спека — без ИИ, реализация — агентом, проверка — ваша." },
                { type: "text", value: "Веб-версия и стартер: olonho.github.io/agentic-class/homework.html", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Задача · issue #7",
            title: "Пустая задача после правки",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "Воспроизведение: открыть задачу → стереть название до пробелов → сохранить.", size: "body" },
                    { type: "text", value: "Фактически: задача остаётся в списке; фильтр «Открытые» показывает пустую строку.", size: "body" },
                    { type: "text", value: "Ожидалось: не сохранять и показать «Название не может быть пустым».", size: "body" },
                    { type: "text", value: "Границы: пробел, табуляция, неразрывный пробел U+00A0.", size: "body" },
                ]},
                { type: "text", value: "R2–R3 в issue не упомянуты: их нужно найти самому, проверив весь экран, а не только отчёт.", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Подготовка · 5 минут",
            title: "Стартер: Vite + React + TypeScript + Vitest",
            nodes: [
                { type: "code", code: "npm install    # зависимости\nnpm test       # 2 стартовых теста, зелёные\nnpm run dev    # Vite, обычно http://localhost:5173\nnpm run build  # tsc --noEmit + production-сборка" },
                { type: "text", value: "Нужен Node.js 20+. Команды и правила для агента — в AGENTS.md.", size: "caption" },
            ],
        },
        {
            kind: "stats",
            kicker: "Как устроено задание",
            title: "90 минут, шесть баллов, один агент",
            stats: [
                { value: "90", label: "минут на всё" },
                { value: "4", label: "требования R1–R4" },
                { value: "3+1", label: "красных прогона: (а)(б)(в) и (г)" },
                { value: "1", label: "worker-агент, только со SPEC" },
            ],
        },
        {
            kind: "flow",
            kicker: "Цикл, а не один проход",
            title: "Спека → тесты → агент → проверка → правило",
            items: ["SPEC.md", "Тесты", "Агент", "Проверка", "Правило"],
        },
        {
            kind: "custom",
            kicker: "Шаг 1 · 15 минут · без ИИ",
            title: "SPEC.md — пять обязательных разделов",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "1. Requirement — одно предложение от лица пользователя.", size: "body" },
                    { type: "text", value: "2. Acceptance tests — по одному на R1–R3; R4 — это сами тесты.", size: "body" },
                    { type: "text", value: "3. Non-goals — что вы сознательно не делаете.", size: "body" },
                    { type: "text", value: "4. Files in scope — src/tasks.ts и src/App.tsx.", size: "body" },
                    { type: "text", value: "5. Definition of done — какие сигналы должны быть зелёными.", size: "body" },
                ]},
                { type: "text", value: "ИИ на этом шаге не используется — это условие зачёта.", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 2 · 20 минут",
            title: "Тесты первыми — агент их не увидит",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "Пишете тесты сами, до работы агента: на R1, R2, R3.", size: "body" },
                    { type: "text", value: "Файл — src/tasks.test.ts или отдельный: пустое имя, края, унаследованная строка, счётчик.", size: "body" },
                    { type: "text", value: "Агент не получает тесты и не должен их читать.", size: "body" },
                ]},
                { type: "text", value: "R4: на каждое требование R1–R3 — минимум один тест. Зелёные стартовые 2/2 ничего не доказывают.", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 3 · 20 минут",
            title: "Агент работает, вы ведёте лог",
            nodes: [
                { type: "code", code: "Прочитай SPEC.md и реализуй задачу точно по нему.\nМеняй только src/tasks.ts и src/App.tsx.\nПосле изменений запусти npm test и покажи результат." },
                { type: "text", value: "Код не правите. Каждое вмешательство — строка в INTERVENTIONS.md:", size: "body" },
                { type: "text", value: "время · что · зачем (например: 14:05 · переписал промпт · агент менял файлы вне scope).", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 4 · 10 минут",
            title: "Проверяете сами, не по слову агента",
            nodes: [
                { type: "code", code: "mkdir -p evidence\nnpm test                 # должно быть зелёно\nnpm run build            # типы и сборка\ngit diff --stat          # только src/tasks.ts и src/App.tsx\nnpm run dev              # скриншот в evidence/app.png" },
                { type: "text", value: "На скриншоте: «Открытых: 1», пустых строк нет. Если тесты не зелёные, шаг не зачтён.", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 5 · 10 минут",
            title: "Красный прогон: три поломки, три блока",
            nodes: [
                { type: "column", gap: 8, children: [
                    { type: "text", value: "(а) убрать обрезание пробелов в createTask;", size: "body" },
                    { type: "text", value: "(б) убрать валидацию в renameTask;", size: "body" },
                    { type: "text", value: "(в) убрать фильтрацию унаследованной пустой строки (R2).", size: "body" },
                ]},
                { type: "code", code: "npm test 2>&1 | tee -a evidence/red.txt   # блок (а)\n# восстановить код, затем так же блоки (б) и (в)" },
                { type: "callout", tone: "danger", icon: SvgIcons.Error, title: "Иначе",
                  text: "Если после поломки тесты остались зелёными — ваш сигнал ничего не проверяет; исправьте тесты и повторите." },
            ],
        },
        {
            kind: "custom",
            kicker: "Изменение требования · после шага 5",
            title: "U+200B — тоже пустота",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "Название из одного символа U+200B (zero-width space) тоже считается пустым.", size: "body" },
                    { type: "text", value: "Обновите SPEC.md, тесты и реализацию тем же циклом: спека → агент → проверка → красный прогон.", size: "body" },
                    { type: "text", value: "Новая поломка — отдельный блок (г) в evidence/red.txt.", size: "body" },
                ]},
                { type: "text", value: "Это и есть проверка на «вариант»: первая реализация на String.trim() этот случай не ловит.", size: "caption" },
            ],
        },
        {
            kind: "grid",
            kicker: "Шаг 6 · 10 минут",
            title: "Каждый провал — в таксономию",
            columns: 3,
            cells: [
                { title: "Планирование", icon: SvgIcons.Info, items: ["спека"] },
                { title: "Контекст", icon: SvgIcons.Eye, items: ["агент не знал"] },
                { title: "Инструмент", icon: SvgIcons.Settings, items: ["команда"] },
                { title: "Политика", icon: SvgIcons.Shield, items: ["перила"] },
                { title: "Артефакт", icon: SvgIcons.Check, items: ["не тот файл"] },
                { title: "Проверка", icon: SvgIcons.Search, items: ["ложный сигнал"] },
                { title: "UX", icon: SvgIcons.Star, items: ["неудобно"] },
                { title: "Восстановление", icon: SvgIcons.Refresh, items: ["откат"] },
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 6 · продолжение",
            title: "Одно правило, которое ловит тот же провал",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "Строка в REPORT.md: <категория>: <что произошло> → <правило>, с уликой (транскрипт, хунк диффа или имя теста).", size: "body" },
                    { type: "text", value: "Правило — один из трёх видов: тест, правило линтера или строка в AGENTS.md.", size: "body" },
                    { type: "text", value: "Оно должно ловить вариант провала, а не только увиденный случай.", size: "body" },
                ]},
                { type: "text", value: "Проверка: сломайте код так же, как в шаге 5 — правило обязано сработать.", size: "caption" },
            ],
        },
        {
            kind: "table",
            kicker: "Шаг 6 · пример",
            title: "Строка REPORT.md, которую можно проверить",
            headers: ["Категория", "Что произошло", "Правило"],
            rows: [
                ["Проверка", "Агент сдал зелёный trim()", "таблица классов: пробел, tab, NBSP, U+200B"],
                ["Артефакт", "Правки вне разрешённых файлов", "lint: только src/tasks.ts и src/App.tsx"],
                ["Контекст", "Агент не знал про R2", "в SPEC — фильтр «Открытые» и унаследованная строка"],
            ],
        },
        {
            kind: "custom",
            kicker: "Шаг 7 · 5 минут",
            title: "REFLECTION.md — пять строк, без ИИ",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "1. Что агент понял не так, как вы, и какой строкой спеки это было вызвано?", size: "body" },
                    { type: "text", value: "2. Какой ваш сигнал оказался ложным и что вы им заменили?", size: "body" },
                    { type: "text", value: "3. Какое правило вы добавили и какой провал оно закрывает?", size: "body" },
                ]},
                { type: "text", value: "Ровно пять строк. Без ИИ.", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Сдача · 6 баллов",
            title: "Что лежит в репозитории",
            nodes: [
                { type: "column", gap: 8, children: [
                    { type: "text", value: "SPEC.md — 5 разделов, написан без ИИ  ·  1 балл", size: "body" },
                    { type: "text", value: "Тесты на R1–R3 в репозитории  ·  1 балл", size: "body" },
                    { type: "text", value: "evidence/app.png и evidence/red.txt с блоками (а)(б)(в)  ·  1 балл", size: "body" },
                    { type: "text", value: "INTERVENTIONS.md — все вмешательства  ·  1 балл", size: "body" },
                    { type: "text", value: "REPORT.md — таксономия и правило, которое ловит вариант  ·  1 балл", size: "body" },
                    { type: "text", value: "REFLECTION.md — пять строк  ·  1 балл", size: "body" },
                ]},
                { type: "text", value: "Скрытый набор тестов преподавателя — обязательный гейт: не проходит — не зачтено.", size: "caption" },
                { type: "text", value: "Защита 3 минуты: сломать одно из трёх мест, показать красное и объяснить, почему зелёный значит «проверено».", size: "caption" },
            ],
        },
        {
            kind: "custom",
            kicker: "Бонус · +1",
            title: "Два прогона одной задачи: с SPEC и без",
            nodes: [
                { type: "column", gap: 10, children: [
                    { type: "text", value: "Прогон 1: агент получает задачу одним предложением (SPEC не показываете).", size: "body" },
                    { type: "text", value: "Прогон 2: тот же промпт, но с SPEC.md — как в шаге 3.", size: "body" },
                    { type: "text", value: "Таблица: время до первой сдачи · ходы · вмешательства · дефекты при приёмке.", size: "body" },
                    { type: "text", value: "Вывод одной фразой: что именно дала спецификация.", size: "body" },
                ]},
                { type: "text", value: "Без спецификации начинайте с чистого репозитория (git stash), иначе прогоны несравнимы.", size: "caption" },
            ],
        },
        {
            kind: "quote",
            kicker: "Перед сдачей",
            quote: "Зелёный прогон доказывает ровно то, что перечислено в тестах.",
            attribution: "Поэтому нужен вариант, которого в перечислении не было.",
        },
        {
            kind: "custom",
            kicker: "Не зачтено, если…",
            title: "Стоп-условия",
            nodes: [
                { type: "callout", tone: "danger", icon: SvgIcons.Error, title: "Стоп-условия",
                  text: "SPEC писал ИИ · нет трёх красных блоков · правило не срабатывает на своём провале · скрытый набор не проходит." },
                { type: "takeaway", tone: "accent", icon: SvgIcons.Star,
                  value: "Сдаётся портфолио процесса, а не патч агента.",
                  text: "Оценивается то, что вы проверили сами, и правило, которое не даст провалу повториться." },
            ],
        },
    ],
}

export function main(): void {
    runDataDeck(deck)
}
