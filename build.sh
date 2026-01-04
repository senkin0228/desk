#!/bin/bash

DTS_SOURCE_DIR="/home/lyra/desk/lyra"
DTS_TARGET_DIR="/home/lyra/sdk/kernel-6.1/arch/arm/boot/dts"

DTS_FILES=(
    "rk3506-luckfox-lyra-ultra.dtsi"
    "rk3506b-luckfox-lyra-ultra-w.dts"
)

BackUp_SingleFile() {
    local file="$1"
    echo "Process: $file"
    
    # 检查target目录原始文件是否存在
    if [ ! -f "$DTS_TARGET_DIR/$file" ]; then
        echo "Error: Target file does not exist: $DTS_TARGET_DIR/$file"
        return 1
    fi
    
    # 检查source目录文件是否存在
    if [ ! -f "$DTS_SOURCE_DIR/$file" ]; then
        echo "Warning: Source file does not exist: $DTS_SOURCE_DIR/$file"
        echo "Copying from target directory..."
        cp "$DTS_TARGET_DIR/$file" "$DTS_SOURCE_DIR/$file"
        if [ $? -eq 0 ]; then
            echo "Copied $file to source directory"
        else
            echo "Error copying $file to source directory"
            return 1
        fi
    fi
    
    # 备份逻辑
    # 1. 如果target目录存在.bk1，备份为.bk2
    if [ -f "$DTS_TARGET_DIR/$file.bk1" ]; then
        echo "Backing up existing .bk1 to .bk2..."
        cp "$DTS_TARGET_DIR/$file.bk1" "$DTS_TARGET_DIR/$file.bk2"
        if [ $? -ne 0 ]; then
            echo "Error backing up .bk1 to .bk2"
            return 1
        fi
    fi
    
    # 2. 备份当前target文件为.bk1
    echo "Creating .bk1 backup..."
    cp "$DTS_TARGET_DIR/$file" "$DTS_TARGET_DIR/$file.bk1"
    if [ $? -ne 0 ]; then
        echo "Error creating .bk1 backup"
        return 1
    fi
    
    # 3. 从source复制到target
    echo "Copying from source to target..."
    cp "$DTS_SOURCE_DIR/$file" "$DTS_TARGET_DIR/$file"
    if [ $? -eq 0 ]; then
        echo "Successfully copied $file to target directory"
        echo "----------------------------------------"
        return 0
    else
        echo "Error copying $file to target directory"
        return 1
    fi
}

# Function: bk - Backup dtsi file and copy new file
BackUp_DTSFile() {
    echo "Starting backup and copy process..."
    
    local error_count=0

    for file in "${DTS_FILES[@]}"; do
        if ! BackUp_SingleFile "$file"; then
            ((error_count++))
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        echo ""
        echo "All files processed successfully."
    else
        echo ""
        echo "Completed with $error_count errors."
    fi
}

# 6. Main program
case "$1" in
    bk)
        BackUp_DTSFile
        ;;
    *)
        echo "Usage: $0 {bk} back up dts files"
        exit 1
        ;;
esac