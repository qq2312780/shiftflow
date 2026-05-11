# Android 签名配置

## 修改 `android/app/build.gradle`

打开 `android/app/build.gradle`，在 `android {}` 块内添加以下内容：

```gradle
android {
    // ... 现有配置保持不变 ...
    
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
}
```

## 本地构建测试（可选）

如果你不想等 GitHub Actions，可以在本地先测试构建：

```bash
# 1. 进入项目目录
cd shiftflow_app

# 2. 获取依赖
flutter pub get

# 3. 本地构建未签名 APK（快速测试）
flutter build apk --release

# 4. 或者构建签名 APK（需要 keystore）
export KEYSTORE_PATH=android/app/keystore.jks
export KEYSTORE_PASSWORD=你的密码
export KEY_ALIAS=shiftflow
export KEY_PASSWORD=你的密码

# 把 keystore 放到 android/app/keystore.jks
flutter build apk --release
```

## 提交到 GitHub 触发部署

```bash
cd shiftflow_app
git add .
git commit -m "feat: ShiftFlow v1.0.0 + CI/CD"
git push origin main
```

push 后 5-8 分钟，访问 http://43.136.34.59:8080 下载 APK。

## 如果构建失败

1. **Flutter 版本不匹配**：workflow 里写的是 `3.24.0`，如果你的本地版本不同，修改 `.github/workflows/deploy.yml` 里的 `flutter-version`
2. **Android SDK 版本**：检查 `pubspec.yaml` 里的 `minSdkVersion` 是否与目标设备兼容
3. **签名失败**：确保 `KEYSTORE_BASE64` 是完整的 base64 编码（用 `base64 -w0` 生成，不要带换行）

## 完整文件检查清单

提交到 GitHub 之前，确认以下文件存在：

```
shiftflow_app/
├── .github/workflows/deploy.yml   ✅ 已生成
├── .gitignore                     ✅ 已生成
├── pubspec.yaml                   ✅ 已生成
├── lib/
│   ├── main.dart                  ✅ 已生成
│   ├── models/                    ✅ 已生成
│   ├── database/                  ✅ 已生成
│   ├── services/                  ✅ 已生成
│   └── screens/                   ✅ 已生成
└── android/app/build.gradle       ⚠️ 需手动修改签名配置
```

## 下载页预览

部署成功后，访问 http://43.136.34.59:8080 会看到：

- 蓝色主题下载页面
- 显示版本号、文件大小、构建时间
- 一键下载 APK 按钮

## 后续迭代

每次代码更新后：

```bash
git add .
git commit -m "update: xxx"
git push origin main
```

Actions 会自动构建并部署新版本。
