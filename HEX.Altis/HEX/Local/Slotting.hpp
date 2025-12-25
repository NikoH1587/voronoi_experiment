class HEX_SLOTTING
{
	idd = 1500;

	class ControlsBackground
	{
		class Background : RscText
		{
			idc = -1;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 40 * GUI_GRID_CENTER_W;
			h = 24 * GUI_GRID_CENTER_H;
			colorBackground[] = {0.1,0.1,0.1,1};
		};
	};

	class Controls
	{			
		class Title : RscText
		{
			text = "CHOOSE UNIT TO CONTROL:";
			idc = 1501;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};
		
		class Groups : RscListbox
		{
			idc = 1502;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 20 * GUI_GRID_CENTER_H;
			onLBSelChanged = "hint 'update confirm button'";
			rowHeight = 1 * GUI_GRID_CENTER_H;
		};
		
		class Units : RscListbox
		{
			idc = 1503;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 20 * GUI_GRID_CENTER_H;
			onLBSelChanged = "hint 'update confirm button'";
			rowHeight = 1 * GUI_GRID_CENTER_H;
		};

		class Confirm: RscButton
		{
			idc = 1504;
			x = GUI_GRID_CENTER_X + 5 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 22 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call LOC_FNC_CONFIRM;";
		};
		
		class Minimap : RscMapControl
		{
			idc = 1505;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 24 * GUI_GRID_CENTER_H;
		};
	};
};