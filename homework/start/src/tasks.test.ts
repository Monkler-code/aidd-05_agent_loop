import { describe, expect, it } from "vitest"
import { createTask, visibleTasks, seedTasks, openCount, renameTask } from "./tasks"

// Два теста, с которыми поставляется стартер. Они проходят и не покрывают
// поведение, описанное в ISSUE-7.md.
describe("базовая доска", () => {
    it("создаёт задачу и обрезает название", () => {
        const task = createTask(9, "  Купить хлеб  ")
        expect(task?.title).toBe("Купить хлеб")
    })

    it("фильтрует готовые задачи", () => {
        expect(visibleTasks(seedTasks, "done").map((task) => task.id)).toEqual([2])
    })
})

describe("R1 — переименование задач", () => {
    const originalTask = {
        id: 10,
        title: "Купить хлеб",
        done: false,
    }

    it.each(["", " ", "\t", "\u00A0", " \t\u00A0 "])(
        "отклоняет пустое название и сохраняет старое: %j",
        (title) => {
            const result = renameTask(
                [originalTask],
                originalTask.id,
                title,
            )

            expect(
                result.find((task) => task.id === originalTask.id)?.title,
            ).toBe("Купить хлеб")
        },
    )

    it("обрезает пробельные символы по краям непустого названия", () => {
        const result = renameTask(
            [originalTask],
            originalTask.id,
            " \t\u00A0Купить хлеб\u00A0\t ",
        )

        expect(
            result.find((task) => task.id === originalTask.id)?.title,
        ).toBe("Купить хлеб")
    })
})

describe("R2 — отображение задач", () => {
    it("не показывает унаследованную пустую задачу на всей доске", () => {
        expect(
            visibleTasks(seedTasks, "all").map((task) => task.id),
        ).toEqual([1, 2])
    })

    it("не показывает пустую задачу среди открытых", () => {
        expect(
            visibleTasks(seedTasks, "open").map((task) => task.id),
        ).toEqual([1])
    })
})

describe("R3 — счётчик открытых задач", () => {
    it("не учитывает унаследованную пустую задачу", () => {
        expect(openCount(seedTasks)).toBe(1)
    })
})