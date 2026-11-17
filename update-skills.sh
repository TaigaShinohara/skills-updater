#!/usr/bin/env bash
# TaigaShinohara のスキル一括インストール／更新スクリプト
#
# 使い方（導入も更新も、この1行で同じ）:
#   curl -fsSL https://raw.githubusercontent.com/TaigaShinohara/skills-updater/main/update-skills.sh | bash
#
# 置き場を変えたい場合（Codex / Cursor など）:
#   SKILLS_DIR=~/.codex/skills bash update-skills.sh
#
# 動作:
#   - 対象リポジトリを ~/.taiga-skills-src に clone（2回目以降は pull で最新化）
#   - 各リポジトリの skills/ フォルダ内（SKILL.md を含むフォルダ）を置き場へ丸ごとコピー
#   - リポジトリ直下がスキル本体のもの（material-design-3-ui-skill）も自動で拾う
#   - meaningful-app-design は非公開リポジトリ。gh CLI でログイン済みなら取得でき、
#     できなければその旨を表示して他のスキルだけ進める

set -u

DEST="${SKILLS_DIR:-$HOME/.claude/skills}"
SRC="${SKILLS_SRC:-$HOME/.taiga-skills-src}"
OWNER="TaigaShinohara"
REPOS="concept-driven-ux mobile-onboarding meaningful-app-design store-submission-skills easy-i18n-skill simple-glass-skill material-design-3-ui-skill"

mkdir -p "$DEST" "$SRC"

clone_or_pull() {
  local repo="$1"
  if [ -d "$SRC/$repo/.git" ]; then
    git -C "$SRC/$repo" pull --ff-only --quiet 2>/dev/null \
      || echo "  ! pull できませんでした（手元の clone のまま続行）: $repo"
  else
    if command -v gh >/dev/null 2>&1; then
      gh repo clone "$OWNER/$repo" "$SRC/$repo" -- --quiet 2>/dev/null \
        || git clone --quiet "https://github.com/$OWNER/$repo.git" "$SRC/$repo" 2>/dev/null
    else
      git clone --quiet "https://github.com/$OWNER/$repo.git" "$SRC/$repo" 2>/dev/null
    fi
  fi
  [ -d "$SRC/$repo" ]
}

skill_version() {
  local v
  v=$(grep -m1 -E '^[[:space:]]*version:' "$1" 2>/dev/null | sed 's/.*version:[[:space:]]*//')
  if [ -n "$v" ]; then echo "$v"; else echo "-"; fi
}

install_skill() {
  local srcdir="$1" name="$2"
  local destdir="$DEST/$name"
  local ver state
  ver=$(skill_version "$srcdir/SKILL.md")
  if [ -d "$destdir" ]; then state="更新"; else state="導入"; fi
  rm -rf "$destdir"
  cp -R "$srcdir" "$destdir"
  echo "  $state: $name (version: $ver)"
}

for repo in $REPOS; do
  echo "== $repo"
  if ! clone_or_pull "$repo"; then
    echo "  ! 取得できませんでした（非公開リポジトリの認証が必要な場合があります）: $repo"
    continue
  fi
  if [ -d "$SRC/$repo/skills" ]; then
    found=0
    for d in "$SRC/$repo/skills"/*/; do
      [ -f "$d/SKILL.md" ] || continue
      found=1
      install_skill "${d%/}" "$(basename "$d")"
    done
    [ "$found" = "0" ] && echo "  ! skills/ 内に SKILL.md が見つかりませんでした"
  elif [ -f "$SRC/$repo/SKILL.md" ]; then
    tmp="$SRC/.tmp-$repo"
    rm -rf "$tmp"; mkdir -p "$tmp"
    cp -R "$SRC/$repo/." "$tmp/"
    rm -rf "$tmp/.git" "$tmp/.github"
    name=$(grep -m1 -E '^name:' "$SRC/$repo/SKILL.md" | sed 's/name:[[:space:]]*//')
    [ -z "$name" ] && name="$repo"
    install_skill "$tmp" "$name"
    rm -rf "$tmp"
  else
    echo "  ! スキル本体が見つかりませんでした: $repo"
  fi
done

echo ""
echo "完了: $DEST にスキルをそろえました。"
ls "$DEST"
