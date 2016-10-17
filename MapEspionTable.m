%% First, select files
%%
clear;startup;
expdate='20150605';
infocsv='01_Iseries';
datacsv='Test';
%%
clear;startup;
expdate='20150529';
infocsv='Squirrel Dark-adapted ERG Xenon';
datacsv='Iseries_Xe';
fname='_Xe';
%%
clear;startup;
expdate='20150529';
infocsv='Squirrel Dark-Adapted ERG';
datacsv='Iseries_Green';
fname='_Green';
%% Load Sq. Info
import = importdata(sprintf('%s/invivoERG/%s/%s.csv',dir.li_dbroot,expdate,infocsv));

index=struct();
index.arch=textscan(import.textdata{2},'%s','delimiter',',');
index.name=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'Name'),index.arch{1},'UniformOutput',0))==1);
index.dob=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'DOB'),index.arch{1},'UniformOutput',0))==1);
index.date=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'Date'),index.arch{1},'UniformOutput',0))==1);
index.datastart=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'Step..'),index.arch{1},'UniformOutput',0))==1);

multiplier=1;

info=struct();
if ~isempty(index.name)
    info.name=char(import.textdata(4,index.name(1)));
end
if ~isempty(index.dob)
    info.dob=char(import.textdata(4,index.dob(1)));
end
if ~isempty(index.date)
    info.date=char(import.textdata(4,index.date(1)));
end
if ~isempty(index.datastart)
    temp=char(import.textdata(3,index.datastart(1)));
    info.unitt=temp(end-2:end-1);
    temp=char(import.textdata(3,index.datastart(1)+1));
    info.unit=temp(end-2:end-1);
    if strcmp(info.unit,'nV')
        multiplier=1000;
        info.unit='uV';
    end
end


info
% Load Stimulus info

%% Load Data
import = importdata(sprintf('%s/invivoERG/%s/%s.csv',dir.li_dbroot,expdate,datacsv));
run=struct();

run.indarch=textscan(import.textdata{1},'%s','delimiter',',');

run.indl=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'Chan 1'),run.indarch{1},'UniformOutput',0))==1);
run.indr=find(cellfun(@(x)(~isempty(x)),cellfun(@(x)regexp(x,'Chan 2'),run.indarch{1},'UniformOutput',0))==1);
run.indt=run.indl-1; %assume time axis is just left of channel 1
run.n=size(run.indt,1);

erg=struct();
erg.info=info;
for i=1:run.n
    runname=sprintf('run%02g',i);
    indt=run.indt(i);
    if i<run.n
        indtnext=run.indt(i+1);
    else
        indtnext=run.indr(end)+1;
    end
    indl=run.indl(i);
    indr=run.indr(i);
    erg.(runname).t=import.data(~isnan(import.data(:,indt)),indt);
    erg.(runname).l=import.data(1:size(erg.(runname).t,1),indl:indr-1)./multiplier;
    erg.(runname).r=import.data(1:size(erg.(runname).t,1),indr:indr+indr-indl-1)./multiplier; %assuming same number of epochs for left and right eye
end

erg

%% Save mapped data
svstr=sprintf('%s/invivoERG/erg%s%s.mat',dir.li_dbroot,expdate,fname);
save(svstr,'erg')
fprintf('saved to:\n %s\n',svstr);
