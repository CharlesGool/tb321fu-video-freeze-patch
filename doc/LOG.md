---
name: project-log
description: 项目缺陷, 限制, 决策和交接
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# 日志

## 多语言

**简体中文** | [English](en/LOG.md) | [Español](es/LOG.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 记录

- [历史记录](HISTORY.md)
- [变更日志](CHANGELOG.md)

## 缺陷

暂无.

## 限制

- 只验证过 ZUI 17.0.12.044 的 vendor 和 DP11 (A17) 底包; 其他 vendor 版本由定位工具判断能否打, 打得上也未经真机验证.
- `001` 的修改让预加载后一直没播放的解码器每 150 ms 醒一次, 直到被释放.

## 决策

| 日期 | 决策 | 状态 | 原因 |
| --- | --- | --- | --- |
| 2026-11-09 | libgui 去掉 `Surface::disconnect` 里的 generation 清零 | 接受 | 恢复 A16 行为只需 1 条指令, 其他方案要在二进制里插调用. |
| 2026-11-09 | `Surface::attachBuffer` 永远不覆盖 generation | 拒绝 | ImageWriter, 相机等跨 BufferQueue attach 的场景依赖覆盖. |
| 2026-11-09 | vendor 解码器超时后永远重试 (阈值等效为 0) | 接受 | 高通代码本来支持阈值 0, 改 1 条分支即可. |
| 2026-11-09 | 加大输入槽或输出缓冲数量 | 拒绝 | 只推后上限, 预加载会把槽位再次占满. |
| 2026-11-09 | vendor 库随 system 分发, 开机 bind, 不改 vendor 分区 | 接受 | 不用重做 vendor 的 hashtree 和 vbmeta, vendor 不匹配时自动回到原厂行为. |
| 2026-11-09 | 拆成独立仓库, 作为补丁的唯一来源, Mods 保留同步副本 | 接受 | 与 tango, faceunlock 补丁的组织方式一致. |

## 交接

- 当前分支: `main`.
- 已完成: 从 TB321FU-GSI-Mods 提取 `video-freeze-fix` 到 `patch/` (V1.1, 只改文档: 真机结果, 调研记录链接); 加入 `tools/apply-to-images.sh`; 按项目模板建立简体中文文档, 英文和西班牙语文档仍是模板.
- 检查: 两个定位工具在原厂 vendor 库和 DP11 libgui 上的输出 sha256 与进程内存热补丁验证过的二进制一致; A15 libgui 正确跳过; Mods 中整包构建通过, 用户 2026-11-09 真机验证 X 刷视频不再卡画面. 本仓库内没有可运行的构建或测试.
- 剩余步骤:
  - [ ] 翻译英文和西班牙语文档.
- 阻碍: 无.
- 临时项目规则: 未发现.
