# ABOUTME: Pytest configuration — adds scripts/ to sys.path so unit tests can import sort_json.
# ABOUTME: Required because sort_json.py is not in a package.
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
