%% Run Crammer-Singer on appropriately modified datasets
test_predictions_levels=cell(h-1,1);


for level=1:(h-1)
    level
    
    if trainmode==1
        command=['../svm_light_Cram-Sing_learn -v 0 -c ' num2str(C) ' ' level_files_folder '/' train_file_name '_' num2str(level) ' ./temp/model_' ...
            num2str(level) '_' num2str(C,'%5.0e')];
        unix(command);
        
        command=['../svm_light_Cram-Sing_classify ' level_files_folder '/' test_file_name '_'  num2str(level) ' ./temp/model_' ...
            num2str(level) '_' num2str(C,'%5.0e') ' ./temp/predictions'];
        
        unix(command);
        
        test_results_file=fopen('./temp/predictions');
        test_score_matrix=read_predictions_SVM_light(test_results_file);
        
        unix('rm ./temp/predictions');
        
    else
        command=['../svm_light_Cram-Sing_learn -v 0 -c ' num2str(C) ' ' level_files_folder '/' train_file_name '_' num2str(level) ' ./temp_final/model_' ...
            num2str(level) '_' num2str(C,'%5.0e')];
        unix(command);
        
        command=['../svm_light_Cram-Sing_classify ' level_files_folder '/' test_file_name '_'  num2str(level) ' ./temp_final/model_' ...
            num2str(level) '_' num2str(C,'%5.0e') ' ./temp_final/predictions'];
        
        unix(command);
        
        test_results_file=fopen('./temp_final/predictions');
        test_score_matrix=read_predictions_SVM_light(test_results_file);
        
        unix('rm ./temp_final/predictions');
        
    end
    
    
    
    
    
    
    
    preds_test=zeros(num_test,2);
    
    for i=1:num_test
        scores=test_score_matrix(i,:);
        preds_test(i,1)=find(scores==max(scores));
        scores=sort(scores,'descend');
        preds_test(i,2)=scores(1)-scores(2);
    end
    
    
    test_predictions_levels{level}=preds_test;
end


test_predictions_levels_store{C_index}=test_predictions_levels;


