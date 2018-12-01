%% Do validation 
clear all;
trainmode=2;
load ../hierarchy_data.mat

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
end


num_test=length(metadata_test);


error_fraction=zeros(length(C_vals),1);
error_fraction_dash=zeros(length(C_vals),1);
test_predictions_levels_store=cell(length(C_vals),1);

h=max(nodes_level)+1;


for c_index=1:length(C_vals)
    C_value=C_vals(c_index)
    test_predictions_levels=cell(h-1,1);
    for level=1:h-1
        preds_test=zeros(num_test,2);
        preds_test(:,2)=-inf; % Low number
        nodes=find(nodes_level==level);
        for node_index=1:length(nodes)
            node=nodes(node_index);
            file_name=[outputs_folder '/' num2str(node) '_' num2str(C_value,'%5.0e') '.mat'] ;
            load(file_name);
            preds_test(values>preds_test(:,2),1)=node;
            preds_test(:,2)=max(preds_test(:,2),double(values));
        end   
        test_predictions_levels{level}=preds_test;
    end
    
    
    
    test_predictions_levels_store{c_index}=test_predictions_levels;
    
    cur_preds=zeros(num_test,1);
    cur_probs=zeros(num_test,1);
    for level=h-1:-1:1
        new_indices=((test_predictions_levels{level}(:,2)>cur_probs) .* (cur_probs<0.5))>0.5;
        cur_preds(new_indices,1)=test_predictions_levels{level}(new_indices,1);
        cur_probs(new_indices,1)=test_predictions_levels{level}(new_indices,2);
    end
    total_loss=0;
    for i=1:num_test
        y=metadata_test(i,3);
        y_hat=cur_preds(i);
        loss=sum(abs(descendants(:,y)-descendants(:,y_hat)));
        total_loss=total_loss+loss;
    end
    avg_loss=total_loss/num_test
    error_fraction(c_index)=avg_loss;
end
% error_fraction
