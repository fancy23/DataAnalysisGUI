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

% Last Modified by GUIDE v2.5 19-Jul-2017 16:22:29

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
    fileIdIndex = [fileIdIndex , ones(1, length(dataTmp.gates{i,2}))*i ];
end
dataTmp.sessionData = [dataTmp.sessionData , fileIdIndex'];
for i =1:fileNum
    fileDataMat{i,1} = dataTmp.sessionData(find(dataTmp.sessionData(:,end) == i),:);
end


 %%
 % build a selection list to choose the cluster channel
 clusterIdChannel = listdlg('ListString',dataTmp.gates{1,3},'PromptString','Please select the cluster channel',...
     'SelectionMode','single','ListSize',[200 300]);
 
 
groupID = unique(dataTmp.sessionData(:,clusterIdChannel));
for i = 1:length(groupID)
    groupFre(i,1) = length(find(dataTmp.sessionData(:,clusterIdChannel) == groupID(i))) / length(dataTmp.sessionData);
    for  j =1:fileNum
          fileFreTmp = length(fileDataMat{j,1}(:,clusterIdChannel) == groupID(i)) /size(fileDataMat{j,1},1);
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


% filter out the outlier group
% sessionMat is the matrix with filtered Groups
% calulated the mean expression level.

[heatmapMat, sessionMat] = getHeatmapMat(dataTmp.sessionData,fGroupId,clusterIdChannel);

% the last column is the cluster ID.
% rearrange the heatmap matrix based on the hierarchy clustering

pdata =  pdist(heatmapMat(:,1:end-1),'cosine');
Z = linkage(pdata,'average');
[Hx,Hy,Hz] = dendrogram(Z,0);
clear Hx Hy;
Hz = fliplr(Hz);
newHeatmapMat = heatmapMat(Hz',:);
newClusterIndex = [newHeatmapMat(:,end) , (1:size(heatmapMat,1))' ];

for i =1:size(newClusterIndex,1)
     groupIdTmp = newClusterIndex(i,1);
     indexTmp = find(sessionMat(:,clusterIdChannel) == groupIdTmp);
     sessionMat(indexTmp,clusterIdChannel) = newClusterIndex(i,2);
end

%% output the cluster by files
fileSortIndex = [];

for i  = 1:fileNum
    fileData.filename = dataTmp.gates{i,1};
    fileData.chlname = dataTmp.gates{i,3};
    fileData.data = sessionMat(find(sessionMat(:,end) == i),:);
    fileGroup{i,1} = fileData;
    fileName{i,1} = dataTmp.gates{i,1};
    
   for j =1:length(fGroupId)
      cellFreMat(i,j) = length(find(fileData.data(:,end -3) == j)) / size(fileData.data,1) * 100;
   end
end
    clear fileData; 
       
set(handles.fileName,'String',fileName);
set(handles.ChannelName,'String',[fileGroup{1,1}.chlname, 'Gates']);  
set(handles.listbox3,'string',{});

axes(handles.axes1);
scatter(sessionMat(:,end-2),sessionMat(:,end-1),10,'k','filled');

handles.channelList.string = {};
handles.channelList.value = {};
handles.cellFreMat = cellFreMat;
handles.heatmapMat = newHeatmapMat;
handles.dataSet = dataTmp;
handles.fileGroup = fileGroup; 
handles.sessionMat = sessionMat;
guidata(hObject, handles);


% --- Executes on selection change in fileName.
function fileName_Callback(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileID = get(hObject,'value');
if length(fileID) == 1
    set(handles.edit1,'string',num2str(size(handles.fileGroup{fileID,1}.data,1)));
else
    set(handles.edit1,'string','');
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

markerVol = length(get(handles.ChannelName,'String'));
markerId = get(handles.ChannelName,'value');
if length(markerId) >1
    errordlg('Please Select One Marker');
elseif markerId ~= markerVol & markerId ~= markerVol - 3 
    cla reset;
    axes(handles.axes1);
    scatter(handles.sessionMat(:,end-2),handles.sessionMat(:,end-1),10,handles.sessionMat(:,markerId),'filled');
    clim = [prctile(handles.sessionMat(:,markerId), 0.3) prctile(handles.sessionMat(:,markerId), 99.7)];
    colormap( jet(10)) ;
    colorbar;
    caxis(clim);
elseif  markerId == markerVol
    fileId = get(handles.fileName,'value'); 
    sessionData = [] ;
    colorMat = {};
     color_str = {'b', 'r', 'g', 'm' ,'y', 'm', 'c', 'k'} ;
     cla reset;
     hold on;
    for i =1: length(fileId)
        sessionData =handles.fileGroup{fileId(i),1}.data;
        scatter(sessionData(:,end-2),sessionData(:,end-1),10,color_str{i},'filled');  
        legendname{1,i} = handles.fileGroup{fileId(i),1}.filename;
    end
    hold off;
   legend(legendname,'Interpreter','none');
else
    cla reset;
    groupID = unique(handles.sessionMat(:,end-3));
    colorMat = jet(20);
    hold on ;
    for i = 1:length(groupID)
        groupIdTmp = groupID(i);
        sessionData = handles.sessionMat(find(handles.sessionMat(:,end-3) == groupIdTmp),:);
        legendName{1,i} = ['Cluster: ', num2str(groupIdTmp)];
        k = mod(i,20);
        scatter(sessionData(:,end-2),sessionData(:,end-1),10,colorMat(k+1,:),'filled'); 
    end
    legend(legendName,'Interpreter','none');

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
cellFreMat = handles.cellFreMat;
clusterStr = [];
for i =1:size(cellFreMat,2)
    eval(['Cluster',num2str(i),'= cellFreMat(:,i);']);
    clusterStr = [ clusterStr,'Cluster',num2str(i),','];
end
clusterStr = clusterStr(1,1:end-1);
FileName = get(handles.fileName,'String');
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
channelId = get(handles.ChannelName,'value');
channelName = get(handles.ChannelName,'String');
markerVol = length(channelName);

for i = 1:length(channelId)
     
      markerId = channelId(i);
       markerName = channelName{markerId};
      
     if markerId ~= markerVol & markerId ~= markerVol - 3 
            figure;
            scatter(handles.sessionMat(:,end-2),handles.sessionMat(:,end-1),10,handles.sessionMat(:,markerId),'filled');
            clim = [prctile(handles.sessionMat(:,markerId), 0.3) prctile(handles.sessionMat(:,markerId), 99.7)];
            colormap( jet(10)) ;
            colorbar;
            caxis(clim);
            title(markerName,'Interpreter','none');
            set(gcf,'Position',[0 0 1800 1500]);
            saveas(gcf,[filedir,'\',markerName,'.jpeg']);
            close Figure 1;
            
      elseif  markerId == markerVol
            figure;
             color_str = {'b', 'r', 'g', 'm' ,'y', 'm', 'c', 'k'} ;
             cla reset;
             hold on;
        for i =1: length(get(handles.fileName,'String'))
            sessionData =handles.fileGroup{i,1}.data;
            scatter(sessionData(:,end-2),sessionData(:,end-1),10,color_str{i},'filled');  
            legendname{1,i} = handles.fileGroup{i,1}.filename;
        end
            hold off;
           legend(legendname,'Interpreter','none');
            title(markerName,'Interpreter','none');
            set(gcf,'Position',[0 0 1800 1500]);
            saveas(gcf,[filedir,'\',markerName,'.jpeg']);
            close Figure 1;
     else
        figure;
        groupID = unique(handles.sessionMat(:,end-3));
        colorMat = jet(20);
        hold on ;
     for i = 1:length(groupID)
        groupIdTmp = groupID(i);
        sessionData = handles.sessionMat(find(handles.sessionMat(:,end-3) == groupIdTmp),:);
        legendName{1,i} = ['Cluster: ', num2str(groupIdTmp)];
        k = mod(i,20);
        scatter(sessionData(:,end-2),sessionData(:,end-1),10,colorMat(k+1,:),'filled'); 
     end
        legend(legendName,'Interpreter','none');
         set(gcf,'Position',[0 0 1800 1500]);
        saveas(gcf,[filedir,'\',markerName,'.jpeg']);
        close Figure 1;
     end
end
      
      



% --- Executes on button press in Outheatmap.
function Outheatmap_Callback(hObject, eventdata, handles)
% hObject    handle to Outheatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filedir = uigetdir();
heatmapMat = handles.heatmapMat(:,1:end-1);
channelId = get(handles.ChannelName,'value');
channelName = get(handles.ChannelName,'String');
channelName = channelName(channelId,1);
for i =1:size(heatmapMat,1)
    yTickName{i,1} = ['Cluster: ',num2str(i)];
end
figure;
imagesc(NormalizeMat(heatmapMat(:,channelId)));
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
