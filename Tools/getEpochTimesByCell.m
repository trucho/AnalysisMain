function EpochTime = getEpochTimesByCell(node,params)
Cell=findCell(node);
EpochTime=NaN(1,node.epochList.length);
for epoch = 1:(node.epochList.length)
        EpochTime(epoch)=(86400*node.epochList.valueByIndex(epoch).startDate(3)+3600*node.epochList.valueByIndex(epoch).startDate(4)+60*node.epochList.valueByIndex(epoch).startDate(5)+node.epochList.valueByIndex(epoch).startDate(6));
end

if ~isempty(node.epochList.firstValue.protocolSettings('acquirino:epochNumber'))
    startDate=Cell.epochList.sortedBy('protocolSettings(acquirino:epochNumber)').elements(1).startDate;
    StartTime=(86400*startDate(3)+3600*startDate(4)+60*startDate(5)+startDate(6));
else
    startDate=node.epochList.firstValue.cell.experiment.startDate;
    StartTime=(86400*startDate(3)+3600*startDate(4)+60*startDate(5)+startDate(6));
end
EpochTime=EpochTime-StartTime;