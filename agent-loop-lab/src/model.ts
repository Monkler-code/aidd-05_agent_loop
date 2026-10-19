/**
 * The agent-loop model: a closed-form simulation, not a real agent.
 *
 * The point of the app is the *comparison* — the same task and the same agent,
 * with different amounts of feedback — so the model is deliberately small and
 * deterministic per seed: every knob's effect is legible, and two runs with the
 * same seed and mode give the same numbers.
 */

export type LoopMode = "open" | "almost" | "closed"

export type DefectKind = "type" | "logic" | "visual" | "destructive"

export interface Config {
    mode: LoopMode
    /** The pipeline reports green regardless of what the tests saw. */
    pipelineLies: boolean
    /** The agent asks before a destructive action. */
    askBeforeRisky: boolean
    /** Destructive actions are forbidden outright. */
    neverDelete: boolean
    /** 0..1 — how good the agent is on the first attempt. */
    skill: number
}

export interface RunResult {
    id: number
    mode: LoopMode
    turns: number
    timeSec: number
    humanInterventions: number
    /** Defects present at acceptance — the ones no available signal could see. */
    defectsAtAcceptance: number
    /** Defects the loop did surface and the agent fixed. */
    caught: number
    /** Whether the pipeline's "green" means what it claims. */
    greenWasHonest: boolean
    pipelineLies: boolean
}

export const MODE_LABEL: Record<LoopMode, string> = {
    open: "Разомкнут",
    almost: "Почти замкнут",
    closed: "Замкнут",
}

export const MODE_HINT: Record<LoopMode, string> = {
    open: "Агент не видит ничего: ни сборки, ни тестов, ни интерфейса.",
    almost: "Агент собирает и гоняет тесты, но не видит интерфейс.",
    closed: "Агент видит сборку, тесты и скриншот интерфейса.",
}

const TURN_SEC = 6
const HUMAN_SEC = 45
const MAX_TURNS = 12

/** Which signals the agent can actually observe in each mode. */
export function feedbackOf(mode: LoopMode): { build: boolean; tests: boolean; visual: boolean } {
    return { build: mode !== "open", tests: mode !== "open", visual: mode === "closed" }
}

function makeRng(seed: number): () => number {
    let s = seed >>> 0
    return () => {
        s = (s * 1664525 + 1013904223) >>> 0
        return s / 4294967296
    }
}

export function runOnce(cfg: Config, seed: number, id: number): RunResult {
    const rng = makeRng(seed)
    const fb = feedbackOf(cfg.mode)
    // A better agent writes fewer defects; even a good one makes some.
    const defectChance = 0.22 + 0.55 * (1 - cfg.skill)
    const kinds: DefectKind[] = ["type", "logic", "visual", "destructive"]

    let turns = 0
    let caught = 0
    let interventions = 0
    // A defect kind the loop surfaced once is fixed for good: the agent learned
    // it. A kind no available signal can see is never fixed and is what is left
    // at acceptance — the whole point of the comparison.
    const learned = new Set<DefectKind>()
    const hidden = new Set<DefectKind>()

    while (turns < MAX_TURNS) {
        turns++
        let surfacedThisTurn = 0

        for (const kind of kinds) {
            if (learned.has(kind)) continue
            if (rng() >= defectChance) continue
            if (kind === "destructive") {
                // A guardrail is the only thing that can stop a destructive action
                // before it happens; no signal catches it afterwards.
                if (cfg.neverDelete) {
                    learned.add(kind)
                    if (cfg.askBeforeRisky) interventions++
                } else {
                    hidden.add(kind)
                }
                continue
            }
            let visible = false
            if (kind === "type") visible = fb.build
            if (kind === "logic") visible = fb.tests && !cfg.pipelineLies
            if (kind === "visual") visible = fb.visual
            if (visible) {
                surfacedThisTurn++
                caught++
                learned.add(kind)
            } else {
                hidden.add(kind)
            }
        }

        if (surfacedThisTurn === 0) break
    }

    return {
        id,
        mode: cfg.mode,
        turns,
        timeSec: turns * TURN_SEC + interventions * HUMAN_SEC,
        humanInterventions: interventions,
        defectsAtAcceptance: hidden.size,
        caught,
        greenWasHonest: !cfg.pipelineLies,
        pipelineLies: cfg.pipelineLies,
    }
}

export function fmtTime(sec: number): string {
    const m = Math.floor(sec / 60)
    const s = Math.round(sec % 60)
    return m > 0 ? `${m} мин ${s} с` : `${s} с`
}
