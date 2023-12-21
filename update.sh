#!/bin/bash

# نام مخزن GitHub
REPO_NAME="IPTABLE-Tunnel-multi-port"

# مسیری که می‌خواهید مخزن در آن clone شود
INSTALL_PATH="/root/dds-tunnel"

# مسیری که مخزن در آن clone شده است
CLONE_PATH="$INSTALL_PATH/$REPO_NAME"

# اگر مخزن قبلاً clone نشده باشد، آن را clone کنید
if [ ! -d "$CLONE_PATH" ]; then
    git clone "https://github.com/azavaxhuman/$REPO_NAME.git" "$CLONE_PATH"
else
    # اگر مخزن قبلاً clone شده باشد، آن را به‌روزرسانی کنید
    cd "$CLONE_PATH" || exit
    git pull origin master
fi
