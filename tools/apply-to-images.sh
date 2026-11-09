#!/usr/bin/env bash
# 不用 TB321FU-GSI-Mods 时:把两个修复直接打进已挂载的 system / vendor 镜像(保留原权限、属主、SELinux 标签)。
# 用 Mods 构建时不需要它:patch/ 会把 vendor 那份改成开机 bind,vendor 分区不动。
# 用法:
#   sudo tools/apply-to-images.sh --system <system 挂载点> --vendor <vendor 挂载点>
#   只打其中一个也可以: 只给 --system 或只给 --vendor
#   --check 只检查不修改
# system 挂载点 = 能看到 <挂载点>/system/lib64/libgui.so 或 <挂载点>/lib64/libgui.so 的目录都行
# 依赖: python3 + pyelftools, getfattr(attr 包)
set -euo pipefail
PARTS="$(cd "$(dirname "$0")/../patch/parts" && pwd)"
SYS="" VND="" CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --system) SYS="$2"; shift 2;;
    --vendor) VND="$2"; shift 2;;
    --check)  CHECK=1; shift;;
    *) echo "未知参数 $1"; exit 1;;
  esac
done
[ -n "$SYS$VND" ] || { sed -n '2,9p' "$0"; exit 1; }

patch_one() {   # $1=lib 路径  $2=补丁脚本
  local LIB="$1" PY="$PARTS/$2"
  [ -f "$LIB" ] || { echo "找不到 $LIB"; exit 1; }
  echo "== $LIB"
  python3 "$PY" --check "$LIB"
  [ $CHECK = 1 ] && return
  local MODE UID_ GID LABEL TMP
  MODE=$(stat -c %a "$LIB"); UID_=$(stat -c %u "$LIB"); GID=$(stat -c %g "$LIB")
  LABEL=$(getfattr -n security.selinux --only-values "$LIB" | tr -d '\0')
  TMP=$(mktemp)
  python3 "$PY" "$LIB" "$TMP"
  cp -a "$LIB" "$TMP.orig"
  install -m "$MODE" -o "$UID_" -g "$GID" "$TMP" "$LIB"
  python3 -I -c 'import os,sys; os.setxattr(sys.argv[1],"security.selinux",sys.argv[2].encode()+b"\0")' "$LIB" "$LABEL"
  echo "-- 改动字节(应只有 1 处 4 字节内的差异):"; cmp -l "$TMP.orig" "$LIB" || true
  echo "-- 复查:"; python3 "$PY" --check "$LIB"
  echo "-- 权限/标签: $(stat -c '%a %u:%g' "$LIB") $(getfattr -n security.selinux --only-values "$LIB" | tr -d '\0')"
  rm -f "$TMP" "$TMP.orig"
}

if [ -n "$SYS" ]; then
  if   [ -f "$SYS/system/lib64/libgui.so" ]; then L="$SYS/system/lib64/libgui.so"
  else L="$SYS/lib64/libgui.so"; fi
  patch_one "$L" 002.libgui-surface-gen/patch_libgui_surface_gen.py
fi
if [ -n "$VND" ]; then
  patch_one "$VND/lib64/libqcodec2_v4l2codec.so" 001.codec2-alloc-retry/patch_qcodec2_alloc_retry.py
fi
echo "完成。vendor 改动后记得重新生成 vendor 镜像 hashtree / vbmeta(或沿用现有关校验方式)。"
