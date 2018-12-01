
test_thresholded_predictions_levels=cell(h,1);



for curr_lev=1:(h-1)
    thres=thres_schedule(curr_lev);
    test_thresholded_predictions_levels{curr_lev}=test_predictions_levels{curr_lev}(:,1);
    test_thresholded_predictions_levels{curr_lev}(test_predictions_levels{curr_lev}(:,2)<thres)=-1;
end

total_loss=0;
total_loss_dash=0;
total_zo_loss=0;
total_zo_loss_dash=0;

preds_index=zeros(num_test,1);



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
        preds_index(i)=0;
    else
        y_i_hat=curr_preds_levels(pred_index);
        preds_index(i)=pred_index;
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
    
%     OVA_zo_err = OVA_zo_err+ (y_i ~=OVA_y_hat(i));
%     OVA_err= OVA_err +
%     sum(abs(descendants(:,y_i)-descendants(:,OVA_y_hat(i) ) ) );
    
    total_loss=total_loss+loss;
    total_loss_dash=total_loss_dash+loss_dash;
    
    total_zo_loss=total_zo_loss+zo_loss;
    total_zo_loss_dash=total_zo_loss_dash+zo_loss_dash;
end



avg_loss=total_loss/num_test
avg_loss_dash=total_loss_dash/num_test;

avg_zo_loss=total_zo_loss/num_test;
avg_zo_loss_dash=total_zo_loss_dash/num_test;

