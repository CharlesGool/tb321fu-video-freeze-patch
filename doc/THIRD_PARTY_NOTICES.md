---
name: project-third-party-notices
description: 第三方署名与合规声明
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# 第三方声明

## 多语言

**简体中文** | [English](en/THIRD_PARTY_NOTICES.md) | [Español](es/THIRD_PARTY_NOTICES.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 第三方声明

### 组件清单

本项目不随附第三方源码或二进制文件. 补丁在构建时修改使用者自备的以下文件, 修改结果只进入使用者自己构建的镜像:

| 组件名称 | 版本或哈希 | 上游地址 | 许可证类型 | 使用方式 | 版权归属 | 发布合规义务 | 核验日期 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `libqcodec2_v4l2codec.so` | sha256 `e328076b…df25` (ZUI 17.0.12.044) | 联想 TB321FU 原厂固件 | 专有 | 构建时从使用者自备的 vendor 镜像读取并修改 4 字节 | Qualcomm, Lenovo | 本仓库不分发; 再分发构建出的镜像时由分发者自行确认 | 2026-11-09 |
| `libgui.so` | sha256 `222ca5e3…3007` (Pixel DP11.261016.003) | Google Pixel 工厂镜像, 源码 [AOSP frameworks/native](https://android.googlesource.com/platform/frameworks/native/) | Apache-2.0 (源码); 工厂镜像另有 Google 条款 | 构建时从使用者自备的 GSI 读取并修改 4 字节 | Google, The Android Open Source Project | 本仓库不分发 | 2026-11-09 |

### 许可证文本

本仓库不含第三方材料, 没有需要附带的许可证文本.

### 源代码提供

不适用.

### 合规审查

不适用.
