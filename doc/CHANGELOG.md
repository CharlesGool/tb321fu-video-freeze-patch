---
name: project-changelog
description: 变更日志
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# 变更日志

## 多语言

**简体中文** | [English](en/CHANGELOG.md) | [Español](es/CHANGELOG.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 变更日志

### V1.1 — 2026-11-09

#### 变更

- 记录真机结果 (DP11 `BTtest-v1.7-cust_bebug`, X 刷视频不再卡画面); 调研记录移到 gsi-codec2-video-freeze-guide, 补丁文档改为链接过去.

### V1.0 — 2026-11-09

#### 新增

- `001.codec2-alloc-retry`: 高通解码器申请输出缓冲超时后永远重试, 补丁版库开机 bind 到 `/vendor`.
- `002.libgui-surface-gen`: A17 libgui 的 `Surface::disconnect` 不再清零 generation.
