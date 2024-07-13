require 'xcodeproj'

project_path = '/Users/chenhui/Gitlab/ZGZSCX/ZGZS-Swift.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first
main_group = project.main_group

def update_uuid(target, group)
    group.children.each do |child|
        if child.is_a?(Xcodeproj::Project::PBXGroup) && child.path
            sub_group = group.find_subpath(File.join(child.path), false)
            update_uuid(target, sub_group)
        elsif child.is_a?(Xcodeproj::Project::PBXFileReference) &&
            child.display_name.end_with?(".m", ".mm", "AppDelegate.swift") &&
            !child.display_name.end_with?("Ext.swift")
            #
            puts "PBXFileReference: #{child.display_name}"
            # 先移除
            child.remove_from_project
            group.remove_reference(child)
            # 再添加
            file_ref = group.new_reference(child.display_name)
            target.add_file_references([file_ref])
        end
    end
end

update_uuid(target, main_group)

project.save


#group = project.main_group.find_subpath(File.join('ZGZS-Swift', 'Models'), true)
#group_files = group.files
#group_files.each do |file|
#    file.remove_from_project
#    group.remove_reference(file)
#end

## 根据路径名寻找 group , 如果当前的 group 不存在, 会根据参数 true 递归地创建
#group = project.main_group.find_subpath(File.join('ZGZS-Swift', 'Models'), true)
##group.set_source_tree('SOURCE_ROOT')
#file_ref = group.new_reference('ZGZSULDelayTaskManager.swift')
#target.add_file_references([file_ref])

