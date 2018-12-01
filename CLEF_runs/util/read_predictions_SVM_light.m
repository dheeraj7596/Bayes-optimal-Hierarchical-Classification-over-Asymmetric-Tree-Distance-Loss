function score_matrix=read_predictions_SVM_light(fileID)
% score_matrix: n x k matrix, each row gives the score of k classes for one
% instance.
% In case of k=2, gives single score for each instance.
%Closes file at end

line=fgetl(fileID);
score_matrix=[];
i=1;
while line~=-1
    components=regexp(line,' ','split');
    if length(components)==1
        score_matrix(i)=str2num(components{1});
    else
        for j=2:length(components)
            value=str2num(components{j});
            score_matrix(i,j-1)=value;
        end
    end
    line=fgetl(fileID);
    i=i+1;
end
fclose(fileID);