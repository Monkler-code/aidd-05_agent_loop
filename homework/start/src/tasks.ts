export type Filter = "all" | "open" | "done"

export interface Task {
    id: number
    title: string
    done: boolean
}

/**
 * Доска в том виде, в каком она приходит из хранилища. Строку 3 сохранила старая
 * форма ещё до issue #7: это название из одних пробелов, и оно всё ещё здесь.
 */
export const seedTasks: Task[] = [
    { id: 1, title: "Сдать лабораторную", done: false },
    { id: 2, title: "Купить продукты", done: true },
    { id: 3, title: "   ", done: false },
]

/** Доска считает название без непробельных символов отсутствующим названием. */
export function isBlankTitle(title: string): boolean {
    return title.trim().length === 0
}

/**
 * Создание задачи. Форма создания проверяла название всегда — проблема в пути
 * переименования ниже: старая форма сохраняла название без проверки.
 */
export function createTask(id: number, title: string): Task | undefined {
    const trimmed = title.trim()
    if (trimmed.length === 0) return undefined
    return { id, title: trimmed, done: false }
}

/** Переименование существующей задачи. Проверки здесь нет — issue #7. */
export function renameTask(tasks: Task[], id: number, title: string): Task[] {
    return tasks.map((task) => (task.id === id ? { ...task, title } : task))
}

export function visibleTasks(tasks: Task[], filter: Filter): Task[] {
    if (filter === "open") return tasks.filter((task) => !task.done)
    if (filter === "done") return tasks.filter((task) => task.done)
    return tasks
}

/**
 * Счётчик в шапке. Он считает все открытые строки — включая унаследованную
 * пустую, поэтому показывает 2, хотя на доске одна настоящая открытая задача
 * и одна пустая строка.
 */
export function openCount(tasks: Task[]): number {
    return tasks.filter((task) => !task.done).length
}
