import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir, platform } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const IS_WINDOWS = platform() === "win32";

/**
 * Spawn a child process and return a promise.
 * Used for both ffplay and PowerShell fallback.
 */
const spawnAsync = (cmd, args) =>
  new Promise((resolve, reject) => {
    const child = execFile(cmd, args, { windowsHide: true }, (err) => {
      if (err) reject(err);
      else resolve();
    });
    child.unref();
  });

/**
 * Play audio via PowerShell using System.Windows.Media.MediaPlayer.
 * Fallback for Windows when ffplay is not available.
 */
const playWithPowerShell = async (soundPath) => {
  // Convert to absolute Windows path with backslashes for .NET
  const winPath = soundPath.replace(/\//g, "\\");
  const script = `
Add-Type -AssemblyName presentationCore
$p = New-Object System.Windows.Media.MediaPlayer
$p.Open([uri]"${winPath}")
$p.Play()
Start-Sleep -Milliseconds 3000
$p.Close()
`;
  await spawnAsync("powershell.exe", [
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
    script,
  ]);
};

export const SC2SoundPlugin = async ({ $, client }) => {
  const soundsDir = join(__dirname, "sounds");
  const poolPath = join(soundsDir, "pool.json");

  // Use ~/.claude/sc2-state on Windows, ~/.config/claude/sc2-state elsewhere
  const stateDir = IS_WINDOWS
    ? join(homedir(), ".claude", "sc2-state")
    : join(homedir(), ".config/claude/sc2-state");

  const sessionMapPath = join(stateDir, "session-sound-map.json");
  const lastIndexPath = join(stateDir, "last-sound-index.json");

  let cachedSoundPool = null;
  let cachedSessionMap = null;
  let cachedLastIndex = null;

  // Async mutex — serializes read-modify-write cycles on state files
  let lock = Promise.resolve();

  const withLock = async (fn) => {
    const prev = lock;
    let releaseLock;
    lock = new Promise((resolve) => { releaseLock = resolve; });
    await prev;
    try {
      return await fn();
    } finally {
      releaseLock();
    }
  };

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

    return withLock(async () => {
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
    });
  };

  const playSound = async (sessionID, eventType) => {
    const soundEntry = await getSessionSound(sessionID, eventType);
    if (!soundEntry?.file) {
      return;
    }

    const soundPath = join(soundsDir, soundEntry.file);
    try {
      // Try ffplay first (works on all platforms when installed)
      await spawnAsync("ffplay", [
        "-nodisp",
        "-autoexit",
        "-loglevel",
        "quiet",
        soundPath,
      ]);
    } catch {
      // On Windows, fall back to PowerShell audio playback
      if (IS_WINDOWS) {
        try {
          await playWithPowerShell(soundPath);
        } catch {
          // Silently ignore — no audio backend available
        }
      }
      // On macOS/Linux, silently ignore (ffplay is the only backend)
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
          await withLock(async () => {
            const sessionMap = await loadSessionMap();
            if (sessionMap[sessionID]) {
              delete sessionMap[sessionID];
              await saveSessionMap(sessionMap);
            }
          });
        }
      }
    },
  };
};
