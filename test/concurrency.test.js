import { describe, it, after, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { rm, readFile } from "node:fs/promises";
import { homedir, platform } from "node:os";
import { join } from "node:path";
import { SC2SoundPlugin } from "../plugin.js";

// Mirror the state-dir logic from plugin.js
const IS_WINDOWS = platform() === "win32";
const stateDir = IS_WINDOWS
  ? join(homedir(), ".claude", "sc2-state")
  : join(homedir(), ".config/claude/sc2-state");

const sessionMapPath = join(stateDir, "session-sound-map.json");
const lastIndexPath = join(stateDir, "last-sound-index.json");

// ── Helpers ──────────────────────────────────────────────────────────────────

const cleanState = async () => {
  await rm(sessionMapPath, { force: true });
  await rm(lastIndexPath, { force: true });
};

const mockClient = {
  session: {
    // Every session is treated as a main session (parentID: null)
    get: async () => ({ parentID: null }),
  },
};

const createPlugin = async () => {
  // Each call produces a fresh closure with its own cache variables
  return SC2SoundPlugin({ $: () => {}, client: mockClient });
};

const makeEvent = (sessionID, type = "user.prompt.submit") => ({
  event: {
    type,
    properties: { sessionID },
  },
});

// ── Tests ────────────────────────────────────────────────────────────────────

describe("SC2SoundPlugin concurrency", () => {
  beforeEach(async () => {
    await cleanState();
  });

  after(async () => {
    await cleanState();
  });

  it("sequential events rotate sounds correctly", { timeout: 30_000 }, async () => {
    const plugin = await createPlugin();

    // Fire first event and wait for it to complete entirely
    await plugin.event(makeEvent("session-A"));
    // Fire second event only after the first is done
    await plugin.event(makeEvent("session-B"));

    // Read final state from disk
    const sessionMap = JSON.parse(await readFile(sessionMapPath, "utf8"));
    const lastIndex = JSON.parse(await readFile(lastIndexPath, "utf8"));

    // Both sessions should be present in the map
    assert.ok(sessionMap["session-A"], "session-A should be in session map");
    assert.ok(sessionMap["session-B"], "session-B should be in session map");

    // They should have different sounds (rotation: index 0 then index 1)
    const soundA = sessionMap["session-A"].userPrompt.file;
    const soundB = sessionMap["session-B"].userPrompt.file;
    assert.equal(soundA, "scv-yes05.mp3", "first session gets first sound in pool");
    assert.equal(soundB, "scv-yes03.mp3", "second session gets second sound in pool");
    assert.notEqual(soundA, soundB, "sessions should get different sounds");

    // Rotation index should have advanced to 1 (started at -1, incremented twice)
    assert.equal(lastIndex.userPrompt, 1, "rotation index should be 1 after two assignments");
  });

  it("concurrent events should rotate sounds correctly", { timeout: 30_000 }, async () => {
    const plugin = await createPlugin();

    // Fire both events concurrently — this triggers the race condition
    // in loadSessionMap() and loadLastIndex()
    await Promise.all([
      plugin.event(makeEvent("session-A")),
      plugin.event(makeEvent("session-B")),
    ]);

    // Read final state from disk
    const sessionMap = JSON.parse(await readFile(sessionMapPath, "utf8"));
    const lastIndex = JSON.parse(await readFile(lastIndexPath, "utf8"));

    // ASSERTION 1: Both sessions should be in the map
    // BUG: Only the last-written session survives (the other is overwritten)
    assert.ok(sessionMap["session-A"], "session-A should be in session map");
    assert.ok(sessionMap["session-B"], "session-B should be in session map");

    // ASSERTION 2: Sessions should have different sounds
    // BUG: Both get eventSounds[0] ("scv-yes05.mp3") because both read
    //       lastIndex as {} concurrently before either caches the result
    const soundA = sessionMap["session-A"].userPrompt.file;
    const soundB = sessionMap["session-B"].userPrompt.file;
    assert.notEqual(soundA, soundB, "sessions should get different sounds");

    // ASSERTION 3: Rotation index should reflect two assignments
    // BUG: lastIndex.userPrompt === 0 (not 1) because both handlers
    //       independently computed nextIndex = 0
    assert.equal(lastIndex.userPrompt, 1, "rotation index should be 1 after two assignments");
  });
});
