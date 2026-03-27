#!/system/bin/sh
# customize.sh-单路径 REPLACE（降低bootloop风险）

MODDIR=${0%/*}

# 仅替换app所在路径
REPLACE="/system/product/app/MiSound"

ui_print "已启用单路径 REPLACE 机制：仅覆盖 /system/product/app/MiSound"