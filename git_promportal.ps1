# === НАСТРОЙКА ПЕРЕМЕННЫХ ===
$RepoPath  = "C:\Users\Esther\PycharmProjects\promportal\promportal_clean\converted_webp"  # твоя папка с файлами
$UserName  = "Esther"                         # имя автора коммитов
$UserEmail = "mari160588@gmail.com"        # <-- замени на email из GitHub-аккаунта
$RepoUrl   = "https://github.com/EstherrDearr/promportal.git"  # URL репозитория

# === ДАЛЕЕ НИЧЕГО МЕНЯТЬ НЕ НУЖНО ===
chcp 65001 | Out-Null   # UTF-8 в консоли, чтобы не было проблем с кириллицей
Set-Location $RepoPath

# 1) Проверка наличия git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "Git не найден в системе. Установи Git for Windows: https://git-scm.com/download/win"
  exit 1
}

# 2) Настройка user.name / user.email (только если ещё не заданы глобально)
$hasName  = (git config --global user.name)  -ne $null -and (git config --global user.name)  -ne ""
$hasEmail = (git config --global user.email) -ne $null -and (git config --global user.email) -ne ""

if (-not $hasName)  { git config --global user.name  "$UserName"  | Out-Null }
if (-not $hasEmail) { git config --global user.email "$UserEmail" | Out-Null }

Write-Host "Git user: $(git config --global user.name) <$(git config --global user.email)>"

# 3) Инициализация репозитория (если .git ещё нет)
if (-not (Test-Path ".git")) {
  git init | Out-Null
  Write-Host "Инициализирован локальный git-репозиторий."
}

# 4) Переключение на main (создание, если нужно)
git branch -M main 2>$null

# 5) Добавляем/обновляем удалённый origin
$existingOrigin = ""
try { $existingOrigin = git remote get-url origin 2>$null } catch {}
if ($existingOrigin) {
  if ($existingOrigin -ne $RepoUrl) {
    git remote set-url origin $RepoUrl | Out-Null
    Write-Host "Обновлён origin: $RepoUrl"
  } else {
    Write-Host "origin уже настроен: $RepoUrl"
  }
} else {
  git remote add origin $RepoUrl | Out-Null
  Write-Host "Добавлен origin: $RepoUrl"
}

# 6) Добавляем файлы и делаем коммит (если есть что коммитить)
git add -A
$pending = git status --porcelain
if ($pending) {
  git commit -m "initial commit" | Out-Null
  Write-Host "Создан коммит."
} else {
  Write-Host "Нет изменений для коммита — пропускаю commit."
}

# 7) Пушим в GitHub
try {
  git push -u origin main
  Write-Host "✅ Готово: запушено в origin/main."
} catch {
  Write-Host "❗ Если просит логин/пароль: используй GitHub username и Personal Access Token (вместо пароля)."
  Write-Host "Создать PAT: https://github.com/settings/tokens (scopes: repo)."
  throw
}