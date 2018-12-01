function write_data_SVM_light(X,Y,fileID)
% X : n x d matrix (reals)
% Y : n x 1 matrix (multiclass, 1 to k or binary +1,-1)
% writes the X  and Y matrices  in SVM light format
%Close file at end
[n,d]=size(X);
eps=1e-7;
for i=1:n
    fprintf(fileID,'%d ',Y(i));
    for j=1:d
        if abs(X(i,j))<eps
            continue;
        end
        fprintf(fileID,'%d:%f ',j,X(i,j));
    end
    fprintf(fileID,'\n');
end
fclose(fileID);

