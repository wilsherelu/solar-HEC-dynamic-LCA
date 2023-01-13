clear all
load('capdata.mat')
[~,~, database]=xlsread(['C:\Users\lu\Desktop\job\ECfuture\CarbonFootprint data.xlsx'],'cal');
Sdb=zeros(size(State,1),size(database,1)-1);
lifespan=25;
SolarE=1.739091465836273e+06/570;%kWp
SolarGHGM=(1269717.29611237-1.002548039078863e+06)/570;%kg co2e
Solardaily=cell2mat(State(:,3));

for i=1:size(State,1)
    Gname=find(strcmpi(database(:,1),State(i,4)));
    Sdb(i,:)=cell2mat(database(Gname,2:8));
    
end
list0=[1 3 5 6 7 10 11 9];
list=[1 3 5 6 7 10 11];
SGratio0=Cprediction(:,list0,1)./sum(Cprediction(:,list0,1),2);
newsolar=zeros(size(Cprediction,1),size(Cprediction,3));
NSghg=newsolar;
avgsolar=newsolar;
NSghg(:,1)=(SolarGHGM+SolarE*1.002548/1.73909)./(lifespan*365*Solardaily);
avgsolar(:,1)=NSghg(:,1);
Eghg=newsolar;
Eghg(:,1)=sum(Sdb.*SGratio0(:,1:7),2)+NSghg(:,1).*SGratio0(:,8);
newsolar(:,1)=Cprediction(:,9,1);
solar0=newsolar(:,1);
natavgsolar(1)=sum(avgsolar(:,1).*newsolar(:,1),1)./sum(newsolar(:,1),1);

for i=2:size(Cprediction,3)%size(Cprediction,3)

    NSghg(:,i)=(SolarGHGM+SolarE*1.002548/1.73909)./(lifespan*365*Solardaily);
    if i<=20
    newsolar(:,i)=Cprediction(:,9,i)-Cprediction(:,9,i-1);
        [m,n]=find(newsolar<0);
        for j=1:size(m,1)
            Cprediction(m(j),9,n(j))=Cprediction(m(j),9,n(j))-newsolar(m(j),n(j));
            newsolar(m(j),n(j))=0;
        end
    Sumcap=sum(Cprediction(:,list,i),2)+sum(newsolar(:,1:i),2);
    avgsolar(:,i)=sum(NSghg(:,1:i).*newsolar(:,1:i)./sum(newsolar(:,1:i),2),2);
    SGratioBase=Cprediction(:,list,i)./Sumcap;
    SGratioSolar=newsolar(:,1:i)./Sumcap;
    Eghg(:,i)=sum(Sdb.*SGratioBase,2)+sum(NSghg(:,1:i).*SGratioSolar,2);
    natavgsolar(i)=sum(avgsolar(:,i).*sum(newsolar(:,1:i),2),1)./sum(sum(newsolar(:,1:i),2),1);
    elseif i<=26
    newsolar(:,i)=Cprediction(:,9,i)-Cprediction(:,9,i-1)+solar0/6;
    newsolar(:,1)=newsolar(:,1)-solar0/6;
    [m,n]=find(newsolar<0);
        for j=1:size(m,1)
            Cprediction(m(j),9,n(j))=Cprediction(m(j),9,n(j))-newsolar(m(j),n(j));
            newsolar(m(j),n(j))=0;
        end
    Sumcap=sum(Cprediction(:,list,i),2)+sum(newsolar(:,1:i),2);
    avgsolar(:,i)=sum(NSghg(:,1:i).*newsolar(:,1:i)./sum(newsolar(:,1:i),2),2);
    SGratioBase=Cprediction(:,list,i)./Sumcap;
    SGratioSolar=newsolar(:,1:i)./Sumcap;
    Eghg(:,i)=sum(Sdb.*SGratioBase,2)+sum(NSghg(:,1:i).*SGratioSolar,2);
    natavgsolar(i)=sum(avgsolar(:,i).*sum(newsolar(:,1:i),2),1)./sum(sum(newsolar(:,1:i),2),1);
    else
    newsolar(:,i)=Cprediction(:,9,i)-Cprediction(:,9,i-1)+newsolar(:,i-lifespan);
    [m,n]=find(newsolar<0);
        for j=1:size(m,1)
            Cprediction(m(j),9,n(j))=Cprediction(m(j),9,n(j))-newsolar(m(j),n(j));
            newsolar(m(j),n(j))=0;
        end
    Sumcap=sum(Cprediction(:,list,i),2)+sum(newsolar(:,i-24:i),2);
    avgsolar(:,i)=sum(NSghg(:,i-24:i).*newsolar(:,i-24:i)./sum(newsolar(:,i-24:i),2),2);
    SGratioBase=Cprediction(:,list,i)./Sumcap;
    SGratioSolar=newsolar(:,i-24:i)./Sumcap;
    Eghg(:,i)=sum(Sdb.*SGratioBase,2)+sum(NSghg(:,i-24:i).*SGratioSolar,2);
    natavgsolar(i)=sum(avgsolar(:,i).*sum(newsolar(:,i-24:i),2),1)./sum(sum(newsolar(:,i-24:i),2),1);
    end
end
Natcap=sum(Cprediction(:,list0,:),2);
NatAvg=(sum(Eghg.*squeeze(Natcap),1)./sum(squeeze(Natcap),1))';
natavgsolar=natavgsolar';
% xlswrite('C:\Users\lu\Desktop\job\ECfuture\base.xlsx',NatAvg,'NatAvg','A1');
% xlswrite('C:\Users\lu\Desktop\job\ECfuture\base.xlsx',avgsolar,'SolarAvg','A1');
% xlswrite('C:\Users\lu\Desktop\job\ECfuture\base.xlsx',NSghg,'SolarNew','A1');
% xlswrite('C:\Users\lu\Desktop\job\ECfuture\base.xlsx',Eghg,'State','A1');