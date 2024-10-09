# Pindot
> Pin your Dot : 锁定重点！

![GitHub Release](https://img.shields.io/github/v/release/PingziDev/Pindot)	![GitHub License](https://img.shields.io/github/license/PingziDev/Pindot)	![GitHub contributors](https://img.shields.io/github/contributors/PingziDev/Pindot)	![GitHub last commit](https://img.shields.io/github/last-commit/PingziDev/Pindot)	![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/PingziDev/Pindot/total)	


欢迎来到 **Pindot**，一个 **轻量、易上手、可插拔组件化、持续维护、中文友好** 的游戏开发框架！基于 **Godot 4**，为开发者提供通用解决方案，帮助你跳过基础的繁琐功能，专注于游戏开发的核心！

不积跬步，无以至千里。用 **Pindot** 开启你的游戏创作之旅！

## 🌟 项目特点

- **组件化开发**：基于Entity+Component模式，像搭积木一样构建游戏功能。
- **轻量化设计**：简洁代码，减少冗余，实现高效开发。
- **易上手**：封装常用功能，降低门槛，让开发者专注游戏逻辑。
- **实用性强**：经过实际项目测试，解决开发中的常见痛点。
- **持续更新**：与Godot保持同步，确保框架始终兼容最新版本。
- **中文友好**：全面支持中文环境，文档和接口贴近中文开发者习惯。

## 🚀 功能一览

- **游戏管理（Game）**：全局控制游戏进度、速度、难度等。
- **场景管理（Scene）**：随时加载、卸载和切换多个游戏场景。
- **数据管理（Data）**：处理游戏的存档与读档，管理动态产生的游戏数据。
- **资源管理（Resource）**：高效管理资源加载，支持同步与异步模式，优化内存使用。
- **实体管理（Entity）**：动态创建、显示、隐藏、销毁游戏对象。
- **输入处理（Input）**：统一管理键盘、鼠标、手柄等输入设备的控制。
- **事件系统（Event）**：解耦事件与响应逻辑，提供事件管理和触发机制。
- **界面管理（UI）**：处理游戏中的用户界面元素，提供流畅的交互体验。
- **音效管理（Sound）**：控制背景音乐和音效，创造沉浸式体验。
- **[调制工具](docs/LOG.md)（Debug）**：提供开发调试工具，便于问题排查与优化。 []

## 📂 目录结构

```bash
.
├── addons/
│   └── pingdot/    # pingdot 框架根目录
│       ├── game/       # 游戏控制
│       ├── scene/      # 场景管理
│       ├── data/       # 数据管理
│       ├── resource/   # 资源管理
│       ├── entity/     # 实体管理
│       ├── input/      # 输入管理
│       ├── event/      # 事件管理
│       ├── ui/         # 界面管理
│       ├── sound/      # 声音管理
│       ├── debug/      # 调试工具
│       ├── plugin.cfg  # 插件配置文件
└── README.md       # 插件说明文档
```
### 💾 如何安装

**资源库下载**

1. 在 Godot 中打开 **资源库** 选项卡。
2. 搜索并下载 “Pindot”。
3. 在 **项目** > **项目设置** > **插件** 中启用插件。

**GitHub Release下载**

1. 下载发布版本。
2. 解压缩 zip 文件，将 `addons/pindot` 目录移动到项目`addons/`下。
3. 在 **项目** > **项目设置** > **插件** 中启用插件。

## 🛤️ 开发路线图
- ~~项目基础架构~~
	- [x]  确定项目目录结构
	- [x]  创建基本的配置文件
	- [x]  设置版本控制（如 Git）
- **游戏管理**
	- [ ]  创建游戏进度管理类
	- [ ]  实现游戏速度调节功能
	- [ ]  设计游戏难度调整系统
- **数据管理**
	- [ ]  设计存档结构
	- [ ]  实现存档功能
	- [ ]  实现读档功能
- **场景管理**
	- [ ]  创建场景管理器
	- [ ]  实现场景加载与卸载
	- [ ]  设计场景切换效果
- **资源管理**
	- [ ]  实现资源加载系统
	- [ ]  优化资源缓存机制
	- [ ]  设计异步资源加载功能
- **实体管理**
	- [ ]  创建游戏对象类
	- [ ]  实现动态创建与销毁对象
	- [ ]  设计对象的显示与隐藏功能
- **输入处理**
	- [ ]  设计输入管理器
	- [ ]  实现多种输入设备支持
	- [ ]  实现输入事件处理功能
- **事件系统**
	- [ ]  创建事件管理系统
	- [ ]  设计事件触发机制
	- [ ]  实现事件与响应的解耦
- **界面管理**
	- [ ]  设计用户界面框架
	- [ ]  实现界面动态更新
	- [ ]  设计用户交互功能
- **音效管理**
	- [ ]  创建音效管理类
	- [ ]  实现背景音乐控制
	- [ ]  设计音效动态加载功能
- **调试工具**
	- [ ]  开发调试工具
	- [ ]  实现问题排查功能
	- [ ]  提供性能监控工具

## 📝 所需 Godot 版本
- 本框架需要 **Godot 4.0 及以上版本** 才能正常运行。请确保你安装了正确的版本，以获得最佳体验。
## 🤝 贡献指南
想加入开发？欢迎啊！Fork 这个项目，做出你的修改，提交 Pull Request，我们来一起让这个框架更好玩！
## 📜 协议
MIT 协议，随便玩，别忘了给个 Star⭐！
