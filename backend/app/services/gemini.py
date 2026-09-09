import base64
import json

from google import genai
from pydantic import BaseModel, Field

from app.config import settings
from app.exceptions import UpstreamError


class SpeechAnalysis(BaseModel):
    transcript: str
    filler_word_count: int
    words_per_minute: int
    coherence_score: int = Field(ge=0, le=10)
    grammar_score: int = Field(ge=0, le=10)
    content_accuracy_score: int = Field(ge=0, le=10)
    feedback_summary: str


_PROMPT_TEMPLATE = """You are a speaking coach reviewing a short (up to 60 second) \
practice talk. The speaker was given this topic: "{topic}".

Listen to the audio and return:
- transcript: a verbatim transcript of what was said.
- filler_word_count: count of filler words/sounds ("um", "uh", "like", "you know", "so", etc).
- words_per_minute: speaking pace, estimated from transcript length and audio duration.
- coherence_score: 0-10, how logically the talk flows.
- grammar_score: 0-10, grammatical correctness of the speech.
- content_accuracy_score: 0-10, how relevant and accurate the content is to the given topic.
- feedback_summary: 2-3 sentences of specific, encouraging, actionable feedback.
"""


def _gemini_mime_type(filename: str | None) -> str:
    # Gemini's audio content type only lists wav/mp3/aiff/aac/ogg/flac/opus/etc as
    # supported mime types — no webm and no bare mp4 container. But the video
    # mime types DO cover both webm and mp4, and each container here holds no
    # visual frames, just an audio track. Sending it as a "video" block with the
    # matching container mime type lets Gemini demux and transcribe the audio
    # without adding a transcoding step on our side.
    # - Browser (web) recordings: webm (MediaRecorder's default container).
    # - Mobile (Flutter `record` package) recordings: m4a, an MPEG-4 audio
    #   container — same family as mp4, so video/mp4 demuxes it the same way.
    name = (filename or "").lower()
    if name.endswith(".m4a") or name.endswith(".mp4") or name.endswith(".aac"):
        return "video/mp4"
    return "video/webm"


async def analyze_speech(
    audio_bytes: bytes, topic: str, filename: str | None = None
) -> SpeechAnalysis:
    if not settings.gemini_api_key:
        raise UpstreamError("Speech analysis is not configured")

    client = genai.Client(api_key=settings.gemini_api_key)

    try:
        interaction = await client.aio.interactions.create(
            model=settings.gemini_model,
            input=[
                {"type": "text", "text": _PROMPT_TEMPLATE.format(topic=topic)},
                {
                    "type": "video",
                    "data": base64.b64encode(audio_bytes).decode("utf-8"),
                    "mime_type": _gemini_mime_type(filename),
                },
            ],
            response_format={
                "type": "text",
                "mime_type": "application/json",
                "schema": SpeechAnalysis.model_json_schema(),
            },
        )
    except Exception as exc:
        raise UpstreamError("Speech analysis failed") from exc

    if not interaction.output_text:
        raise UpstreamError("Speech analysis returned no result")

    try:
        return SpeechAnalysis.model_validate(json.loads(interaction.output_text))
    except (json.JSONDecodeError, ValueError) as exc:
        raise UpstreamError("Speech analysis returned an unexpected result") from exc
