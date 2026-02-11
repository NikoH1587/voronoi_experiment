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
		class formation: RscCombo
		{
			idc = 1201;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 6 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_FORMATION";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Configure formations. (Click on list to remove group)";
		};			
		
		class for_list: RscListbox
		{
			idc = 1202;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 8 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 17 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_DELCFG";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class faction: RscCombo
		{
			idc = 1203;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 6 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_FACTION";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
			tooltip = "Click on list to add groups.";
		};	
		
		class cfg_list: RscListbox
		{
			idc = 1204;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 8 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 17 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDCFG";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class blufor: RscCombo
		{
			idc = 1205;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 1 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDWEST";
			tooltip = "Add formation to BLUFOR side.";
		};

		class blu_list: RscListbox
		{
			idc = 1206;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 1 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 5 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_DELWEST";
			colorBackground[] = {0, 0.3, 0.6, 0.5};
			wholeHeight = 0.1 * GUI_GRID_CENTER_H;
		};		
		
		class opfor: RscCombo
		{
			idc = 1207;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 1 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_ADDEAST";
			tooltip = "Add formation to OPFOR side.";
		};

		class opf_list: RscListbox
		{
			idc = 1208;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 1 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 5 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call VOX_FNC_DELEAST";
			colorBackground[] = {0.5, 0, 0, 0.5};
		};
		
		class importfield : RscEdit
		{
			idc = 1209;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			tooltip = "Paste config here. (ctrl + v)";
		};

		class cimport: RscButton
		{
			idc = 1210;
			text = "IMPORT";			
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call VOX_FNC_IMPORT;";
			tooltip = "Load pasted config.";
		};

		class cexport: RscButton
		{
			idc = 1211;
			text = "EXPORT";			
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 4 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call VOX_FNC_EXPORT;";
			tooltip = "Copy config to clipboard.";
		};			
		
		class scenario: RscCombo
		{
			idc = 1212;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "VOX_SCENARIO = ['WEST','EAST','NORTH','SOUTH'] select (_this select 1)";
			tooltip = "Cange scenario.";
		};		
		
		class start: RscButton
		{
			idc = 1213;
			text = "> START <";			
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 4 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call VOX_FNC_START;";
			tooltip = "Start scenario.";
		};		
	};
};