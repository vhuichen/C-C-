#!/bin/bash

echo "开始替换..."

read -p "请输入目标路径:" path

cd $path
echo "目标路径：$path"

read -p "请输入需要替换的字符串:" projectName

read -p "请输入目标字符串:" targetName

export LC_ALL='C' # 没有这句会报错 sed: RE error: illegal byte sequence

# 这个命令会有问题，遇到带空格的路径会异常
# sed -i "" "s/$projectName/$targetName/g" `grep "$projectName" -rl .`

# find . -type f -exec grep -l "$projectName" {} + | xargs sed -i "" "s/$projectName/$targetName/g"

find . -type f -print0 | xargs -0 -I {} sh -c 'grep -l "$projectName" "{}"' | xargs sed -i "" "s/$projectName/$targetName/g"

echo "--------"

recursive_rename() {
    cd $1
    rename "s/$projectName/$targetName/" *
    for file in `ls`; do
        if [ -d $1/$file ]; then
            recursive_rename $1/$file
        fi
    done
}

recursive_rename $PWD

echo "执行完毕..."
