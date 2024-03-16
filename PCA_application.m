% plot electrode locations
load('chan_locs.mat')

chan_coordinates = chan_locs{2,1};
plot3(chan_coordinates(1,:),chan_coordinates(2,:),chan_coordinates(3,:),'*')
grid on 
axis square

title('Electrode Montage')
xlabel('posterior - anterior')
ylabel('left - right')
zlabel('inferior - superior')

labels = chan_locs{1,1};
text(chan_coordinates(1,:),chan_coordinates(2,:),chan_coordinates(3,:),labels,'VerticalAlignment','bottom','HorizontalAlignment','right')

%% Import data
load('group_01_sujet_01.mat')
load('Header.mat')

%extract subject 1, session 1
data = samples(:,[1:33,66,67]); 
data_header = Header(1,[1:33,66,67]);

measures_per_second = 512; 
exp_duration = data(end,1); %in seconds

%% re-sructure data
%240 trials, 40 targets, 200 non-targets (divided into two blocks)
% assign to trials
trial_rown = find((data(:,34)~=0) & (data(:,34) <100)); 
start = 0; 
trial_rown = [start; trial_rown]; 

idx = [1 : (length(trial_rown)-1)]; 
trialn = zeros(length(data),1); 

for i = idx 
     if  ((data(:,1) < trial_rown(i)) & (i == 240))
       trialn([trial_rown(i+1):length(data)],1) = i;    
     elseif ((data(:,1) < trial_rown(i+1))& (i ~= 1))
       trialn([trial_rown(i+1):trial_rown(i+2)],1) = i;
     elseif ((data(:,1) < trial_rown(i+1))& (i == 1))
        trialn([trial_rown(i+1):trial_rown(i+2)],1) = i;
    end
end

data = [data trialn];

%average for each time point across all trials 
count_trial_rows = zeros(length(data),1); 

for i = idx
    sub_rown = find(data(:,36)== i); 
    sub_count = [1:length(sub_rown)]'; %number of items in trial

    row_values = [sub_rown(1):sub_rown(length(sub_rown))];    
    count_trial_rows(row_values) = sub_count ; 
end

data = [data count_trial_rows];

%average over column for each row that represents the same time point
avg_elec_time = zeros(max(data(:,37)),32);

for i = 1 : max(data(:,37)) 
   time_pnt = find(data(:,37)== i); 
   electrodes_at_time = data(time_pnt,:);
   avg_elec = mean(electrodes_at_time(:,[2:33])); 
   avg_elec_time(i,:) = avg_elec; 
end

%% plot ERP
time = [1:4775]';
chan2plot = 10;
figure
yt = movmean(avg_elec_time([1:4775],chan2plot),50); 
plot(time, yt)
set(gca, 'xlim',[0 4775])
title(['ERP at electrode ', num2str(chan2plot)])

%during P3 time window
time = [1:4775]';
chan2plot = 10;
figure
yt = movmean(avg_elec_time([1:4775],chan2plot),50); 
plot(time, yt)
set(gca, 'xlim',[0 800])
set(gca, 'ylim',[62540 62600])
title(['ERP at electrode ', num2str(chan2plot)])
xlabel('time (ms)')
ylabel('Voltage (mV)')
xt = [285];
yt = [62590];
str = {'P300'};
text(xt,yt,str)

%% PCA !!
%Calculate for 2 variables using eigenvector function
cov2 = cov(data(:,[2,3])); 
[v2,d2] = eig(cov2);

%check using pca function
[PCCOEFF, PCVEC] = pca(data(:,[2,3])); 

%all
[PCCOEFF2, PCVEC2] = pca(data(:,[2:33])); 
cov_matrix = cov(data(:,[2:33])); 

%% determine which variable contributes the most in a principal component
number_of_principle_components = 32;
number_of_variables = 32;

correlation_matrix = zeros(number_of_principle_components, number_of_variables);

for i = 1:number_of_principle_components
for j = 1:number_of_variables
correlation = corr(PCVEC2(:,i),cov_matrix(:,j));
correlation_matrix(i,j) = correlation;
end
end

pos_corr = max(correlation_matrix');
neg_corr = min(correlation_matrix'); 
corrs = [pos_corr; neg_corr]; 

max_corr_per_component = max(abs(corrs)); 

for i = 1 : 32
if corrs(1,i) == max_corr_per_component(i) ||corrs(2,i) == max_corr_per_component(i) 
    
else 
    max_corr_per_component(i) = max_corr_per_component(i) * (-1); 
end
end

%now which column does the biggest correlation come from?
corr_location = zeros(2,32);

for i = 1:number_of_principle_components
    [row_idx, col_idx] = find(correlation_matrix == max_corr_per_component(i));
    corr_location(1,i) = row_idx;
    corr_location(2,i) = col_idx;
end

%biggest single contributor of 4 most important principle components
elecs_of_4_pc = corr_location(2,[1:4]); 

%% plot waveforms
load('Header.mat')
elec_labels = Header(2:33); 
elec_labels = strrep(elec_labels,'_1','');
pc_elecs = elec_labels(elecs_of_4_pc); 

figure;
for i = 1:length(elecs_of_4_pc)
subplot(2,2,i)
time = [1:4775]';
chan2plot = elecs_of_4_pc(i);
yt = movmean(avg_elec_time([1:4775],chan2plot),50); 
plot(time, yt)
set(gca, 'xlim',[0 4775])
title(['PC #', num2str(i), 'ERP at electrode ', pc_elecs(i)])
xlabel('time (ms)')
ylabel('Voltage (mV)')
end

%% plot electrodes 3D
mz = zeros(1,4); 
for i = 1:4
value = strcmp(pc_elecs(i),labels);
m = find(value == 1);
mz(i) = m; 
end

figure;
plot3(chan_coordinates(1,:),chan_coordinates(2,:),chan_coordinates(3,:),'*')
hold on
plot3(chan_coordinates(1,mz),chan_coordinates(2,mz),chan_coordinates(3,mz),'*','markerSize',10, 'markerEdgeColor','r')
grid on
axis square
title('Electrode Montage')
xlabel('posterior - anterior')
ylabel('left - right')
zlabel('inferior - superior')
labels = chan_locs{1,1};
text(chan_coordinates(1,:),chan_coordinates(2,:),chan_coordinates(3,:),labels,'VerticalAlignment','bottom','HorizontalAlignment','right')

%% plot P300
figure;
time = [1:800]';
chan2plot = elecs_of_4_pc(3);
yt = movmean(avg_elec_time([1:800],chan2plot),50); 
plot(time, yt)
patch([265 335 335 265],[100000 100000 0 0],[0.6 0.6 0.6])
alpha(.5)
set(gca, 'xlim',[0 800])
set(gca, 'ylim',[59015 59050])
title(['PC #3; ERP at electrode FC1'])
xlabel('time (ms)')
ylabel('Voltage (mV)')
xt = [270];
yt = [59047];
str = {'P300'};
text(xt,yt,str,'Color','r')

