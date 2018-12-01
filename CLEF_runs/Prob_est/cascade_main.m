function cascade_main(root_node_index_set, unique_run_id, trainmode)
% When running the function parallelly on separete matalb workers with
% different root_node_index_sets make sure to use different unique_run_ids

% train mode of 1 for validation 
% train mode of 2 for final 
load ../hierarchy_data children descendants  rootnodes

if trainmode==1
    trainfile_name='prepped_train.txt';
    testfile_name='prepped_vali.txt';
    load ../metadata metadata_train metadata_vali
    metadata_test=metadata_vali;
    clear metadata_vali;
    outputs_folder='outputs_validation';
    C_vals=[0.01 0.1 1 10];
elseif trainmode==2
    trainfile_name='prepped_final_train.txt';
    testfile_name='prepped_test.txt';
    load ../final_metadata metadata_train metadata_test
    outputs_folder='outputs';
    C_vals=[1];
else
    assert(1==0,'trainmode must be 1 or 2');
end



num_train=length(metadata_train);
num_test=length(metadata_test);

unix(['mkdir ' outputs_folder]);

for root_node_index=root_node_index_set
    curr_rootnode=rootnodes(root_node_index);
    curr_root_descendants=find(descendants(curr_rootnode,:));
    for pivot_index=1:length(curr_root_descendants)
        
        
        
        pivot_class_label=curr_root_descendants(pivot_index)
        temp_folder_name=['temp_' num2str(unique_run_id)];
        unix(['rm -r -f ' temp_folder_name]);
        mkdir_command=['mkdir ' temp_folder_name];
        unix(mkdir_command);
        copy_command=['cp ../Dataset_files/' trainfile_name '  ./' temp_folder_name] ;
        unix(copy_command);
        new_name_trainfile= [temp_folder_name '/train_' num2str(pivot_class_label) '.txt'];
        rename_command=['mv ' temp_folder_name '/' trainfile_name ' '   new_name_trainfile];
        unix(rename_command);
        
        copy_command=['cp ../Dataset_files/' testfile_name  ' ./' temp_folder_name];
        unix(copy_command);
        new_name_testfile= [temp_folder_name '/test_' num2str(pivot_class_label) '.txt'];
        rename_command=['mv ' temp_folder_name '/' testfile_name ' '   new_name_testfile];
        unix(rename_command);
        
        train_file_id=fopen([new_name_trainfile],'r+');
        test_file_id=fopen([new_name_testfile],'r+');
        
        % vali_file_id=fopen('../Hierarchical_classification_datasets/DMOZ_2010/prepped_vali.txt','w');
        % test_file_id=fopen('../Hierarchical_classification_datasets/DMOZ_2010/prepped_test.txt','w');
        
        %
        positive_labels=sparse(length(children),1);
        negative_labels=sparse(length(children),1);
        
        positive_labels(descendants(pivot_class_label,:)>0)=1;
        negative_labels(sum(descendants,2)>0)=1;
        negative_labels(descendants(pivot_class_label,:)>0)=0;
        
        % Relabel train file labels as +1 or -1
        linenum=0;
        while(linenum<num_train)
            linenum=linenum+1;
            fseek(train_file_id, metadata_train(linenum,1),'bof');
            if negative_labels(metadata_train(linenum,3))==1
                fwrite(train_file_id, [num2str(-1) repmat(' ',1,metadata_train(linenum,2)-2)]);
            elseif positive_labels(metadata_train(linenum,3))==1
                fwrite(train_file_id, [num2str(1) repmat(' ',1,metadata_train(linenum,2)-1)]);
            else
                assert(1==0,'Label error');
            end
        end
        
        
        %
        % Relabel test file labels as +1 or -1
        linenum=0;
        while(linenum<num_test)
            linenum=linenum+1;
            fseek(test_file_id, metadata_test(linenum,1),'bof');
            if negative_labels(metadata_test(linenum,3))==1
                fwrite(test_file_id, [num2str(-1) repmat(' ',1,metadata_test(linenum,2)-2)]);
            elseif positive_labels(metadata_test(linenum,3))==1
                fwrite(test_file_id, [num2str(1) repmat(' ',1,metadata_test(linenum,2)-1)]);
            else
               assert(1==0,'Label error');
            end
        end
        
        fclose(train_file_id);
        fclose(test_file_id);
        
        unix('chmod +x ../liblinear_train');
        unix('chmod +x ../liblinear_predict');
        for c_index=1:length(C_vals)
            
            % Train model
            
            C_value=C_vals(c_index)
            modelfile_name=['models/' num2str(pivot_class_label) '_' num2str(C_value,'%5.0e')];
            SVM_train_command=['../liblinear_train -q -s 0 -B 1 -c ' num2str(C_value,'%5.0e') ' ' new_name_trainfile ' ' modelfile_name];
            unix(SVM_train_command);
            
            % Make predictions on validation and testfile
            
          
            outputfile2_name=[ outputs_folder '/' num2str(pivot_class_label) '_' num2str(C_value,'%5.0e')];
          
            
            SVM_predict_command2=['../liblinear_predict -b 1 ' new_name_testfile ' ' modelfile_name ' ' outputfile2_name];
            unix(SVM_predict_command2);
            
            % Delete model file
            delete_command=['rm ' modelfile_name];
            unix(delete_command);
            
          
            
            % Read output on test set save as matfile in same folder
            % and delete the text file output
            
            test_outputfile=fopen(outputfile2_name);
            values=zeros(num_test,1);
            line=fgetl(test_outputfile);  % Read first line and find out what label is +1
            components=regexp(line,' ','split');
            if length(components)==2 && str2double(components{2})==1
                pos_index=2;
            elseif length(components)==2 && str2double(components{2})==-1
                pos_index=-1;
            elseif str2double(components{2})==1 && str2double(components{3})==-1 
                pos_index=2;
            elseif str2double(components{2})==-1 && str2double(components{3})==1 
                pos_index=3;
                assert(1==0,'Liblinear swaps labels');
            else
                assert(1==0,'Liblinear outputs wrong');
            end  
            
            for i=1:num_test
                line=fgetl(test_outputfile);
                components=regexp(line,' ','split');
                if pos_index==-1
                    values(i)=0;
                else    
                    values(i)=str2double(components{pos_index});
                end
            end
            fclose(test_outputfile);
            
            % values=int8(100*values);
            
            delete_command=['rm ' outputfile2_name];
            unix(delete_command);
            
            save(outputfile2_name,'values');
            
            
        end
        
        
        delete_command=['rm -r -f ' temp_folder_name];
        unix(delete_command);
    end
end







