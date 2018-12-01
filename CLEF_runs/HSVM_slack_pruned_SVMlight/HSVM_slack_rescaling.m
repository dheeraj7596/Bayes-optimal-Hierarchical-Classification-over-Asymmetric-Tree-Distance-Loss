clear all;
addpath ../util
trainmode=2;
load ../hierarchy_data.mat

if trainmode==1
    load ../metadata metadata_train metadata_vali
    metadata_test=metadata_vali;
    clear metadata_vali
    train_file='prepped_train.txt';
    test_file='prepped_vali.txt';
    C_vals=[1 10 100];
    outputs_folder='validation';
else
    load ../final_metadata metadata_train metadata_test
    train_file='prepped_final_train.txt';
    test_file='prepped_test.txt';
    outputs_folder='final';
    C_vals=10;
end


num_test=length(metadata_test);
num_train=length(metadata_train);

h=max(nodes_level)+1;


type='linear';


% unix(['rm -r -f ' outputs_folder]);
unix(['mkdir ' outputs_folder]);
unix('chmod +x ../HSVM_CLEF_classify');
unix('chmod +x ../HSVM_CLEF_learn');

for C_index=1:length(C_vals)
    C_value=C_vals(C_index)
    
    command=['../HSVM_CLEF_learn -v 1 -o 1 -c ' num2str(C_value) ' ../Dataset_files/' train_file '  ' outputs_folder '/model' num2str(C_value,'%5.0e')];
    unix(command);
    
    command=['../HSVM_CLEF_classify ../Dataset_files/' test_file  ' ' outputs_folder '/model' num2str(C_value,'%5.0e') '  ' outputs_folder '/predictions_' num2str(C_value,'%5.0e')];
    unix(command);
    
    
%     command=['rm -r -f temp'];
%     unix(command);
end

rmpath ../util