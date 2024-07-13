import os
import argparse

parser = argparse.ArgumentParser(description="示例：python3 rename.py -d /Users/chenhui/Note/test  -o BBB -n AAA")
parser.add_argument('-d', '--directory', type=str, help='项目根目录路径', required=True)
parser.add_argument('-o', '--old', type=str, help='旧字符串', required=True)
parser.add_argument('-n', '--new', type=str, help='新字符串', required=True)

args = parser.parse_args()
folder_path = args.directory
old_string = args.old
new_string = args.new

# 只匹配的文件后缀
mach_files = ('.swift', '.pbxproj', '.h', '.m', '.md', 'Podfile', '.rb', '.entitlements', '.xcworkspacedata')
# 忽略的文件夹
ignore_folders = ['Pods']

def rename_item(old, new, path, item):
    item_path = os.path.join(path, item)
    if old in item:
        # 构造新的文件名
        new_item = item.replace(old, new)
        new_item_path = os.path.join(path, new_item)
        # 重命名文件
        os.rename(item_path, new_item_path)
        print(f"rename '{item_path}' to '{new_item_path}'")
        item_path = new_item_path
    return item_path


def replace(old, new, path):
    for item in os.listdir(path):
        item_path = os.path.join(path, item)
        # 如果是文件夹，则递归调用
        if os.path.isdir(item_path) and any(item != folder for folder in ignore_folders):
            item_path = rename_item(old, new, path, item)
            replace(old, new, item_path)
        elif item.endswith(mach_files):
            item_path = rename_item(old, new, path, item)
            # 读取文件内容
            with open(item_path, 'r+') as file:
                content = file.read()
                file.close()
                if old in content:
                    print(f"replace '{item_path}'")
                    # 替换字符串
                    content = content.replace(old, new)
                    # 将新内容写回文件
                    with open(item_path, 'w+') as file_new:
                        file_new.write(content)
                        file_new.close()


replace(old_string, new_string, folder_path)
