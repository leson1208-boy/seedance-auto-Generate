# Dreamina Nightly Windows 自动化工具

这是一个面向 Windows 用户的即梦 Dreamina CLI 自动化脚本包，用于批量读取任务文件夹中的提示词和图片，自动提交 `multimodal2video` 视频生成任务，轮询任务状态，并下载生成结果。

项目提供 PowerShell + WinForms 图形启动器，也保留命令行脚本入口，适合分发给不会使用终端的用户。

## 功能特性

- 图形界面配置：输入目录、执行时间、模型、时长、比例、分辨率等
- 自动检查、安装和更新 `dreamina` CLI
- 自动检测登录状态，并支持一键触发登录
- 支持单任务目录或母目录递归扫描
- 统一使用 `dreamina multimodal2video`
- 支持计划任务：每日定时执行、取消指定任务、取消全部 Dreamina 任务
- 支持任务状态持久化，避免重复提交
- 支持失败重试和已提交任务续查
- 生成视频统一下载到 `done` 目录
- 日志、状态、临时下载文件统一收纳到 `tmp` 目录

## 运行环境

- Windows x64
- PowerShell 5.1 或更高版本
- 可访问外网
- 当前 Windows 用户允许运行 PowerShell 脚本
- 首次使用需要人工完成 Dreamina 登录

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `DreaminaLauncher.ps1` | 图形界面启动器 |
| `dreamina-nightly.ps1` | 主执行脚本，负责安装、登录、扫描、提交、轮询、下载 |
| `register-task.ps1` | Windows 计划任务注册、查询、取消脚本 |
| `config.json` | 用户配置文件 |
| `Start Dreamina.vbs` | 日常双击启动入口 |
| `Start Dreamina.bat` | 排障启动入口，会保留错误输出 |
| `使用教程.md` | 完整中文使用教程 |

## 快速开始

1. 下载或克隆本仓库到本地。
2. 双击 `Start Dreamina.vbs` 打开图形界面。
3. 点击 `检测环境`。
4. 如未安装 CLI，点击 `安装/更新 CLI`。
5. 点击 `登录`，按即梦 CLI 提示完成登录。
6. 选择任务输入目录。
7. 点击 `保存配置`。
8. 点击 `扫描任务`，确认识别到任务。
9. 点击 `立即执行`，手动跑一次。
10. 确认流程正常后，点击 `注册计划任务`。

如果双击后窗口闪退，请改用 `Start Dreamina.bat`，它会显示错误信息。

## 任务目录规则

一个任务对应一个子文件夹。

任务文件夹必须满足：

- 有且仅有 `1` 个 `.txt` 文件
- 至少有 `1` 张图片
- 支持图片格式：`png`、`jpg`、`jpeg`、`webp`
- 图片会按文件名升序传给 `dreamina multimodal2video`

示例：

```text
D:\TASK
├─ 11
│  ├─ 1.txt
│  ├─ 001.png
│  └─ 002.png
├─ 22
│  ├─ prompt.txt
│  ├─ front.jpg
│  └─ back.jpg
├─ tmp
│  ├─ _dreamina_tmp
│  ├─ logs
│  └─ state
└─ done
```

`input_path` 可以指向单个任务目录，也可以指向母目录。指向母目录时，脚本会递归扫描最深层的叶子任务目录。

## 输出目录

脚本运行后，母目录下会产生：

```text
<母目录>
├─ done
└─ tmp
   ├─ _dreamina_tmp
   ├─ logs
   └─ state
```

- `done/YYYY-MM-DD/<任务名>/`：最终下载的视频
- `tmp/logs/YYYY-MM-DD.log`：运行日志
- `tmp/state/tasks.json`：任务状态记录
- `tmp/_dreamina_tmp/`：下载临时目录

## 配置文件

默认 `config.json`：

```json
{
  "input_path": "D:\\DreaminaTasks",
  "poll_interval_seconds": 600,
  "max_poll_hours": 12,
  "model_version": "seedance2.0fast",
  "duration": 5,
  "ratio": "",
  "video_resolution": "",
  "login_timeout_minutes": 10,
  "task_time": "23:00",
  "log_retention_days": 30
}
```

常用字段：

- `input_path`：任务输入目录
- `task_time`：每日计划任务执行时间，格式如 `23:00`
- `model_version`：模型版本，GUI 中可下拉选择
- `duration`：视频时长
- `ratio`：画幅比例，可留空
- `video_resolution`：分辨率，可留空
- `poll_interval_seconds`：轮询间隔，默认 `600`
- `max_poll_hours`：最长轮询小时数，默认 `12`

当前 `multimodal2video` 支持的模型：

- `seedance2.0fast`
- `seedance2.0`
- `seedance2.0fast_vip`
- `seedance2.0_vip`

## 命令行用法

环境检测：

```powershell
powershell -ExecutionPolicy Bypass -File .\dreamina-nightly.ps1 -CheckOnly
```

安装或更新 CLI：

```powershell
powershell -ExecutionPolicy Bypass -File .\dreamina-nightly.ps1 -InstallOnly
```

登录：

```powershell
powershell -ExecutionPolicy Bypass -File .\dreamina-nightly.ps1 -LoginOnly
```

扫描任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\dreamina-nightly.ps1 -ScanOnly
```

立即执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\dreamina-nightly.ps1 -ConfigPath .\config.json -RunOnce
```

注册计划任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\register-task.ps1 -ConfigPath .\config.json
```

查看 Dreamina 计划任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\register-task.ps1 -List
```

取消指定计划任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\register-task.ps1 -Unregister -TaskName DreaminaNightly
```

取消全部 Dreamina 计划任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\register-task.ps1 -UnregisterAll
```

## 任务状态规则

- 成功任务会跳过，避免重复提交
- 已提交但未完成的任务会续查，不重复提交
- 更换图片、提示词或生成参数后，会重新提交
- 提交失败会自动重试一次
- 终态失败会自动重提一次
- 第二次仍失败则标记为失败

生成参数包括：

- `model_version`
- `duration`
- `ratio`
- `video_resolution`

## 常见问题

### 双击启动后闪退

请双击 `Start Dreamina.bat`，查看窗口中保留的错误信息。

### 显示未登录

点击 GUI 中的 `登录` 按钮，完成 `dreamina login`。登录后点击 `检测环境`，确认登录状态变为已登录。

### 扫描不到任务

检查任务目录是否满足：

- 正好 `1` 个 `.txt`
- 至少 `1` 张支持格式图片
- 输入目录是否选对
- 任务是否位于过深或错误的目录层级

### 更换模型后没有重新提交

当前版本已经把生成参数纳入任务指纹。更换模型、时长、比例或分辨率后，会重置对应任务并重新提交。

## 联系方式

如需交流、定制或反馈问题，可以通过下方二维码联系：

![联系方式](./微信图片_20260429094055_33_155.png)

## 使用与转载声明

允许使用、转载、二次修改和分发本仓库内容，但转载或分发时必须注明来源仓库和原作者。

推荐署名格式：

```text
本文/工具/脚本基于 leson1208-boy 的 GitHub 仓库 seedance-auto-Generate 转发或修改：
https://github.com/leson1208-boy/seedance-auto-Generate
```

完整说明见 [LICENSE](./LICENSE)。

## 说明

本项目是 Dreamina CLI 的 Windows 自动化封装。实际视频生成能力、额度、登录和模型权限由 Dreamina 官方服务决定。
