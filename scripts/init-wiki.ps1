<#
.SYNOPSIS
    初始化一个新的 obsidian-llm-wiki 知识库 vault。
.DESCRIPTION
    创建目录结构、模板文件、index.md、log.md 和 README.md。
.PARAMETER VaultPath
    vault 根目录路径。
.PARAMETER Topic
    知识库主题名称。
.EXAMPLE
    .\init-wiki.ps1 -VaultPath "C:\MyVault" -Topic "AI学习"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,

    [Parameter(Mandatory=$false)]
    [string]$Topic = "我的知识库"
)

$ErrorActionPreference = "Stop"

# 解析绝对路径
$VaultPath = (Resolve-Path $VaultPath -ErrorAction SilentlyContinue) 2>$null
if (-not $VaultPath) {
    $VaultPath = $PSScriptRoot
    Write-Host "[INFO] 使用脚本所在目录: $VaultPath"
}

# 获取 skill 目录（模板源）
$SkillDir = Split-Path -Parent $PSScriptRoot
$TemplatesDir = Join-Path $SkillDir "templates"

if (-not (Test-Path $TemplatesDir)) {
    Write-Error "模板目录不存在: $TemplatesDir"
    exit 1
}

Write-Host "=== 初始化 obsidian-llm-wiki 知识库 ===" -ForegroundColor Cyan
Write-Host "Vault: $VaultPath"
Write-Host "主题: $Topic"
Write-Host ""

# 创建目录结构
$dirs = @(
    "raw\articles",
    "raw\tweets",
    "raw\wechat",
    "raw\xiaohongshu",
    "raw\zhihu",
    "raw\pdfs",
    "raw\notes\learning",
    "raw\notes\projects",
    "raw\notes\testing",
    "wiki\entities",
    "wiki\topics",
    "wiki\sources",
    "wiki\comparisons",
    "wiki\synthesis",
    "templates"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $VaultPath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "[CREATE] $dir" -ForegroundColor Green
    } else {
        Write-Host "[SKIP ] $dir (已存在)" -ForegroundColor Yellow
    }
}

# 复制模板文件
Write-Host ""
Write-Host "=== 复制模板文件 ===" -ForegroundColor Cyan
$templateFiles = @("entity-template.md", "topic-template.md", "source-template.md")
foreach ($tpl in $templateFiles) {
    $src = Join-Path $TemplatesDir $tpl
    $dst = Join-Path $VaultPath "templates\$tpl"
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "[COPY ] templates\$tpl" -ForegroundColor Green
    }
}

# 创建 README.md
Write-Host ""
Write-Host "=== 创建 README.md ===" -ForegroundColor Cyan
$readmeContent = @"
# $Topic

> 知识库主题：$Topic

## 关于

这是一个基于 [obsidian-llm-wiki](https://github.com/clawhub/obsidian-llm-wiki) 方法论构建的个人知识库。

## 目录结构

- `raw/` — 原始素材（不可变）
- `wiki/` — 编译后的知识（AI 维护）
- `templates/` — 页面模板

## 工作流

- **ingest**：消化素材 → 创建 wiki 页面
- **query**：查询知识库
- **lint**：健康检查
- **digest**：深度综合报告

## 快速开始

1. 把素材文件放入 `raw/` 对应目录
2. 告诉 AI "帮我消化这篇"
3. AI 自动整理到 `wiki/`

_Last updated: $(Get-Date -Format "yyyy-MM-dd")_
"@

$readmePath = Join-Path $VaultPath "README.md"
Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
Write-Host "[CREATE] README.md" -ForegroundColor Green

# 创建 index.md
Write-Host ""
Write-Host "=== 创建 index.md ===" -ForegroundColor Cyan
$date = Get-Date -Format "yyyy-MM-dd"
$indexContent = @"
# 知识库索引

_Last updated: $date_

---

## 实体页

> 人物、组织、概念、工具等

| Page | Summary | Updated |
|------|---------|---------|

---

## 主题页

> 研究主题，知识领域

| Page | Summary | Updated |
|------|---------|---------|

---

## 素材摘要

> 每个消化过的素材都有一篇摘要

| Page | Summary | Updated |
|------|---------|---------|

---

## 对比分析

| Page | Summary | Updated |
|------|---------|---------|

---

## 综合分析

| Page | Summary | Updated |
|------|---------|---------|

"@

$indexPath = Join-Path $VaultPath "index.md"
Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
Write-Host "[CREATE] index.md" -ForegroundColor Green

# 创建 log.md
Write-Host ""
Write-Host "=== 创建 log.md ===" -ForegroundColor Cyan
$logContent = @"
# 操作日志

> 记录知识库的所有变更历史。只追加，不编辑历史条目。

---

## [$date] init | 初始化知识库

Source: init-wiki.ps1
Pages affected: README.md (new), index.md (new), log.md (new), templates/ (created)
"@

$logPath = Join-Path $VaultPath "log.md"
Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "[CREATE] log.md" -ForegroundColor Green

Write-Host ""
Write-Host "=== 初始化完成 ===" -ForegroundColor Cyan
Write-Host "Vault 路径: $VaultPath" -ForegroundColor White
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  1. 用 Obsidian 打开这个文件夹" -ForegroundColor White
Write-Host "  2. 告诉 AI '帮我消化一篇素材'" -ForegroundColor White
Write-Host "  3. AI 会自动整理知识到 wiki/" -ForegroundColor White
