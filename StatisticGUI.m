function varargout = StatisticGUI(varargin)
% STATISTICGUI MATLAB code for StatisticGUI.fig
%      STATISTICGUI, by itself, creates a new STATISTICGUI or raises the existing
%      singleton*.
%
%      H = STATISTICGUI returns the handle to a new STATISTICGUI or the handle to
%      the existing singleton*.
%
%      STATISTICGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATISTICGUI.M with the given input arguments.
%
%      STATISTICGUI('Property','Value',...) creates a new STATISTICGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StatisticGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StatisticGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StatisticGUI

% Last Modified by GUIDE v2.5 27-Jul-2017 10:15:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatisticGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StatisticGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before StatisticGUI is made visible.
function StatisticGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StatisticGUI (see VARARGIN)

% Choose default command line output for StatisticGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatisticGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StatisticGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadmatfile.
function loadmatfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadmatfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname ] = uigetfile('*.mat','Please Select the mat file');
dataTmp = load([pathname,filename]);
fileNum = size(dataTmp.gates,1);
fileIdIndex = [];
for i = 1:fileNum
    file.name = dataTmp.gates{i,1};
    file.index = dataTmp.gates{i,2};
    file.chlname = dataTmp.gates{i,3};
    file.dir = dataTmp.gates{i,4};
    fileCell{1,i} = file;
    fileName{1,i} =  dataTmp.gates{i,1};
end
clear file;
sessionData = dataTmp.sessionData;

%% output the cluster by files

set(handles.fileName,'String',fileName);
set(handles.ChannelName,'String',fileCell{1,1}.chlname);  
set(handles.listbox3,'string',{});

handles.sessionData = sessionData;
handles.fileCell = fileCell;

handles.channelList.string = {};
handles.channelList.value = {};

channelList = get(handles.ChannelName,'String');
 clusterIdChannel = listdlg('ListString',channelList,'PromptString','Please select the channel for clustering',...
     'SelectionMode','mutiple','ListSize',[200 300]);
 
 handles.clusterChannel = clusterIdChannel;
 
guidata(hObject, handles);


% --- Executes on selection change in fileName.
function fileName_Callback(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileID = get(hObject,'value');
if length(fileID) == 1
    set(handles.edit1,'string',num2str(length(handles.fileCell{1,fileID}.index)));
    set(handles.ChannelName,'String',handles.fileCell{1,fileID}.chlname);
else
    set(handles.edit1,'string','');
    for i =1:length(fileID)
        chlNameCell{1,i} = handles.fileCell{1,fileID(i)}.chlname;
    end
    k = 0;
    for i =1:length(fileID) - 1
        if isequal(chlNameCell{1,i},chlNameCell{1,i+1})
        else
            warndlg('The Channel Name of Selected files is not equal !');
            set(handles.ChannelName,'String','');
            k =1;
            break;
        end
    end
    if k == 0
        set(handles.ChannelName,'String',handles.fileCell{1,fileID(i)}.chlname);
    end     
end

guidata(hObject, handles);



% Hints: contents = cellstr(get(hObject,'String')) returns fileName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileName


% --- Executes during object creation, after setting all properties.
function fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{});


% --- Executes on selection change in ChannelName.
function ChannelName_Callback(hObject, eventdata, handles)
% hObject    handle to ChannelName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChannelName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChannelName


% --- Executes during object creation, after setting all properties.
function ChannelName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChannelName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end
set(hObject,'String',{});


% --- Executes on button press in Setclusterchannel.
function Setclusterchannel_Callback(hObject, eventdata, handles)
% hObject    handle to Setclusterchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clusterChannelId = get(handles.ChannelName,'value');
handles.channelList.string = [ handles.channelList.string, 'Cluster Channel'];
handles.channelList.value = [ handles.channelList.value, clusterChannelId];
set(handles.listbox3,'String',handles.channelList.string);
guidata(hObject, handles);





% --- Executes on button press in SetvisneChannel.
function SetvisneChannel_Callback(hObject, eventdata, handles)
% hObject    handle to SetvisneChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clusterChannelId = get(handles.ChannelName,'value');
handles.channelList.string = [ handles.channelList.string, 'viSNE Channel'];
handles.channelList.value = [ handles.channelList.value, clusterChannelId];
set(handles.listbox3,'String',handles.channelList.string);
guidata(hObject, handles);


% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'visneFileIndex')
    warndlg('Please select the visne Files');
    return
else
end
visneFileId = handles.visneFileIndex;


channelList =handles.fileCell{1,visneFileId(1)}.chlname;
set(handles.ChannelName,'String',[channelList , 'Gates']);
tsne1Id = find(strcmp(channelList,'bh-SNE1'));
tsne2Id = find(strcmp(channelList,'bh-SNE2'));
clusterChlId = find(strcmp(channelList,handles.cluChlName));
if length(tsne1Id) == 0 | length(tsne2Id) == 0
    warndlg(' Cannot find the tsne channel ! ');
else
    markerId = get(handles.ChannelName,'value');
    if length(markerId) >1
        errordlg('Please Select One Marker');
    elseif markerId ~= clusterChlId & markerId ~= length(channelList) + 1
        cla reset;
        axes(handles.axes1);
        scatter(handles.fSessionData(:,tsne1Id),handles.fSessionData(:,tsne2Id),10,handles.fSessionData(:,markerId),'filled');
        clim = [prctile(handles.fSessionData(:,markerId), 0.3) prctile(handles.fSessionData(:,markerId), 99.7)];
        colormap( jet(10)) ;
        colorbar;
        caxis(clim);
    elseif  markerId == length(channelList) + 1
        cla reset;
        k =0;
        fileId = handles.visneFileIndex; 
        sessionData = [] ;
        colorMat = {};
        color_str = {'b', 'r', 'g', 'm' ,'y', 'm', 'c', 'k'} ;
        cla reset;
        hold on;
        for i =1: length(fileId)
            sessionData = handles.sessionData(handles.fileCell{1,fileId(i)}.findex,:);
            k = mod(i,8) + 1;
            scatter(sessionData(:,tsne1Id),sessionData(:,tsne2Id),10,color_str{k},'filled');  
            legendname{1,i} = handles.fileCell{1,fileId(i)}.name;
        end
        hold off;
       legend(legendname,'Interpreter','none');

    else
        cla reset;
        groupID = unique(handles.fSessionData(:,clusterChlId));
        colorMat = jet(20);
        hold on ;
        for i = 1:length(groupID)
            groupIdTmp = groupID(i);
            sessionData = handles.fSessionData(find(handles.fSessionData(:,clusterChlId) == groupIdTmp),:);
            legendName{1,i} = ['Cluster: ', num2str(groupIdTmp)];
            k = mod(i,20);
            scatter(sessionData(:,tsne1Id),sessionData(:,tsne2Id),10,colorMat(k+1,:),'filled'); 
        end
        legend(legendName,'Interpreter','none');
    end
end
guidata(hObject, handles);

    
    
    


% --- Executes on button press in SetHeatmapChannel.
function SetHeatmapChannel_Callback(hObject, eventdata, handles)
% hObject    handle to SetHeatmapChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clusterChannelId = get(handles.ChannelName,'value');
handles.channelList.string = [ handles.channelList.string, 'Heatmap Channel'];
handles.channelList.value = [ handles.channelList.value, clusterChannelId];
set(handles.listbox3,'String',handles.channelList.string);
guidata(hObject, handles);


% --- Executes on button press in OutputCellMat.
function OutputCellMat_Callback(hObject, eventdata, handles)
% hObject    handle to OutputCellMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cellFreMat = handles.cellFreMat .* 100;
clusterStr = [];
for i =1:size(cellFreMat,2)
    eval(['Cluster',num2str(i),'= cellFreMat(:,i);']);
    clusterStr = [ clusterStr,'Cluster',num2str(i),','];
end
clusterStr = clusterStr(1,1:end-1);
FileName = get(handles.fileName,'String');
FileName = FileName(handles.oriFileIndex,1);
eval(['T = table(FileName,',clusterStr,');']);
[filename,filedir] = uiputfile('CellFreMat.csv');
writetable(T,[filedir,filename],'Delimiter',',');
  
guidata(hObject, handles);




% --- Executes on button press in OutvisneImage.
function OutvisneImage_Callback(hObject, eventdata, handles)
% hObject    handle to OutvisneImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filedir = uigetdir();
%%
if ~isfield(handles,'visneFileIndex')
    warndlg('Please select the visne Files');
    return
else
end

visneFileId = handles.visneFileIndex;
channelList =handles.fileCell{1,visneFileId(1)}.chlname;
tsne1Id = find(strcmp(channelList,'bh-SNE1'));
tsne2Id = find(strcmp(channelList,'bh-SNE2'));
clusterChlId = find(strcmp(channelList,handles.cluChlName));

markerList = get(handles.ChannelName,'value');
for i =1:length(markerList)
    markerId = markerList(i);
            if markerId ~= clusterChlId & markerId ~= length(channelList) + 1  % normal marker
                markerName = channelList{1,markerId};
                figure;
                scatter(handles.fSessionData(:,tsne1Id),handles.fSessionData(:,tsne2Id),10,handles.fSessionData(:,markerId),'filled');
                clim = [prctile(handles.fSessionData(:,markerId), 0.3) prctile(handles.fSessionData(:,markerId), 99.7)];
                colormap( jet(10)) ;
                colorbar;
                caxis(clim);
                title(markerName,'Interpreter','none');
                set(gcf,'Position',[0 0 1800 1500]);
                saveas(gcf,[filedir,'\',markerName,'.jpeg']);
                close Figure 1;
            elseif  markerId == length(channelList) + 1 % gates
                figure;
                k =0;
                fileId = handles.visneFileIndex; 
                sessionData = [] ;
                colorMat = {};
                color_str = {'b', 'r', 'g', 'm' ,'y', 'm', 'c', 'k'} ;
                cla reset;
                hold on;
                for i =1: length(fileId)
                    sessionData = handles.sessionData(handles.fileCell{1,fileId(i)}.findex,:);
                    k = mod(i,8) + 1;
                    scatter(sessionData(:,tsne1Id),sessionData(:,tsne2Id),10,color_str{k},'filled');  
                    legendname{1,i} = handles.fileCell{1,fileId(i)}.name;
                end
                hold off;
               legend(legendname,'Interpreter','none');
                title('Gates','Interpreter','none');
                set(gcf,'Position',[0 0 1800 1500]);
                saveas(gcf,[filedir,'\gates.jpeg']);
                close Figure 1;
            else              % cluster Channel
                figure;
                groupID = unique(handles.fSessionData(:,clusterChlId));
                colorMat = jet(20);
                hold on ;
                for i = 1:length(groupID)
                    groupIdTmp = groupID(i);
                    sessionData = handles.fSessionData(find(handles.fSessionData(:,clusterChlId) == groupIdTmp),:);
                    legendName{1,i} = ['Cluster: ', num2str(groupIdTmp)];
                    k = mod(i,20);
                    scatter(sessionData(:,tsne1Id),sessionData(:,tsne2Id),10,colorMat(k+1,:),'filled'); 
                end
                legend(legendName,'Interpreter','none');
                set(gcf,'Position',[0 0 1800 1500]);
                saveas(gcf,[filedir,'\clusters.jpeg']);
                close Figure 1;
                
            end
end


      
      



% --- Executes on button press in Outheatmap.
function Outheatmap_Callback(hObject, eventdata, handles)
% hObject    handle to Outheatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,filedir] = uiputfile('heatmap.jpeg');

heatmapMat = handles.heatmapMat(:,1:end-1);
clusterChannel = handles.clusterChannel;

channelId = get(handles.ChannelName,'value');

heatmapColIndex = intersect(channelId,clusterChannel);
channelName = handles.fileCell{1,handles.oriFileIndex(1)}.chlname;
channelName = channelName(1,heatmapColIndex);

for i =1:length(heatmapColIndex)
     heatmapCol(i,1) = find(clusterChannel(1,:) == heatmapColIndex(i));
end
for i =1:size(heatmapMat,1)
    yTickName{i,1} = ['Cluster: ',num2str(i)];
end
figure;
imagesc(NormalizeMat(heatmapMat(:,heatmapCol)));
colormap(jet(15));
colorbar;
set(gca,'ytick',1:size(heatmapMat,1));
set(gca,'yticklabel',yTickName);
set(gca,'xtick',1:length(channelId));
set(gca,'xticklabel',channelName,'FontSize',12,'FontWeight', 'bold');
set(gca,'ticklabelinterpreter','none');
sc = gca;
sc.XTickLabelRotation = 90;
title('HeatMap');
 set(gcf,'Position',[0 0 1800 1500]);
 saveas(gcf,[filedir,'\heatmap.jpeg']);
 close Figure 1;
 guidata(hObject, handles);
 









% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channelNum = get(hObject,'value');
channelListValue = handles.channelList.value{1,channelNum};
set(handles.ChannelName,'value',channelListValue);
guidata(hObject, handles);




% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end
set(hObject,'String',{});



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filter.
function filter_Callback(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'oriFileIndex')
    warndlg('Please select the original Files');
    return
else
end

channelList = get(handles.ChannelName,'String');
clusterIdChannel = listdlg('ListString',channelList,'PromptString','Please select the cluster channel',...
     'SelectionMode','single','ListSize',[200 300]); 
fileId=handles.oriFileIndex;
  
  % rearrang the rows based on the phenotype of each cluster
  [heatmapMatrix,newSessionData ] = getHeatmapMat(handles.sessionData,handles.clusterChannel,clusterIdChannel);
  
  handles.newSessionData = newSessionData;
 
 groupID = unique(newSessionData(:,clusterIdChannel));
for i = 1:length(groupID)
    groupFre(i,1) = length(find(newSessionData(:,clusterIdChannel) == groupID(i))) / size(newSessionData,1);
    for  j =1:length(fileId)
         fileIndex = handles.fileCell{1,fileId(j)}.index;
         clustIndex = find(newSessionData(:,clusterIdChannel) == groupID(i));
         fileFreTmp = length(intersect(clustIndex,fileIndex)) / length(handles.fileCell{1,fileId(j)}.index);
         fileFreTmp1(1,j) = fileFreTmp;
    end
    groupFileFre(i,:) = fileFreTmp1; 
end

filterID = questdlg('Please Select the filter                                                                      Filter1 : Cluster Frequency                                                    Filter2: File Frequency in Cluster ','Select Filter?','Filter1','Filter2','Cancel','Cancel');
if  ~strcmp(filterID,'Cancel')
    if strcmp(filterID,'Filter1')
         fIndex = find(groupFre >= 0.001);
         fGroupId = groupID(fIndex,1);
    else
        fIndex = find(max(groupFileFre') >= 0.01)';
        fGroupId = groupID(fIndex,1);
    end
else
    fGroupId = groupID;
end

fHeatmapMatrix = heatmapMatrix(fIndex,:);
cellFreMat = groupFileFre(fIndex,:)';

% caluculate the new file index
filterOutId = setxor(fGroupId,groupID);
sessionIndex = [];
if length(filterOutId) == 0
    for i =1:length(fileId)
         handles.fileCell{1,i}.findex = handles.fileCell{1,i}.index;
    end
else
    for i = 1:length(filterOutId)
        filterOutIdTmp = filterOutId(i);
        sessionIndex = [sessionIndex ; find(newSessionData(:,clusterIdChannel) == filterOutIdTmp)];
    end
    for i = 1:length(handles.fileCell)
        fileIndexTmp = handles.fileCell{1,i}.index;
        fileFilterIdTmp = setxor(fileIndexTmp,intersect(sessionIndex,fileIndexTmp));
        handles.fileCell{1,i}.findex = fileFilterIdTmp;
    end
end

fSessionIndex = setxor(1:size(handles.sessionData,1), sessionIndex);
handles.fSessionData = newSessionData(fSessionIndex,:);

axes(handles.axes1);
imagesc(fHeatmapMatrix(:,1:end-1));
colormap(jet(20));


handles.cellFreMat =  cellFreMat;
handles.heatmapMat = fHeatmapMatrix
handles.cluChlName = channelList{clusterIdChannel};
handles.fGroupId = fGroupId;

guidata(hObject, handles);


% --- Executes on selection change in filelist.
function filelist_Callback(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelist


% --- Executes during object creation, after setting all properties.
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in setvisnefiles.
function setvisnefiles_Callback(hObject, eventdata, handles)
% hObject    handle to setvisnefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   fileList = get(handles.fileName,'String');
  fileId= listdlg('ListString',fileList,'PromptString','Please select the files for filter',...
     'SelectionMode','mutiple','ListSize',[200 300]);
 handles.visneFileIndex = fileId;
 guidata(hObject, handles);
 
% --- Executes on button press in setorgfiles.
function setorgfiles_Callback(hObject, eventdata, handles)
% hObject    handle to setorgfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fileList = get(handles.fileName,'String');
  fileId= listdlg('ListString',fileList,'PromptString','Please select the files for filter',...
     'SelectionMode','mutiple','ListSize',[200 300]);
 handles.oriFileIndex = fileId;
 guidata(hObject, handles);
