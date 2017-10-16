function Avg = MB001Fen_collectAverages(whichones)

Avg=struct();

switch whichones
    case 'MB001Low'
        Sq993=struct;
        dirData='20170829/20170829_Sq993_MB001Low';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'11_IseriesPost10min_merged');
        dirData='20170831/20170831_Sq993_MB001Low';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'14_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        
        Sq998=struct;
        dirData='20170830/20170830_Sq998_MB001Low';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'12_IseriesPost');
        dirData='20170901/20170901_Squirrel998_MB001Low';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        
        Avg.iF=unique([Sq(1).results.d3post.iF, Sq(2).results.d3post.iF, ...
            Sq(1).results.d1pre.iF, Sq(2).results.d1pre.iF]);
        nSq = 2;
        
    case 'MB001High'
        Sq1006=struct;
        dirData='20170829/20170829_Sq1006_MB001High';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre_merged');
        Sq(1).d1post=ERGobj(dirData,'11_IseriesPost10min');
        dirData='20170831/20170831_Sq1006_MB001High';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'13_IseriesPost10min_merged');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        
        Sq928=struct;
        dirData='20170830/20170830_Sq928_MB001High';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'12_IseriesPost10min');
        dirData='20170901/20170901_Squirrel928_MB001High';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'01_IseriesPre');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        Avg.iF=unique([Sq(1).results.d3post.iF, Sq(2).results.d3post.iF, ...
            Sq(1).results.d1pre.iF, Sq(2).results.d1pre.iF]);
        nSq = 2;
        
    case 'Vehicle'
        Sq1000=struct;
        dirData = '20170829/20170829_Sq1000_Veh';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170831/20170831_Sq1000_Vehicle';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'13_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        
        
        Sq992=struct;
        dirData = '20170830/20170830_Sq992_Veh';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'12_IseriesPost10min');
        dirData='20170901/20170901_Squirrel992_Vehicle';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        
        Sq999=struct;
        dirData = '20170905/20170905_Sq999_Vehicle';
        Sq(3).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d1post=ERGobj(dirData,'10_IseriesPost10min20s');
        dirData='20170907/20170907_Sq999_Vehicle';
        Sq(3).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(3).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(3).results.d1pre=Sq(3).d1pre.Iseries_abpeaks();
        Sq(3).results.d1post=Sq(3).d1post.Iseries_abpeaks();
        Sq(3).results.d3pre=Sq(3).d3pre.Iseries_abpeaks();
        Sq(3).results.d3post=Sq(3).d3post.Iseries_abpeaks();
        
        Avg.iF=unique([Sq(1).results.d3post.iF, Sq(2).results.d3post.iF, Sq(3).results.d3post.iF, ...
            Sq(1).results.d1pre.iF, Sq(2).results.d1pre.iF, Sq(3).results.d1pre.iF]);
        nSq = 3;
        
    case 'Fenretinide'
        %Sq990
        Sq(1)=struct;
        dirData = '20170905/20170905_Sq990_Fenretinide';
        Sq(1).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq990_Fenretinide';
        Sq(1).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(1).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(1).results.d1pre=Sq(1).d1pre.Iseries_abpeaks();
        Sq(1).results.d1post=Sq(1).d1post.Iseries_abpeaks();
        Sq(1).results.d3pre=Sq(1).d3pre.Iseries_abpeaks();
        Sq(1).results.d3post=Sq(1).d3post.Iseries_abpeaks();
        
        
        %Sq995
        Sq(2)=struct;
        dirData = '20170905/20170905_Sq995_Fenretinide';
        Sq(2).d1pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d1post=ERGobj(dirData,'10_IseriesPost10min');
        dirData='20170907/20170907_Sq995_Fenretinide';
        Sq(2).d3pre=ERGobj(dirData,'01_IseriesPre');
        Sq(2).d3post=ERGobj(dirData,'10_IseriesPost10min');
        Sq(2).results.d1pre=Sq(2).d1pre.Iseries_abpeaks();
        Sq(2).results.d1post=Sq(2).d1post.Iseries_abpeaks();
        Sq(2).results.d3pre=Sq(2).d3pre.Iseries_abpeaks();
        Sq(2).results.d3post=Sq(2).d3post.Iseries_abpeaks();
        
        Avg.iF=unique([Sq(1).results.d3post.iF, Sq(2).results.d3post.iF, ...
            Sq(1).results.d1pre.iF, Sq(2).results.d1pre.iF]);
        nSq = 2;
end

Avg.ad1pre=NaN(nSq,size(Avg.iF,2));
Avg.bd1pre=NaN(nSq,size(Avg.iF,2));
Avg.ad3pre=NaN(nSq,size(Avg.iF,2));
Avg.bd3pre=NaN(nSq,size(Avg.iF,2));

Avg.uad1pre=NaN(nSq,size(Avg.iF,2));
Avg.ubd1pre=NaN(nSq,size(Avg.iF,2));
Avg.uad3pre=NaN(nSq,size(Avg.iF,2));
Avg.ubd3pre=NaN(nSq,size(Avg.iF,2));

Avg.ad1post=NaN(nSq,size(Avg.iF,2));
Avg.bd1post=NaN(nSq,size(Avg.iF,2));
Avg.ad3post=NaN(nSq,size(Avg.iF,2));
Avg.bd3post=NaN(nSq,size(Avg.iF,2));

Avg.uad1post=NaN(nSq,size(Avg.iF,2));
Avg.ubd1post=NaN(nSq,size(Avg.iF,2));
Avg.uad3post=NaN(nSq,size(Avg.iF,2));
Avg.ubd3post=NaN(nSq,size(Avg.iF,2));

switch whichones
    case 'MB001Low'
    case 'Fenretinide'
    case 'Vehicle'
    case 'MB001High'
end


iF=4000;


for i=1:length(Avg.iF);
    %Sq990
    i_pre=find(Sq(1).results.d1pre.iF==Avg.iF(i));
    nf = Sq(1).results.d1pre.Ra_peak((Sq(1).results.d1pre.iF==iF));
    unf = Sq(1).results.d1pre.La_peak((Sq(1).results.d1pre.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_pre)
        Avg.ad1pre(1,i)= Sq(1).results.d1pre.Ra_peak(i_pre)/nf;
        Avg.bd1pre(1,i)= Sq(1).results.d1pre.Rb_peak(i_pre)/-nf;
        
        Avg.uad1pre(1,i)= Sq(1).results.d1pre.La_peak(i_pre)/unf;
        Avg.ubd1pre(1,i)= Sq(1).results.d1pre.Lb_peak(i_pre)/-unf;
    end
    i_post=find(Sq(1).results.d1post.iF==Avg.iF(i));
%     nf = Sq(1).results.d1post.Ra_peak((Sq(1).results.d1post.iF==iF));
%     unf = Sq(1).results.d1post.La_peak((Sq(1).results.d1post.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_post)
        Avg.ad1post(1,i)= Sq(1).results.d1post.Ra_peak(i_post)/nf;
        Avg.bd1post(1,i)= Sq(1).results.d1post.Rb_peak(i_post)/-nf;
        
        Avg.uad1post(1,i)= Sq(1).results.d1post.La_peak(i_post)/unf;
        Avg.ubd1post(1,i)= Sq(1).results.d1post.Lb_peak(i_post)/-unf;
    end
    
    i_pre=find(Sq(1).results.d3pre.iF==Avg.iF(i));
    nf = Sq(1).results.d3pre.Ra_peak((Sq(1).results.d3pre.iF==iF));
    unf = Sq(1).results.d3pre.La_peak((Sq(1).results.d3pre.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_pre)
        Avg.ad3pre(1,i)= Sq(1).results.d3pre.Ra_peak(i_pre)/nf;
        Avg.bd3pre(1,i)= Sq(1).results.d3pre.Rb_peak(i_pre)/-nf;
        
        Avg.uad3pre(1,i)= Sq(1).results.d3pre.La_peak(i_pre)/unf;
        Avg.ubd3pre(1,i)= Sq(1).results.d3pre.Lb_peak(i_pre)/-unf;
    end
    i_post=find(Sq(1).results.d3post.iF==Avg.iF(i));
%     nf = Sq(1).results.d1post.Ra_peak((Sq(1).results.d1post.iF==iF));
%     unf = Sq(1).results.d1post.La_peak((Sq(1).results.d1post.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_post)
        Avg.ad3post(1,i)= Sq(1).results.d3post.Ra_peak(i_post)/nf;
        Avg.bd3post(1,i)= Sq(1).results.d3post.Rb_peak(i_post)/-nf;
        
        Avg.uad3post(1,i)= Sq(1).results.d3post.La_peak(i_post)/unf;
        Avg.ubd3post(1,i)= Sq(1).results.d3post.Lb_peak(i_post)/-unf;
    end
    
    %Sq995
    i_pre=find(Sq(2).results.d1pre.iF==Avg.iF(i));
    nf = Sq(2).results.d1pre.Ra_peak((Sq(2).results.d1pre.iF==iF));
    unf = Sq(2).results.d1pre.La_peak((Sq(2).results.d1pre.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_pre)
        Avg.ad1pre(2,i)= Sq(2).results.d1pre.Ra_peak(i_pre)/nf;
        Avg.bd1pre(2,i)= Sq(2).results.d1pre.Rb_peak(i_pre)/-nf;
        
        Avg.uad1pre(2,i)= Sq(2).results.d1pre.La_peak(i_pre)/unf;
        Avg.ubd1pre(2,i)= Sq(2).results.d1pre.Lb_peak(i_pre)/-unf;
    end
    i_post=find(Sq(2).results.d1post.iF==Avg.iF(i));
%     nf = Sq(2).results.d1post.Ra_peak((Sq(2).results.d1post.iF==iF));
%     unf = Sq(2).results.d1post.La_peak((Sq(2).results.d1post.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_post)
        Avg.ad1post(2,i)= Sq(2).results.d1post.Ra_peak(i_post)/nf;
        Avg.bd1post(2,i)= Sq(2).results.d1post.Rb_peak(i_post)/-nf;
        
        Avg.uad1post(2,i)= Sq(2).results.d1post.La_peak(i_post)/unf;
        Avg.ubd1post(2,i)= Sq(2).results.d1post.Lb_peak(i_post)/-unf;
    end
    
    i_pre=find(Sq(2).results.d3pre.iF==Avg.iF(i));
    nf = Sq(2).results.d3pre.Ra_peak((Sq(2).results.d3pre.iF==iF));
    unf = Sq(2).results.d3pre.La_peak((Sq(2).results.d3pre.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_pre)
        Avg.ad3pre(2,i)= Sq(2).results.d3pre.Ra_peak(i_pre)/nf;
        Avg.bd3pre(2,i)= Sq(2).results.d3pre.Rb_peak(i_pre)/-nf;
        
        Avg.uad3pre(2,i)= Sq(2).results.d3pre.La_peak(i_pre)/unf;
        Avg.ubd3pre(2,i)= Sq(2).results.d3pre.Lb_peak(i_pre)/-unf;
    end
    i_post=find(Sq(2).results.d3post.iF==Avg.iF(i));
%     nf = Sq(2).results.d1post.Ra_peak((Sq(2).results.d1post.iF==iF));
%     unf = Sq(2).results.d1post.La_peak((Sq(2).results.d1post.iF==iF));
    %nf=-1;unf=-1;
    if ~isempty(i_post)
        Avg.ad3post(2,i)= Sq(2).results.d3post.Ra_peak(i_post)/nf;
        Avg.bd3post(2,i)= Sq(2).results.d3post.Rb_peak(i_post)/-nf;
        
        Avg.uad3post(2,i)= Sq(2).results.d3post.La_peak(i_post)/unf;
        Avg.ubd3post(2,i)= Sq(2).results.d3post.Lb_peak(i_post)/-unf;
    end
   
end

end
