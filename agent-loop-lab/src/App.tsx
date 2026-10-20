import { useEffect, useMemo, useRef, useState } from "react"
import type { Config, LoopMode, RunResult } from "./model"
import {
    MODE_HINT,
    MODE_LABEL,
    feedbackOf,
    fmtTime,
    runOnce,
} from "./model"

const MODES: LoopMode[] = ["open", "almost", "closed"]

type Need = "build" | "tests" | "visual" | null

const STEPS: Array<{ label: string; needs: Need }> = [
    { label: "написал", needs: null },
    { label: "собрал", needs: "build" },
    { label: "запустил", needs: "build" },
    { label: "увидел", needs: "visual" },
    { label: "проверил", needs: "tests" },
]

const MODE_GLYPH: Record<LoopMode, string> = { open: "×", almost: "!", closed: "✓" }

function nextSeed(): number {
    return (Date.now() ^ Math.floor(Math.random() * 0xffffffff)) >>> 0
}

function Bar({ value, max, label }: { value: number; max: number; label: string }) {
    const pct = Math.max(2, Math.round((value / max) * 100))
    return (
        <span className="bar-cell" data-tip={label}>
            <span className="bar" style={{ width: `${pct}%` }} aria-hidden="true" />
        </span>
    )
}

export default function App() {
    const [cfg, setCfg] = useState<Config>({
        mode: "closed",
        pipelineLies: false,
        askBeforeRisky: true,
        neverDelete: true,
        skill: 0.6,
    })
    const [runs, setRuns] = useState<RunResult[]>(() => {
        // `?demo=1` prefills one run per mode, so the comparison can be reviewed
        // without clicking — useful for a teacher demoing it from a projector.
        if (!new URLSearchParams(window.location.search).has("demo")) return []
        const base: Config = { mode: "open", pipelineLies: false, askBeforeRisky: true, neverDelete: true, skill: 0.6 }
        return [
            runOnce({ ...base, mode: "open" }, 7, 1),
            runOnce({ ...base, mode: "almost" }, 11, 2),
            runOnce({ ...base, mode: "closed" }, 13, 3),
        ]
    })
    const [active, setActive] = useState(-1)
    const [theme, setTheme] = useState<"auto" | "light" | "dark">("auto")
    const seedRef = useRef(nextSeed())

    useEffect(() => {
        const root = document.documentElement
        if (theme === "auto") root.removeAttribute("data-theme")
        else root.setAttribute("data-theme", theme)
    }, [theme])

    const fb = feedbackOf(cfg.mode)

    const canRun = (needs: Need): boolean => needs === null || fb[needs]

    function start() {
        if (active !== -1) return
        const frozen = { ...cfg }
        const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
        const finish = () => {
            const result = runOnce(frozen, seedRef.current, runs.length + 1)
            seedRef.current = (seedRef.current * 1664525 + 1013904223) >>> 0
            setRuns((prev) => [...prev, result])
            setActive(-1)
        }
        if (reduced) {
            finish()
            return
        }
        let i = 0
        setActive(0)
        const timer = window.setInterval(() => {
            i += 1
            if (i >= STEPS.length || !canRun(STEPS[i].needs)) {
                window.clearInterval(timer)
                window.setTimeout(finish, 300)
                return
            }
            setActive(i)
        }, 280)
    }

    const maxima = useMemo(() => {
        const max = (pick: (r: RunResult) => number) => Math.max(1, ...runs.map(pick))
        return {
            turns: max((r) => r.turns),
            time: max((r) => r.timeSec),
            human: max((r) => r.humanInterventions),
            defects: max((r) => r.defectsAtAcceptance),
        }
    }, [runs])

    return (
        <div className="viz-root">
            <header className="top">
                <div>
                    <a href="../" style={{ fontSize: 14, color: "var(--muted)", textDecoration: "none" }}>
                        ← Материалы курса
                    </a>
                    <h1>Агентный цикл</h1>
                    <p className="sub">
                        Один и тот же агент, одна и та же задача. Меняется только обратная связь.
                    </p>
                </div>
                <label className="theme">
                    Тема
                    <select value={theme} onChange={(e) => setTheme(e.target.value as typeof theme)}>
                        <option value="auto">как в системе</option>
                        <option value="light">светлая</option>
                        <option value="dark">тёмная</option>
                    </select>
                </label>
            </header>

            <div className="layout">
                <section className="card controls">
                    <h2>Прогон</h2>
                    <div className="segmented" role="radiogroup" aria-label="Режим цикла">
                        {MODES.map((m) => (
                            <button
                                key={m}
                                role="radio"
                                aria-checked={cfg.mode === m}
                                className={`seg ${cfg.mode === m ? "on" : ""} status-${m}`}
                                onClick={() => setCfg({ ...cfg, mode: m })}
                            >
                                <span className="glyph" aria-hidden="true">{MODE_GLYPH[m]}</span>
                                {MODE_LABEL[m]}
                            </button>
                        ))}
                    </div>
                    <p className="hint">{MODE_HINT[cfg.mode]}</p>

                    <h2>Правила</h2>
                    <label className="check">
                        <input
                            type="checkbox"
                            checked={cfg.pipelineLies}
                            onChange={(e) => setCfg({ ...cfg, pipelineLies: e.target.checked })}
                        />
                        Пайплайн всегда зелёный
                    </label>
                    <label className="check">
                        <input
                            type="checkbox"
                            checked={cfg.askBeforeRisky}
                            onChange={(e) => setCfg({ ...cfg, askBeforeRisky: e.target.checked })}
                        />
                        Спрашивать перед опасным
                    </label>
                    <label className="check">
                        <input
                            type="checkbox"
                            checked={cfg.neverDelete}
                            onChange={(e) => setCfg({ ...cfg, neverDelete: e.target.checked })}
                        />
                        Никогда не удалять
                    </label>

                    <h2>Скилл агента</h2>
                    <input
                        type="range"
                        min={0}
                        max={100}
                        value={Math.round(cfg.skill * 100)}
                        onChange={(e) => setCfg({ ...cfg, skill: Number(e.target.value) / 100 })}
                    />
                    <p className="hint">Первый заход: {Math.round(cfg.skill * 100)}% без ошибок</p>

                    <div className="actions">
                        <button className="primary" onClick={start} disabled={active !== -1}>
                            Запустить прогон
                        </button>
                        <button onClick={() => setRuns([])} disabled={active !== -1 || runs.length === 0}>
                            Очистить
                        </button>
                    </div>
                </section>

                <main className="card stage">
                    <h2>Цикл</h2>
                    <ol className="loop">
                        {STEPS.map((s, i) => {
                            const available = canRun(s.needs)
                            const state = i === active ? "active" : available ? "" : "off"
                            return (
                                <li key={s.label} className={`step ${state}`}>
                                    <span className="num">{i + 1}</span>
                                    <span className="label">{s.label}</span>
                                    {!available && <span className="nosignal">нет сигнала</span>}
                                    {i < STEPS.length - 1 && <span className="arrow" aria-hidden="true">→</span>}
                                </li>
                            )
                        })}
                    </ol>

                    {runs.length === 0 ? (
                        <p className="empty">Запустите первый прогон — и сравните режимы.</p>
                    ) : (
                        <div className="verdict">
                            <p className="ask">
                                Сравните прогоны и ответьте сами:
                            </p>
                            <ol className="ask-list">
                                <li>Где быстрее до первой сдачи — и почему?</li>
                                <li>Где меньше дефектов при приёмке — и каких сигналов не хватило?</li>
                                <li>Что вы изменили бы в своей постановке задачи после этого?</li>
                            </ol>
                        </div>
                    )}

                    <h2>История прогонов</h2>
                    {runs.length === 0 ? (
                        <p className="empty">Пока пусто.</p>
                    ) : (
                        <table className="runs">
                            <thead>
                                <tr>
                                    <th scope="col">Режим</th>
                                    <th scope="col">Ходы</th>
                                    <th scope="col">Время</th>
                                    <th scope="col">Вмешательства</th>
                                    <th scope="col">Дефекты при приёмке</th>
                                </tr>
                            </thead>
                            <tbody>
                                {runs.map((r) => (
                                    <tr key={r.id}>
                                        <td>
                                            <span className={`mode status-${r.mode}`}>
                                                <span className="glyph" aria-hidden="true">{MODE_GLYPH[r.mode]}</span>
                                                {MODE_LABEL[r.mode]}
                                            </span>
                                        </td>
                                        <td className="num">
                                            {r.turns}
                                            <Bar value={r.turns} max={maxima.turns} label={`${r.turns} ход(ов)`} />
                                        </td>
                                        <td className="num">
                                            {fmtTime(r.timeSec)}
                                            <Bar value={r.timeSec} max={maxima.time} label={fmtTime(r.timeSec)} />
                                        </td>
                                        <td className="num">
                                            {r.humanInterventions}
                                            <Bar value={r.humanInterventions} max={maxima.human} label={`${r.humanInterventions} вмешательств`} />
                                        </td>
                                        <td className="num">
                                            {r.defectsAtAcceptance}
                                            <Bar value={r.defectsAtAcceptance} max={maxima.defects} label={`${r.defectsAtAcceptance} дефект(ов)`} />
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </main>
            </div>
        </div>
    )
}
