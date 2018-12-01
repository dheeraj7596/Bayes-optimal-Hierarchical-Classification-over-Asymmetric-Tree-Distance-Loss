%% Create level training files where labels are mapped to their appropriate level ancestor



clear all;
load ../hierarchy_data

    valifile_name='../Dataset_files/prepped_vali.txt';
    trainfile_name='../Dataset_files/prepped_train.txt';
    testfile_name='../Dataset_files/prepped_test.txt';

train_file_id=fopen(trainfile_name,'r');
vali_file_id=fopen(valifile_name,'r');
test_file_id=fopen(testfile_name,'r');
 

unix('rm -r -f level_files');
unix('mkdir level_files');

for level=1:max(nodes_level)
    train_level_file_id=fopen(['level_files/train_' num2str(level)],'w');
    test_level_file_id=fopen(['level_files/test_' num2str(level)],'w');
    vali_level_file_id=fopen(['level_files/vali_' num2str(level)],'w');
    full_train_level_file_id=fopen(['level_files/full_' num2str(level)],'w');
    
    while 1
        line=fgetl(train_file_id);
        if line==-1
            break;
        end
        components=regexp(line,'[\s]+','split');
        class=str2double(components{1});
        
        while nodes_level(class)>level
            class=find(children(:,class));
        end
        
        line(1:length(components{1}))= [];
        line=[num2str(class) ' ' line line_break];
        fwrite(train_level_file_id,line);
        fwrite(full_train_level_file_id,line);
    end
    frewind(train_file_id);
    
    while 1
        line=fgetl(vali_file_id);
        if line==-1
            break;
        end
        components=regexp(line,'[\s]+','split');
        class=str2double(components{1});
        
        while nodes_level(class)>level
            class=find(children(:,class));
        end
        
        line(1:length(components{1}))= [];
        line=[num2str(class) ' ' line line_break];
        fwrite(vali_level_file_id,line);
        fwrite(full_train_level_file_id,line);
    end
    frewind(vali_file_id);
    
    
    while 1
        line=fgetl(test_file_id);
        if line==-1
            break;
        end
        components=regexp(line,'[\s]+','split');
        class=str2double(components{1});
        
        while nodes_level(class)>level
            class=find(children(:,class));
        end
        
        line(1:length(components{1}))= [];
        line=[num2str(class) ' ' line line_break];
        fwrite(test_level_file_id,line);
        
    end
    frewind(test_file_id);
    
    fclose(train_level_file_id);
    fclose(test_level_file_id);
    fclose(full_train_level_file_id);
    fclose(vali_level_file_id);
end

fclose(train_file_id);
fclose(test_file_id);
fclose(vali_file_id);