import argparse
import json
import os
import sys
from pathlib import Path

try:
    import requests
except Exception:
    requests = None

API_BASE = "https://api.elevenlabs.io"


def die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    raise SystemExit(code)

def load_env_file() -> None:
    # Load .env from repo root or current working directory, if present.
    candidates = [
        Path.cwd() / ".env",
        Path(__file__).resolve().parents[2] / ".env",
    ]
    for path in candidates:
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = value
        break


def read_paragraphs(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    paras = [p.strip() for p in text.split("\n\n") if p.strip()]
    return paras


def build_content_json(chapter_name: str, paragraphs: list[str], voice_id: str) -> list[dict]:
    blocks = []
    for p in paragraphs:
        blocks.append({
            "sub_type": "p",
            "nodes": [
                {
                    "type": "tts_node",
                    "text": p,
                    "voice_id": voice_id,
                }
            ],
        })
    return [{"name": chapter_name, "blocks": blocks}]


def ensure_requests():
    if requests is None:
        die("Missing dependency: requests. Install with `pip install requests`.")


def create_project(api_key: str, project_name: str, voice_id: str, model_id: str,
                   from_content_json: str | None = None,
                   language: str | None = None,
                   author: str | None = None,
                   title: str | None = None,
                   description: str | None = None,
                   genres: list[str] | None = None,
                   target_audience: str | None = None,
                   fiction: str | None = None,
                   mature_content: bool | None = None,
                   auto_convert: bool = False,
                   quality_preset: str | None = None,
                   volume_normalization: bool | None = None,
                   apply_text_normalization: str | None = None) -> dict:
    ensure_requests()
    url = f"{API_BASE}/v1/studio/projects"
    headers = {"xi-api-key": api_key}
    data = {
        "name": project_name,
        "default_title_voice_id": voice_id,
        "default_paragraph_voice_id": voice_id,
        "default_model_id": model_id,
    }
    if from_content_json:
        data["from_content_json"] = from_content_json
    if language:
        data["language"] = language
    if author:
        data["author"] = author
    if title:
        data["title"] = title
    if description:
        data["description"] = description
    if genres:
        data["genres"] = json.dumps(genres)
    if target_audience:
        data["target_audience"] = target_audience
    if fiction:
        data["fiction"] = fiction
    if mature_content is not None:
        data["mature_content"] = str(mature_content).lower()
    if quality_preset:
        data["quality_preset"] = quality_preset
    if volume_normalization is not None:
        data["volume_normalization"] = str(volume_normalization).lower()
    if apply_text_normalization:
        data["apply_text_normalization"] = apply_text_normalization
    data["auto_convert"] = str(auto_convert).lower()

    resp = requests.post(url, headers=headers, data=data, timeout=60)
    if not resp.ok:
        die(f"Create project failed: {resp.status_code} {resp.text}")
    return resp.json()["project"]


def create_chapter(api_key: str, project_id: str, chapter_name: str) -> dict:
    ensure_requests()
    url = f"{API_BASE}/v1/studio/projects/{project_id}/chapters"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json"}
    payload = {"name": chapter_name}
    resp = requests.post(url, headers=headers, data=json.dumps(payload), timeout=60)
    if not resp.ok:
        die(f"Create chapter failed: {resp.status_code} {resp.text}")
    return resp.json()["chapter"]


def update_chapter_content(api_key: str, project_id: str, chapter_id: str, content: dict) -> dict:
    ensure_requests()
    url = f"{API_BASE}/v1/studio/projects/{project_id}/chapters/{chapter_id}"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json"}
    payload = {"content": content}
    resp = requests.post(url, headers=headers, data=json.dumps(payload), timeout=60)
    if not resp.ok:
        die(f"Update chapter failed: {resp.status_code} {resp.text}")
    return resp.json()["chapter"]


def convert_chapter(api_key: str, project_id: str, chapter_id: str) -> None:
    ensure_requests()
    url = f"{API_BASE}/v1/studio/projects/{project_id}/chapters/{chapter_id}/convert"
    headers = {"xi-api-key": api_key}
    resp = requests.post(url, headers=headers, timeout=60)
    if not resp.ok:
        die(f"Convert chapter failed: {resp.status_code} {resp.text}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Push Chapter 1 to ElevenLabs Studio")
    parser.add_argument("--input", required=True, help="Path to _audio_book markdown")
    parser.add_argument("--project-name", required=True, help="Studio project name")
    parser.add_argument("--chapter-name", required=True, help="Chapter name")
    parser.add_argument("--voice-id", required=True, help="ElevenLabs voice_id")
    parser.add_argument("--model-id", required=True, help="ElevenLabs model_id (e.g., eleven_v3)")
    parser.add_argument("--language", default="en", help="ISO 639-1 code")
    parser.add_argument("--author", default=None)
    parser.add_argument("--title", default=None)
    parser.add_argument("--description", default=None)
    parser.add_argument("--genres", default=None, help="Comma-separated list")
    parser.add_argument("--target-audience", default=None, choices=["children","young adult","adult","all ages"])
    parser.add_argument("--fiction", default=None, choices=["fiction","non-fiction"])
    parser.add_argument("--mature-content", default=None, choices=["true","false"])
    parser.add_argument("--quality-preset", default=None, choices=["standard","high","ultra","ultra_lossless"])
    parser.add_argument("--volume-normalization", default=None, choices=["true","false"])
    parser.add_argument("--apply-text-normalization", default=None, choices=["auto","on","off","apply_english"])
    parser.add_argument("--project-id", default=None, help="Reuse existing project id")
    parser.add_argument("--convert", action="store_true", help="Trigger conversion after upload")

    args = parser.parse_args()

    load_env_file()
    api_key = os.getenv("ELEVENLABS_API_KEY")
    if not api_key:
        die("ELEVENLABS_API_KEY is not set.")

    input_path = Path(args.input)
    if not input_path.exists():
        die(f"Input not found: {input_path}")

    paragraphs = read_paragraphs(input_path)
    content_json = build_content_json(args.chapter_name, paragraphs, args.voice_id)

    project_id = args.project_id
    if not project_id:
        project = create_project(
            api_key=api_key,
            project_name=args.project_name,
            voice_id=args.voice_id,
            model_id=args.model_id,
            from_content_json=json.dumps(content_json),
            language=args.language,
            author=args.author,
            title=args.title,
            description=args.description,
            genres=[g.strip() for g in args.genres.split(",")] if args.genres else None,
            target_audience=args.target_audience,
            fiction=args.fiction,
            mature_content=(args.mature_content == "true") if args.mature_content else None,
            auto_convert=False,
            quality_preset=args.quality_preset,
            volume_normalization=(args.volume_normalization == "true") if args.volume_normalization else None,
            apply_text_normalization=args.apply_text_normalization,
        )
        project_id = project["project_id"]
        chapter_id = None
    else:
        chapter = create_chapter(api_key, project_id, args.chapter_name)
        chapter_id = chapter["chapter_id"]
        content = {"blocks": content_json[0]["blocks"]}
        update_chapter_content(api_key, project_id, chapter_id, content)

    print(f"Project created/used: {project_id}")

    if args.convert:
        if chapter_id is None:
            print("Project created with content. To convert, list chapters and convert the first one.")
        else:
            convert_chapter(api_key, project_id, chapter_id)
            print("Conversion triggered.")


if __name__ == "__main__":
    main()
