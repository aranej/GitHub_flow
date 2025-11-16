# 📦 GitHub Essentials Starter Pack

> **Kompletný balík pre začiatočníkov - od nuly k produktívnej práci s GitHubom**
> Časová náročnosť: 6.5 hodiny | Výstup: Profesionálna práca s GitHubom od prvého dňa

---

## 🎯 O tomto balíku

**Pre koho:**
- Úplní začiatočníci s Git/GitHub
- Vývojári prechádzajúci z iných verziovacích systémov
- Tímy, ktoré potrebujú štandardizovať GitHub workflow

**Čo získaš:**
- ✅ Pochopenie Git fundamentals
- ✅ Praktické zručnosti s GitHub Desktop
- ✅ Schopnosť vytvárať Pull Requesty
- ✅ Daily workflow pre produktívnu prácu
- ✅ Best practices pre collaboration

**Formát:**
- 4 moduly (6.5 hodiny celkom)
- Praktické cvičenia v každom module
- Checklist pre overenie zručností
- Reálne príklady z praxe

---

## 📚 MODUL 1: Git Fundamentals (2 hodiny)

### 1.1 Čo je Git a prečo sa používa

**Git = Distributed Version Control System**

**Analógia:**
```
Git je ako "Time Machine" pre tvoj kód
- Môžeš sa vrátiť do minulosti
- Vidieť, kto čo zmenil a kedy
- Experimentovať bez rizika
- Spolupracovať bez konfliktov
```

**Prečo potrebuješ Git:**
1. **História zmien**: Vidíš každú zmenu v projekte
2. **Bezpečnosť**: Nikdy nestratíš starý kód
3. **Collaboration**: Viac ľudí pracuje na rovnakom projekte
4. **Branching**: Experimentuj bez ovplyvnenia production kódu
5. **Backup**: Automatický backup v cloude

**Príklad bez Git:**
```
moj_projekt.zip
moj_projekt_final.zip
moj_projekt_final_FINAL.zip
moj_projekt_final_FINAL_v2.zip
moj_projekt_final_FINAL_v2_SKUTOCNE_FINAL.zip
```

**S Gitom:**
```
moj_projekt/
  └── Git trackuje všetky verzie automaticky
  └── Každá zmena má autor + timestamp + message
```

---

### 1.2 Základné koncepty

#### Repository (Repo)
**Čo to je:**
- Adresár s projektom + `.git` folder
- `.git` obsahuje celú históriu projektu

**Typy:**
- **Local repository**: Na tvojom počítači
- **Remote repository**: Na GitHube (v cloude)

**Vytvorenie:**
```bash
# Nový projekt
git init

# Existujúci projekt z GitHubu
git clone https://github.com/user/repo.git
```

---

#### Commit
**Čo to je:**
- Snapshot (momentka) projektu v určitom čase
- "Save point" ako vo videohre

**Anatómia commitu:**
```
Commit: a3f2c1b (unique ID)
Author: Ján Novák <jan@example.com>
Date: 2025-11-16 10:30:00
Message: "Add login functionality"

Changes:
  + login.js (added)
  M index.html (modified)
  - old_auth.js (deleted)
```

**Best Practices:**
- Jeden commit = jedna logická zmena
- Popisná commit message
- Commituj často (každých 30-60 min práce)

---

#### Branch
**Čo to je:**
- Paralelná verzia projektu
- Izolovaný priestor pre experimenty

**Vizualizácia:**
```
main     A---B---C---D---E (production code)
              \
feature        F---G---H (new feature)
```

**Prečo branching:**
- Ochrana production kódu
- Paralelný vývoj features
- Experimentovanie bez rizika
- Code review pred mergom

**Konvencie názvov:**
```
main              - Production kód
feature/login     - Nová funkcionalita
bugfix/auth-error - Oprava bugu
hotfix/security   - Kritická oprava
```

---

#### Merge
**Čo to je:**
- Spojenie dvoch branches
- Integrácia zmien z feature do main

**Vizualizácia:**
```
main     A---B---C-------M (merged feature)
              \         /
feature        F---G---H
```

**Typy merge:**
1. **Fast-forward**: Lineárna história
2. **Three-way merge**: Merge commit
3. **Squash merge**: Všetky commity → 1 commit

---

#### Pull Request (PR)
**Čo to je:**
- Návrh na merge zmien
- Code review pred spojením do main
- Diskusia o zmenách

**Workflow:**
```
1. Vytvor branch
2. Urob zmeny + commity
3. Push na GitHub
4. Otvor Pull Request
5. Code review
6. Oprav pripomienky
7. Approval → Merge
```

**Výhody PR:**
- Peer review (kontrola kódu)
- Diskusia o implementácii
- Automatické testy (CI/CD)
- Dokumentácia zmien

---

### 1.3 Git Workflow (základný cyklus)

**Každodenný cyklus:**

```bash
# 1. RÁNO: Sync s main branch
git checkout main
git pull origin main

# 2. NOVÁ FEATURE: Vytvor branch
git checkout -b feature/my-feature

# 3. PRÁCA: Edituj súbory
# ... robíš zmeny v kóde ...

# 4. STAGING: Pridaj zmeny do staging area
git add .

# 5. COMMIT: Ulož snapshot
git commit -m "Add user authentication"

# 6. PUSH: Nahraj na GitHub
git push -u origin feature/my-feature

# 7. PULL REQUEST: Vytvor PR na GitHube
# ... otvoríš Pull Request cez web interface ...

# 8. MERGE: Po approval
# ... merge cez GitHub UI ...

# 9. CLEANUP: Zmaz branch
git checkout main
git pull origin main
git branch -d feature/my-feature
```

**Working Tree States:**
```
Untracked ──→ Staged ──→ Committed ──→ Pushed
  (new)       (git add)  (git commit)  (git push)
```

---

### 1.4 GitHub Desktop vs Command Line

**Kedy použiť GitHub Desktop:**
- ✅ Vizualizácia zmien (diff viewer)
- ✅ Conflict resolution (grafický editor)
- ✅ Jednoduchý commit workflow
- ✅ Začiatočníci a non-technical tímy

**Kedy použiť Command Line:**
- ✅ Pokročilé operácie (rebase, cherry-pick)
- ✅ Automation scripty
- ✅ Remote servery (SSH)
- ✅ Rýchlosť pre expertov

**Hybrid prístup (odporúčané):**
```
GitHub Desktop: Daily workflow (commit, push, PR)
Command Line: Advanced operations (rebase, stash, reset)
```

---

### ✅ MODUL 1 - Checklist

Po dokončení by si mal vedieť:

```
□ Vysvetliť, čo je Git a prečo sa používa
□ Definovať: repository, commit, branch, merge, pull request
□ Popísať základný Git workflow (clone → edit → commit → push)
□ Rozlíšiť local vs remote repository
□ Pochopiť, kedy použiť GitHub Desktop vs CLI
□ Vytvoriť nový branch
□ Urobiť commit so zmysluplnou message
□ Pushnúť zmeny na GitHub
```

**Praktické cvičenie:**
1. Vytvor testovací repository na GitHube
2. Naklonuj ho na svoj počítač
3. Vytvor branch `test-branch`
4. Pridaj súbor `hello.txt` s textom "Hello Git!"
5. Commit zmeny
6. Push na GitHub
7. Over na github.com, že branch a súbor sú tam

---

## 🖥️ MODUL 2: GitHub Desktop Mastery (1.5 hodiny)

### 2.1 Inštalácia a Setup

**Inštalácia:**
```
1. Stiahni: https://desktop.github.com
2. Nainštaluj (Windows/Mac/Linux)
3. Spusti GitHub Desktop
4. Sign in s GitHub účtom
5. Konfigurácia:
   - Name: Tvoje meno
   - Email: tvoj@email.com (rovnaký ako na GitHube)
```

**Prvé nastavenia:**
```
Preferences → Advanced:
  [x] External editor: Visual Studio Code
  [x] Shell: /bin/bash (Mac/Linux) alebo Git Bash (Windows)

Preferences → Git:
  Name: Ján Novák
  Email: jan@example.com
```

---

### 2.2 Klony Repository

**Metóda 1: Clone cez URL**
```
File → Clone Repository → URL
URL: https://github.com/user/repo.git
Local path: /Users/jan/projects/repo
[Clone]
```

**Metóda 2: Clone z tvojich repozitárov**
```
File → Clone Repository → GitHub.com
Vybereš repo zo zoznamu
[Clone]
```

**Po klonovaní:**
- Repository sa zobrazí v ľavom paneli
- Vidíš aktuálny branch
- Môžeš začať editovať súbory

---

### 2.3 Branching a Merging graficky

**Vytvorenie branch:**
```
Current Branch: main ▼
→ New Branch
→ Name: feature/login
→ Create from: main
[Create Branch]
```

**Vizualizácia:**
```
GitHub Desktop zobrazí:
┌─────────────────────────────────┐
│ Current Branch: feature/login ▼ │
│                                  │
│ Changes (3)                      │
│  ☑ login.js                      │
│  ☑ index.html                    │
│  ☑ auth.css                      │
└─────────────────────────────────┘
```

**Merging branch:**
```
1. Checkout main: Current Branch → main
2. Branch → Merge into Current Branch
3. Vyber: feature/login
4. [Merge feature/login into main]
```

**Fast-forward merge:**
```
main     A---B (HEAD)
              \
feature        C---D

After merge:
main     A---B---C---D (HEAD)
```

---

### 2.4 Conflict Resolution vo vizuálnom editore

**Kedy vzniká conflict:**
```
main      A---B---C (editoval si login.js)
               \
feature         D (niekto iný editoval login.js)
```

**GitHub Desktop conflict indicator:**
```
┌─────────────────────────────────────┐
│ ⚠️ Conflicts detected (1)           │
│                                      │
│ login.js                             │
│ [Open in Visual Studio Code]        │
└─────────────────────────────────────┘
```

**Riešenie v VS Code:**
```javascript
<<<<<<< HEAD (Current Change)
function login(user, pass) {
  return authenticate(user, pass);
}
=======
function login(username, password) {
  return auth.verify(username, password);
}
>>>>>>> feature/login (Incoming Change)

Možnosti:
[Accept Current Change]
[Accept Incoming Change]
[Accept Both Changes]
[Compare Changes]
```

**Po vyriešení:**
```
1. Ulož súbor
2. Vráť sa do GitHub Desktop
3. Stage vyriešený súbor
4. Commit: "Merge branch and resolve conflicts"
```

---

### 2.5 Push a Pull operácie

**Push (upload zmien na GitHub):**
```
Podmienky pre Push:
✅ Máš commity, ktoré nie sú na remote
✅ Si prihlásený do GitHubu

Postup:
1. Urob commit(y)
2. Klikni "Push origin" (top right)
3. GitHub Desktop uploadne zmeny
```

**Pull (download zmien z GitHubu):**
```
Kedy pullnúť:
- Ráno pred začatím práce
- Niekto iný pushol zmeny
- Vidíš "Fetch origin" s číslom

Postup:
1. Klikni "Fetch origin"
2. Ak sú zmeny → tlačidlo zmení na "Pull origin"
3. Klikni "Pull origin"
```

**Fetch vs Pull:**
```
Fetch: Stiahni info o zmenách (neaplikuj ich)
Pull:  Stiahni zmeny + aplikuj ich (fetch + merge)
```

---

### 2.6 Diff Viewer (vizualizácia zmien)

**GitHub Desktop Diff View:**
```
┌─────────────────────────────────────────────┐
│ Changes (1)                                  │
│                                              │
│ ☑ login.js                                   │
│                                              │
│  1  function login(user, pass) {             │
│  2 -  return true; // TODO                   │  (červené - deleted)
│  2 +  return authenticate(user, pass);       │  (zelené - added)
│  3  }                                        │
└─────────────────────────────────────────────┘
```

**Farby:**
- 🟥 Červená: Deletnuté riadky
- 🟩 Zelená: Pridané riadky
- ⬜ Biela: Nezmenené riadky

**Split view vs Unified view:**
```
Split:    Stará verzia | Nová verzia (side-by-side)
Unified:  Stará a nová v jednom view (+-diff)
```

---

### ✅ MODUL 2 - Checklist

Po dokončení by si mal vedieť:

```
□ Nainštalovať a nakonfigurovať GitHub Desktop
□ Naklonovať repository cez UI
□ Vytvoriť nový branch graficky
□ Mergnutí branch cez GitHub Desktop
□ Vyriešiť merge conflict vo vizuálnom editore
□ Pushnúť zmeny na GitHub
□ Pullnúť zmeny z GitHubu
□ Používať diff viewer na kontrolu zmien
□ Switchovať medzi branchmi
```

**Praktické cvičenie:**
1. Naklonuj svoj testovací repository
2. Vytvor branch `desktop-test`
3. Edituj `hello.txt` (pridaj "Testing Desktop")
4. Commit zmeny v GitHub Desktop
5. Push na GitHub
6. Prejdi na `main` branch
7. Pullni zmeny z GitHubu
8. Mergni `desktop-test` do `main`

---

## 🤝 MODUL 3: Collaboration Basics (2 hodiny)

### 3.1 Pull Requesty - čo to je a ako fungujú

**Pull Request (PR) = Code Review Request**

**Životný cyklus PR:**
```
1. Developer: Vytvorí branch
              ↓
2. Developer: Robí zmeny + commity
              ↓
3. Developer: Push na GitHub
              ↓
4. Developer: Otvorí Pull Request
              ↓
5. Reviewer:  Code review (komentáre, suggestions)
              ↓
6. Developer: Opraví pripomienky (commit + push)
              ↓
7. Reviewer:  Approval (LGTM - Looks Good To Me)
              ↓
8. Merge:     PR sa mergne do main
              ↓
9. Cleanup:   Branch sa zmaže
```

---

### 3.2 Vytvorenie Pull Request

**Metóda 1: GitHub Desktop**
```
1. Push tvoj branch na GitHub
2. GitHub Desktop zobrazí:
   "Create Pull Request"
3. Klikni → otvorí sa prehliadač
4. Vyplň PR details
```

**Metóda 2: GitHub Web**
```
1. Choď na github.com/user/repo
2. Vidíš banner: "feature/login had recent pushes"
3. Klikni "Compare & pull request"
4. Vyplň formulár
```

**PR Formulár:**
```
Title: Add user authentication system

Base: main ← Compare: feature/login

Description:
## Summary
Implements user login and authentication

## Changes
- Added login.js with authentication logic
- Updated index.html with login form
- Added auth.css for styling

## Testing
- [x] Manual testing completed
- [x] All existing tests pass
- [x] Added new tests for auth

## Screenshots
[Attach images of login form]

Reviewers: @john @sarah
Labels: enhancement, security
```

---

### 3.3 Code Review Proces

**Role:**
- **Author**: Vytvoriteľ PR (ty)
- **Reviewer**: Kontrolór kódu (kolega)

**Review checklist pre Reviewera:**
```
Code Quality:
□ Kód je čitateľný a pochopiteľný
□ Dodržiava coding standards
□ Žiadny duplicitný kód

Functionality:
□ Implementácia je správna
□ Edge cases sú ošetrené
□ Žiadne security vulnerabilities

Testing:
□ Testy sú prítomné a dostatočné
□ Všetky testy prechádzajú

Documentation:
□ Komentáre sú jasné
□ README je aktualizované (ak treba)
```

**Typy komentárov:**
```
1. Question (🤔): "Why did you choose this approach?"
2. Suggestion (💡): "Consider using async/await here"
3. Nitpick (🔍): "Minor: typo in variable name"
4. Blocking (⛔): "This will break production, must fix"
```

**Review states:**
```
✅ Approved: LGTM, môže sa mergnúť
💬 Comment: Komentáre bez blokovania merge
❌ Request Changes: Musí sa opraviť pred merge
```

---

### 3.4 Responding to Review Comments

**Ako spracovať pripomienky:**

```
1. Prečítaj si všetky komentáre
2. Odpovedz na otázky
3. Implementuj zmeny
4. Commit + push (PR sa auto-update)
5. Resolve conversations
6. Request re-review
```

**Príklad diskusie:**
```
Reviewer: "This function is too complex, split it?"

Author:   "Good point! I'll extract the validation logic
          into a separate function."

[Author commits changes]

Author:   "Done! Check out the new validateInput() function."

Reviewer: "Perfect, much cleaner now ✅"
[Resolve conversation]
```

**GitHub Suggestions feature:**
```
Reviewer môže navrhnúť kód priamo:

```suggestion
function login(username, password) {
  return authenticate(username, password);
}
```

Author klikne "Commit suggestion" → auto-commit
```

---

### 3.5 Issues a Project Tracking

**GitHub Issues = Task Management**

**Vytvorenie Issue:**
```
Title: User cannot login with email

Labels: bug, priority-high

Description:
## Bug Report

**Expected behavior:**
User should be able to login with email address

**Actual behavior:**
Error message: "Invalid credentials"

**Steps to reproduce:**
1. Go to /login
2. Enter email: user@example.com
3. Enter password: correct_password
4. Click "Login"
5. See error

**Environment:**
- Browser: Chrome 120
- OS: macOS 14

**Screenshots:**
[Attach error screenshot]
```

**Issue Types:**
```
🐛 bug         - Niečo nefunguje
✨ enhancement - Nová funkcionalita
📝 documentation - Docs update
❓ question    - Otázka
🔧 maintenance - Technický dlh
```

**Issue Linking s PR:**
```
V PR description:

Closes #123
Fixes #456
Resolves #789

→ Keď sa PR mergne, issues sa auto-close
```

---

### 3.6 Team Coordination

**Daily Standup s GitHubom:**
```
Včera:
- Merged PR #45 (login feature)
- Reviewed 2 PRs

Dnes:
- Working on Issue #67 (password reset)
- Will create PR by EOD

Blockers:
- Waiting for API documentation (Issue #70)
```

**GitHub Projects (Kanban):**
```
┌──────────┬──────────┬──────────┬──────────┐
│ Backlog  │ To Do    │ In Prog  │ Done     │
├──────────┼──────────┼──────────┼──────────┤
│ Issue#80 │ Issue#67 │ PR#45    │ Issue#45 │
│ Issue#81 │ Issue#68 │ Issue#69 │ PR#44    │
│          │          │          │ Issue#50 │
└──────────┴──────────┴──────────┴──────────┘
```

**Pull Request Templates:**
```
.github/pull_request_template.md:

## Description
<!-- What does this PR do? -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Code reviewed by team
```

---

### ✅ MODUL 3 - Checklist

Po dokončení by si mal vedieť:

```
□ Vysvetliť, čo je Pull Request a prečo sa používa
□ Vytvoriť PR cez GitHub Desktop alebo web
□ Napísať kvalitný PR description
□ Robiť code review iných PR
□ Odpovedať na review komentáre
□ Používať GitHub suggestions
□ Vytvoriť a manažovať Issues
□ Linkovať Issues s PR
□ Používať GitHub Projects pre tracking
```

**Praktické cvičenie:**
1. Vytvor branch `pr-exercise`
2. Pridaj súbor `feature.js` s funkciou
3. Push a vytvor PR
4. V PR description spomeň "Implements #XYZ"
5. Požiadaj kolegu o review
6. Zareaguj na komentáre
7. Mergni po approval

---

## 🔄 MODUL 4: Daily Workflow (1 hodina)

### 4.1 Ranná rutina: Sync s main branch

**Každé ráno pred začatím práce:**

```bash
# GitHub Desktop:
1. Current Branch → main
2. Fetch origin
3. Pull origin (ak sú zmeny)

# Command Line:
git checkout main
git pull origin main
```

**Prečo:**
- Máš najnovší kód
- Vyhneš sa konfliktom
- Vidíš, čo robil team

**Ak máš rozpracovanú feature:**
```bash
# 1. Ulož aktuálnu prácu
git checkout feature/my-feature
git stash save "WIP: morning sync"

# 2. Update main
git checkout main
git pull origin main

# 3. Update feature branch
git checkout feature/my-feature
git rebase main  # alebo: git merge main

# 4. Obnov prácu
git stash pop
```

---

### 4.2 Feature Development Workflow

**Standard flow pre novú feature:**

```
┌─────────────────────────────────────────┐
│ 1. PLÁN (5 min)                         │
│    - Prečítaj Issue/ticket              │
│    - Pochop requirements                │
│    - Naplánuj approach                  │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 2. BRANCH (1 min)                       │
│    git checkout -b feature/ticket-123   │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 3. VÝVOJ (2-4 hodiny)                   │
│    - Implementuj feature                │
│    - Commit každých 30-60 min           │
│    - Push priebežne                     │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 4. TESTING (30 min)                     │
│    - Manual testing                     │
│    - Unit tests                         │
│    - Edge cases                         │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 5. PULL REQUEST (15 min)                │
│    - Vyplň PR template                  │
│    - Pridaj screenshots                 │
│    - Request reviewers                  │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 6. CODE REVIEW (4-24 hodín)             │
│    - Odpovedaj na komentáre             │
│    - Implementuj zmeny                  │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ 7. MERGE (5 min)                        │
│    - Squash merge                       │
│    - Delete branch                      │
└─────────────────────────────────────────┘
```

---

### 4.3 Commit Best Practices

**Conventional Commits (industry standard):**

```
Format:
<type>(<scope>): <description>

[optional body]

[optional footer]

Types:
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Formatting (no code change)
refactor: Code refactoring
test:     Adding tests
chore:    Maintenance
```

**Príklady dobrých commits:**
```
✅ feat(auth): add JWT token validation
✅ fix(login): resolve email validation bug
✅ docs(readme): update installation steps
✅ refactor(api): extract user service
✅ test(auth): add unit tests for login
```

**Príklady zlých commits:**
```
❌ fixed stuff
❌ WIP
❌ asdfasdf
❌ final version (really)
❌ update
```

**Commit message template:**
```
# <type>(<scope>): <short summary>
#   │       │             │
#   │       │             └─> Summary in present tense
#   │       │
#   │       └─> Scope: auth|api|ui|db
#   │
#   └─> Type: feat|fix|docs|style|refactor|test|chore

# Body (optional): More detailed explanation
# - What was changed
# - Why it was changed
# - Any side effects

# Footer (optional):
# Closes #123
# Breaking Change: API endpoint /auth removed
```

---

### 4.4 PR Submission Checklist

**Pred vytvorením PR skontroluj:**

```
Code Quality:
□ Kód je otestovaný (manual + unit tests)
□ Žiadne console.log() / debugger statements
□ Žiadne commented-out code
□ Formátovanie je konzistentné

Commit History:
□ Commity majú zmysluplné messages
□ Žiadne "WIP" commity (alebo squash pred PR)
□ Jeden commit = jedna logická zmena

Documentation:
□ README aktualizované (ak treba)
□ Komentáre v kóde (complex logic)
□ API dokumentácia (ak je API change)

Testing:
□ Všetky existujúce testy prechádzajú
□ Pridané testy pre novú funkcionalitu
□ Edge cases pokryté

Security:
□ Žiadne hardcoded credentials
□ Input validation implementovaná
□ No SQL injection vulnerabilities

PR Description:
□ Jasný title
□ Summary of changes
□ Screenshots (ak UI change)
□ Testing notes
□ Linked issues (Closes #123)
```

---

### 4.5 Productivity Tips

**Skratky v GitHub Desktop:**
```
macOS:
⌘ + T    New branch
⌘ + N    New repository
⌘ + ,    Preferences
⌘ + Enter  Commit
⌘ + P    Push

Windows:
Ctrl + T    New branch
Ctrl + N    New repository
Ctrl + ,    Preferences
Ctrl + Enter  Commit
Ctrl + P    Push
```

**Git Aliases (CLI speedup):**
```bash
# Add to ~/.gitconfig:
[alias]
  st = status
  co = checkout
  ci = commit
  br = branch
  unstage = reset HEAD --
  last = log -1 HEAD
  visual = log --oneline --graph --decorate --all

# Usage:
git st        # git status
git co main   # git checkout main
git ci -m "message"  # git commit -m "message"
```

**VS Code Git Integration:**
```
Extensions:
- GitLens: Git supercharged
- Git History: View git log
- Git Graph: Visual branch graph

Shortcuts:
Ctrl + Shift + G   Git panel
Ctrl + Enter       Commit
Ctrl + Shift + P → Git: Pull
```

---

### ✅ MODUL 4 - Checklist

Po dokončení by si mal vedieť:

```
□ Ranná sync rutina (pull main)
□ Vytvoriť branch pre novú feature
□ Commitovať s best practices messages
□ Pushovať priebežne počas práce
□ Vytvoriť kvalitný Pull Request
□ Používať PR checklist
□ Robiť self-review pred submission
□ Udržiavať clean commit history
```

**Praktické cvičenie:**
1. Ráno: Pull main branch
2. Vytvor branch `daily-workflow-test`
3. Implementuj jednoduchú feature (napr. add function)
4. Commit s Conventional Commit format
5. Push na GitHub
6. Vytvor PR s kompletným description
7. Self-review (skontroluj diff)
8. Mergni (ak si vlastník repo) alebo požiadaj o review

---

## 📊 ZÁVEREČNÉ HODNOTENIE

### Skill Matrix (self-assessment)

```
Ohodnoť sa (1-5) po dokončení kurzu:

Git Fundamentals:
□ Repository concepts (local/remote)        /5
□ Commit workflow                           /5
□ Branching and merging                     /5
□ Understanding conflicts                   /5

GitHub Desktop:
□ UI navigation                             /5
□ Branching operations                      /5
□ Conflict resolution                       /5
□ Push/pull operations                      /5

Collaboration:
□ Creating Pull Requests                    /5
□ Code review (giving)                      /5
□ Code review (receiving)                   /5
□ Issue management                          /5

Daily Workflow:
□ Morning sync routine                      /5
□ Feature development flow                  /5
□ Commit best practices                     /5
□ PR submission quality                     /5

Total Score: ___/80

Interpretation:
60-80: Excellent - Ready for production
40-59: Good - Needs practice
20-39: Basic - Continue learning
0-19:  Beginner - Repeat modules
```

---

### Certification Test (10 otázok)

**1. Čo je to commit?**
- A) Súbor v Git repository
- B) Snapshot projektu v určitom čase
- C) Merge dvoch branches
- D) Push na GitHub

<details>
<summary>Odpoveď</summary>
B - Commit je snapshot (momentka) projektu
</details>

**2. Aký je rozdiel medzi `git pull` a `git fetch`?**
- A) Žiadny rozdiel
- B) `pull` = `fetch` + `merge`
- C) `fetch` je rýchlejší
- D) `pull` funguje len s main branch

<details>
<summary>Odpoveď</summary>
B - Pull stiahne zmeny a aplikuje ich (fetch + merge)
</details>

**3. Prečo používame Pull Requesty?**
- A) Je to povinné v Gite
- B) Pre code review pred merge
- C) Len pre open-source projekty
- D) Na backup kódu

<details>
<summary>Odpoveď</summary>
B - PR umožňuje code review a diskusiu pred merge
</details>

**4. Čo znamená "LGTM" v code review?**
- A) Let's Get This Merged
- B) Looks Good To Me
- C) Large Git Task Manager
- D) Login GitHub Token Manager

<details>
<summary>Odpoveď</summary>
B - "Looks Good To Me" = approval
</details>

**5. Ktorý commit message je najlepší?**
- A) `fix stuff`
- B) `update`
- C) `feat(auth): add JWT token validation`
- D) `asdf`

<details>
<summary>Odpoveď</summary>
C - Conventional Commits format s clear description
</details>

**6. Kedy vzniká merge conflict?**
- A) Vždy pri merge
- B) Keď 2 branches editovali ten istý riadok
- C) Pri push na GitHub
- D) Pri vytvorení branch

<details>
<summary>Odpoveď</summary>
B - Conflict vzniká pri súbežnej editácii rovnakého kódu
</details>

**7. Čo robí `git stash`?**
- A) Deletuje zmeny
- B) Dočasne uloží uncommitted zmeny
- C) Vytvorí nový branch
- D) Push na GitHub

<details>
<summary>Odpoveď</summary>
B - Stash dočasne uschová zmeny (napr. pre sync s main)
</details>

**8. Ako linknúť Issue s PR?**
- A) Nie je to možné
- B) Manuálne v komentári
- C) V PR description: "Closes #123"
- D) Automaticky sa to robí

<details>
<summary>Odpoveď</summary>
C - Keywords ako "Closes #123" auto-linkujú a zatvoria issue
</details>

**9. Čo je to branch protection rule?**
- A) Heslo na branch
- B) Pravidlá pre merge do branch (napr. vyžadovať review)
- C) Automatický backup
- D) GitHub premium feature

<details>
<summary>Odpoveď</summary>
B - Protection rules vynucujú workflow (napr. PR + approval)
</details>

**10. Aký je prvý krok daily workflow?**
- A) Vytvor branch
- B) Commit zmeny
- C) Pull main branch (sync)
- D) Otvor Issue

<details>
<summary>Odpoveď</summary>
C - Vždy začni sync s main (pull)
</details>

**Vyhodnotenie:**
- 9-10: Expert 🌟
- 7-8: Pokročilý ✅
- 5-6: Stredne pokročilý 📚
- 0-4: Zopakuj kurz 🔄

---

## 🎓 Ďalšie kroky po absolvovaní

**Intermediate Level (ďalších 10 hodín učenia):**
```
→ GIT_WORKFLOWS_2025_RESEARCH.md
  - GitHub Flow vs Trunk-based Development
  - Git rebase advanced
  - Cherry-picking commits

→ GITHUB_ACTIONS_README.md
  - CI/CD automation
  - Automated testing
  - Deployment pipelines

→ CODEOWNERS_QUICK_START.md
  - Code ownership
  - Auto-review assignment
```

**Advanced Level (20+ hodín):**
```
→ MONOREPO_WORKFLOWS_2025.md
  - Managing large-scale projects
  - Multi-package repositories

→ SECURITY_ARCHITECTURE_PATTERNS.md
  - Security scanning
  - Dependency management
  - CodeQL analysis

→ LLM_GIT_WORKFLOW_GUIDE_2025.md
  - AI-assisted development
  - Automation scripts
```

---

## 📚 Zdroje a Ďalšie Čítanie

**Oficiálna dokumentácia:**
- Git: https://git-scm.com/doc
- GitHub: https://docs.github.com
- GitHub Desktop: https://docs.github.com/en/desktop

**Interaktívne tutoriály:**
- Learn Git Branching: https://learngitbranching.js.org
- GitHub Learning Lab: https://lab.github.com
- Git Kata: https://github.com/eficode-academy/git-katas

**Videá (YouTube):**
- "Git and GitHub for Beginners" - freeCodeCamp
- "GitHub Desktop Tutorial" - GitHub
- "Pull Request Best Practices" - GitHub

**Knihy:**
- "Pro Git" (free) - Scott Chacon: https://git-scm.com/book
- "GitHub Essentials" - Achilleas Pipinellis

**Komunity:**
- GitHub Community: https://github.community
- Stack Overflow: [git] tag
- Reddit: r/git, r/github

---

## ❓ FAQ - Často kladené otázky

**Q: Musím používať Command Line alebo stačí GitHub Desktop?**
A: GitHub Desktop je úplne dostačujúci pre 90% daily workflow. CLI sa hodí pre pokročilé operácie (rebase, stash, reset).

**Q: Ako často mám commitovať?**
A: Každých 30-60 minút práce, alebo po dokončení logickej časti (napr. jedna funkcia).

**Q: Môžem pushovat nedokončenú prácu?**
A: Áno, pokiaľ je to v tvojom feature branchi (nie v main). Commituj s "WIP:" prefix.

**Q: Čo ak omylom commitnem do main namiesto feature branch?**
A: Použij `git reset HEAD~1` (vráti commit, zachová zmeny) alebo vytvor branch z aktuálneho stavu.

**Q: Kedy používať Squash merge vs Normal merge?**
A: Squash pre feature branches (1 feature = 1 commit v main), Normal pre release branches.

**Q: Ako dlho čakať na code review?**
A: Standard je 24 hodín. Urgentné PR označ "urgent" labelom.

**Q: Môžem mergnúť vlastný PR?**
A: Závisí od team policy. Väčšinou minimálne 1 approval od niekoho iného.

**Q: Čo robiť, ak mám 20+ conflicts?**
A: Najskôr sync s main (pull), potom postupne rieš po súbore. Alebo ask for help.

**Q: Je bezpečné používať force push?**
A: NIE na main/shared branches. Áno na vlastné feature branches (po rebase).

**Q: Ako zmazať branch po merge?**
A: GitHub ho automaticky zmaže (ak je nastavené). Lokálne: `git branch -d branch-name`.

---

## ✅ Absolvent Checklist

```
□ Prešiel som všetky 4 moduly (6.5 hodiny)
□ Dokončil som praktické cvičenia v každom module
□ Prešiel som skill matrix self-assessment
□ Absolvoval som certification test (7+/10)
□ Vytvoril som aspoň 1 Pull Request v reálnom projekte
□ Dostal som approval na svoj PR (od reviewera)
□ Vyriešil som aspoň 1 merge conflict
□ Používam Conventional Commits formát
□ Mám nastavený daily workflow (morning sync)
□ Poznám, kde nájsť advanced dokumentáciu

🎓 Som pripravený pracovať s GitHubom profesionálne!
```

---

## 🏆 Záverečné Slovo

Gratulujeme k dokončeniu **GitHub Essentials Starter Pack**!

**Čo si sa naučil:**
- ✅ Git fundamentals (repository, commit, branch, merge)
- ✅ GitHub Desktop mastery (UI workflow)
- ✅ Collaboration basics (Pull Requests, code review)
- ✅ Daily workflow (productivity routines)

**Čo ďalej:**
1. **Precvič** naučené zručnosti na reálnom projekte
2. **Začni pracovať** s týmom cez Pull Requesty
3. **Študuj** intermediate topics (GitHub Actions, CODEOWNERS)
4. **Automatizuj** repetitívne úlohy (git aliases, scripts)

**Pamätaj:**
> "The best way to learn Git is to use it daily."
> Practice makes perfect. 🚀

---

**Dokument:** GITHUB_ESSENTIALS_STARTER_PACK.md
**Verzia:** 1.0.0
**Dátum:** November 16, 2025
**Autor:** GitHub Workflow Documentation Project
**Časová náročnosť:** 6.5 hodiny
**Úroveň:** Beginner to Confident User

---

**Feedback?** Otvor Issue na projekte alebo navrhni Pull Request s vylepšeniami!

🌟 Happy Git-ing! 🌟
