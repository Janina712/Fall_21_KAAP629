% import dataset
[num, txt, raw] = xlsread('plantData.xlsx');

%calculate variable means
variable_means = mean(num);
avg_sepal_length = variable_means(1);
avg_sepal_width = variable_means(2);
avg_petal_length = variable_means(3);
avg_petal_width = variable_means(4);

% calculate covariance 
N = length(num);

cov_sl_sw =(sum((num(:,1)-avg_sepal_length).*(num(:,2)-avg_sepal_width)))/N;
cov_sl_pl = (sum((num(:,1)-avg_sepal_length).*(num(:,3)-avg_petal_length)))/N;
cov_sl_pw = (sum((num(:,1)-avg_sepal_length).*(num(:,4)-avg_petal_width)))/N;
cov_sw_pl = (sum((num(:,2)-avg_sepal_width).*(num(:,3)-avg_petal_length)))/N;
cov_sw_pw = (sum((num(:,2)-avg_sepal_width).*(num(:,4)-avg_petal_width)))/N;
cov_pl_pw = (sum((num(:,3)-avg_petal_length).*(num(:,4)-avg_petal_width)))/N;

% calculate variance 
var_sl = ((sum((num(:,1) - avg_sepal_length).^2)))/(N-1);
var_sw = ((sum((num(:,2) - avg_sepal_width).^2)))/(N-1);
var_pl = ((sum((num(:,3) - avg_petal_length).^2)))/(N-1); 
var_pw = ((sum((num(:,4) - avg_petal_width).^2)))/(N-1); 

% construct covariance matrix
cov_matrix = {' ', 'sepal_length', 'sepal_width', 'petal_length', 'petal_width'; 
              'sepal_length', var_sl, cov_sl_sw, cov_sl_pl, cov_sl_pw; 
              'sepal_width', cov_sl_sw, var_sw, cov_sw_pl, cov_sw_pw; 
              'petal_length', cov_sl_pl, cov_sw_pl, var_pl, cov_pl_pw;
              'petal_width', cov_sl_pw, cov_sw_pw, cov_pl_pw, var_pw};
disp(cov_matrix)

% visualize
% 2x2 example: sepal length and width of iris setosa
num = num([1:50],[1,2]); 

% construct new means
variable_means = mean(num);
avg_sepal_length = variable_means(1);
avg_sepal_width = variable_means(2);

% construct new covariance matrix
N = length(num);

cov_sl_sw =(sum((num(:,1)-avg_sepal_length).*(num(:,2)-avg_sepal_width)))/(N-1);

var_sl = ((sum((num(:,1) - avg_sepal_length).^2)))/(N-1);
var_sw = ((sum((num(:,2) - avg_sepal_width).^2)))/(N-1);

matrix2plot = {' ', 'sepal_length', 'sepal_width'; 
              'sepal_length', var_sl, cov_sl_sw; 
              'sepal_width', cov_sl_sw, var_sw};

disp(matrix2plot)

% create figure and axes 
figure;
ax2 = axes;
hold on
plot(ax2, [num(1:50,1)],[num(1:50,2)],'ko','markerFaceColor','#9867C5')
set(gca,'DataAspectRatio',[1 1 1])
title('Iris Setosa')
xlabel('sepal length')
ylabel('sepal width')

% create eigenvectors and values
M = cell2num(matrix2plot([2,3],[2,3]));
T = cov([num(:,1)],[num(:,2)]);              % sanity check

%if isequal(M,T)      rounding difference?

[v,d] = eig(M); 

% scale eigenvectors by eigenvalues
d = sqrt(diag(d));

v_x1 = v(1,1)*abs(d(1));
v_x2 = v(2,1)*abs(d(2));
v_y1 = v(1,2)*abs(d(1));
v_y2 = v(2,2)*abs(d(2));

% plot eigenvectors
hold on;
quiver(mean(num([1:50],1)),mean(num([1:50],2)),v_x1,v_y1,'k','LineWidth',2);
quiver(mean(num([1:50],1)),mean(num([1:50],2)),v_x2,v_y2,'r','LineWidth',2);

%else 
%    disp('Problem with covariance matrix')
%end
