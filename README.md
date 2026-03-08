# OCR App

Flutter OCR Android 应用 - 离线文字识别工具

## 功能特性

- 📷 **拍照识别**：使用相机拍摄文档进行OCR识别
- 🖼️ **相册选择**：从相册选择图片进行识别
- 🔍 **离线识别**：无需网络，本地RapidOCR引擎识别
- ✏️ **结果编辑**：识别结果可编辑修改
- 💾 **本地存储**：SQLite存储识别历史
- 📋 **一键复制**：快速复制识别结果
- 📱 **自适应图标**：Material Design 3 设计风格

## 技术栈

- **框架**: Flutter 3.x
- **OCR引擎**: RapidOCR v1.3.0 (基于PaddleOCR + ONNX Runtime)
- **数据库**: SQLite (sqflite)
- **状态管理**: Provider
- **相机**: camera + image_picker

## 项目结构

```
ocr_app/
├── android/
│   ├── app/
│   │   ├── libs/
│   │   │   └── OcrLibrary-1.3.0-release.aar  # RapidOCR库（含模型）
│   │   ├── src/main/kotlin/com/ocr/app/
│   │   │   └── MainActivity.kt               # Platform Channel桥接
│   │   └── src/main/res/                    # 图标和启动页资源
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── app.dart                  # 应用配置
│   ├── models/
│   │   ├── ocr_record.dart      # OCR记录模型
│   │   └── ocr_result.dart      # OCR结果模型
│   ├── services/
│   │   ├── database_service.dart # SQLite数据库服务
│   │   ├── image_service.dart    # 图片处理服务
│   │   └── ocr_service.dart      # OCR识别服务（含内存管理）
│   ├── screens/
│   │   ├── home_screen.dart      # 主页（拍照/相册入口）
│   │   ├── camera_screen.dart    # 相机页面
│   │   ├── result_screen.dart    # 识别结果展示
│   │   └── history_screen.dart   # 历史记录
│   ├── widgets/
│   │   ├── ocr_result_editor.dart
│   │   └── record_list_tile.dart
│   ├── providers/
│   │   └── ocr_provider.dart    # 状态管理
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── test/                         # 单元测试
└── pubspec.yaml
```

## 环境要求

| 组件 | 版本要求 |
|------|----------|
| Flutter SDK | 3.0+ |
| Dart SDK | 3.0+ |
| Android SDK | 36 (compileSdk) |
| Android minSdk | 21+ |
| JDK | 21 |
| Kotlin | 2.0.21 |
| Gradle | 8.11.1+ |
| Android Gradle Plugin | 8.9.1 |

## 快速开始

### 1. 安装依赖

```bash
cd ocr_app
flutter pub get
```

### 2. 运行应用

```bash
flutter run
```

### 3. 构建发布版APK

```bash
flutter build apk --release
```

APK文件将生成在 `build/app/outputs/apk/release/app-release.apk`

## OCR引擎说明

### AAR文件内容

`OcrLibrary-1.3.0-release.aar` 包含：
- OCR引擎原生库 (`libRapidOcr.so`)
- ONNX Runtime (`libonnxruntime.so`)
- 预训练模型文件（内置于assets）
  - `ch_PP-OCRv3_det_infer.onnx` - 文本检测模型
  - `ch_PP-OCRv3_rec_infer.onnx` - 文本识别模型
  - `ch_ppocr_mobile_v2.0_cls_infer.onnx` - 文本方向分类
  - `ppocr_keys_v1.txt` - 字符字典

### 支持的CPU架构
- arm64-v8a (推荐)
- armeabi-v7a

### 内存管理优化

为防止多次识别后出现乱码，已实现以下优化：
- **Bitmap回收**: 每次识别后立即回收Bitmap内存
- **引擎重置**: 每10次识别自动重置OCR引擎
- **错误恢复**: 识别失败时自动重置状态
- **垃圾回收**: 释放引擎时触发GC

## 权限说明

| 权限 | 用途 |
|------|------|
| `CAMERA` | 相机拍照 |
| `READ_EXTERNAL_STORAGE` | 读取存储（Android 12及以下） |
| `READ_MEDIA_IMAGES` | 读取图片（Android 13+） |
| `WRITE_EXTERNAL_STORAGE` | 写入存储（Android 9及以下） |

## Platform Channel API

### 初始化OCR引擎
```dart
await MethodChannel('com.ocr.app/rapidocr').invokeMethod('initialize');
```

### 识别图片
```dart
final result = await MethodChannel('com.ocr.app/rapidocr').invokeMethod(
  'recognizeText',
  {'imagePath': imagePath},
);
```

### 返回格式
```json
{
  "text": "识别的文字内容",
  "confidence": 0.95,
  "blocks": [
    {
      "text": "文本块",
      "confidence": 0.98,
      "boundingBox": {
        "left": 10,
        "top": 20,
        "right": 100,
        "bottom": 50
      }
    }
  ],
  "detectTime": 150.0
}
```

## 数据库结构

```sql
CREATE TABLE ocr_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,
  original_text TEXT,
  edited_text TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 应用图标

使用 Material Design 自适应图标设计：
- **背景**: 蓝色渐变 (#1976D2)
- **前景**: 白色文档 + 蓝色扫描线 + 放大镜图标
- **启动页**: 白色背景 + 居中图标

## 致谢

- [RapidOCR](https://github.com/RapidAI/RapidOcrAndroidOnnx) - OCR引擎
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) - 模型来源
- [ONNX Runtime](https://github.com/microsoft/onnxruntime) - 推理引擎

## 许可证

[Apache License 2.0](LICENSE)

本项目采用 Apache License 2.0 许可证，详情请参阅 [LICENSE](LICENSE) 文件。
