# ShiftFlow

纯本地 Flutter 排班表 App，零后端、零服务器成本。

## 核心功能

- **班次库**：自定义班次名称、起止时间、颜色、薪资倍率
- **月历视图**：日期格子内显示班次色块，一目了然
- **排班操作**：点击日期 → 选择班次，拖拽式换班
- **循环排班**：按周/月模板一键生成未来排班
- **工时统计**：当月总工时、预估薪资
- **本地存储**：SQLite 存储，数据完全本地，可导出备份
- **提醒通知**：班次开始前自动推送

## 技术栈

- Flutter 3.x
- SQLite (sqflite)
- flutter_local_notifications
- intl (日期格式化)

## 运行

```bash
cd shiftflow_app
flutter pub get
flutter run
```

## 构建

```bash
# iOS
flutter build ios

# Android
flutter build apk --release
```

## 文件结构

```
lib/
├── main.dart                 # 入口
├── models/
│   ├── shift.dart            # 班次类型模型
│   └── schedule.dart         # 排班记录模型
├── database/
│   └── db_helper.dart        # SQLite 数据库操作
├── screens/
│   ├── home_screen.dart      # 月历主页面
│   ├── shift_library.dart    # 班次库管理
│   ├── statistics_screen.dart # 统计页面
│   ├── shift_detail.dart     # 排班详情/编辑
│   └── loop_setting.dart     # 循环排班设置
└── services/
    └── notification_service.dart # 本地通知
```
