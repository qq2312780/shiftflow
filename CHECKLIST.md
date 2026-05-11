# ShiftFlow 发布检查清单

## 当前状态
- [x] Flutter 项目代码已生成
- [x] CI/CD 配置已生成
- [x] 服务器 Nginx 已就绪（http://43.136.34.59:8080）
- [ ] GitHub 仓库待创建
- [ ] Android 签名配置待修改
- [ ] GitHub Secrets 待配置

---

## 接下来每一步

### Step 1：修改 Android 签名配置（必须在提交前完成）

找到 `shiftflow_app/android/app/build.gradle`，在 `android {}` 块内找到 `buildTypes` 并替换为：

```gradle
    signingConfigs {
        release {
            storeFile file(System.getenv("KEYSTORE_PATH") ?: "release-key.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias System.getenv("KEY_ALIAS") ?: ""
            keyPassword System.getenv("KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
```

### Step 2：创建 GitHub 仓库

```bash
cd /path/to/shiftflow_app

git init
git add .
git commit -m "init: ShiftFlow v1.0.0"
git branch -M main

# 去 GitHub 创建空仓库，然后：
git remote add origin https://github.com/你的用户名/shiftflow.git
git push -u origin main
```

### Step 3：生成签名密钥库（Keystore）

**方式 A：有 JDK 的本地机器**
```bash
keytool -genkey -v \
  -keystore shiftflow.keystore \
  -alias shiftflow \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass 你的密码 -keypass 你的密码 \
  -dname "CN=ShiftFlow, OU=App, O=ShiftFlow, L=City, ST=State, C=CN"

# 转 base64（复制输出到 GitHub Secrets）
base64 -w0 shiftflow.keystore
```

**方式 B：在服务器上生成**
```bash
sshpass -p "Qq231247100" ssh ubuntu@43.136.34.59

sudo apt-get install -y openjdk-17-jdk

cd ~ && keytool -genkey -v \
  -keystore shiftflow.keystore \
  -alias shiftflow \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass 你的密码 -keypass 你的密码 \
  -dname "CN=ShiftFlow, OU=App, O=ShiftFlow, L=City, ST=State, C=CN"

cat shiftflow.keystore | base64 -w0
# 复制这串字符
```

### Step 4：配置 GitHub Secrets

进入 https://github.com/你的用户名/shiftflow/settings/secrets/actions

添加以下 6 个 secrets：

| Secret | 值 |
|--------|-----|
| `KEYSTORE_BASE64` | keystore 的 base64 编码（上一步复制的长字符串） |
| `KEYSTORE_PASSWORD` | 你的密钥库密码 |
| `KEY_ALIAS` | `shiftflow` |
| `KEY_PASSWORD` | 你的别名密码 |
| `SERVER_HOST` | `43.136.34.59` |
| `SERVER_USER` | `ubuntu` |
| `SERVER_PASSWORD` | `Qq231247100` |

### Step 5：推送代码触发部署

```bash
cd shiftflow_app
git add .
git commit -m "feat: configure signing + CI/CD"
git push origin main
```

### Step 6：查看构建进度

1. 打开 https://github.com/你的用户名/shiftflow/actions
2. 等待约 5-8 分钟
3. 绿色勾 = 成功，红色叉 = 失败（点进去看日志）

### Step 7：下载 APK

构建成功后，访问：
**http://43.136.34.59:8080**

看到蓝色下载页面，点击"下载 APK"即可。

---

## 常见问题

**Q: Actions 构建失败，提示找不到 Flutter SDK？**
A: 检查 `.github/workflows/deploy.yml` 里的 `flutter-version`，改为你本地的版本号。

**Q: 签名失败？**
A: 检查 `KEYSTORE_BASE64` 是否完整（不能有换行），检查 `KEY_ALIAS` 是否与生成时一致。

**Q: 部署到服务器失败？**
A: 检查 `SERVER_PASSWORD` 是否正确，检查服务器 22 端口是否开放。

**Q: 下载页面能打开但 APK 下载不了？**
A: 检查 `/var/www/apk/` 目录权限：`ssh ubuntu@43.136.34.59 ls -la /var/www/apk/`

---

## 后续迭代

每次更新代码后：

```bash
git add .
git commit -m "update: xxx"
git push origin main
```

Actions 会自动构建新版本并部署。
