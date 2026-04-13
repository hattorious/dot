# ABOUTME: Pytest configuration — adds scripts/ and dotbot_plugins/ to sys.path.
# ABOUTME: Required because neither directory is a Python package.
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "dotbot_plugins"))
