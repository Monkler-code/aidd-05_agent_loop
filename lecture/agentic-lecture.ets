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

import { memo } from "arkui.incremental.runtime.annotations"
import { RepeatByArray } from "arkui.incremental.runtime"
import { FontStyle } from "arktsx.graphics"
import {
    Alignment,
    Color,
    Column,
    Container,
    HorizontalAlignment,
    IconByPathSVG,
    indents,
    RoundedCorners,
    Row,
    SizePolicy,
    stroke,
    SvgIcons,
    Text,
    TextAlignment,
    VerticalAlignment,
} from "arktsx.ui"
import {
    Callout,
    CellMark,
    CellMarkKind,
    CheckMatrix,
    Code,
    Columns,
    ComparePanels,
    currentSlideTheme,
    deckOf,
    Diagram,
    DiagramFigure,
    DENSE_DENSITY,
    LIGHT_THEME,
    MIDNIGHT_THEME,
    PresoBackgroundKind,
    PresentationOptions,
    PresoDeck,
    ProvideSlideTheme,
    PyramidStack,
    RevealGroup,
    runPresentationCli,
    SectionDivider,
    SlideHeader,
    slideOf,
    SLIDE_WIDE,
    SlideTransitionKind,
    SlideFrame,
    SlideImage,
    SlideTheme,
    StatusBoard,
    TableSlide,
    themeWithDensity,
    toneAccentInk,
    toneBorder,
    toneFill,
} from "../lib/index"

// Lecture "Agentic development" for 1st–2nd year students.
// General principles of fast, stable agentic development:
// a short feedback loop, echeloned safety, a high cadence.
//
// This is a code deck (not `deckFromData`) on purpose: the argument needs the
// composition primitives the data path cannot reach — a judged A/B pair
// (`ComparePanels`), width-weighted columns (`Columns`), a grouped outline, and
// the pattern families' figures (`CheckMatrix`, `PyramidStack`, `StatusBoard`).

// ── Diagrams (mermaid) ──────────────────────────────────────────────────────

const DIAGRAM_LOOP: string = `flowchart LR
  A["код"] --> B["сборка"]
  B --> C["запуск"]
  C --> D["снимок"]
  D --> E["сверка"]
  E --> A
  classDef stage fill:#e8effc,stroke:#2563eb,stroke-width:1px,color:#161a22
  class A,B,C,D,E stage`

const DIAGRAM_CONVERGENCE: string = `flowchart LR
  S1["5 ошибок"] -- правка --> S2["2 ошибки"]
  S2 -- правка --> S3["1 ошибка"]
  S3 -- правка --> S4["0 — готово"]
  classDef bad fill:#fde2e1,stroke:#dc2626,color:#161a22
  classDef mid fill:#fdeccb,stroke:#d97706,color:#161a22
  classDef ok fill:#d7f0dd,stroke:#16a34a,color:#161a22
  class S1 bad
  class S2,S3 mid
  class S4 ok`

const REJECTED: CellMark = { kind: CellMarkKind.Tick, on: false, tone: "danger" }
const ACCEPTED: CellMark = { kind: CellMarkKind.Tick, on: true, tone: "ok" }

// ── Shared text and card helpers ────────────────────────────────────────────

function sizeOf(role: string, theme: SlideTheme): int {
    switch (role) {
        case "display": return theme.displaySize
        case "title": return theme.titleSize
        case "subtitle": return theme.subtitleSize
        case "caption": return theme.captionSize
        default: return theme.bodySize
    }
}

function inkOf(role: string, theme: SlideTheme): Color {
    switch (role) {
        case "secondary": return theme.textSecondary
        case "accent": return theme.accent
        default: return theme.textPrimary
    }
}

@memo
function Txt(value: string, role: string = "body", tone: string = "primary"): void {
    const theme = currentSlideTheme()
    Text(value, {
        fontSize: sizeOf(role, theme),
        color: inkOf(tone, theme),
        fontFamily: theme.fontFamily,
        widthPolicy: SizePolicy.Stretched,
        textAlign: TextAlignment.Start,
    })
}

/**
 * A tonal card: a round mark (badge or icon), a bold title, then fixed lines.
 * Data-only on purpose — the memo transform cannot take a content lambda as a
 * positional argument of a struct with `@memo` fields.
 */
@memo
function InfoCard2(
    title: string,
    tone: string,
    lines: Array<string>,
    icon: string = "",
    badge: string = "",
    image: string = "",
    imageSize: int = 0,
    fillHeight: boolean = false,
): void {
    const theme = currentSlideTheme()
    const tinted: boolean = tone != ""
    const markTone: string = tinted ? tone : "accent"
    Container({
        backgroundColor: tinted ? toneFill(tone, theme) : theme.surface,
        stroke: stroke(1, tinted ? toneBorder(tone, theme) : theme.surfaceBorder),
        corners: RoundedCorners.dp(theme.radius),
        padding: indents(theme.gap),
        heightPolicy: fillHeight ? SizePolicy.Stretched : SizePolicy.Wrapped,
        widthPolicy: SizePolicy.Stretched,
    }) {
        Column({
            contentGap: 10,
            heightPolicy: fillHeight ? SizePolicy.Stretched : SizePolicy.Wrapped,
            widthPolicy: SizePolicy.Stretched,
            contentHorizontalAlignment: HorizontalAlignment.Start,
        }) {
            Row({
                contentGap: 10,
                verticalAlignment: VerticalAlignment.Center,
                heightPolicy: SizePolicy.Wrapped,
                widthPolicy: SizePolicy.Stretched,
            }) {
                if (badge != "") {
                    Container({
                        width: 30, height: 30,
                        corners: RoundedCorners.dp(999),
                        backgroundColor: toneAccentInk(markTone, theme),
                        alignment: Alignment.Center,
                    }) {
                        Text(badge, {
                            fontSize: theme.captionSize,
                            color: theme.onAccent,
                            fontFamily: theme.fontFamily,
                            fontStyle: FontStyle.BOLD,
                        })
                    }
                } else if (icon != "") {
                    IconByPathSVG(22, icon, { foreground: toneAccentInk(markTone, theme) })
                }
                if (title != "") {
                    Text(title, {
                        fontSize: theme.subtitleSize,
                        color: theme.textPrimary,
                        fontFamily: theme.fontFamily,
                        fontStyle: FontStyle.BOLD,
                        textAlign: TextAlignment.Start,
                        widthPolicy: SizePolicy.Stretched,
                    })
                }
            }
            if (image != "" && imageSize > 0) {
                SlideImage(image, imageSize, imageSize, 12)
            }
            RepeatByArray(lines, (line: string, index: int): int => index,
                (line: string, index: int): void => {
                    Text(line, {
                        fontSize: theme.captionSize,
                        color: theme.textSecondary,
                        fontFamily: theme.fontFamily,
                        widthPolicy: SizePolicy.Stretched,
                        textAlign: TextAlignment.Start,
                    })
                })
        }
    }
}

@memo
function BulletColumn(items: Array<string>): void {
    const theme = currentSlideTheme()
    Column({ contentGap: 10, heightPolicy: SizePolicy.Wrapped }) {
        RepeatByArray(items, (item: string, index: int): int => index,
            (item: string, index: int): void => {
                Row({
                    contentGap: 10,
                    verticalAlignment: VerticalAlignment.Top,
                    heightPolicy: SizePolicy.Wrapped,
                }) {
                    Container({
                        width: 8, height: 8,
                        corners: RoundedCorners.dp(999),
                        backgroundColor: theme.accent,
                    }) {}
                    Text(item, {
                        fontSize: theme.bodySize,
                        color: theme.textPrimary,
                        fontFamily: theme.fontFamily,
                        widthPolicy: SizePolicy.Stretched,
                    })
                }
            })
    }
}

// ── Content blocks ──────────────────────────────────────────────────────────

@memo
function LoopText(): void {
    BulletColumn([
        "Пишет: сотни строк кода за секунды",
        "Запускает: компилирует и выполняет сам",
        "Смотрит: видит результат, а не только код",
        "Повторяет: правит и запускает снова",
    ])
}

@memo
function LoopArt(): void {
    SlideImage("demo/assets/lecture-1/07-fastcycle.jpg", 400, 260, 16)
}

@memo
function PillarTools(): void {
    InfoCard2("Инструменты", "accent", ["язык, компилятор, среда", "дают скорость"],
        SvgIcons.Settings, "", "demo/assets/lecture-1/02-tools.jpg", 124)
}

@memo
function PillarPrinciples(): void {
    InfoCard2("Принципы", "alt", ["стандарты и соглашения", "дают стабильность"],
        SvgIcons.Shield, "", "demo/assets/lecture-1/03-principles.jpg", 124)
}

@memo
function PillarProcesses(): void {
    InfoCard2("Процессы", "warn", ["документация, знания", "дают темп"],
        SvgIcons.Clock, "", "demo/assets/lecture-1/04-processes.jpg", 124)
}

@memo
function DifficultyCost(): void {
    InfoCard2("Дорогая проверка", "danger", [
        "проверка — второй билет: стоит столько же, сколько генерация",
        "поэтому важна частота циклов, а не размер шага",
    ], SvgIcons.Clock, "", "", 0, true)
}

@memo
function DifficultyProbability(): void {
    InfoCard2("Вероятностные ошибки", "danger", [
        "каждая строка — монетка: может быть неверной",
        "надёжность даёт не модель, а слои проверки",
    ], SvgIcons.Error, "", "", 0, true)
}

@memo
function DifficultyForgetting(): void {
    InfoCard2("Забывание", "danger", [
        "контекст — оперативка без диска",
        "знания надо выносить в файлы и заметки",
    ], SvgIcons.Info, "", "", 0, true)
}

@memo
function CycleDiagram(): void {
    Container({ height: 220, widthPolicy: SizePolicy.Stretched }) {
        Diagram(DIAGRAM_LOOP)
    }
}

@memo
function CycleArt(): void {
    SlideImage("demo/assets/lecture-1/07-fastcycle.jpg", 320, 236, 16)
}

@memo
function QuestionA(): void {
    InfoCard2("Написать код", "accent", [
        "быстро выдать рабочую версию",
        "модель видела миллионы примеров",
        "ошибку видно сразу: код не компилируется",
    ], SvgIcons.LightningBolt, "A", "", 0, true)
}

@memo
function QuestionB(): void {
    InfoCard2("Понять, что именно нужно", "alt", [
        "уточнить требования и границы",
        "решить, что считается правильным",
        "ошибку не видно: код работает, но не то",
    ], SvgIcons.Eye, "B", "", 0, true)
}

@memo
function AnswerA(): void {
    InfoCard2("Код виден", "alt", [
        "компилятор скажет, что не так",
        "ошибка приходит быстро и на месте",
    ], SvgIcons.Eye, "", "", 0, true)
}

@memo
function AnswerB(): void {
    InfoCard2("Задача невидима", "ok", [
        "код работает, но не то",
        "границы и критерии готовности задаёт человек",
    ], SvgIcons.Check, "", "", 0, true)
}

@memo
function ConvergenceText(): void {
    BulletColumn([
        "Каждый шаг неидеален — это нормально",
        "Цель — последовательность, которая сходится",
        "Конец — когда сигнал перестал меняться",
        "Управляем циклом: сигнал → правка → сигнал",
    ])
}

@memo
function ConvergenceFigure(): void {
    const theme = currentSlideTheme()
    Container({
        height: 250,
        widthPolicy: SizePolicy.Stretched,
        backgroundColor: theme.surface,
        stroke: stroke(1, theme.surfaceBorder),
        corners: RoundedCorners.dp(theme.radius),
        padding: indents(14, 10),
    }) {
        DiagramFigure(DIAGRAM_CONVERGENCE, undefined, 1.1f)
    }
}

@memo
function LeversText(): void {
    Column({ contentGap: 10, heightPolicy: SizePolicy.Wrapped }) {
        Txt("Короче оборот", "subtitle")
        BulletColumn(["Сборка за секунды, а не минуты", "Тесты дают сигнал сразу"])
        Txt("Меньше оборотов", "subtitle")
        BulletColumn(["Типы ловят ошибку до запуска", "Отладчик даёт факты, а не догадки", "Маленький шаг: ошибка локальна"])
    }
}

@memo
function LeversArt(): void {
    SlideImage("demo/assets/lecture-1/07-fastcycle.jpg", 380, 284, 16)
}

@memo
function ToolsGrid(): void {
    Column({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
        Row({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Язык", "accent", ["статическая типизация"], SvgIcons.Check)
            InfoCard2("Сборка", "accent", ["секунды, не минуты"], SvgIcons.LightningBolt)
        }
        Row({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Наблюдаемость", "accent", ["отладчик и анализатор"], SvgIcons.Eye)
            InfoCard2("Библиотеки", "accent", ["UI, сеть, хранение"], SvgIcons.Star)
        }
    }
}

@memo
function ToolsArt(): void {
    SlideImage("demo/assets/lecture-1/02-tools.jpg", 320, 238, 16)
}

@memo
function TypesText(): void {
    Column({ contentGap: 12, heightPolicy: SizePolicy.Wrapped }) {
        Code("const n: number = \"текст\"  // ✗\nconst n: number = 42       // ✓", "ArkTS")
        BulletColumn([
            "Агенту не нужно запускать код, чтобы узнать о неверном типе",
            "Ошибка приходит за секунды и там, где она сделана",
        ])
    }
}

@memo
function TypesArt(): void {
    SlideImage("demo/assets/lecture-1/06-types.jpg", 320, 238, 16)
}

@memo
function EyesText(): void {
    BulletColumn([
        "Видит отрисованный результат, а не только код",
        "Ходит по дереву интерфейса и кликает",
        "Сравнивает с ожидаемым состоянием",
    ])
}

@memo
function EyesArt(): void {
    SlideImage("demo/assets/lecture-1/09-inspect.jpg", 340, 254, 16)
}

@memo
function GuardRepo(): void {
    InfoCard2("Никогда: репозиторий", "danger", [
        "публикация в публичный реестр",
        "перезапись истории",
        "необратимое удаление файлов",
    ], SvgIcons.Shield, "", "", 0, true)
}

@memo
function GuardAccess(): void {
    InfoCard2("Никогда: доступы", "danger", [
        "запуск чужого кода с правами",
        "правка секретов и ключей",
        "«добавить всё» одной командой",
    ], SvgIcons.Lock, "", "", 0, true)
}

@memo
function GuardAsk(): void {
    InfoCard2("Только по просьбе", "warn", [
        "публикация артефактов",
        "массовая очистка репозитория",
        "изменение конфигурации CI",
    ], SvgIcons.Bell, "", "", 0, true)
}

@memo
function TestsText(): void {
    BulletColumn([
        "Тесты пишутся вместе с функцией, а не после",
        "Граничные случаи — там, где живут ошибки",
        "Пирамида: много быстрых юнит-тестов, меньше интеграционных, единицы end-to-end",
        "Тест обязан падать до правки и проходить после",
        "CI: установка, сборка и тесты на каждом коммите",
    ])
}

@memo
function TestsArt(): void {
    SlideImage("demo/assets/lecture-1/10-tests.jpg", 340, 254, 16)
}

@memo
function BadTestBody(): void {
    Code("test(\"сложение\", () => {\n  print(\"ок\")\n})", "ArkTS")
}

@memo
function GoodTestBody(): void {
    Code("test(\"сложение\", () => {\n  assert(sum(2, 2) == 4)\n})", "ArkTS")
}

@memo
function PipelineGrid(): void {
    Column({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
        Row({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Упало", "danger", ["лог, шаг, первая ошибка"], "", "1")
            InfoCard2("Понять", "warn", ["воспроизвести локально"], "", "2")
        }
        Row({ contentGap: 14, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Починить", "warn", ["правкой в репозитории"], "", "3")
            InfoCard2("Перезапустить", "ok", ["зелёный не случаен?"], "", "4")
        }
    }
}

@memo
function PipelineArt(): void {
    SlideImage("demo/assets/lecture-1/16-pipeline.jpg", 320, 238, 16)
}

@memo
function ReviewText(): void {
    BulletColumn([
        "Четыре роли: архитектура, безопасность, скорость, соглашения",
        "У каждого свой чек-лист рядом с определением",
        "Ревью ловит то, чего не видит CI: замысел, границы, последствия",
        "Одобряет человек: иначе проверка сертифицирует сама себя",
    ])
}

@memo
function ReviewArt(): void {
    SlideImage("demo/assets/lecture-1/11-review.jpg", 340, 254, 16)
}

@memo
function KnowledgeText(): void {
    BulletColumn([
        "«Почему» и «как связано» — рядом с кодом",
        "Заметки живут между сессиями агента",
        "Правила и заметки — вход агента, а не отчёт для людей",
        "Устаревшая заметка хуже отсутствующей",
        "Обновляется вместе с изменением, а не после",
    ])
}

@memo
function KnowledgeArt(): void {
    SlideImage("demo/assets/lecture-1/12-knowledge.jpg", 340, 254, 16)
}

@memo
function StackText(): void {
    Column({ contentGap: 12, heightPolicy: SizePolicy.Wrapped }) {
        Txt("Что даёт агенту дружелюбный инструментарий", "subtitle")
        BulletColumn([
            "Компиляция и запуск — секунды, не минуты",
            "Статические типы ловят ошибку до запуска",
            "Тесты без экрана и «глаза» на интерфейс",
            "Внешняя память: правила и заметки рядом с кодом",
        ])
    }
}

@memo
function StackArt(): void {
    const theme = currentSlideTheme()
    Container({
        backgroundColor: toneFill("accent", theme),
        stroke: stroke(1, toneBorder("accent", theme)),
        corners: RoundedCorners.dp(theme.radius),
        padding: indents(theme.gap),
        heightPolicy: SizePolicy.Wrapped,
    }) {
        Column({ contentGap: 10, heightPolicy: SizePolicy.Wrapped }) {
            Txt("Пример стека", "subtitle")
            SlideImage("demo/arkui3-qr.png", 150, 150, 8)
            Txt("gitcode.com/rri_opensource/arkui3", "caption", "accent")
        }
    }
}

@memo
function ChecklistTop(): void {
    Row({ contentGap: 16, heightPolicy: SizePolicy.Wrapped }) {
        InfoCard2("Правила", "accent", ["файл, который агент читает до работы"], SvgIcons.Lock)
        InfoCard2("Короткий цикл", "accent", ["компиляция и проверка за секунды"], SvgIcons.Refresh)
        InfoCard2("Ранние ошибки", "accent", ["типы и валидация до запуска"], SvgIcons.Shield)
    }
}

@memo
function ChecklistBottom(): void {
    Row({ contentGap: 16, heightPolicy: SizePolicy.Wrapped }) {
        InfoCard2("«Глаза»", "ok", ["снимок и дерево вместо слепого кода"], SvgIcons.Eye)
        InfoCard2("Тесты с кодом", "ok", ["и запуск на каждом коммите"], SvgIcons.Check)
        InfoCard2("База знаний", "ok", ["«почему» и «как связано»"], SvgIcons.Star)
    }
}

@memo
function ActionRules(): void {
    InfoCard2("Правила", "accent", [
        "создайте файл, который агент читает до работы",
        "границы, запреты, как проверять",
    ], "", "1")
}

@memo
function ActionSignal(): void {
    InfoCard2("Сигнал", "accent", [
        "добейтесь сборки и тестов за секунды",
        "одна команда — и видно результат",
    ], "", "2")
}

@memo
function ActionTest(): void {
    InfoCard2("Один тест", "ok", [
        "напишите падающий тест до правки",
        "затем попросите агента его починить",
    ], "", "3")
}

// ── Pages ───────────────────────────────────────────────────────────────────

@memo
function CoverPage(): void {
    const theme = currentSlideTheme()
    Container({ backgroundColor: theme.background, padding: indents(theme.gutter) }) {
        Row({
            contentGap: 28,
            widthPolicy: SizePolicy.Stretched,
            heightPolicy: SizePolicy.Wrapped,
            verticalAlignment: VerticalAlignment.Center,
        }) {
            Column({
                contentGap: 12,
                widthPolicy: SizePolicy.Stretched,
                heightPolicy: SizePolicy.Wrapped,
            }) {
                Txt("Лекция · агентская разработка", "caption", "accent")
                Text("Как бежать быстро и не сломаться", {
                    fontSize: theme.displaySize,
                    color: theme.textPrimary,
                    fontFamily: theme.fontFamily,
                    fontStyle: FontStyle.BOLD,
                })
                Txt("— Николай Иготти", "subtitle")
            }
            SlideImage("demo/assets/lecture-1/01-cover.jpg", 400, 298, 16)
        }
    }
}

@memo
function RoutePage(): void {
    SlideFrame("Четыре остановки", RouteBody, "Маршрут")
}

@memo
function RouteBody(): void {
    Column({ contentGap: 18, heightPolicy: SizePolicy.Wrapped }) {
        Row({ contentGap: 18, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Что такое агент", "accent", ["цикл, а не автодополнение"], SvgIcons.Refresh, "1")
            InfoCard2("Три столпа", "accent", ["инструменты, принципы, процессы"], SvgIcons.Settings, "2")
        }
        Row({ contentGap: 18, heightPolicy: SizePolicy.Wrapped }) {
            InfoCard2("Где цикл ломается", "warn", ["четыре режима отказа"], SvgIcons.Error, "3")
            InfoCard2("Что сделать", "ok", ["три действия в свой проект"], SvgIcons.Check, "4")
        }
    }
    Callout("Скорость даёт цикл, надёжность — проверка. Всё остальное — способы ускорить одно, не испортив другое.", "Одна мысль на выходе")
}

@memo
function LoopPage(): void {
    SlideFrame("Агент — это цикл, не автодополнение", LoopBody, "Что это такое")
}

@memo
function LoopBody(): void {
    Columns([
        { weight: 7, content: LoopText },
        { weight: 3, content: LoopArt },
    ], { gap: 24 })
    Callout("Термостат, а не нагреватель: измеряет, сравнивает с целью и подкручивает — пока не станет ровно.", "Аналогия")
}

@memo
function PillarsPage(): void {
    SlideFrame("Три составляющих быстрой разработки", PillarsBody, "Организующая рамка")
}

@memo
function PillarsBody(): void {
    RevealGroup(1, [
        { content: PillarTools },
        { content: PillarPrinciples },
        { content: PillarProcesses },
    ], { horizontal: true, staggerMs: 160 })
    Callout("Без любого из трёх цикл станет медленным, опасным или хаотичным.", "Все три нужны одновременно")
}

@memo
function DifficultiesPage(): void {
    SlideFrame("Три трудности, которые создаёт агент", DifficultiesBody, "Почему это проблема")
}

@memo
function DifficultiesBody(): void {
    Columns([
        { weight: 1, content: DifficultyCost },
        { weight: 1, content: DifficultyProbability },
        { weight: 1, content: DifficultyForgetting },
    ], { gap: 16, stretch: true })
    Callout("Стоимость работы ≈ число оборотов × (генерация + проверка). Дешёвая проверка делает ошибку дешёвой.", "Проверка не бесплатна")
}

@memo
function CyclePage(): void {
    SlideFrame("Главный цикл: секунды, не минуты", CycleBody, "Сердце агентной разработки",
        "И снова по кругу: один оборот цикла и есть единица работы агента")
}

@memo
function CycleBody(): void {
    Columns([
        { weight: 6, content: CycleDiagram },
        { weight: 4, content: CycleArt },
    ], { gap: 24 })
    Callout("Не шаг, а оборот: время от правки до сигнала.", "Что оптимизируем")
}

@memo
function NumbersPage(): void {
    TableSlide("Полный круг за секунды",
        ["Этап", "Время", "Что ограничивает"],
        [
            ["Генерация кода", "1–5 с", "инференс модели"],
            ["Компиляция", "0,5–2 с", "проверка типов"],
            ["Запуск", "0,2 с", "среда выполнения"],
            ["Проверка", "0,5 с", "рендер и снимок"],
            ["Полный цикл", "≈2–8 с", "—"],
        ],
        "Цикл по цифрам",
        "Порядок величин на ноутбуке: важна не точность, а соотношение", 1, [4])
}

@memo
function QuestionPage(): void {
    const theme = currentSlideTheme()
    Container({ backgroundColor: theme.background, padding: indents(theme.gutter) }) {
        Column({
            contentGap: theme.gap * 2,
            heightPolicy: SizePolicy.Stretched,
            contentVerticalAlignment: VerticalAlignment.Center,
        }) {
            SlideHeader("Что труднее: написать код или понять задачу?", "Вопрос аудитории", "")
            QuestionBody()
        }
    }
}

@memo
function QuestionBody(): void {
    // A bounded band keeps the equal-height cards compact: a stretched page
    // column would otherwise inflate them to the whole remaining height.
    Container({ height: 280, widthPolicy: SizePolicy.Stretched }) {
        Columns([
            { weight: 1, content: QuestionA },
            { weight: 1, content: QuestionB },
        ], { gap: 24, stretch: true })
    }
}

@memo
function AnswerPage(): void {
    SlideFrame("Понять задачу — дороже, чем написать код", AnswerBody, "Ответ")
}

@memo
function AnswerBody(): void {
    Columns([
        { weight: 1, content: AnswerA },
        { weight: 1, content: AnswerB },
    ], { gap: 24, stretch: true })
    Callout("Код — это черновик; требования — это ТЗ. Проверять надо ТЗ, а не скорость письма.", "Аналогия")
}

@memo
function ConvergencePage(): void {
    SlideFrame("Сходимость вместо идеального шага", ConvergenceBody, "Как это работает")
}

@memo
function ConvergenceBody(): void {
    Columns([
        { weight: 5, content: ConvergenceText },
        { weight: 5, content: ConvergenceFigure },
    ], { gap: 24 })
    Callout("Автофокус: линза крутится, пока картинка не станет резкой. Один идеальный поворот не нужен.", "Аналогия")
}

@memo
function LeversPage(): void {
    SlideFrame("Рычаги скорости", LeversBody, "Как ускорить сходимость")
}

@memo
function LeversBody(): void {
    Columns([
        { weight: 6, content: LeversText },
        { weight: 4, content: LeversArt },
    ], { gap: 24 })
    Callout("Сердцебиение: важнее частота ударов, чем сила одного.", "Аналогия")
}

@memo
function FailuresPage(): void {
    SlideFrame("Когда процесс не сходится", FailuresBody, "Обратная сторона")
}

@memo
function FailuresBody(): void {
    StatusBoard(
        [
            { name: "Расходимость", tone: "danger" },
            { name: "Блуждание", tone: "warn" },
            { name: "Хаос", tone: "warn" },
            { name: "Ложная сходимость", tone: "danger" },
        ],
        ["Признак", "Лечить"],
        [
            { column: 0, row: 0, text: "Ошибка копится незаметно" },
            { column: 1, row: 0, text: "Каждая итерация оптимизирует своё" },
            { column: 2, row: 0, text: "Ошибка не локализована" },
            { column: 3, row: 0, text: "Тест проходит через раз" },
            { column: 0, row: 1, text: "Короткий автоматический сигнал" },
            { column: 1, row: 1, text: "Одна цель и критерий готовности" },
            { column: 2, row: 1, text: "Одна правка — один запуск" },
            { column: 3, row: 1, text: "Тест должен быть детерминированным" },
        ],
        { rowHeight: 104, cardHeight: 40, railShare: "1.2fr" })
    Callout("Все четыре лечатся процессом, а не более сильной моделью.", "Это не про модель")
}

@memo
function ToolsSection(): void {
    ProvideSlideTheme(MIDNIGHT_THEME) {
        SectionDivider("1", "Инструменты",
            "язык · компилятор · среда · отладчик · анализатор · библиотеки",
            PresoBackgroundKind.None, "", SvgIcons.Settings)
    }
}

@memo
function ToolsPage(): void {
    SlideFrame("Что ускоряет агента", ToolsBody, "Столп 1 · Инструменты")
}

@memo
function ToolsBody(): void {
    Columns([
        { weight: 6, content: ToolsGrid },
        { weight: 4, content: ToolsArt },
    ], { gap: 24 })
    Callout("Не «модель умнее», а «ошибка видна быстрее». Хороший инструмент сокращает оборот.", "Инструменты — про скорость сигнала")
}

@memo
function TypesPage(): void {
    SlideFrame("Ошибка видна до запуска", TypesBody, "Инструмент №1")
}

@memo
function TypesBody(): void {
    Columns([
        { weight: 6, content: TypesText },
        { weight: 4, content: TypesArt },
    ], { gap: 24 })
    Callout("Проверка орфографии — до отправки, не после.")
}

@memo
function EyesPage(): void {
    SlideFrame("«Глаза и руки» агента", EyesBody, "Инструмент №2")
}

@memo
function EyesBody(): void {
    Columns([
        { weight: 7, content: EyesText },
        { weight: 3, content: EyesArt },
    ], { gap: 24 })
    Callout("Смотреть на код — как читать меню на незнакомом языке. Снимок и дерево — это переводчик.", "Аналогия")
}

@memo
function PrinciplesSection(): void {
    ProvideSlideTheme(MIDNIGHT_THEME) {
        SectionDivider("2", "Принципы", "стандарты · соглашения · защитные перила",
            PresoBackgroundKind.None, "", SvgIcons.Shield)
    }
}

@memo
function GuardrailsPage(): void {
    SlideFrame("Защитные перила", GuardrailsBody, "Столп 2 · Принципы")
}

@memo
function GuardrailsBody(): void {
    Columns([
        { weight: 1, content: GuardRepo },
        { weight: 1, content: GuardAccess },
        { weight: 1, content: GuardAsk },
    ], { gap: 16, stretch: true })
    Callout("Они не замедляют движение — они не дают уехать туда, откуда нет возврата.", "Перила делают ошибку обратимой")
}

@memo
function SelfCheckPage(): void {
    SlideFrame("Кто что проверяет перед сдачей", SelfCheckBody, "Принципы · Самопроверка")
}

@memo
function SelfCheckBody(): void {
    const theme = currentSlideTheme()
    CheckMatrix([
        { label: "Сборка и типы", ticks: [true, false] },
        { label: "Тесты и граничные случаи", ticks: [true, true] },
        { label: "Дифф и посторонние файлы", ticks: [true, true] },
        { label: "Требования и критерии готовности", ticks: [false, true] },
        { label: "Секреты, доступы и последствия", ticks: [false, true] },
    ], {
        header: ["Проверка", "Агент", "Человек"],
        rowHeight: 46,
        labelShare: "3fr",
        labelFill: toneFill("accent", theme),
        labelInk: toneAccentInk("accent", theme),
        headerFill: toneFill("accent", theme),
        headerInk: toneAccentInk("accent", theme),
        cellFill: theme.surface,
        shadedFill: theme.surfaceAlt,
    })
    Callout("Машина проверяет видимое; человек — смысл, границы и последствия.", "Разделение труда")
}

@memo
function DefensePage(): void {
    SlideFrame("Эшелонированная оборона", DefenseBody, "Итог принципов",
        "Чем раньше слой ловит ошибку — тем дешевле исправление")
}

@memo
function DefenseBody(): void {
    PyramidStack([
        { label: "4 · Среда выполнения", caption: "дорого, ловит мало", tone: "danger" },
        { label: "3 · Сверка отрисовки", caption: "видно, что получилось", tone: "warn" },
        { label: "2 · Валидация", caption: "данные и границы", tone: "info" },
        { label: "1 · Типы", caption: "дёшево, ловит больше всего", tone: "ok" },
    ], { rowHeight: 48, apexShare: 0.42, soft: true })
    Callout("Каждая проверка ловит то, что пропустила предыдущая; ошибка дорожает вглубь.", "Аналогия: досмотр в аэропорту")
}

@memo
function ProcessesSection(): void {
    ProvideSlideTheme(MIDNIGHT_THEME) {
        SectionDivider("3", "Процессы", "документация · ревью · CI · тесты · база знаний",
            PresoBackgroundKind.None, "", SvgIcons.Clock)
    }
}

@memo
function TestsPage(): void {
    SlideFrame("Тесты и CI: предсказуемый агент", TestsBody, "Процессы · Тесты")
}

@memo
function TestsBody(): void {
    Columns([
        { weight: 7, content: TestsText },
        { weight: 3, content: TestsArt },
    ], { gap: 24 })
    Callout("Тест — датчик дыма, CI — ночной сторож: срабатывают без вас и не устают к третьему часу ночи.", "Аналогия")
}

@memo
function GreenPage(): void {
    SlideFrame("Зелёный сигнал должен что-то значить", GreenBody, "Процессы · Сигнал")
}

@memo
function GreenBody(): void {
    ComparePanels([
        { label: "Плохо: тест без проверки", content: BadTestBody, verdict: REJECTED },
        { label: "Хорошо: тест утверждает", content: GoodTestBody, verdict: ACCEPTED },
    ])
    Callout("Тест без assert — датчик, отключённый от провода.", "Аналогия")
}

@memo
function PipelinePage(): void {
    SlideFrame("Красный пайплайн — это задача", PipelineBody, "Процессы · CI")
}

@memo
function PipelineBody(): void {
    Columns([
        { weight: 6, content: PipelineGrid },
        { weight: 4, content: PipelineArt },
    ], { gap: 24 })
    Callout("Красный пайплайн — письмо от ночного сторожа. Чинить причину, а не перезапускать до зелёного.", "Не «перезапустить», а прочитать")
}

@memo
function ReviewPage(): void {
    SlideFrame("Ревью: независимые взгляды", ReviewBody, "Процессы · Ревью")
}

@memo
function ReviewBody(): void {
    Columns([
        { weight: 7, content: ReviewText },
        { weight: 3, content: ReviewArt },
    ], { gap: 24 })
    Callout("Второй пилот в кабине: не потому что первый хуже, а потому что один взгляд устаёт и привыкает.", "Аналогия")
}

@memo
function KnowledgePage(): void {
    SlideFrame("База знаний и память агента", KnowledgeBody, "Процессы · Знание")
}

@memo
function KnowledgeBody(): void {
    Columns([
        { weight: 7, content: KnowledgeText },
        { weight: 3, content: KnowledgeArt },
    ], { gap: 24 })
    Callout("Контекст — оперативная память, заметки — диск. Что не записано, теряется при первой же перезагрузке.", "Аналогия")
}

@memo
function StackPage(): void {
    SlideFrame("Один конкретный стек как иллюстрация", StackBody, "Пример · Как это выглядит")
}

@memo
function StackBody(): void {
    Columns([
        { weight: 7, content: StackText },
        { weight: 3, content: StackArt },
    ], { gap: 24 })
    Callout("Те же свойства собираются из других инструментов.", "Берите свойства, а не бренд")
}

@memo
function ChecklistPage(): void {
    SlideFrame("Чек-лист агентной разработки", ChecklistBody, "Что взять с собой",
        "Что не проверяется машиной — того не существует")
}

@memo
function ChecklistBody(): void {
    ChecklistTop()
    ChecklistBottom()
}

@memo
function ActionsPage(): void {
    SlideFrame("Три действия в свой проект", ActionsBody, "Что сделать на этой неделе")
}

@memo
function ActionsBody(): void {
    Columns([
        { weight: 1, content: ActionRules },
        { weight: 1, content: ActionSignal },
        { weight: 1, content: ActionTest },
    ], { gap: 20 })
    Callout("Правила + быстрый сигнал + один тест. Всё остальное — улучшения поверх этого.", "Минимальный цикл")
}

// ── Deck ────────────────────────────────────────────────────────────────────

const lectureDeck: PresoDeck = deckOf("Агентская разработка", [
    slideOf("cover", "Как бежать быстро и не сломаться", CoverPage),
    slideOf("route", "Четыре остановки", RoutePage, 4,
        "Показать маршрут и вернуться к нему в конце: каждый блок отвечает на один вопрос."),
    slideOf("loop", "Агент — это цикл", LoopPage, 0,
        "Термостат, а не нагреватель: действие → сигнал → правка."),
    slideOf("pillars", "Три составляющих", PillarsPage, 1,
        "Три столпа — три условия: скорость, предсказуемость, темп."),
    slideOf("difficulties", "Три трудности", DifficultiesPage, 1,
        "Главная — дорогая проверка; она объясняет, почему цикл важнее одной большой попытки."),
    slideOf("cycle", "Главный цикл", CyclePage, 0,
        "Один оборот — единица работы агента."),
    slideOf("numbers", "Цикл по цифрам", NumbersPage, 5,
        "Порядок величин, не точные замеры: соотношение важнее конкретных секунд."),
    slideOf("question", "Что труднее", QuestionPage, 0,
        "Пауза 30 секунд, обсуждение с соседом. Ответ — на следующем слайде."),
    slideOf("answer", "Ответ: понять задачу", AnswerPage, 0,
        "Генерация воспроизводит увиденное, а требований и границ модель не знает."),
    slideOf("convergence", "Сходимость", ConvergencePage, 0,
        "Каждый шаг неидеален; цель — сходящаяся последовательность."),
    slideOf("levers", "Рычаги скорости", LeversPage, 0,
        "Короче оборот и меньше оборотов: две группы рычагов."),
    slideOf("failures", "Режимы отказа", FailuresPage, 0,
        "Четыре режима лечатся процессом, а не моделью."),
    slideOf("tools-section", "Инструменты", ToolsSection),
    slideOf("tools", "Что ускоряет агента", ToolsPage, 0,
        "Инструменты — про скорость сигнала, не про «умнее»."),
    slideOf("types", "Ошибка до запуска", TypesPage, 0,
        "Типы — проверка орфографии для кода."),
    slideOf("eyes", "Глаза и руки", EyesPage, 0,
        "Снимок и дерево — переводчик между кодом и результатом."),
    slideOf("principles-section", "Принципы", PrinciplesSection),
    slideOf("guardrails", "Защитные перила", GuardrailsPage, 0,
        "Перила не замедляют — они делают ошибку обратимой. История про git add -A."),
    slideOf("selfcheck", "Кто что проверяет", SelfCheckPage, 0,
        "Машина проверяет видимое; человек — смысл."),
    slideOf("defense", "Эшелонированная оборона", DefensePage, 0,
        "Типы — широкий и дешёвый слой; среда выполнения — узкий и дорогой."),
    slideOf("processes-section", "Процессы", ProcessesSection),
    slideOf("tests", "Тесты и CI", TestsPage, 0,
        "Тест — датчик дыма, CI — ночной сторож."),
    slideOf("green", "Зелёный сигнал", GreenPage, 0,
        "Тест без assert — датчик, отключённый от провода."),
    slideOf("pipeline", "Красный пайплайн", PipelinePage, 0,
        "Чинить причину, а не перезапускать до зелёного."),
    slideOf("review", "Ревью", ReviewPage, 0,
        "Второй пилот: один взгляд устаёт и привыкает."),
    slideOf("knowledge", "База знаний", KnowledgePage, 0,
        "Контекст — оперативка, заметки — диск."),
    slideOf("stack", "Пример стека", StackPage, 0,
        "Важны свойства, а не бренд."),
    slideOf("checklist", "Чек-лист", ChecklistPage, 0,
        "Если правило не проверяется машиной, агент его не соблюдает."),
    slideOf("actions", "Три действия", ActionsPage, 0,
        "Минимальный цикл: правила + быстрый сигнал + один тест."),
], SLIDE_WIDE)

export function getPresentationOptions(): PresentationOptions {
    return {
        theme: LIGHT_THEME,
        transition: SlideTransitionKind.PageTurn,
        transitionDurationMs: 900,
    }
}

export function main(): void {
    runPresentationCli(lectureDeck, getPresentationOptions())
}
