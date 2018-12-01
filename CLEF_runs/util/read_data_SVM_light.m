function [X,Y]=read_data_SVM_light(fileID)
% X : n x d matrix (reals)
% Y : n x 1 matrix (multiclass, 1 to k)
% wites the X  and Y matrices  in SVM light format
%Closes file at end

line=fgetl(fileID);
X=[];
Y=[];
i=1;
while line~=-1
    components=regexp(line,' ','split');
    Y=[Y; str2num(components{1})];
    for j=2:length(components)
        if sum(components{j}==':')==0
            continue;
        end
        word=regexp(components{j},':','split');
        index=str2num(word{1});
        value=str2num(word{2});
        X(i,index)=value;
    end
    line=fgetl(fileID);
    i=i+1;
end

fclose(fileID);

    