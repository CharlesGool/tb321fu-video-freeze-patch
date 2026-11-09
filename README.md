# tb321fu-video-freeze-patch

**简体中文** | [English](doc/en/README.md) | [Español](doc/es/README.md)

拯救者 Y700 三代 (TB321FU) 刷 Pixel GSI 后, X 等 app 刷视频时声音继续, 画面定格, 拖进度条才恢复; 本项目是修复它的 TB321FU-GSI-Mods 补丁.

[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-orange)](LICENSE)

## 文档

- 项目概览: [README](README.md)

- 设计思路: [DESIGN](doc/DESIGN.md)

- 项目状态: [LOG](doc/LOG.md)
- 历史记录: [HISTORY](doc/HISTORY.md)
- 变更日志: [CHANGELOG](doc/CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](doc/THIRD_PARTY_NOTICES.md)

## 简介

同一个现象有两个独立原因, 补丁 `video-freeze-fix` 用两个部分各改 1 条 AArch64 指令 (4 字节):

| 部分 | 改哪 | 原因 | 影响版本 |
| --- | --- | --- | --- |
| [001.codec2-alloc-retry](patch/parts/001.codec2-alloc-retry/README.md) | `/vendor/lib64/libqcodec2_v4l2codec.so` (开机 bind) | 高通解码器申请输出缓冲超时后, 距上次输入超过 1 秒就放弃, 而输入槽被它自己占满, 形成死锁 | 与框架版本无关, A15 和 A17 GSI 都有 |
| [002.libgui-surface-gen](patch/parts/002.libgui-surface-gen/README.md) | `/system/lib64/libgui.so` | A17 的 `Surface::disconnect` 清零 generation, HIDL Codec2 切换 Surface 时缓冲迁移全部被拒 | 只有 A17; A15/A16 的 libgui 自动跳过 |

- 两个工具按符号和指令模式定位, 不写死偏移, 命中不唯一就停止构建.
- vendor 分区不改: 补丁版的 vendor 库随 system 镜像分发, 开机时核对原厂文件 sha256 后 bind 到 `/vendor`, 对不上就不覆盖.
- 2026-11-09 在 TB321FU (ZUI 17.0.12.044 vendor, DP11 底包) 上刷入验证: X 刷视频不再出现画面定格.

排查过程和通用方法见 [gsi-codec2-video-freeze-guide](https://github.com/CharlesGool/gsi-codec2-video-freeze-guide), 本仓库是它的参考实现.

本仓库是该补丁的唯一来源. [TB321FU-GSI-Mods](https://github.com/CharlesGool/TB321FU-GSI-Mods) 的 `patches/required/general/hardware-fix/video-freeze-fix/` 是同步副本.

## 要求

- 拯救者 Y700 三代 (TB321FU), 原厂联想高通 vendor (HIDL Codec2 `vendor.qti.media.c2@1.0-service`)
- 构建机: `python3` 和 `pyelftools` (Debian/Ubuntu: `apt install python3-pyelftools`)
- 使用者自备原厂 vendor 镜像; 仓库不含任何联想, 高通或 Google 的二进制文件

## 安装

本项目不单独安装, 有两种用法.

### 快速安装

用 [TB321FU-GSI-Mods](https://github.com/CharlesGool/TB321FU-GSI-Mods) 构建 system 镜像. Mods 已带同步副本, DP11 (A17) 设备目录 `devices/tb321fu-a15-dp11` 默认启用本补丁:

```bash
make 9008 DEVICE=tb321fu-a15-dp11 NOTE="video-freeze-fix"
```

其他设备目录要先把 `required/general/hardware-fix/video-freeze-fix` 加进它 `device.conf` 的 `MODS`.

### 常规安装

把本仓库克隆到 Mods 旁边 (同一父目录), 在 Mods 中同步副本后再构建. 其他位置用 `VIDEO_FREEZE_PATCH_DIR` 指定:

```bash
cd <TB321FU-GSI-Mods>
make sync-video-freeze
```

不用 Mods 时, 直接改已挂载的镜像 (vendor 镜像改完要重新生成 hashtree 和 vbmeta, 或沿用已有的关校验方式):

```bash
sudo tools/apply-to-images.sh --check --system <system 挂载点> --vendor <vendor 挂载点>
sudo tools/apply-to-images.sh --system <system 挂载点> --vendor <vendor 挂载点>
```

## 指南

### 参数

在 Mods 的 `devices/<设备>/device.conf` 或 `conf.d/` 中设置, 同名环境变量优先.

| 参数 | 含义 |
| --- | --- |
| `STOCK_VENDOR_IMG` | 原厂 vendor 镜像, 从中取 `libqcodec2_v4l2codec.so` (Mods 的 `device.conf` 已设置) |
| `DEVICE` | vendor-bind 开机脚本核对的 `ro.product.vendor.device` |
| `VF_QCODEC2_REL` | 可选. 库在 vendor 中的相对路径, 默认 `lib64/libqcodec2_v4l2codec.so` |

### 检查

只检查文件状态, 不修改:

```bash
python3 patch/parts/002.libgui-surface-gen/patch_libgui_surface_gen.py --check <libgui.so>
python3 patch/parts/001.codec2-alloc-retry/patch_qcodec2_alloc_retry.py --check <libqcodec2_v4l2codec.so>
```

刷机后:

```bash
adb shell dmesg | grep vendor-bind      # 应有 ok video-qcodec2-alloc-retry
adb logcat -d | grep -E "generation number mismatch|remote graphic buffer migration|Allocating output buffer timedout"
```

通过标准: 没有 `generation number mismatch`; `remote graphic buffer migration N/N` 全部成功; 不再出现 `Allocating output buffer timedout ... elapsed since last input`.

## 升级

暂无.

## 卸载

### 快速卸载

暂无. 补丁在镜像里, 只能完全卸载.

### 完全卸载

在 Mods 中去掉本补丁重新构建并刷机:

```bash
make 9008 DEVICE=tb321fu-a15-dp11 WITHOUT=video-freeze-fix NOTE="不带视频卡住修复"
```

## 致谢

- [AOSP](https://source.android.com/) `frameworks/native` 和 `frameworks/av`: 用于对照 `Surface` 和 `MediaCodec` 的行为

## 许可证

本项目以 GNU General Public License v3.0 或更新版本授权, SPDX 标识符 `GPL-3.0-or-later`, 全文见 [LICENSE](LICENSE). 补丁要修改的联想, 高通和 Google 二进制文件不随本项目分发, 见 [THIRD_PARTY_NOTICES](doc/THIRD_PARTY_NOTICES.md).
