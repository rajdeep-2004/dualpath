# AGENTS.md: instructions for coding agents

You are helping one team member add **their own part** of this Verilog project to `main`.
The code is finished and tested. Your job is only to move the right files into `main` and push
them from the user's own GitHub account. Do not write or change any Verilog.

## 1. Find out who you are helping

Ask the user for their name if they have not said it, then use this table:

| Name | Phase | Branch |
|---|---|---|
| Rajat | 1 | `phase-1-regfile-pc` |
| Sachin | 2 | `phase-2-cpu` |
| Anand | 3 | `phase-3-decoder-io` |
| Rajdeep | 4 | `phase-4-harvard` |
| Omved | 5 | `phase-5-shared` |

## 2. Read the full guide

```sh
git fetch origin
git show origin/<branch>:CONTRIBUTING.md
```

Follow **only the section for the user's phase**. It lists the exact files, commands, commit
messages and the check to run.

## 3. Hard rules

1. Work on `main`. Run `git checkout main && git pull` before anything else.
2. The earlier phases must already be on `main` (phase order 1, 2, 3, 4, 5). Check with
   `git log --oneline` and the file list. If an earlier phase is missing, **stop** and tell the
   user to wait for that teammate.
3. Bring files in **only** with `git checkout origin/<branch> -- <files>`, listing only the
   files from the user's phase.
4. **Never** merge, rebase or cherry-pick a phase branch. **Never** push to a phase branch.
5. **Never** add `AGENTS.md`, `CONTRIBUTING.md` or any file from another phase to `main`. Never
   use `git add .` or `git add -A`.
6. Before committing, confirm `git config user.name` and `git config user.email` are the
   user's own. If not, ask the user to set them.
7. Use the commit messages from the guide, one commit per step.
8. Run the check from the guide. If it fails, **do not push**: tell the user.
9. Push with `git push origin main`. If rejected, run `git pull` and push again.
10. Do not edit, reformat or "improve" any file.

## 4. When done

Show the user `git log --oneline -5` and the files you added. Then offer to explain each file
line by line: the user must be able to explain their code in the viva.
