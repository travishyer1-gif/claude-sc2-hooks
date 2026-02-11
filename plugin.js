import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const SC2SoundPlugin = async ({ $, client }) => {
  const soundsDir = join(__dirname, "sounds");
  const poolPath = join(soundsDir, "pool.json");
  const stateDir = join(homedir(), ".config/claude/sc2-state");
  const sessionMapPath = join(stateDir, "session-sound-map.json");
  const lastIndexPath = join(stateDir, "last-sound-index.json");

  let cachedSoundPool = null;
  let cachedSessionMap = null;
  let cachedLastIndex = null;

  const ensureStateDir = async () => {
    await mkdir(stateDir, { recursive: true });
  };

  const readJson = async (filePath, fallback) => {
    try {
      const contents = await readFile(filePath, "utf8");
      return JSON.parse(contents);
    } catch {
      return fallback;
    }
  };

  const loadSoundPool = async () => {
    if (!cachedSoundPool) {
      cachedSoundPool = await readJson(poolPath, {});
    }
    return cachedSoundPool;
  };

  const loadSessionMap = async () => {
    if (!cachedSessionMap) {
      cachedSessionMap = await readJson(sessionMapPath, {});
    }
    return cachedSessionMap;
  };

  const loadLastIndex = async () => {
    if (cachedLastIndex === null) {
      const storedIndex = await readJson(lastIndexPath, {});
      cachedLastIndex = storedIndex;
    }
    return cachedLastIndex;
  };

  const saveSessionMap = async (sessionMap) => {
    await ensureStateDir();
    cachedSessionMap = sessionMap;
    await writeFile(sessionMapPath, JSON.stringify(sessionMap, null, 2));
  };

  const saveLastIndex = async (indexMap) => {
    await ensureStateDir();
    cachedLastIndex = indexMap;
    await writeFile(lastIndexPath, JSON.stringify(indexMap, null, 2));
  };

  const getSessionSound = async (sessionID, eventType) => {
    if (!sessionID || !eventType) {
      return null;
    }

    const soundPool = await loadSoundPool();
    const eventSounds = soundPool[eventType];

    if (!Array.isArray(eventSounds) || eventSounds.length === 0) {
      return null;
    }

    const sessionMap = await loadSessionMap();

    // Check if this session already has a sound assigned for this event
    if (sessionMap[sessionID]?.[eventType]) {
      return sessionMap[sessionID][eventType];
    }

    // Assign next sound in rotation
    const lastIndex = await loadLastIndex();
    const currentIndex = lastIndex[eventType] ?? -1;
    const nextIndex = (currentIndex + 1) % eventSounds.length;
    const soundEntry = eventSounds[nextIndex];

    // Store assignment
    if (!sessionMap[sessionID]) {
      sessionMap[sessionID] = {};
    }
    sessionMap[sessionID][eventType] = soundEntry;
    await saveSessionMap(sessionMap);

    // Update rotation index
    lastIndex[eventType] = nextIndex;
    await saveLastIndex(lastIndex);

    return soundEntry;
  };

  const playSound = async (sessionID, eventType) => {
    const soundEntry = await getSessionSound(sessionID, eventType);
    if (!soundEntry?.file) {
      return;
    }

    const soundPath = join(soundsDir, soundEntry.file);
    try {
      // ffplay: quiet, auto-exit, no display window
      await $`ffplay -nodisp -autoexit -loglevel quiet ${soundPath}`;
    } catch {
      // Silently ignore playback errors
    }
  };

  // Check if a session is a main (non-subagent) session
  const isMainSession = async (sessionID) => {
    try {
      const result = await client.session.get({ path: { id: sessionID } });
      const session = result.data ?? result;
      return !session.parentID;
    } catch {
      // If we can't fetch the session, assume it's main to avoid missing notifications
      return true;
    }
  };

  return {
    event: async ({ event }) => {
      const sessionID = event.properties?.sessionID || event.properties?.info?.id;

      // Session.idle — Agent finished response (main sessions only)
      if (event.type === "session.idle") {
        if (await isMainSession(sessionID)) {
          await playSound(sessionID, "sessionIdle");
        }
      }

      // Session.start — New session created
      if (event.type === "session.start") {
        await playSound(sessionID, "sessionStart");
      }

      // Permission.asked — Agent needs user approval
      if (event.type === "permission.asked") {
        await playSound(sessionID, "permissionAsked");
      }

      // Tool.use.failure — Tool execution failed
      if (event.type === "tool.use.failure") {
        await playSound(sessionID, "toolFailure");
      }

      // User.prompt.submit — User sent a message
      if (event.type === "user.prompt.submit") {
        await playSound(sessionID, "userPrompt");
      }

      // Session.deleted — Clean up state
      if (event.type === "session.deleted") {
        if (sessionID) {
          const sessionMap = await loadSessionMap();
          if (sessionMap[sessionID]) {
            delete sessionMap[sessionID];
            await saveSessionMap(sessionMap);
          }
        }
      }
    },
  };
};
