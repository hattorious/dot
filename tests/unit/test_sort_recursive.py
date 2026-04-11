# ABOUTME: Unit tests for the sort_recursive function in sort_json.py.
# ABOUTME: Covers dicts, nested dicts, arrays, and primitive values.
from sort_json import sort_recursive


def test_sorts_top_level_keys():
    assert sort_recursive({"b": 1, "a": 2}) == {"a": 2, "b": 1}


def test_sorts_nested_dict_keys():
    result = sort_recursive({"b": {"d": 1, "c": 2}, "a": 3})
    assert result == {"a": 3, "b": {"c": 2, "d": 1}}


def test_preserves_array_order():
    assert sort_recursive({"a": [3, 1, 2]}) == {"a": [3, 1, 2]}


def test_sorts_dicts_nested_inside_arrays():
    result = sort_recursive([{"b": 1, "a": 2}])
    assert result == [{"a": 2, "b": 1}]


def test_leaves_strings_unchanged():
    assert sort_recursive("hello") == "hello"


def test_leaves_numbers_unchanged():
    assert sort_recursive(42) == 42


def test_leaves_none_unchanged():
    assert sort_recursive(None) is None


def test_leaves_booleans_unchanged():
    assert sort_recursive(True) is True


def test_empty_dict():
    assert sort_recursive({}) == {}


def test_empty_list():
    assert sort_recursive([]) == []
