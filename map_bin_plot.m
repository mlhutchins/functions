function map_bin_plot(ndata,varargin)
%MAP_BIN_PLOT(ndata, options) takes in a global density array and returns a global contour
%map of the data. ndata generated from MAP_BIN.m
%   Options:
%     'Resolution',resolution - Override default resolution
%     'Stations',station_number - Plot stations on map
%     'Title',titletext - Give plot title 'titletext'
%     'Save',savename - save figure as 'savename'
%     'Log',true/false - Plots as log of the density (default true)
%     'Zoom' - Zooms view to ndata strokes
%     'XWindow' - Set Xlim of plot
%     'YWindow' - Set Ylim of plot
%     'ColorText',colorbartext - Set colorbar label
%     'ColorMax',cbarmax - Sets maximum colorbar to 10^cbarmax
%     'ColorMin',cbarmin - Sets minumum colorbar to 10^cbarmax
%     'NoFigure' - does not create new figure (used for subplots)
%     'SmallTick',size - Sets tick marks at size degree resolution
%     'Blue' - Makes a bin of 0 strokes colorbar 0 instead of white
%     'Coast','high'/'low',color - Adjusts the coastlines plotted
%           high/low determines the level of detail
%           color specifies the color as matlab colorspec 'k' - black,
%                'w' - white 
%     'squareKM',time - Plots in strokes/km^2/year, time is days spanned
%           by data

%   2011/10/17 - Created by - Michael Hutchins
%   2011/10/20 - Updated options and print code
%   2011/10/24 - More options desired by Bob

    Options=varargin;
    Log=true; 
    res=180/size(ndata,1);
    titletext=[];
    Save=false;
    savename=[];
    stationPlot=[];
    Zoom=false;
    colortext=[];
    NoFigure=false;
    SmallTick=false;
    ColorMax=false;
    ColorMin=false;
    ScreenSize=false;
    Blue=false;
    CoastColor='k';
    CoastDetail=1;
    xwin=false;
    ywin=false;
    zeroData=sum(ndata(:))==0;
    km=false;
    
    %strcmp(Options)
    for i=1:length(Options)
        if strncmp(Options{i},'Resolution',4)
            res=Options{i+1};
        elseif strncmp(Options{i},'Stations',8)
            stationPlot=Options{i+1};
        elseif strncmp(Options{i},'Title',5)
            titletext=Options{i+1};
        elseif strncmp(Options{i},'Save',4)
            Save=true;
            savename=Options{i+1};
        elseif strncmp(Options{i},'Log',3)
            Log=Options{i+1};
        elseif strncmp(Options{i},'Zoom',4)
            Zoom=true;
        elseif strncmp(Options{i},'ColorText',9)
            colortext=Options{i+1};
        elseif strncmp(Options{i},'NoFigure',8)
            NoFigure=true;
        elseif strncmp(Options{i},'SmallTick',9)
            SmallTick=true;
            smalltick=Options{i+1};
        elseif strncmp(Options{i},'ColorMax',8)
            cbarmax=Options{i+1};
            ColorMax=true;
        elseif strncmp(Options{i},'ColorMin',8)
            cbarmin=Options{i+1};
            ColorMin=true;
        elseif strncmp(Options{i},'ScreenSize',10);
            ScreenSize=true;
            screenPixel=Options{i+1};
        elseif strncmp(Options{i},'Blue',4)
            Blue=true;
        elseif strncmp(Options{i},'Coast',5)
            if strncmp(Options{i+1},'high',4)
                CoastDetail=1;
            elseif strncmp(Options{i+1},'low',3)
                CoastDetail=0;
            elseif length(Options{i+1})==1
                CoastColor=Options{i+1};
            end
            if length(Options)>=i+2;
                if strncmp(Options{i+2},'high',4)
                    CoastDetail=1;
                elseif strncmp(Options{i+2},'low',3)
                    CoastDetail=0;
                elseif length(Options{i+2})==1
                    CoastColor=Options{i+2};
                end
            end
        elseif strncmp(Options{i},'XWindow',7)
            xwin=true;
            xwindow=Options{i+1};
        elseif strncmp(Options{i},'YWindow',7)
            ywin=true;
            ywindow=Options{i+1};
        elseif strncmp(Options{i},'squareKM',8)
            km=true;
            kmTime=Options{i+1};
        end
    end
        
    hold off
    
    %% Adjust data
    
    % Set to strokes/km^2/year
    if km
        lat=[-90:res:90];
        latCenter=[-90+res/2:res:90-res/2];
        height=vdist(lat(1:end-1),ones(1,180/res),lat(2:end),ones(1,180/res))./1000;
        width=vdist(latCenter,zeros(1,180/res),latCenter,repmat(res,1,180/res))./1000;
        squareKM = repmat([width.*height]',1,360/res);
        
        years=kmTime./356;
        
        ndata=ndata./squareKM./years;
        
    end
    

    
    % Remove infs
    ndata(isinf(ndata))=NaN;

    % Preformat meshgrid
    [x,y] = meshgrid(-180+res/2:res:180-res/2,-90+res/2:res:90-res/2);
    xRange=x(1,nansum(ndata,1)>0);
    yRange=y(nansum(ndata,2)>0,1);

    % Set data to log(data)
    if Log
        ndata=log10(ndata);
    end
    
    %% Load Coast and Station Data
    
    if CoastDetail==1
        load coast_high
    elseif CoastDetail==0
        load coast
    end
    stations
    
    %% Create Figure
    
    if NoFigure
        plot1=gcf;
    else
        plot1 = figure;
    end
    
    if ScreenSize
        set(plot1,'units','pixels','Position',[0,0,screenPixel(1),screenPixel(2)]);
    end
    
    
    %% Plot Data
    
    [C,h] = contourf(x,y,ndata);
    set(h,'EdgeColor','none');
    hold on
    scatter(station_loc(stationPlot+1,2),station_loc(stationPlot+1,1),100,'r^','Filled')
    plot(long+res/2,lat+res/2,CoastColor);
 
    %% Format Figure
    
    axis equal
    set(gcf,'Color','w')

    %% Format Axis
    
    if SmallTick
        set(gca,'YTick',[-90:smalltick:90])
        set(gca,'XTick',[-180:smalltick:180])
    else
        set(gca,'YTick',[-90:30:90])
        set(gca,'XTick',[-180:60:180])
    end

    xlabel('Longitude');
    ylabel('Latitude')
   

    
    %% Format Zoom Window
    
    if Zoom
        xlim([xRange(1),xRange(end)]);
        ylim([yRange(1),yRange(end)]);
    else
        xlim([-180,180])
        ylim([-90,90])
    end
    
    if xwin
        xlim(xwindow);
    end
    if ywin
        ylim(ywindow);
    end
      
    %% Format colorbar range

    cLow=0;
    cHigh=ceil(max(ndata(:)));
    
    if ColorMax
        cHigh=cbarmax;
    elseif zeroData
        cHigh=1;
    end
        
    if ColorMin
        cLow=cbarmin;
    end
    
    if ColorMax || ColorMin
        if Log
            cMap=jet((cHigh-cLow)*3);
        else
            cMap=jet(cHigh-cLow);
        end
    else
        cMap=jet(ceil(max(max(ndata)))*3);
    end
   
    % Adjust for solid blue background
    if Blue
        set(gca,'Color',cMap(1,:))
    end
    
    h=colorbar;
    set(h,'Location','SouthOutside')
    caxis([cLow cHigh])
    colormap(cMap);
    
    %% Format colorbar text
        
    if isempty(colortext)
        if km
            colorbarText=sprintf('Stroke Density (strokes/km^2/year)    ');
        else
            colorbarText=sprintf('Stroke Density (strokes per %g degree x %g degree)    ',res,res);
        end
    else
        colorbarText=colortext;
    end
    xlabel(h,colorbarText)
    
    if Log
        set(h,'XTick',[-6:1:6],'XTickLabel',{'10^-6','10^-5','10^-4','10^-3','0.01','0.1','1','10','100','10^3','10^4','10^5','10^6'})
    end
    %% Set title

    title(titletext);
    
    %% Format fonts
    
    Figures
    Figures(h)
    
    
    %% Save
    if Save
        if ScreenSize
            set(gcf,'PaperPositionMode','auto')
            print(gcf, '-dpng', savename);
        else
            saveas(gcf,savename);
        end
    end
end
