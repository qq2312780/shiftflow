# ShiftFlow - 手机端 GitHub Actions 部署指南

## 你已拿到的密钥（先复制保存）

**KEYSTORE_BASE64**（复制这整段，等下粘贴到 GitHub）：

```
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
```

密码：
- **KEYSTORE_PASSWORD**: `ShiftFlow2024`
- **KEY_ALIAS**: `shiftflow`
- **KEY_PASSWORD**: `ShiftFlow2024`

---

## 手机上操作（全程浏览器，不需要电脑）

### Step 1：注册 GitHub

1. 手机浏览器打开 https://github.com
2. 点 "Sign up" 注册（邮箱验证在手机上完成）
3. 登录后记住你的用户名（如 `zhangsan123`）

### Step 2：创建仓库

1. 登录后点右上角 `+` → "New repository"
2. 仓库名填：`shiftflow`
3. 选 "Public"（公开，免费）
4. 点 "Create repository"

### Step 3：上传项目文件

GitHub 手机网页版可以直接上传文件夹：

1. 进入刚创建的仓库页面
2. 点 "Add file" → "Upload files"
3. 点 "choose your files"
4. **关键操作**：在手机的文件管理器里先下载项目 zip：
   - 访问 `http://43.136.34.59:8080/shiftflow_app.zip`
   - 下载后解压到某个文件夹
5. 回到 GitHub 上传界面，**全选解压后的所有文件和文件夹**
6. 点 "Commit changes"

> 如果手机浏览器不支持多文件夹上传，用下面这个更简单的方法：
> 1. 在仓库页面按 **`.`** 键（或访问 `https://github.dev/你的用户名/shiftflow`）
> 2. 这会打开 VS Code 网页版
> 3. 在左侧文件树右键 → "New Folder" / "New File"
> 4. 逐个创建文件并粘贴内容（需要的内容我发给你）

### Step 4：配置 Secrets（最关键）

1. 在仓库页面点 "Settings"（最下面那个齿轮图标）
2. 左侧菜单找到 "Secrets and variables" → "Actions"
3. 点 "New repository secret"
4. 逐个添加以下 7 个 secret：

| Name | Value |
|------|-------|
| `KEYSTORE_BASE64` | 上面那整段 base64 字符串 |
| `KEYSTORE_PASSWORD` | `ShiftFlow2024` |
| `KEY_ALIAS` | `shiftflow` |
| `KEY_PASSWORD` | `ShiftFlow2024` |
| `SERVER_HOST` | `43.136.34.59` |
| `SERVER_USER` | `ubuntu` |
| `SERVER_PASSWORD` | `Qq231247100` |

### Step 5：触发构建

1. 回到仓库主页
2. 随便改点东西（比如编辑 README.md 加个空格）
3. 点 "Commit changes"
4. 等待 5-8 分钟

### Step 6：下载 APK

1. 手机浏览器访问 `http://43.136.34.59:8080`
2. 看到蓝色下载页面
3. 点 "下载 APK" 安装

---

## 如果上传文件太麻烦

直接告诉我你的 **GitHub 用户名**，我可以把代码文件内容发给你，你复制粘贴到 GitHub 的在线编辑器里。

或者，如果你有 **Personal Access Token**（在 GitHub Settings → Developer settings → Personal access tokens → Tokens (classic) 里生成，勾选 `repo` 权限），把 Token 发给我，我直接帮你 push 代码。
