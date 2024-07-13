#coding=utf-8
from pbxproj import XcodeProject
from pbxproj.pbxextensions import TreeType
import argparse

# python3 changeUUID.py -d /Users/chenhui/Gitlab/tiance-public -p TC-Swift
parser = argparse.ArgumentParser(description="修改项目UUID引用，示例：python3 changeUUID.py -d /Users/chenhui/Gitlab/tiance-public -p TC-Swift")
parser.add_argument('-d', '--directory', type=str, help='项目根目录路径', required=True)
parser.add_argument('-p', '--project', type=str, help='项目文件名，无需后缀', required=True)

args = parser.parse_args()
# 项目文件名pythonpython
project_name = args.project
# 项目路径
project_path = args.directory

# 打开现有的 Xcode 项目
project_path = f"{project_path}/{project_name}.xcodeproj/project.pbxproj"
project = XcodeProject.load(project_path)

# OK
# file_ref = project.add_file('ZGZSULDelayTaskManager.swift', parent='96353D0D2BAD350C005BB295', tree=TreeType.GROUP)
# print(f"file_ref = {file_ref}")

for file_ref in project.objects.get_objects_in_section('PBXFileReference'):
    file_name = file_ref.get_name()
    print(f"file_ref.get_name = {file_name}")

    # 只处理部分文件格式
    if not file_name.endswith(('.swift', '.png')):
        continue

    # 特定文件不处理
    if file_name.endswith('Ext.swift'):
        continue

    file_id = file_ref.get_id()
    print(f"file_ref.get_id = {file_id}")
    print(f"file_ref.path = {file_ref.path}")
    print(f"file_ref.sourceTree = {file_ref.sourceTree}")

    for group in filter(lambda x: file_id in x.children, project.objects.get_objects_in_section('PBXGroup')):
        # group.remove_child(file_ref) # 只能删除 group 里面的引用，别的地方不能删除，改为 project.remove_file_by_id
        project.remove_file_by_id(file_id)

        group_id = group.get_id()
        print(f"group.get_id = {group_id}")

        file_ref_new = project.add_file(file_name, parent=group_id, tree=file_ref.sourceTree)

        print(f"file_ref_new = {file_ref_new}")

# 保存项目更改
project.save()

