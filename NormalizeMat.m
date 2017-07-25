function normalizedMat = NormalizeMat(inputMat)
         T =0;
         if inputMat(1,end) > 100;
             inputMatTmp = inputMat(:,1:end-1);
             T =1;
         else
             inputMatTmp = inputMat;
         end
         maxTld = prctile(reshape(inputMatTmp,size(inputMatTmp,1) * size(inputMatTmp,2),1),99);
        colsize = size(inputMatTmp,2);
        for i =1:colsize
            dataTmp = inputMatTmp(:,i);
            dataTmp(find(dataTmp > maxTld),1 ) = maxTld;
            normalizedMat(:,i) = dataTmp / maxTld;
        end
        if T == 1;
            normalizedMat = [normalizedMat, inputMat(:,end)];
        end
            