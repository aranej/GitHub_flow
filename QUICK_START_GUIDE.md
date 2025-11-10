# ⚡ QUICK START GUIDE - GitHub Workflow 2025

> **15 minút čítania → 30 minút praktického cvičenia → Okamžite produktívny**

---

## 🎯 Čo sa naučíš

Po absolvovaní tohto Quick Start Guide budeš vedieť:
- ✅ Základné Git operácie (clone, commit, push, pull)
- ✅ Pracovať s GitHub Desktop efektívne
- ✅ Vytvoriť a mergnúť svoj prvý Pull Request
- ✅ Nastaviť si základnú CI/CD s GitHub Actions
- ✅ Používať daily workflow ako profesionál

**Časová náročnosť:**
- Čítanie: 15 minút
- Praktické cvičenie: 30 minút
- **Celkom: 45 minút → Produktívna práca**

---

## 📋 PREDPOKLADY

Pred začatím potrebuješ:
- [x] GitHub účet (vytvor na github.com)
- [x] Nainštalovaný GitHub Desktop (github.com/desktop)
- [x] Text editor (VS Code odporúčaný - code.visualstudio.com)
- [x] 45 minút času bez rušenia

**Voliteľné ale odporúčané:**
- [ ] Git CLI nainštalované (git-scm.com)
- [ ] Terminal emulator (iTerm2/Windows Terminal)

---

## 🚀 ČASŤ 1: ZÁKLADNÉ GIT OPERÁCIE (10 minút)

### Čo je Git a GitHub?

**Git** = Verziovací systém (trackuje zmeny v kóde)
**GitHub** = Cloudová platforma pre Git (zdieľanie, collaboration)

**Analógia:**
- Git = Word s "Track Changes"
- GitHub = Google Docs (zdieľanie, komentáre, collaboration)

### Kľúčové Koncepty (musíš vedieť)

**1. Repository (repo)**
- Projekt s históriou zmien
- Ako "project folder" + všetky jeho verzie

**2. Commit**
- Snapshot projektu v určitom čase
- "Save point" ako vo videohre

**3. Branch**
- Paralelná verzia projektu
- Ako "separate timeline" pre experimenty

**4. Merge**
- Spojenie dvoch branches
- Ako "combine changes" z rôznych verzií

**5. Pull Request (PR)**
- Návrh na merge zmien
- Ako "code review request" pred spojením

---

### Základný Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│  GITHUB (remote)                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  origin/main ◄─────────────────── PUSH          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                      │
                   CLONE (raz na začiatku)
                   PULL (denne sync)
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  TVOJ POČÍTAČ (local)                                   │
│  ┌──────────────────────────────────────────────────┐  │
│  │  main                                            │  │
│  │  ├─ commit 1  (snapshot)                         │  │
│  │  ├─ commit 2  (snapshot)                         │  │
│  │  └─ commit 3  (snapshot)                         │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 🖥️ ČASŤ 2: GITHUB DESKTOP SETUP (5 minút)

### Krok 1: Inštalácia a prihlásenie

1. **Stiahni GitHub Desktop**
   - Choď na: https://desktop.github.com
   - Download pre tvoj OS (Windows/Mac)
   - Nainštaluj (next, next, finish)

2. **Prihlás sa**
   - Otvor GitHub Desktop
   - File → Options → Accounts → Sign In
   - Autorizuj vo webovom prehliadači

3. **Konfigurácia**
   ```
   File → Options → Git
   - Name: Tvoje meno
   - Email: tvoj.github@email.com (musí byť rovnaký ako na GitHube!)
   ```

**Overenie:** Ak vidíš "Signed in as YourUsername" → máš hotovo ✅

---

### Krok 2: Naklonuj svoj prvý repository

**Metóda A: Klonuj existujúci projekt**

```
1. GitHub Desktop → File → Clone Repository
2. Vyber repository zo zoznamu
   (alebo zadaj URL: https://github.com/username/repo)
3. Vyber lokálnu cestu (kde uložiť)
4. Click "Clone"
```

**Metóda B: Vytvor nový projekt**

```
1. GitHub Desktop → File → New Repository
2. Zadaj:
   - Name: moj-prvy-projekt
   - Description: Learning GitHub
   - Local Path: C:\Users\Me\GitHub (alebo ~/GitHub na Mac)
   - Initialize with README: ✅
   - Git Ignore: None
   - License: MIT
3. Click "Create Repository"
4. Click "Publish Repository" (odošle na GitHub)
```

**Cvičenie:**
```bash
Vytvor nový repository "quick-start-practice"
Publish to GitHub
Otvor v editore (Repository → Open in Visual Studio Code)
```

---

## 📝 ČASŤ 3: TVOJ PRVÝ COMMIT (5 minút)

### Scenario: Pridaj súbor README.md

**Krok 1: Vytvor súbor**
```
1. Otvor projekt vo VS Code
2. Vytvor nový súbor: README.md
3. Napíš:
```

```markdown
# Môj Prvý GitHub Projekt

Učím sa pracovať s GitHubom!

## Čo som sa naučil
- Vytvoriť repository
- Spraviť commit
- Pushnúť zmeny na GitHub
```

**Krok 2: Ulož súbor** (CTRL+S / CMD+S)

**Krok 3: Commit v GitHub Desktop**

```
1. Prepni sa na GitHub Desktop
2. Uvidíš zmeny v ľavom paneli:
   - README.md (nový súbor)

3. V dolnej časti:
   - Summary: "Add README file"
   - Description: "Initial project documentation"

4. Click "Commit to main"
```

**Krok 4: Push na GitHub**

```
1. Click "Push origin" (hore vpravo)
2. Otvor GitHub.com
3. Choď na tvoj repository
4. Uvidíš nový README! ✅
```

**Čo sa stalo:**
```
Local: Vytvoril si súbor → Commitol → Pushol
GitHub: Prijal zmeny → Uložil → Zobrazil
```

---

## 🌿 ČASŤ 4: BRANCHING & PULL REQUESTS (10 minút)

### Prečo Branches?

**Bez branches:**
```
main: ──●──●──●──●──●─> (všetky zmeny priamo)
         💥 Problém: Nedokončená práca blokuje ostatných
```

**S branches:**
```
main:         ──●────────●─────> (stabilná verzia)
                 \      /
feature:          ●──●──●  (experimenty samostatne)
```

---

### Vytvorenie Feature Branch

**Scenario:** Pridáš novú sekciu do README

**Krok 1: Vytvor branch**
```
GitHub Desktop:
1. Current Branch → New Branch
2. Name: "add-features-section"
3. Create Branch
```

**Krok 2: Urob zmeny**
```
Otvor README.md
Pridaj na koniec:

## Features
- GitHub Desktop workflow
- Commit best practices
- Pull Request collaboration
```

**Krok 3: Commit na branch**
```
GitHub Desktop:
1. Vidíš zmeny v README.md
2. Summary: "Add features section"
3. Commit to add-features-section
4. Push origin
```

**Krok 4: Vytvor Pull Request**
```
GitHub Desktop:
1. Branch → Create Pull Request
2. Otvorí sa GitHub.com

Alebo na GitHub.com:
1. Choď na repository
2. Uvidíš: "add-features-section had recent pushes"
3. Click "Compare & pull request"

Vyplň PR:
- Title: "Add features section to README"
- Description:
  ```
  This PR adds a features section to README to document
  what this project demonstrates.

  - Added Features section
  - Listed key learnings
  ```

4. Click "Create pull request"
```

**Krok 5: Merge PR**
```
1. Skontroluj zmeny (Files changed tab)
2. Click "Merge pull request"
3. Click "Confirm merge"
4. Click "Delete branch" (cleanup)
```

**Krok 6: Sync local main**
```
GitHub Desktop:
1. Current Branch → main
2. Click "Fetch origin"
3. Click "Pull origin"
4. Tvoj local main má teraz zmeny z PR! ✅
```

---

## ⚙️ ČASŤ 5: ZÁKLADNÁ CI/CD S GITHUB ACTIONS (10 minút)

### Čo je CI/CD?

**CI/CD** = Continuous Integration / Continuous Deployment
**V praxi:** Automatické testovanie a deploying pri každom pushu

**Príklad workflow:**
```
Push kód → GitHub Actions:
  1. Stiahne kód
  2. Nainštaluje dependencies
  3. Spustí testy
  4. Ak OK → môže deployovať
  5. Ak FAIL → pošle notifikáciu
```

---

### Tvoj Prvý GitHub Actions Workflow

**Krok 1: Vytvor workflow súbor**

```bash
1. Vo VS Code vytvor:
   .github/workflows/welcome.yml

2. Štruktúra:
   project/
   ├── .github/
   │   └── workflows/
   │       └── welcome.yml
   └── README.md
```

**Krok 2: Pridaj tento kód**

```yaml
name: Welcome Workflow

# Kedy sa spustí
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

# Čo sa vykoná
jobs:
  welcome:
    runs-on: ubuntu-latest

    steps:
      # Krok 1: Stiahni kód
      - name: Checkout code
        uses: actions/checkout@v4

      # Krok 2: Zobraz uvítanie
      - name: Welcome message
        run: |
          echo "🎉 Welcome to GitHub Actions!"
          echo "This workflow runs on every push to main"
          echo "Repository: ${{ github.repository }}"
          echo "Triggered by: ${{ github.actor }}"

      # Krok 3: Zoznam súborov
      - name: List files
        run: |
          echo "📁 Files in repository:"
          ls -la
```

**Krok 3: Commit a push**

```
GitHub Desktop:
1. Summary: "Add GitHub Actions workflow"
2. Commit to main
3. Push origin
```

**Krok 4: Sleduj execution**

```
GitHub.com:
1. Choď na repository
2. Klikni na "Actions" tab
3. Uvidíš: "Welcome Workflow" running
4. Click na workflow
5. Click na "welcome" job
6. Sleduj každý krok v real-time!
```

**Výstup by mal vyzerať:**
```
✅ Checkout code
✅ Welcome message
   🎉 Welcome to GitHub Actions!
   This workflow runs on every push to main
   Repository: username/quick-start-practice
   Triggered by: username
✅ List files
   📁 Files in repository:
   - .github/workflows/welcome.yml
   - README.md
```

---

## 🔄 ČASŤ 6: DENNÝ WORKFLOW (Praktické)

### Ranná Rutina (5 minút)

```bash
1. Otvor GitHub Desktop
2. Current Branch → main
3. Fetch origin (stiahni updates z GitHubu)
4. Pull origin (sync local s remote)
```

**Prečo:** Začínaš s najnovšou verziou kódu

---

### Development Cycle (Opakovanie)

```
1. VYTVOR BRANCH
   └─ Feature branch pre každú úlohu

2. UROB ZMENY
   └─ Edituj kód, pridávaj súbory

3. COMMIT ČASTO
   └─ Každých 30-60 minút práce

4. PUSH NA GITHUB
   └─ Backup + zdieľanie progress

5. VYTVOR PR KEĎ HOTOVO
   └─ Code review pred mergom

6. MERGE A CLEANUP
   └─ Spoj do main, vymaž branch
```

---

### Commit Message Best Practices

**Zlé príklady:**
```
❌ "fixed stuff"
❌ "changes"
❌ "update"
❌ "asdfasdf"
```

**Dobré príklady:**
```
✅ "Add login form validation"
✅ "Fix bug in user authentication"
✅ "Update README with installation steps"
✅ "Refactor database connection logic"
```

**Formát:**
```
<type>: <short description>

Optional longer description explaining WHY
```

**Typy:**
- **feat:** Nová funkcionalita
- **fix:** Oprava bugu
- **docs:** Dokumentácia
- **style:** Formátovanie (nie zmena logiky)
- **refactor:** Refaktoring kódu
- **test:** Pridanie testov
- **chore:** Build/dependency update

**Príklad:**
```
feat: Add user profile page

Created a new profile page that displays user information
including avatar, bio, and recent activity. Includes edit
functionality for authenticated users.
```

---

## 🎓 CHECKPOINT: ČO SI SA NAUČIL

Po dokončení tohto Quick Start Guide vieš:

### Git Basics ✅
- [x] Čo je repository, commit, branch, merge
- [x] Ako funguje Git verziovanie
- [x] Rozdiel medzi local a remote

### GitHub Desktop ✅
- [x] Inštalácia a setup
- [x] Klonování repository
- [x] Robenie commitov
- [x] Push a pull operácie

### Branching ✅
- [x] Vytvorenie feature branch
- [x] Práca na samostatnom branch
- [x] Pull Request workflow
- [x] Merge a cleanup

### CI/CD Basics ✅
- [x] Čo je GitHub Actions
- [x] Vytvorenie workflow súboru
- [x] Monitoring workflow runs
- [x] Základná automatizácia

### Daily Workflow ✅
- [x] Ranná sync rutina
- [x] Development cycle
- [x] Commit best practices
- [x] PR creation a merge

---

## 🚀 ĎALŠIE KROKY

### Immediate (Dnes)

1. **Praktické cvičenie:**
   ```
   1. Vytvor nový repository "github-practice"
   2. Pridaj 3 súbory (README, index.html, style.css)
   3. Vytvor 2 branches (feature/header, feature/footer)
   4. Sprav PR z každého branchu
   5. Mergni oba PRs
   ```

2. **Setup pre reálnu prácu:**
   ```
   1. Naklonuj tvoj pracovný projekt
   2. Vytvor svoj prvý feature branch
   3. Sprav test commit
   4. Pushni a vytvor draft PR
   ```

---

### This Week (Tento týždeň)

3. **Nauč sa viac:**
   ```
   → GITHUB_ESSENTIALS_STARTER_PACK.md (6.5 hodín)
      - Hlbšie Git fundamentals
      - GitHub Desktop mastery
      - Collaboration best practices
   ```

4. **Implementuj automation:**
   ```
   → github-actions-templates.yml
      - Real CI/CD workflow
      - Automated testing
      - Deployment automation
   ```

---

### This Month (Tento mesiac)

5. **Pokročilé workflow:**
   ```
   → WORKFLOW_DECISION_MATRIX.md
      - Výber správneho workflow pre tím
      - Migration na Trunk-based development
   ```

6. **Optimalizácia:**
   ```
   → GITHUB_ACTIONS_OPTIMIZATION_2025.md
      - Caching (60-80% rýchlejšie builds)
      - Cost optimization (80-90% úspora)
   ```

---

## 🆘 TROUBLESHOOTING

### Problém: "Permission denied (publickey)"

**Riešenie:**
```
1. GitHub Desktop → File → Options → Accounts
2. Sign Out
3. Sign In again
4. Authorize in browser
```

---

### Problém: "Changes not showing in GitHub Desktop"

**Riešenie:**
```
1. Ulož súbor v editore (CTRL+S)
2. GitHub Desktop → Repository → Refresh
3. Uisti sa, že si v správnom repository
```

---

### Problém: "Merge conflict"

**Riešenie:**
```
1. GitHub Desktop ukáže konfliktné súbory
2. Click "Open in Visual Studio Code"
3. VS Code zobrazí conflict markers:
   <<<<<<< HEAD
   tvoja verzia
   =======
   iná verzia
   >>>>>>> branch-name
4. Vyber správnu verziu (alebo zkombinuj)
5. Vymaž conflict markers (<<<<, ====, >>>>)
6. Ulož súbor
7. GitHub Desktop: Commit merge
```

---

### Problém: "Can't push to main"

**Riešenie:**
```
Likely: Branch protection enabled
Fix:
1. Vytvor feature branch
2. Push changes tam
3. Vytvor Pull Request
4. Mergni cez PR
```

---

## 📚 ĎALŠIE RESOURCES

### Official Docs
- GitHub Desktop: https://docs.github.com/en/desktop
- GitHub Actions: https://docs.github.com/en/actions
- Git Basics: https://git-scm.com/book/en/v2

### V tomto balíku
- **Master Index:** `MASTER_INDEX.md` - Kompletná navigácia
- **Starter Pack:** `GITHUB_ESSENTIALS_STARTER_PACK.md` - Hlbšie základy
- **Implementation:** `IMPLEMENTATION_ROADMAP.md` - 8-week plan

### Video Tutorials (Recommended)
- GitHub Desktop Intro (YouTube)
- Git & GitHub Crash Course
- GitHub Actions Tutorial

---

## ✅ FINAL CHECKLIST

Pred tým, ako pokračuješ ďalej, over si:

- [x] Mám GitHub účet
- [x] Nainštalovaný GitHub Desktop
- [x] Vytvoril som test repository
- [x] Spravil som aspoň 3 commits
- [x] Vytvoril som aspoň 1 branch
- [x] Mergnul som aspoň 1 Pull Request
- [x] Spustil sa mi GitHub Actions workflow
- [x] Rozumiem daily workflow cycle
- [x] Viem kde nájsť help (MASTER_INDEX.md)

**Ak máš všetko ✅ → Si pripravený na reálnu prácu!**

---

## 🎯 NEXT: GITHUB ESSENTIALS STARTER PACK

Ak chceš ísť hlbšie (odporúčané):
→ `GITHUB_ESSENTIALS_STARTER_PACK.md`

**Obsahuje:**
- Git fundamentals (2 hod)
- GitHub Desktop mastery (1.5 hod)
- Collaboration basics (2 hod)
- Daily workflow (1 hod)

**Celkom:** 6.5 hodín → Profesionálna úroveň

---

**Gratulujeme! Dokončil si Quick Start Guide.** 🎉

Teraz vieš pracovať s GitHubom ako profesionál. Pokračuj na ďalšie moduly alebo začni používať GitHub vo svojich projektoch!

---

*Posledná aktualizácia: November 2025 | Verzia: 1.0.0*
