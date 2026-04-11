# ABOUTME: Unit tests for detect_indent function in sort_json.py.
# ABOUTME: Covers 2-space, 4-space indent detection and the default fallback.
from sort_json import detect_indent


def test_detects_two_space_indent():
    content = '{\n  "key": "value"\n}'
    assert detect_indent(content) == 2


def test_detects_four_space_indent():
    content = '{\n    "key": "value"\n}'
    assert detect_indent(content) == 4


def test_defaults_to_two_spaces_when_no_indent():
    content = '{"key": "value"}'
    assert detect_indent(content) == 2


def test_ignores_blank_lines():
    content = '{\n\n  "key": "value"\n}'
    assert detect_indent(content) == 2


def test_detects_indent_from_first_indented_line():
    content = '{\n  "a": {\n    "b": 1\n  }\n}'
    assert detect_indent(content) == 2


def test_tab_indented_files_normalize_to_two_spaces():
    # Tab-indented JSON is normalized to 2-space on output (by design).
    # lstrip(" ") skips tab lines, falling through to the default of 2.
    content = '{\n\t"key": "value"\n}'
    assert detect_indent(content) == 2
