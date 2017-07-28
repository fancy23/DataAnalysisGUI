function [heatmapMatrix,sessionMat] = getHeatmapMat(sessionData,clusterMarkers,clusterChannel)

% input the session data of all files
% the channel for clustering, for calculate the cosine distance
% clusterChannel = the number of the cluster channel: the information of
% the cluster name
%  output:  the new heatmap with the new cluster name  ; new sessiondata
%  replace the original cluster name by the new order.

heatmapMatrix = [];
sessionMat = sessionData;
groupID = unique(sessionData(:,clusterChannel));


 for i = 1:length(groupID)
     idTmp = groupID(i);
     matTmp = sessionData(find(sessionData(:,clusterChannel) == idTmp),clusterMarkers);
     if size(matTmp,1) == 1
         matMeanTmp = matTmp;
     else
         matMeanTmp = mean(matTmp);
     end   
   heatmapMat(i,:) = [matMeanTmp, idTmp];
 end
 
 pdata =  pdist(heatmapMat(:,1:end-1),'cosine');
Z = linkage(pdata,'average');
[Hx,Hy,Hz] = dendrogram(Z,0);
clear Hx Hy;
Hz = fliplr(Hz);
newHeatmapMat = heatmapMat(Hz',:);
newClusterIndex = [newHeatmapMat(:,end) , (1:size(heatmapMat,1))' ];

for i = 1:length(groupID)
    groupIdTmp = newClusterIndex(i,1);
     indexTmp = find(sessionData(:,clusterChannel) == groupIdTmp);
     sessionMat(indexTmp,clusterChannel) = newClusterIndex(i,2);
end

heatmapMatrix = [newHeatmapMat(:,1:end-1), newClusterIndex(:,end)];

    
     
     