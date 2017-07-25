function [heatmapmatrix,sessionMat] = getHeatmapMat(sessionData,groupID,clusterChannel)
heatmapmatrix = [];
sessionMat = [];

 for i = 1:length(groupID)
     idTmp = groupID(i);
     matTmp = sessionData(find(sessionData(:,clusterChannel) == idTmp),:);
     if size(matTmp,1) == 1
         matMeanTmp = matTmp(:,1:clusterChannel-1);
     else
         matMeanTmp = mean(matTmp(:,1:clusterChannel-1));
     end
     heatmapmatrix(i,:) = [matMeanTmp, idTmp];
     sessionMat = [sessionMat ; matTmp];
 end
     
     