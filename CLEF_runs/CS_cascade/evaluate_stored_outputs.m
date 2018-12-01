%% Threshold the stored results on validation/test set to get loss incurred :
clear all;
trainmode=2;

'==============================================================='
load ../hierarchy_data

if trainmode==1
    load ./validation_results/results test_predictions_levels_store C_vals metadata_test
else
    load ./final_results/results test_predictions_levels_store C_vals metadata_test
end

h=length(test_predictions_levels_store{1})+1;
num_test=length(test_predictions_levels_store{1}{1});

error_fraction=zeros(length(C_vals),1);
    error_fraction_dash=zeros(length(C_vals),1);

best_err=inf;    
for c_index=1:length(C_vals)
    C = C_vals(c_index)
    test_predictions_levels=test_predictions_levels_store{c_index};
    test_thresholded_predictions_levels=cell(h-1,1);
%     
%     for t1=0:2:20
%         t1
%     for t2=0:2:20
%         t2
%     for t3=0:2:20
%         t3

%         
    thres_schedule=[6 16 16] % Recall anything between 0 and 100 is consistent
%     thres_schedule=[t1 t2 t3 t4 t5];    
    for curr_lev=1:(h-1)
        thres=thres_schedule(curr_lev);
        test_thresholded_predictions_levels{curr_lev}=test_predictions_levels{curr_lev}(:,1);
        test_thresholded_predictions_levels{curr_lev}(test_predictions_levels{curr_lev}(:,2)<thres)=-1;
    end
    
    total_loss=0;
    total_loss_dash=0;
    total_zo_loss=0;
    total_zo_loss_dash=0;
    
    
    for i=1:num_test
        
        i;
        y=metadata_test(i,3);
        
        curr_preds_levels=[ones(1,h-1) -1];
        for curr_lev=1:(h-1)
            curr_preds_levels(curr_lev)=test_thresholded_predictions_levels{curr_lev}(i);
        end
        
        pred_index=find(curr_preds_levels~=-1,1,'last');
        if isempty(pred_index)
            y_i_hat=1;
        else
            y_i_hat=curr_preds_levels(pred_index);
        end
        
        if curr_preds_levels(1)==-1
            y_i_hat_dash=1;
        else
            pred_index_dash=find(curr_preds_levels==-1,1,'first')-1;
            y_i_hat_dash=curr_preds_levels(pred_index_dash);
        end
        
        
        
        y_i=y;
        
        loss=sum(abs(descendants(:,y_i)-descendants(:,y_i_hat)));
        loss_dash=sum(abs(descendants(:,y_i)-descendants(:,y_i_hat_dash)));
        zo_loss= (y_i~=y_i_hat);
        zo_loss_dash= (y_i~=y_i_hat_dash);
        
        total_loss=total_loss+loss;
        total_loss_dash=total_loss_dash+loss_dash;
        
        total_zo_loss=total_zo_loss+zo_loss;
        total_zo_loss_dash=total_zo_loss_dash+zo_loss_dash;
    end
    
    
    
    avg_loss=total_loss/num_test
    avg_loss_dash=total_loss_dash/num_test;
    
    avg_zo_loss=total_zo_loss/num_test;
    avg_zo_loss_dash=total_zo_loss_dash/num_test;
    
    error_fraction(c_index)=avg_loss;
    error_fraction_dash(c_index)=avg_loss_dash;
    
    if avg_loss<best_err
        best_err=avg_loss;
        best_thres=thres_schedule;
    end
    
%     end
%     end
%     end
    
end
'==============================================================='