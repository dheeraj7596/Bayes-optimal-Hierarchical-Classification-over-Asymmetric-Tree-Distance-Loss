%% Read the hierarchy and create the children and descendants variables
'Stage 1'
clear all
hierarchy_file_id=fopen('./Dataset_files/clef.hierarchy');
preprocessed_hierarchy_file_id=fopen('./Dataset_files/prepped_hierarchy','w');
line=fgets(hierarchy_file_id);
line_break=line(end);
frewind(hierarchy_file_id);


% Classes are labelled from 0 to 96, with 0 as the root in the original.
% Modified labels from 1 to 97. 1 as root at level 0 . 2 - 9 as level 1
% nodes and so on.


num_classes=97;
class_label_mapping=zeros(num_classes,1); % class_label_mapping (i) gives the class label (i-1) is mapped to. In particular CLM(1)=1 as zero is mapped to 1.

children=zeros(num_classes);

% Read hierarchy file and create children matrix for original labels
while 1
    line=fgetl(hierarchy_file_id);
    if line==-1
        break;
    end
    nodes_string=regexp(line,'[\s]+','split');
    
    node1=str2double(nodes_string{1});
    
    for j=3:length(nodes_string)
        if isempty(nodes_string{j})
            continue;
        end
        node2=str2double(nodes_string{j});
        children(node1+1,node2+1)=1;
    end
end
frewind(hierarchy_file_id);


% Find out node leveles for original labels
nodes_level=-inf*ones(num_classes,1);
nodes_level(1)=0;

for i=2:num_classes
    nodes_level(i) = nodes_level(find(children(:,i),1,'first'))+1;  % parent in the original hierarchy has always lower index
end

% Calculate class mapping

for i=0:max(nodes_level)
    class_label_mapping(nodes_level==i) = max(class_label_mapping) + (1:sum(nodes_level==i)) ;
end


% Write hierarchy file with mapped labels and create children matrix for
% mapped labels.
children=zeros(num_classes);

while 1
    line=fgetl(hierarchy_file_id);
    new_line=[];
    if line==-1
        break;
    end
    nodes_string=regexp(line,' ','split');
    
    node1=class_label_mapping(str2double(nodes_string{1})+1);
    new_line=[new_line num2str(node1)];
    new_line=[new_line ' ' nodes_string{2}];
    
    for j=3:length(nodes_string)
        if isempty(nodes_string{j})
            continue;
        end
        node2=class_label_mapping( str2double(nodes_string{j}) + 1 );
        new_line=[new_line ' ' num2str(node2) ];
        children(node1,node2)=1;
        
    end
    new_line=[new_line line_break];
    fwrite(preprocessed_hierarchy_file_id,new_line);
end
fclose(hierarchy_file_id);
fclose(preprocessed_hierarchy_file_id);


% Create node levels for mapped labels
nodes_level=-inf*ones(num_classes,1);
nodes_level(1)=0;

for i=2:num_classes
    nodes_level(i) = nodes_level(find(children(:,i),1,'first'))+1;  % parent in the mapped hierarchy has always lower index
end


% Create descendants matrix

descendants=eye(num_classes);

for i=num_classes:-1:1
    cur_children=find(children(i,:));
    if isempty(cur_children)
        continue;
    end
    for j=cur_children
        descendants(i,:)=descendants(i,:)+descendants(j,:); 
    end
end

rootnodes=find(nodes_level==1);

save hierarchy_data children descendants rootnodes  class_label_mapping line_break nodes_level

%% Process the train, test and validation files

% Creates multiclass train test and validation files in the
% SVMlight/LIBLINEAR format

clear all;
'Stage 2'
load hierarchy_data class_label_mapping

multiclass_train_file_id=fopen('./Dataset_files/train_vali_test_concat_raw.txt');
feature_index_mapping=sparse(0); % vector of length the maximum feature index occurring. FIM(i)=0 if i never occurs otherwise FIM(i) is the remapped index of i
feature_counts=[];

num_samples=11006;
num_train=9000;
num_vali=1000;
num_test=1006;



RandStream.setDefaultStream ...
    (RandStream('mt19937ar','seed',100));
selections=[randperm(num_train+num_vali) ((num_train+num_vali+1):num_samples) ];


preprocessed_train_file_id=fopen('./Dataset_files/prepped_train.txt','w');
preprocessed_validation_file_id=fopen('./Dataset_files/prepped_vali.txt','w');
preprocessed_test_file_id=fopen('./Dataset_files/prepped_test.txt','w');

line=fgets(multiclass_train_file_id);
line_break=line(end);
frewind(multiclass_train_file_id);

linenum=0;
line=1;

curr_train=0;
curr_vali=0;
curr_test=0;

metadata_train=zeros(num_train,3); % (i,1) - position of line i in train, (i,2) - length of class label , (i,3) - class label
metadata_vali=zeros(num_vali,3);
metadata_test=zeros(num_test,3);

while(1)
    linenum=linenum+1;
    line=fgetl(multiclass_train_file_id);
    if line==-1
        break;
    end
    
    components=regexp(line,'[\s]+','split');
    class=str2double(components{1});
    class=class_label_mapping(class + 1);
    
    components{1}=[num2str(class) ' '];
    
    
    line=components{1};
    for j=2:length(components)
        if components{j}(1)=='#'
            break;
        end
        line=[line ' ' components{j}];
    end
    
    line=[line line_break];
    
    if selections(linenum)<=num_train
        curr_train=curr_train+1;
        metadata_train(curr_train,1)=ftell(preprocessed_train_file_id);
        fwrite(preprocessed_train_file_id,line);
        metadata_train(curr_train,2)=length(components{1});
        metadata_train(curr_train,3)=class;
    elseif selections(linenum)<=num_train+num_vali
        curr_vali=curr_vali+1;
        metadata_vali(curr_vali,1)=ftell(preprocessed_validation_file_id);
        fwrite(preprocessed_validation_file_id,line);
        metadata_vali(curr_vali,2)=length(components{1});
        metadata_vali(curr_vali,3)=class;
    elseif selections(linenum)<=num_train+num_vali+num_test
        curr_test=curr_test+1;
        metadata_test(curr_test,1)=ftell(preprocessed_test_file_id);
        fwrite(preprocessed_test_file_id,line);
        metadata_test(curr_test,2)=length(components{1});
        metadata_test(curr_test,3)=class;
    end
end

fclose(multiclass_train_file_id);
fclose(preprocessed_train_file_id);
fclose(preprocessed_validation_file_id);
fclose(preprocessed_test_file_id);

save metadata metadata_train metadata_vali feature_index_mapping feature_counts


%% Create final train  file and metadata
'Stage 3'
clear all
preprocessed_train_file_id=fopen('./Dataset_files/prepped_train.txt','r');
preprocessed_validation_file_id=fopen('./Dataset_files/prepped_vali.txt','r');
preprocessed_test_file_id=fopen('./Dataset_files/prepped_test.txt','r');

preprocess_full_train_file_id=fopen('./Dataset_files/prepped_final_train.txt','w');

num_train=9000;
num_vali=1000;
num_test=1006;

metadata_train=zeros(num_train,3);
metadata_test=zeros(num_test,3);

for linenum=1:num_train
    line=fgets(preprocessed_train_file_id);
    if line==-1
        break;
    end
    components=regexp(line,'[\s]+','split');
    metadata_train(linenum,1)=ftell(preprocess_full_train_file_id);
    metadata_train(linenum,2)=length(components{1});
    metadata_train(linenum,3)=str2double(components{1});
    fwrite(preprocess_full_train_file_id,line);
end

for linenum=(1+num_train):(num_train+num_vali)
    line=fgets(preprocessed_validation_file_id);
    if line==-1
        break;
    end
    components=regexp(line,'[\s]+','split');
    metadata_train(linenum,1)=ftell(preprocess_full_train_file_id);
    metadata_train(linenum,2)=length(components{1});
    metadata_train(linenum,3)=str2double(components{1});
    fwrite(preprocess_full_train_file_id,line);
end


for linenum=1:num_test
    line=fgetl(preprocessed_test_file_id);
    if line==-1
        break;
    end
    components=regexp(line,'[\s]+','split');
    metadata_test(linenum,1)=ftell(preprocessed_test_file_id);
    metadata_test(linenum,2)=length(components{1});
    metadata_test(linenum,3)=str2double(components{1});
end

load metadata feature_index_mapping feature_counts
save final_metadata metadata_train metadata_test feature_index_mapping feature_counts

%%  Create the loss matrix file and ancestors file
'Stage 4'
clear all
load hierarchy_data
loss_matrix=zeros(size(children));
ancestors=-1*ones(length(children),max(nodes_level)+1);

graph_hierarchy=children+children' ;

for i=1:length(children)
    distances=graphshortestpath(sparse(graph_hierarchy),i);
    loss_matrix(i,:)=distances;
end

for i=1:length(children)
    curr_ancests=[i];
    while 1
        parent=find(children(:,curr_ancests(1)));
        if isempty(parent)
            break;
        end
        curr_ancests=[parent curr_ancests];
    end
    ancestors(i,1:length(curr_ancests))=curr_ancests;
end

loss_matrix_file_id=fopen('./Dataset_files/loss_matrix_file','w');
fwrite(loss_matrix_file_id,['{' line_break]);
for i=1:length(loss_matrix)
    i;
    row=loss_matrix(i,:);
    line=['{' num2str(row(1))];
    for j=2:length(row)
        line=[line ',' num2str(row(j))];
    end
    line=[line '},' line_break];
    fwrite(loss_matrix_file_id,line);
end
fwrite(loss_matrix_file_id,['};' line_break]);
fclose(loss_matrix_file_id);

ancestors_file_id=fopen('./Dataset_files/ancestors_file','w');
fwrite(loss_matrix_file_id,['{' line_break]);
for i=1:length(ancestors)
    i;
    row=ancestors(i,:);
    line=['{' num2str(row(1))];
    for j=2:length(row)
        line=[line ',' num2str(row(j))];
    end
    line=[line '},' line_break];
    fwrite(ancestors_file_id,line);
end
fwrite(ancestors_file_id,['};' line_break]);
fclose(ancestors_file_id);

% 

    