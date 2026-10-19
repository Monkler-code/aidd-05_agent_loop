/*
 * Copyright (c) 2022-2026 Huawei Device Co., Ltd.
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

import { Color, IconColorLayer, SvgIcons } from "arktsx.ui"
import { DeckConfig, runDataDeck } from "../lib/index"

// Lecture "Agentic development" for 1st–2nd year students.
// General principles of fast, stable agentic development:
// a short feedback loop, echeloned safety, a high cadence.

// Multi-color icons for the three pillars (teal · violet · amber).
const TEAL: Color = Color.rgb(0x0d, 0x94, 0x88)
const VIOLET: Color = Color.rgb(0x6d, 0x4a, 0xff)
const AMBER: Color = Color.rgb(0xd9, 0x77, 0x06)
const TOOLS_ICON: Array<IconColorLayer> = [{ path: SvgIcons.Settings, color: TEAL }]
const PRINCIPLES_ICON: Array<IconColorLayer> = [{ path: SvgIcons.Shield, color: VIOLET }]
const PROCESSES_ICON: Array<IconColorLayer> = [{ path: SvgIcons.Clock, color: AMBER }]

// ── Diagrams (mermaid) ──────────────────────────────────────────────────────

// Cheapest-first: each layer catches what the one above it cannot see, and the
// cost of a mistake grows as the error travels down. Four layers, not five:
// the repo's own stack lists the memo dependency graph as layer 2, which is
// framework-specific and out of scope for this lecture.
const DIAGRAM_DEFENSE: string = `flowchart LR
  E["Ошибка агента"] --> L1["1 · Типы"]
  L1 --> L2["2 · Валидация"]
  L2 --> L3["3 · Сверка отрисовки"]
  L3 --> L4["4 · Среда выполнения"]
  icon E Error
  icon L1 Check
  icon L2 Shield
  icon L3 Eye
  icon L4 Power
  classDef ok fill:#d7f0dd,stroke:#16a34a
  classDef teal fill:#cdf0ec,stroke:#0d9488
  classDef blue fill:#dbe7fb,stroke:#1f6feb
  classDef violet fill:#e7e2fd,stroke:#6d4aff
  class L1 ok
  class L2 teal
  class L3 blue
  class L4 violet`

// The agent loop, drawn as a loop: the module routes the back edge onto its own
// lane, so a cycle reads as a cycle rather than as a straight pipeline.
const DIAGRAM_LOOP: string = `flowchart LR
  A["код"] --> B["сборка"]
  B --> C["запуск"]
  C --> D["снимок"]
  D --> E["сверка"]
  E --> A
  classDef stage fill:#e8effc,stroke:#2563eb,stroke-width:1px,color:#161a22
  class A,B,C,D,E stage`

// ── Deck ────────────────────────────────────────────────────────────────────

const deck: DeckConfig = {
    title: "Агентская разработка: как быстро создавать большие качественные проекты и не сойти с ума",
    theme: "light",
    // The physical page fold: a slide leaves as a sheet peeled over a crease
    // rather than a crossfade, so a lecture reads as pages turning. It is a
    // shader over a recorded page, hence the longer settle than a fade's.
    transition: "pageTurn",
    transitionDurationMs: 900,
    slides: [
        {
            kind: "custom",
            kicker: "Лекция · агентская разработка",
            title: "Как бежать быстро и не сломаться",
            nodes: [
                { type: "row", gap: 28, children: [
                    { type: "column", gap: 12, children: [
                        { type: "text", value: "— Николай Иготти", size: "subtitle" },
                        { type: "text", value: "Цикл «написал → проверил» как единица работы", size: "caption" },
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/01-cover.jpg", width: 400, height: 298, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Что это такое",
            title: "Агент — это цикл, не автодополнение",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Пишет: сотни строк кода за секунды",
                        "Запускает: компилирует и выполняет сам",
                        "Проверяет: видит результат, а не код",
                        "Повторяет: правит и запускает снова",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/07-fastcycle.jpg", width: 400, height: 298, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Организующая рамка",
            title: "Три составляющих быстрой разработки",
            nodes: [
                { type: "row", gap: 20, children: [
                    { type: "card", tone: "accent", iconLayers: TOOLS_ICON, title: "Инструменты", children: [
                        { type: "image", src: "demo/assets/lecture-1/02-tools.jpg", width: 160, height: 160, radius: 16, fit: "cover" },
                        { type: "text", value: "язык, компилятор, среда", size: "caption" },
                        { type: "text", value: "дают скорость", size: "caption" },
                    ]},
                    { type: "card", tone: "alt", iconLayers: PRINCIPLES_ICON, title: "Принципы", children: [
                        { type: "image", src: "demo/assets/lecture-1/03-principles.jpg", width: 160, height: 160, radius: 16, fit: "cover" },
                        { type: "text", value: "стандарты и соглашения", size: "caption" },
                        { type: "text", value: "дают стабильность", size: "caption" },
                    ]},
                    { type: "card", tone: "warn", iconLayers: PROCESSES_ICON, title: "Процессы", children: [
                        { type: "image", src: "demo/assets/lecture-1/04-processes.jpg", width: 160, height: 160, radius: 16, fit: "cover" },
                        { type: "text", value: "документация, знания", size: "caption" },
                        { type: "text", value: "дают темп", size: "caption" },
                    ]},
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Почему это проблема",
            title: "Три трудности, которые создаёт агент",
            nodes: [
                { type: "row", gap: 16, children: [
                    { type: "card", tone: "danger", icon: SvgIcons.Clock, title: "Дорогая проверка", children: [
                        { type: "text", value: "проверка не дешевле генерации", size: "caption" },
                        { type: "text", value: "значит цикл проверки — короче", size: "caption" },
                    ]},
                    { type: "card", tone: "danger", icon: SvgIcons.Error, title: "Вероятностные ошибки", children: [
                        { type: "text", value: "каждая строка может быть неверной", size: "caption" },
                        { type: "text", value: "ловить на самом раннем слое", size: "caption" },
                    ]},
                    { type: "card", tone: "danger", icon: SvgIcons.Info, title: "Забывание", children: [
                        { type: "text", value: "контекст короток", size: "caption" },
                        { type: "text", value: "знания — во внешней памяти", size: "caption" },
                    ]},
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Сердце агентной разработки",
            title: "Главный цикл: секунды, не минуты",
            subtitle: "И снова по кругу: один оборот цикла и есть единица работы агента",
            nodes: [
                { type: "row", gap: 20, children: [
                    { type: "row", gap: 24, children: [
                        { type: "diagram", height: 320, source: DIAGRAM_LOOP },
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/07-fastcycle.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Цикл по цифрам",
            title: "Полный круг за секунды",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Генерация кода — 1–5 с (инференс)",
                        "Компиляция — 0,5–2 с (типы)",
                        "Запуск — 0,2 с (среда)",
                        "Проверка — 0,5 с (рендер)",
                        "Полный цикл — ≈2–8 с",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/05-loop.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Вопрос аудитории",
            title: "Что труднее: код или задача?",
            notes: "Пауза, 30 секунд. Правильный ответ — понять задачу: генерация воспроизводит увиденное, а требований и границ модель не знает, пока их не сформулируют. Это и есть причина, по которой в агентной разработке главное — требования, тесты и проверка.",
            nodes: [
                { type: "row", gap: 20, children: [
                    { type: "card", tone: "ok", badge: "A", title: "Написать код", children: [
                        { type: "text", value: "быстро выдать рабочую версию", size: "caption" },
                        { type: "text", value: "модель видела миллионы примеров", size: "caption" },
                        { type: "text", value: "ошибку видно сразу: код не компилируется", size: "caption" },
                    ]},
                    { type: "card", tone: "warn", badge: "B", title: "Понять, что именно нужно", children: [
                        { type: "text", value: "уточнить требования и границы", size: "caption" },
                        { type: "text", value: "решить, что считается правильным", size: "caption" },
                        { type: "text", value: "ошибку не видно: код работает, но не то", size: "caption" },
                    ]},
                ]},
                { type: "text", value: "Правильный ответ — понять задачу: требований модель не знает", size: "body" },
            ],
        },
        {
            kind: "custom",
            kicker: "Как это работает",
            title: "Сходимость вместо идеального шага",
            notes: "Каждый шаг агента — случайная величина: он почти наверняка не идеален, и это нормально. Смысл не в одном идеальном шаге, а в последовательности, которая сходится: цикл уменьшает расстояние до цели, пока сигнал не перестанет меняться — это и есть неподвижная точка. Ускоряют сходимость двумя способами: короче оборот (сборка, тесты) и меньше оборотов (типы, отладчик, анализатор, размер шага).",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Каждый шаг почти наверняка не идеален",
                        "Конец работы — неподвижная точка",
                        "Оптимизируем скорость, а не красоту шага",
                        "Короче оборот и меньше оборотов",
                        "Управляем циклом: сигнал → правка → сигнал",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/13-fixedpoint.jpg", width: 340, height: 254, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Как ускорить сходимость",
            title: "Рычаги скорости",
            notes: "Две группы рычагов. Первая сокращает время оборота, вторая — число оборотов до сходимости. Вторая группа кажется дорогой, но она не ускоряет шаг: она убирает лишние.",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "column", gap: 10, children: [
                        { type: "text", value: "Короче оборот", size: "subtitle" },
                        { type: "bullets", gap: 10, items: [
                            "Быстрая сборка: секунды, не минуты",
                            "Быстрые тесты: сигнал сразу",
                        ]},
                        { type: "text", value: "Меньше оборотов", size: "subtitle" },
                        { type: "bullets", gap: 10, items: [
                            "Типы ловят ошибку до запуска",
                            "Отладчик: состояние, не догадки",
                        ]},
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/07-fastcycle.jpg", width: 320, height: 238, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Обратная сторона",
            title: "Когда процесс не сходится",
            notes: "Четыре режима отказа: расходимость (нет сигнала), блуждание (размытая цель), хаос (крупный шаг), ложная сходимость (мигающий тест). Все четыре лечатся процессом, а не более сильной моделью.",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Нет сигнала: ошибка копится незаметно",
                        "Цель размыта: каждая итерация оптимизирует своё",
                        "Большой шаг: ошибка не локализована",
                        "Мигающий тест: сходимость недостижима в принципе",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/14-stuck.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "section",
            num: "1",
            kicker: "Столп 1",
            title: "Инструменты",
            subtitle: "язык · компилятор · среда · отладчик · анализатор · библиотеки",
            icon: SvgIcons.Settings,
            theme: "midnight",
        },
        {
            kind: "custom",
            kicker: "Столп 1 · Инструменты",
            title: "Что ускоряет агента",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "column", gap: 16, children: [
                        { type: "row", gap: 16, children: [
                            { type: "card", tone: "accent", icon: SvgIcons.Check, title: "Язык", children: [
                                { type: "text", value: "статическая типизация", size: "caption" },
                            ]},
                            { type: "card", tone: "accent", icon: SvgIcons.LightningBolt, title: "Сборка", children: [
                                { type: "text", value: "секунды, не минуты", size: "caption" },
                            ]},
                        ]},
                        { type: "row", gap: 16, children: [
                            { type: "card", tone: "accent", icon: SvgIcons.Eye, title: "Наблюдаемость", children: [
                                { type: "text", value: "отладчик и анализатор", size: "caption" },
                            ]},
                            { type: "card", tone: "accent", icon: SvgIcons.Star, title: "Библиотеки", children: [
                                { type: "text", value: "UI, сеть, хранение", size: "caption" },
                            ]},
                        ]},
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/02-tools.jpg", width: 320, height: 238, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Инструмент №1",
            title: "Ошибка видна до запуска",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "column", gap: 10, children: [
                        { type: "text", value: "Компилятор проверяет типы до запуска:", size: "body" },
                        { type: "code", language: "ArkTS", code: "const n: number = \"текст\"   // ✗ ошибка типов\nconst n: number = 42         // ✓ корректно" },
                        { type: "bullets", gap: 10, size: "caption", items: [
                            "Агенту не нужно запускать код, чтобы узнать о неверном типе",
                            "Ошибка приходит за секунды и там, где она сделана",
                        ]},
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/06-types.jpg", width: 320, height: 238, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Инструмент №2",
            title: "«Глаза и руки» агента",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Видит отрисованный результат, а не код",
                        "Ходит по дереву интерфейса и кликает",
                        "Сравнивает с ожидаемым состоянием",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/09-inspect.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "section",
            num: "2",
            kicker: "Столп 2",
            title: "Принципы",
            subtitle: "стандарты · соглашения · защитные перила",
            icon: SvgIcons.Shield,
            theme: "midnight",
        },
        {
            kind: "custom",
            kicker: "Столп 2 · Принципы",
            title: "Защитные перила",
            nodes: [
                { type: "row", gap: 16, children: [
                    { type: "card", tone: "danger", icon: SvgIcons.Shield, title: "Никогда: репозиторий", children: [
                        { type: "text", value: "публикация в публичный реестр", size: "caption" },
                        { type: "text", value: "перезапись истории", size: "caption" },
                        { type: "text", value: "необратимое удаление файлов", size: "caption" },
                    ]},
                    { type: "card", tone: "danger", icon: SvgIcons.Lock, title: "Никогда: доступы", children: [
                        { type: "text", value: "запуск чужого кода с правами", size: "caption" },
                        { type: "text", value: "правка секретов и ключей", size: "caption" },
                        { type: "text", value: "«добавить всё» одной командой", size: "caption" },
                    ]},
                    { type: "card", tone: "warn", icon: SvgIcons.Bell, title: "Только по просьбе", children: [
                        { type: "text", value: "публикация артефактов", size: "caption" },
                        { type: "text", value: "массовая очистка репозитория", size: "caption" },
                        { type: "text", value: "изменение конфигурации CI", size: "caption" },
                    ]},
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Принципы · Самопроверка",
            title: "Самопроверка перед сдачей",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Чек-лист — по диффу, а не по памяти о правке",
                        "Ищем: неявные преобразования, два способа для «пусто»",
                        "Правки генерённого кода",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/08-debug.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "diagram",
            kicker: "Итог принципов",
            title: "Эшелонированная оборона: 4 слоя",
            subtitle: "Чем раньше слой ловит ошибку — тем дешевле исправление",
            source: DIAGRAM_DEFENSE,
        },
        {
            kind: "section",
            num: "3",
            kicker: "Столп 3",
            title: "Процессы",
            subtitle: "документация · ревью · CI · тесты · база знаний",
            icon: SvgIcons.Clock,
            theme: "midnight",
        },
        {
            kind: "custom",
            kicker: "Процессы · Тесты",
            title: "Тесты и CI: предсказуемый агент",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Тесты пишутся вместе с функцией, а не после",
                        "Граничные случаи — там, где живут ошибки",
                        "CI: установка, сборка и тесты на каждом коммите",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/10-tests.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Процессы · Сигнал",
            title: "Зелёный сигнал должен что-то значить",
            notes: "Код возврата 0 не значит, что тесты прошли: читай итоговую строку прогона. И тест обязан что-то утверждать — печатающая программа зелёная всегда.",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Упал — а код возврата 0: читать итоговую строку",
                        "Тест без проверок: печать «ок» не доказывает",
                        "Только типичный случай: ошибки живут на краях",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/15-green.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Процессы · CI",
            title: "Красный пайплайн — это задача",
            notes: "Зависимости джоб перечисляются полностью: транзитивных в CI не бывает. И публикуй артефакт, а не лог о том, что он собран: пропущенный glob в артефактах выглядит как проблема графа зависимостей, хотя дефект — один glob.",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "column", gap: 14, children: [
                        { type: "row", gap: 14, children: [
                            { type: "card", tone: "danger", badge: "1", title: "Упало", children: [
                                { type: "text", value: "лог, шаг, первая ошибка", size: "caption" },
                            ]},
                            { type: "card", tone: "warn", badge: "2", title: "Понять", children: [
                                { type: "text", value: "воспроизвести локально", size: "caption" },
                            ]},
                        ]},
                        { type: "row", gap: 14, children: [
                            { type: "card", tone: "warn", badge: "3", title: "Починить", children: [
                                { type: "text", value: "правкой в репозитории", size: "caption" },
                            ]},
                            { type: "card", tone: "ok", badge: "4", title: "Перезапустить", children: [
                                { type: "text", value: "зелёный не случаен?", size: "caption" },
                            ]},
                        ]},
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/16-pipeline.jpg", width: 320, height: 238, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Процессы · Ревью",
            title: "Ревью: независимые взгляды",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "Четыре роли: архитектура, безопасность, скорость, соглашения",
                        "У каждого свой чек-лист рядом с определением",
                        "Одобряет человек: иначе проверка сертифицирует сама себя",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/11-review.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Процессы · Знание",
            title: "База знаний и память агента",
            nodes: [
                { type: "row", gap: 24, children: [
                    { type: "bullets", gap: 10, items: [
                        "«Почему» и «как связано» — рядом с кодом",
                        "Заметки живут между сессиями агента",
                        "Обновляется вместе с изменением, а не после",
                    ]},
                    { type: "image", src: "demo/assets/lecture-1/12-knowledge.jpg", width: 380, height: 284, radius: 16, fit: "cover" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Пример · Как это выглядит",
            title: "Один конкретный стек как иллюстрация",
            nodes: [
                { type: "row", gap: 40, children: [
                    { type: "column", gap: 12, children: [
                        { type: "text", value: "Что даёт агенту дружелюбный инструментарий", size: "subtitle" },
                        { type: "bullets", gap: 10, items: [
                            "Компиляция и запуск — секунды, не минуты",
                            "Статические типы ловят ошибку до запуска",
                            "Тесты без экрана и «глаза» на интерфейс",
                            "Внешняя память: правила и заметки рядом с кодом",
                        ]},
                    ]},
                    { type: "image", src: "demo/arkui3-qr.png", width: 200, height: 200, caption: "Пример такого стека: gitcode.com/rri_opensource/arkui3" },
                ]},
            ],
        },
        {
            kind: "custom",
            kicker: "Что взять с собой",
            title: "Чек-лист агентной разработки",
            subtitle: "Что не проверяется машиной — того не существует",
            nodes: [
                { type: "column", gap: 16, children: [
                    { type: "row", gap: 16, children: [
                        { type: "card", tone: "accent", icon: SvgIcons.Lock, title: "Правила", children: [
                            { type: "text", value: "файл, который агент читает до работы", size: "caption" },
                        ]},
                        { type: "card", tone: "accent", icon: SvgIcons.Refresh, title: "Короткий цикл", children: [
                            { type: "text", value: "компиляция и проверка за секунды", size: "caption" },
                        ]},
                        { type: "card", tone: "accent", icon: SvgIcons.Shield, title: "Ранние ошибки", children: [
                            { type: "text", value: "типы и валидация до запуска", size: "caption" },
                        ]},
                    ]},
                    { type: "row", gap: 16, children: [
                        { type: "card", tone: "ok", icon: SvgIcons.Eye, title: "«Глаза»", children: [
                            { type: "text", value: "снимок и дерево вместо слепого кода", size: "caption" },
                        ]},
                        { type: "card", tone: "ok", icon: SvgIcons.Check, title: "Тесты с кодом", children: [
                            { type: "text", value: "и запуск на каждом коммите", size: "caption" },
                        ]},
                        { type: "card", tone: "ok", icon: SvgIcons.Star, title: "База знаний", children: [
                            { type: "text", value: "«почему» и «как связано»", size: "caption" },
                        ]},
                    ]},
                ]},
            ],
        },
    ],
}

export function main(): void {
    runDataDeck(deck)
}
