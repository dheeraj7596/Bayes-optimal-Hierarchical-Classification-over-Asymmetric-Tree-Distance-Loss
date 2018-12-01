clear all;
addpath ../util
load ../hierarchy_data
trainmode=2; % 1 for validation 2 for testing.



    level_files_folder='level_files';

if trainmode==1
unix('rm -r -f temp');
unix('mkdir temp');
else
unix('rm -r -f temp_final');
unix('mkdir temp_final');
end

if trainmode==1
    train_file_name='train';
    test_file_name='vali';
    load ../metadata metadata_train metadata_vali
    metadata_test=metadata_vali;
    clear metadata_vali;
    num_test=length(metadata_test);
    num_train=length(metadata_train);
    C_vals=[10 100 1000 10000 100000];
else
    train_file_name='full';
    test_file_name='test';
    load ../final_metadata metadata_train metadata_test
    num_test=length(metadata_test);
    num_train=length(metadata_train);
    C_vals=10000;
end



h=max(nodes_level)+1;






vali_predictions_levels_store=cell(length(C_vals),1);
test_predictions_levels_store=cell(length(C_vals),1);

%         width=1;
for C_index=1:length(C_vals)
        C=C_vals(C_index)
        
        
        run_cascade_CS
        
end

if trainmode==1
    unix('rm -r -f validation_results');
    unix('mkdir validation_results');
    save ./validation_results/results test_predictions_levels_store C_vals metadata_test
else
    unix('rm -r -f final_results');
    unix('mkdir final_results');
    save ./final_results/results test_predictions_levels_store C_vals metadata_test
end
 


rmpath ../util
save lshtc_results