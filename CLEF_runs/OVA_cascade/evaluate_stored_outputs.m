%% Do validation 
clear all;
trainmode=2;
load ../hierarchy_data.mat


if trainmode==1
    C_vals=[0.001 0.01 0.1 1 10];
    load ../metadata metadata_train metadata_vali
    metadata_test=metadata_vali;
    clear metadata_vali;
    outputfiles_folder='outputs_validation';

elseif trainmode==2
    C_vals=[1];
    load ../final_metadata metadata_train metadata_test
    outputfiles_folder='outputs';

end





num_test=length(metadata_test);

error_fraction=zeros(length(C_vals),1);
error_fraction_dash=zeros(length(C_vals),1);
OVA_error_fraction=zeros(length(C_vals),1);

test_predictions_levels_store=cell(length(C_vals),1);

h=max(nodes_level)+1;



for c_index=1:length(C_vals)
    C_value=C_vals(c_index)
    test_predictions_levels=cell(h-1,1);
    
    
    
    
    
    OVA_y_hat=zeros(num_test,1);
    curr_best_scores=-Inf*ones(num_test,1);
    for node=1:length(nodes_level)
        if sum(descendants(node,:))>1
            continue;
        end
        file_name=[outputfiles_folder '/' num2str(node) '_' num2str(C_value,'%5.0e') '.mat'] ;
        load(file_name);        
        new_win_indices=values>curr_best_scores;
        OVA_y_hat(new_win_indices) = node;
        curr_best_scores(new_win_indices)=values(new_win_indices);
    end
    OVA_zo_err=sum(OVA_y_hat~=metadata_test(:,3))/num_test
    
    for i=1:num_test
        y=metadata_test(i,3);
        y_hat=OVA_y_hat(i);
        OVA_error_fraction(c_index)=OVA_error_fraction(c_index) ...
            + sum(abs(descendants(:,y)-descendants(:,y_hat)));
    end
    
    for level=1:h-1
        preds_test=zeros(num_test,2);
        preds_test(:,2)=-Inf; % Low number
        nodes=find(nodes_level==level);
        for node_index=1:length(nodes)
            node=nodes(node_index);
            file_name=[outputfiles_folder '/' num2str(node) '_' num2str(C_value,'%5.0e') '.mat'] ;
            load(file_name);
            preds_test(values>preds_test(:,2),1)=node;
            preds_test(:,2)=max(preds_test(:,2),double(values));
        end   
        test_predictions_levels{level}=preds_test;
    end
    
    test_predictions_levels_store{c_index}=test_predictions_levels;
    
    thres_schedule=[inf inf inf inf inf] % Recall anything between -20 and 20 gives consistency
    decode_tree_scores;
    
    thres_schedule=-[inf inf inf inf inf] % Recall anything between -20 and 20 gives consistency
    decode_tree_scores;
%     
    
    thres_schedule=[0 0 0 0 0] % Recall anything between -20 and 20 gives consistency
    decode_tree_scores;
    
    
    error_fraction(c_index)=avg_loss;
    error_fraction_dash(c_index)=avg_loss_dash;
end

C_vals
error_fraction
OVA_error_fraction=OVA_error_fraction/num_test