# skills-updater

TaigaShinohara が作って GitHub に上げているスキルを、どのAIコーディングツール（Claude Code / Codex / Cursor など）からでも **1行で導入・最新化** するためのスクリプト置き場。

## 使い方（導入も更新も同じ1行）

```bash
curl -fsSL https://raw.githubusercontent.com/TaigaShinohara/skills-updater/main/update-skills.sh | bash
```

- 初回：対象リポジトリを `~/.taiga-skills-src` に clone し、スキルを `~/.claude/skills` にコピー
- 2回目以降：clone を pull で最新化してからコピーし直すので、**同じ1行で常に最新**になる
- 置き場を変えたい場合：`SKILLS_DIR=~/.codex/skills bash update-skills.sh`（環境変数で指定）

## 対象（7リポジトリ・11スキル）

| リポジトリ | スキル |
|---|---|
| concept-driven-ux | concept-driven-ux / experience-balance / independent-review |
| mobile-onboarding | mobile_onboarding |
| meaningful-app-design（非公開） | meaningful_app_design |
| store-submission-skills | store_review_readiness / store_listing_pack / store_submission_ops |
| easy-i18n-skill | easy_i18n |
| simple-glass-skill | simple_glass |
| material-design-3-ui-skill | material-design-3-ui |

- meaningful-app-design は非公開リポジトリ。gh CLI で本人のアカウントにログイン済みの環境なら自動で取得でき、できない場合はその旨を表示して他だけ進める。
- スキルの使い方は各 SKILL.md が正本。ストア提出の確定・支払い・規約同意は本人の明示承認が必要で、鍵類（署名鍵・証明書秘密鍵・APIキー）は扱わない、という約束は各スキル側の指示に従うこと。
