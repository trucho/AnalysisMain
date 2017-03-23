figH = ephysGUI(1);figH.jSlider;


%%
figure(1)
[j,c] = uicomponent('style','slider', 'position',[50,50,60,150], 'value',70,...
    'MajorTickSpacing',20, 'MinorTickSpacing',5, ...
    'Paintlabels',1,'PaintTicks',1, 'Orientation',0);
