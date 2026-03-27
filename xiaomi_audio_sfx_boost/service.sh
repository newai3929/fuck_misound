#!/system/bin/sh
# service.sh - v1.3 

MODDIR=${0%/*}
MODNAME="Xiaomi Audio SFX Boost"

ui_print " "
ui_print "===================================="
ui_print "  $MODNAME v1.3开始执行"
ui_print "  设备: $(getprop ro.product.model)"
ui_print "  ROM: $(getprop ro.build.version.release)"
ui_print "===================================="
ui_print " "

# 1. 强制晚期 prop 设置
resetprop -n ro.vendor.audio.sfx.harmankardon true
resetprop -n ro.vendor.audio.sfx.audiovisual true
sleep 8
resetprop -n ro.vendor.audio.sfx.harmankardon true
resetprop -n ro.vendor.audio.sfx.audiovisual true

HK=$(getprop ro.vendor.audio.sfx.harmankardon 2>/dev/null || echo "失败")
AV=$(getprop ro.vendor.audio.sfx.audiovisual 2>/dev/null || echo "失败")
ui_print "哈曼卡顿最终状态: $HK"
ui_print "声音视效最终状态: $AV"
ui_print " "

# 2. 部署 APK 
APK_PATH="/system/product/app/MiSound/MiSound.apk"
if [ -f "$APK_PATH" ]; then
  ui_print "检测到修改版 MiSound.apk，正在设置."
  chmod 644 "$APK_PATH"
  chown system:system "$APK_PATH" 2>/dev/null || true
  ui_print "APK 设置完成"
else
  ui_print "警告：未找到 MiSound.apk，请确认模块内路径和文件名正确"
fi

# 3. 视频文件检查（overlay）
TARGET_DIR="/system/etc/audio"
if [ ! -d "$TARGET_DIR" ]; then
  ui_print "警告：$TARGET_DIR 目录不存在，视频文件可能无法生效"
else
  ui_print "检查声音视效视频文件..."
  for vid in video1.mp4 video2.mp4 video3.mp4 video4.mp4; do
    if [ -f "$MODDIR/system/etc/audio/$vid" ]; then
      if [ -f "$TARGET_DIR/$vid" ]; then
        ui_print "已存在 → $vid （跳过）"
      else
        ui_print "将 overlay 添加 → $vid"
      fi
    else
      ui_print "模块缺少 → $vid"
    fi
  done
fi

# 4. 重启音频服务
ui_print "重启 audioserver..."
stop audioserver 2>/dev/null
sleep 2
start audioserver 2>/dev/null || ui_print "audioserver 重启失败"

ui_print " "
ui_print "执行完成！请重启手机，模块将在重启后生效"
ui_print "重启后请检查：设置 → 声音与振动 → 音质音效是否显示开关，app是否为修改版"
ui_print "===================================="