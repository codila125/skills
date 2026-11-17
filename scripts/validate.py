#!/usr/bin/env python3
"""Validate every skill, plugin, and marketplace manifest in this repository.

Usage: python3 scripts/validate.py [repo-root]

Prints one ERROR line per problem and exits 1 if there are any. Standard
library only, so it runs the same locally and in CI.
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
errors = []


def err(path, msg):
    errors.append(f"ERROR {os.path.relpath(path, ROOT)}: {msg}")


def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        err(path, "missing")
    except json.JSONDecodeError as e:
        err(path, f"invalid JSON: {e}")
    return None


def frontmatter(path):
    with open(path) as f:
        text = f.read()
    if not text.startswith("---\n"):
        err(path, "must start with a --- frontmatter block")
        return {}
    end = text.find("\n---", 4)
    if end == -1:
        err(path, "frontmatter block is not closed with ---")
        return {}
    fields = {}
    for line in text[4:end].splitlines():
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if m:
            fields[m.group(1)] = m.group(2).strip().strip("\"'")
    return fields


def check_skill(skill_dir):
    name = os.path.basename(skill_dir)
    skill_md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(skill_md):
        err(skill_dir, "skill folder has no SKILL.md")
        return
    fm = frontmatter(skill_md)
    if not fm:
        return
    if fm.get("name") != name:
        err(skill_md, f"frontmatter name '{fm.get('name')}' must equal folder name '{name}'")
    if not NAME_RE.match(name) or len(name) > 64:
        err(skill_md, f"name '{name}' must be lowercase-hyphenated, 64 chars max")
    desc = fm.get("description", "")
    if not desc:
        err(skill_md, "frontmatter needs a non-empty description")
    elif len(desc) > 1024:
        err(skill_md, f"description is {len(desc)} chars; max is 1024")
    if not os.path.isfile(os.path.join(skill_dir, "agents", "openai.yaml")):
        err(skill_dir, "missing agents/openai.yaml (Codex display metadata)")


def check_links(md_path):
    with open(md_path) as f:
        text = re.sub(r"```.*?```", "", f.read(), flags=re.S)
    for target in LINK_RE.findall(text):
        if re.match(r"^[a-z]+:", target) or target.startswith("#") or "<" in target:
            continue
        rel = target.split("#", 1)[0]
        if rel and not os.path.exists(os.path.join(os.path.dirname(md_path), rel)):
            err(md_path, f"broken link -> {target}")


def check_plugin(plugin_dir, name):
    for kind in (".claude-plugin", ".codex-plugin"):
        manifest = load_json(os.path.join(plugin_dir, kind, "plugin.json"))
        if manifest and manifest.get("name") != name:
            err(os.path.join(plugin_dir, kind, "plugin.json"), f"name must be '{name}'")
    skills_root = os.path.join(plugin_dir, "skills")
    if not os.path.isdir(skills_root):
        err(plugin_dir, "plugin has no skills/ folder")
        return
    for entry in sorted(os.listdir(skills_root)):
        path = os.path.join(skills_root, entry)
        if os.path.isdir(path):
            check_skill(path)


def check_marketplaces():
    claude = load_json(os.path.join(ROOT, ".claude-plugin", "marketplace.json")) or {}
    codex = load_json(os.path.join(ROOT, ".agents", "plugins", "marketplace.json")) or {}
    if claude.get("name") != codex.get("name"):
        err(ROOT, "Claude and Codex marketplace names differ")
    claude_plugins = {p["name"]: p["source"] for p in claude.get("plugins", [])}
    codex_plugins = {p["name"]: p["source"]["path"] for p in codex.get("plugins", [])}
    if set(claude_plugins) != set(codex_plugins):
        err(ROOT, f"marketplaces list different plugins: {sorted(claude_plugins)} vs {sorted(codex_plugins)}")
    on_disk = {d for d in os.listdir(os.path.join(ROOT, "plugins")) if os.path.isdir(os.path.join(ROOT, "plugins", d))}
    for d in sorted(on_disk - set(claude_plugins)):
        err(os.path.join(ROOT, "plugins", d), "plugin folder is not listed in the marketplaces")
    for name, source in {**codex_plugins, **claude_plugins}.items():
        path = os.path.normpath(os.path.join(ROOT, source))
        if not os.path.isdir(path):
            err(ROOT, f"plugin '{name}' source {source} does not exist")
        else:
            check_plugin(path, name)


def walk_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in (".git", "node_modules")]
        for f in filenames:
            yield os.path.join(dirpath, f)


def main():
    check_marketplaces()
    for path in walk_files():
        base = os.path.basename(path)
        if base == ".DS_Store":
            err(path, "remove .DS_Store")
        elif path.endswith(".json"):
            load_json(path)
        elif path.endswith(".md"):
            check_links(path)
        elif path.endswith(".sh"):
            if not os.access(path, os.X_OK):
                err(path, "shell script is not executable")
            r = subprocess.run(["bash", "-n", path], capture_output=True, text=True)
            if r.returncode:
                err(path, f"bash syntax error: {r.stderr.strip()}")
    for e in errors:
        print(e)
    print(f"{'FAIL' if errors else 'OK'}: {len(errors)} problem(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
