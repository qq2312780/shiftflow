# ShiftFlow CI/CD 部署指南

## 概述
每次 `git push` 到 main 分支，GitHub Actions 自动：
1. 构建签名 APK
2. 部署到你的云服务器
3. 生成下载页面：http://43.136.34.59:8080

## 前提准备

### 1. 创建 GitHub 仓库

```bash
cd shiftflow_app
git init
git add .
git commit -m "init: ShiftFlow v1.0.0"
git branch -M main

# 在 GitHub 上创建空仓库，然后：
git remote add origin https://github.com/你的用户名/shiftflow.git
git push -u origin main
```

### 2. 生成签名密钥库（Keystore）

**方式 A：在本地生成（推荐）**

```bash
# 安装 JDK 后执行
keytool -genkey -v \
  -keystore shiftflow.keystore \
  -alias shiftflow \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass 你的密钥库密码 \
  -keypass 你的别名密码

# 转换为 base64（用于 GitHub Secrets）
base64 -w0 shiftflow.keystore > keystore.base64
# 复制 keystore.base64 的内容到 GitHub Secrets
```

**方式 B：在服务器上生成（如果本地没有 JDK）**

```bash
sshpass -p "Qq231247100" ssh ubuntu@43.136.34.59

# 安装 JDK
sudo apt-get update && sudo apt-get install -y openjdk-17-jdk

# 生成 keystore
cd ~ && keytool -genkey -v \
  -keystore shiftflow.keystore \
  -alias shiftflow \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass 你的密码 \
  -keypass 你的密码 \
  -dname "CN=ShiftFlow, OU=App, O=ShiftFlow, L=City, ST=State, C=CN"

# 输出 base64
cat shiftflow.keystore | base64 -w0
cat shiftflow.keystore | base64 -w0 > keystore.b64
```

### 3. 配置 GitHub Secrets

进入 GitHub 仓库 → Settings → Secrets and variables → Actions → New repository secret

添加以下 secrets：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `KEYSTORE_BASE64` | `cat shiftflow.keystore \| base64 -w0` 的输出 | 密钥库文件的 base64 编码 |
| `KEYSTORE_PASSWORD` | 你设置的密钥库密码 | 密钥库密码 |
| `KEY_ALIAS` | `shiftflow` | 密钥别名 |
| `KEY_PASSWORD` | 你设置的别名密码 | 别名密码 |
| `SERVER_HOST` | `43.136.34.59` | 服务器 IP |
| `SERVER_USER` | `ubuntu` | 服务器用户名 |
| `SERVER_PASSWORD` | `Qq231247100` | 服务器密码 |

## 触发部署

### 方式 1：推送代码

```bash
git add .
git commit -m "update: xxx功能"
git push origin main
```

GitHub Actions 会自动运行，约 5-8 分钟后完成。

### 方式 2：手动触发

进入 GitHub 仓库 → Actions → Build & Deploy Flutter APK → Run workflow

## 查看部署结果

- **下载页面**：http://43.136.34.59:8080
- **Actions 日志**：GitHub 仓库 → Actions 标签页
- **APK 文件**：服务器 `/var/www/apk/`

## 更新应用版本

修改 `pubspec.yaml` 中的 `version`：

```yaml
version: 1.1.0+2  # 版本号+构建号
```

或直接通过 GitHub Actions 的 `--build-name` 参数自动生成。

## 故障排查

### Actions 构建失败

1. 检查 `pubspec.yaml` 格式是否正确
2. 检查 `android/app/build.gradle` 中的签名配置是否引用环境变量

### 部署到服务器失败

1. 检查 `SERVER_HOST`、`SERVER_USER`、`SERVER_PASSWORD` 是否正确
2. 检查服务器 8080 端口是否开放（腾讯云安全组）
3. SSH 到服务器确认目录权限：`ls -la /var/www/apk/`

### APK 安装失败

1. 确保 Android 设置 → 安全 → 允许未知来源安装
2. 检查 APK 签名是否正确（未签名 APK 无法安装）

## 安全建议

1. **不要**把 keystore 文件提交到 GitHub（已添加到 `.gitignore`）
2. 定期更换服务器密码
3. 考虑用 SSH 密钥代替密码登录（更安全）
4. 可以考虑在 Nginx 前加 Cloudflare，隐藏真实 IP

## 文件位置速查

| 文件 | 位置 | 用途 |
|------|------|------|
| Workflow | `.github/workflows/deploy.yml` | GitHub Actions 配置 |
| APK 下载页 | `/var/www/apk/index.html` | 服务器上的下载页面 |
| APK 文件 | `/var/www/apk/shiftflow-*.apk` | 部署的 APK |
| Nginx 配置 | Docker 容器内 | 由 `nginx:alpine` 提供 |
