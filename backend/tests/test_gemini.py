from app.services.gemini import _gemini_mime_type


def test_gemini_mime_type_webm_for_browser_recordings():
    assert _gemini_mime_type("clip.webm") == "video/webm"


def test_gemini_mime_type_mp4_for_mobile_m4a():
    assert _gemini_mime_type("clip.m4a") == "video/mp4"


def test_gemini_mime_type_mp4_for_mobile_aac():
    assert _gemini_mime_type("clip.aac") == "video/mp4"


def test_gemini_mime_type_defaults_to_webm_when_missing():
    assert _gemini_mime_type(None) == "video/webm"
