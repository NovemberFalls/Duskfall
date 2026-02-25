# C01 TTS Pipeline Readme

This document summarizes the passes taken to prepare Chapter 01 (C01) for ElevenLabs TTS, including the audit steps, file outputs, and how to resume safely without double-charging.

## Goal
- Produce C01 audio in high‑quality WAV, chunked for ElevenLabs `eleven_v3` limits.
- Avoid wasted credits by using preflight checks, chunk logging, and resume-safe outputs.

## Inputs
- Primary text: `Ralph/Book 1/Chapters/C01/C01 - The Last Good Morning_audio.md`
- Model: `eleven_v3`
- Output format: `wav_44100`
- Chunk limit: 4800 (safe under 5,000 max for `eleven_v3`)

## Passes Completed
1. **Pipeline audit**
   - Identified that Studio isn’t available; must use TTS API directly.
   - Verified script locations and flow in `Ralph/Book 1/scripts/tts_ch1.py`.

2. **Preflight + probe**
   - Implemented subscription preflight check against `/v1/user/subscription`.
   - Added probe system to estimate credits and log to CSV.
   - Logged probe results in `Ralph/Book 1/logs/elevenlabs_usage_log.csv`.

3. **Resume-safe chunking**
   - Added chunk persistence to prevent re-sends.
   - Added chunks log for audit trail.
   - Added default 120s delay between chunk calls to avoid rapid duplicate sends and allow history to settle.

4. **History recovery**
   - Downloaded a prior history item from ElevenLabs and renamed it as part 1:
     - `C01 - The Last Good Morning_part_1.wav`

5. **Chunk text files**
   - Wrote deterministic chunk text files for audit and resume:
     - `Ralph/Book 1/Chapters/C01/chunks/chunk_0001.txt` … `chunk_0005.txt`

6. **Audio parts**
   - Confirmed audio parts created and placed in the audio folder:
     - `C01 - The Last Good Morning_part_1.wav`
     - `C01 - The Last Good Morning_part_2.wav`
     - `C01 - The Last Good Morning_part_3.wav`
     - `C01 - The Last Good Morning_part_4.wav`
     - `C01 - The Last Good Morning_part_5.wav`

## Current Output Locations
- Final parts:
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_part_1.wav`
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_part_2.wav`
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_part_3.wav`
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_part_4.wav`
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_part_5.wav`
- Raw parts:
  - `Ralph/Book 1/Chapters/C01/audio/C01 - The Last Good Morning_parts/part_0001.wav` … `part_0005.wav`
- Chunk text files:
  - `Ralph/Book 1/Chapters/C01/chunks/chunk_0001.txt` … `chunk_0005.txt`
- Chunk audit log:
  - `Ralph/Book 1/Chapters/C01/chunks/chunks_log.json`
- Session log:
  - `Ralph/Book 1/Chapters/C01/chunks/session_log_2026-02-24.md`

## Operational Defaults (tts_ch1.py)
- Default inter-chunk delay: **120 seconds**
- Resume‑safe part writing
- Optional `--start-chunk` and `--stop-chunk` to limit sends
- Chunk text files and JSON log for audit

## Recommended Usage
Write chunks only (no API calls):
```powershell
python "Ralph\Book 1\scripts\tts_ch1.py" `
  --input "Ralph\Book 1\Chapters\C01\C01 - The Last Good Morning_audio.md" `
  --output "Ralph\Book 1\Chapters\C01\audio\C01 - The Last Good Morning.wav" `
  --voice-id <VOICE_ID> `
  --chunks-dir "Ralph\Book 1\Chapters\C01\chunks" `
  --write-chunks-only --skip-preflight
```

Generate specific chunks only:
```powershell
python "Ralph\Book 1\scripts\tts_ch1.py" `
  --input "Ralph\Book 1\Chapters\C01\C01 - The Last Good Morning_audio.md" `
  --output "Ralph\Book 1\Chapters\C01\audio\C01 - The Last Good Morning.wav" `
  --voice-id <VOICE_ID> `
  --output-format wav_44100 `
  --chunks-dir "Ralph\Book 1\Chapters\C01\chunks" `
  --parts-dir "Ralph\Book 1\Chapters\C01\audio\C01 - The Last Good Morning_parts" `
  --final-parts-dir "Ralph\Book 1\Chapters\C01\audio" `
  --final-part-prefix "C01 - The Last Good Morning" `
  --start-chunk 4 --stop-chunk 5
```

## Notes
- If you must avoid any risk of double‑charging, only run chunk ranges that are missing.
- History lookup did not return metadata for some IDs; keep local logs as the source of truth.
