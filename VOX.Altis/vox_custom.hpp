class VOX_CUSTOM
{
	idd = 1200;

	class ControlsBackground
	{
		class Background : RscText
		{
			idc = -1;
			x = safeZoneX;
			y = safeZoneY;
			w = safeZoneW;
			h = safeZoneH;
			colorBackground[] = {0.1,0.1,0.1,1};
		};
	};

	class Controls
	{		
		class company: RscCombo
		{
			idc = 1201;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_COMPANY";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Change currently configured company. (Click on list to remove from company)";
		};			
		
		class coy_list: RscListbox
		{
			idc = 1202;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 12 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_COYDEL";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class faction: RscCombo
		{
			idc = 1203;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_FACTION";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Select faction filter. (Click on list to add to company)";
		};	
		
		class cfg_list: RscListbox
		{
			idc = 1204;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 12 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDCFG";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class blufor: RscCombo
		{
			idc = 1205;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 14 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_BLUFOR";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Add company to BLUFOR side. (Click on list to remove)";
		};

		class blu_list: RscListbox
		{
			idc = 1206;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 16 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 9 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDWEST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};		
		
		class opfor: RscCombo
		{
			idc = 1207;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 14 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_OPFOR";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Add company to OPFOR side. (Click on list to remove)";
		};

		class opf_list: RscListbox
		{
			idc = 1208;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 16 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 9 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDEAST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};

		class minimap : RscMapControl
		{
			idc = 1209;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 14 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 9 * GUI_GRID_CENTER_H;
			tooltip = "Click on map to change positions of HQ's and LOG hub.";
		};
		
		class turn: RscCombo
		{
			idc = 1210;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 23 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "VOX_TURN = [west,east] select (_this select 1);";
			tooltip = "Change which side has first strategic turn.";
		};
		
		class start: RscButton
		{
			idc = 1211;
			text = "START CAMPAIGN";			
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 23 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call HEX_ADM_FNC_START;";
			tooltip = "Start campaign with current configuration.";
		};		
	};
};