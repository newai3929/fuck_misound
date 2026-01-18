#!/system/bin/sh
# =============================================
# Xiaomi Audio SFX Boost - service.sh (v1.2 强制晚期版)
# 晚期执行 + 双保险 + 日志
# =============================================

MODDIR=${0%/*}
MODNAME="Xiaomi Audio SFX Boost"

ui_print " "
ui_print "===================================="
ui_print "  $MODNAME v1.2 开始执行"
ui_print "  设备: $(getprop ro.product.model)"
ui_print "  ROM: HyperOS $(getprop ro.build.version.release)"
ui_print "  时间: $(date)"
ui_print "===================================="
ui_print " "

# 第一轮强制设置（-n 防覆盖）
resetprop -n ro.vendor.audio.sfx.harmankardon true
resetprop -n ro.vendor.audio.sfx.audiovisual true

# 等 5-10 秒（系统可能晚期重设属性）
sleep 8

# 第二轮双保险
resetprop -n ro.vendor.audio.sfx.harmankardon true
resetprop -n ro.vendor.audio.sfx.audiovisual true

# 验证最终状态
HK=$(getprop ro.vendor.audio.sfx.harmankardon 2>/dev/null || echo "读取失败")
AV=$(getprop ro.vendor.audio.sfx.audiovisual 2>/dev/null || echo "读取失败")
ui_print "哈曼卡顿最终: $HK"
ui_print "声音视效最终: $AV"
ui_print " "

# 视频文件 overlay 检查
TARGET_DIR="/system/etc/audio"
if [ ! -d "$TARGET_DIR" ]; then
  ui_print "警告: $TARGET_DIR 不存在，视频文件无法 overlay"
else
  ui_print "目录存在，检查视频文件..."
  for vid in video1.mp4 video2.mp4 video3.mp4 video4.mp4; do
    if [ -f "$MODDIR/system/etc/audio/$vid" ]; then
      if [ -f "$TARGET_DIR/$vid" ]; then
        ui_print "已存在 → $vid (跳过覆盖)"
      else
        ui_print "将 overlay → $vid"
      fi
    else
      ui_print "模块缺少 → $vid (请添加文件)"
    fi
  done
fi

# 尝试重启音频服务
ui_print "尝试重启 audioserver..."
stop audioserver 2>/dev/null
sleep 2
start audioserver 2>/dev/null || ui_print "audioserver 重启失败（可能正常）"

ui_print " "
ui_print "执行完成！重启手机后请检查 设置 → 声音与振动 → 音质音效"
ui_print "日志查看: /cache/magisk.log 或 APatch.log"
ui_print "===================================="