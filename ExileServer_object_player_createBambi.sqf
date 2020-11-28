/**
 * ExileServer_object_player_createBambi
 *
 * Exile Mod
 * www.exilemod.com
 * © 2015 Exile Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
 
private["_sessionID","_requestingPlayer","_spawnLocationMarkerName","_thugToCheck","_HaloSpawnCheck","_bambiPlayer","_accountData","_direction","_position","_spawnAreaPosition","_spawnAreaRadius","_clanID","_clanData","_clanGroup","_player","_devFriendlyMode","_devs","_parachuteNetID","_spawnType","_parachuteObject"];
_sessionID = _this select 0;
_requestingPlayer = _this select 1;
_spawnLocationMarkerName = _this select 2;
_bambiPlayer = _this select 3;
_accountData = _this select 4;
_direction = random 360;
_Respect = (_accountData select 0);
if ((count ExileSpawnZoneMarkerPositions) isEqualTo 0) then 
{
    _position = call ExileClient_util_world_findCoastPosition;
    if ((toLower worldName) isEqualTo "namalsk") then 
    {
        while {(_position distance2D [76.4239, 107.141, 0]) < 100} do 
        {
            _position = call ExileClient_util_world_findCoastPosition;
        };
    };
}
else 
{
    _spawnAreaPosition = getMarkerPos _spawnLocationMarkerName;
    _spawnAreaRadius = getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "spawnZoneRadius");
    _position = [_spawnAreaPosition, _spawnAreaRadius] call ExileClient_util_math_getRandomPositionInCircle;
    while {surfaceIsWater _position} do 
    {
        _position = [_spawnAreaPosition, _spawnAreaRadius] call ExileClient_util_math_getRandomPositionInCircle;
    };
};

_name = name _requestingPlayer;
_clanID = (_accountData select 3);
if !((typeName _clanID) isEqualTo "SCALAR") then
{
    _clanID = -1;
    _clanData = [];
}
else
{
    _clanData = missionNamespace getVariable [format ["ExileServer_clan_%1",_clanID],[]];
    if(isNull (_clanData select 5))then
    {
        _clanGroup = createGroup independent;
        _clanData set [5,_clanGroup];
        _clanGroup setGroupIdGlobal [_clanData select 0];
        missionNameSpace setVariable [format ["ExileServer_clan_%1",_clanID],_clanData];
    }
    else
    {
        _clanGroup = (_clanData select 5);
    };
    [_player] joinSilent _clanGroup;
};
_bambiPlayer setPosATL [_position select 0,_position select 1,0];
_bambiPlayer disableAI "FSM";
_bambiPlayer disableAI "MOVE";
_bambiPlayer disableAI "AUTOTARGET";
_bambiPlayer disableAI "TARGET";
_bambiPlayer disableAI "CHECKVISIBLE";
_bambiPlayer setDir _direction;
_bambiPlayer setName _name;
_bambiPlayer setVariable ["ExileMoney", 0, true]; 
_bambiPlayer setVariable ["ExileScore", (_accountData select 0)];
_bambiPlayer setVariable ["ExileKills", (_accountData select 1)];
_bambiPlayer setVariable ["ExileDeaths", (_accountData select 2)];
_bambiPlayer setVariable ["ExileClanID", _clanID];
_bambiPlayer setVariable ["ExileClanData", _clanData];
_bambiPlayer setVariable ["ExileHunger", 100];
_bambiPlayer setVariable ["ExileThirst", 100];
_bambiPlayer setVariable ["ExileTemperature", 37];
_bambiPlayer setVariable ["ExileWetness", 0];
_bambiPlayer setVariable ["ExileAlcohol", 0]; 
_bambiPlayer setVariable ["ExileName", _name]; 
_bambiPlayer setVariable ["ExileOwnerUID", getPlayerUID _requestingPlayer]; 
_bambiPlayer setVariable ["ExileIsBambi", true];
_bambiPlayer setVariable ["ExileXM8IsOnline", false, true];
_bambiPlayer setVariable ["ExileLocker", (_accountData select 4), true];
_devFriendlyMode = getNumber (configFile >> "CfgSettings" >> "ServerSettings" >> "devFriendyMode");
if (_devFriendlyMode isEqualTo 1) then 
{
    _devs = getArray (configFile >> "CfgSettings" >> "ServerSettings" >> "devs");
    {
        if ((getPlayerUID _requestingPlayer) isEqualTo (_x select 0))exitWith 
        {
            if((name _requestingPlayer) isEqualTo (_x select 1))then
            {
                _bambiPlayer setVariable ["ExileMoney", 500000, true];
                _bambiPlayer setVariable ["ExileScore", 100000];
            };
        };
    }
    forEach _devs;
};
_parachuteNetID = "";

_thugToCheck = _sessionID call ExileServer_system_session_getPlayerObject;
_HaloSpawnCheck = _thugToCheck getVariable ["playerWantsHaloSpawn", 0];

if (_HaloSpawnCheck isEqualTo 1) then
{
    _position set [2, getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "parachuteDropHeight")]; 
    if ((getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "haloJump")) isEqualTo 1) then
    {
        _bambiPlayer addBackpackGlobal "B_Parachute";
        _bambiPlayer setPosATL _position;
        _spawnType = 2;
    }
    else 
    {
        _parachuteObject = createVehicle ["Steerable_Parachute_F", _position, [], 0, "CAN_COLLIDE"];
        _parachuteObject setDir _direction;
        _parachuteObject setPosATL _position;
        _parachuteObject enableSimulationGlobal true;
        _parachuteNetID = netId _parachuteObject;
        _spawnType = 1;
    };
}
else
{
    _spawnType = 0;
};

//Weapon Tier is to randomize what weapon the player spawns in with.
//if you change the weapons in these weapon tiers make sure all the weapons will be able to use the type of attachments you are using in the loadout your putting them in.
//if using the weapon tiers code found in the respect based loadouts below do not define ammo because it is automatically coded to give the ammo specific to the random gun players end up with.
private _Tier1PrimaryWeapons = selectRandom
											[		//5.56mm
												"arifle_Mk20_plain_F",				
												"arifle_TRG20_F",
												"arifle_SPAR_01_blk_F",				
												"Exile_Weapon_M16A4",
												"Exile_Weapon_M4"		
											];	
	
private _Tier2PrimaryWeapons = selectRandom
											[		//6.5mm
												"LMG_Mk200_F",
												"arifle_Katiba_F",
												"arifle_MXC_Black_F",
												"srifle_DMR_07_blk_F",
												"arifle_ARX_blk_F"
											];
											
private _Tier3PrimaryWeapons = selectRandom
											[		//7.62mm
												"srifle_DMR_01_F",
												"srifle_EBR_F",
												"LMG_Zafir_F",
												"srifle_DMR_03_F",
												"Exile_Weapon_AK47",
												"arifle_SPAR_03_khk_F",
												"Exile_Weapon_DMR",
												"Exile_Weapon_PKP"
											];

private _Tier4PrimaryWeapons = selectRandom
											[	//Random High Calib.
												"srifle_DMR_05_hex_F",
												"MMG_01_tan_F",
												"srifle_DMR_02_F",
												"MMG_02_black_F",
												"srifle_GM6_F"			
											];
				
switch (true) do 
{
//Loadouts by UID place the player UID in "PlacePlayerUIDHere" inside the quotations.

//UID Loadout 1
	if((getPlayerUID _requestingPlayer) in ["PlacePlayerUIDHere"]) then {
		clearWeaponCargo _bambiPlayer; 
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
		_bambiPlayer addVest "V_HarnessOGL_gry";
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemRadio";
		_bambiPlayer addWeapon "ItemGPS";
		_bambiPlayer addWeapon "Rangefinder";
		_bambiPlayer addItem "NVGoggles_INDEP";
		_bambiPlayer assignItem "NVGoggles_INDEP";
		_bambiPlayer addBackpack "B_Carryall_cbr";
		_bambiPlayer addItemToBackpack "HandGrenade";
		_bambiPlayer addWeapon "srifle_GM6_camo_F";
		_bambiPlayer addPrimaryWeaponItem "optic_KHS_blk";
		_bambiPlayer addMagazines ["5Rnd_127x108_Mag", 4];
		_bambiPlayer addWeapon "hgun_Pistol_heavy_01_F";
		_bambiPlayer addHandgunItem "muzzle_snds_acp";
		_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 3];
		_bambiPlayer addItemToVest "Exile_Item_EMRE";
		_bambiPlayer addItemToVest "Exile_Item_EnergyDrink";
		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
		_bambiPlayer addItemToVest "Exile_Item_DuctTape";
		_bambiPlayer addItemToUniform "Exile_Item_Bandage";
		_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
		};
	
//UID Loadout 2
	if((getPlayerUID _requestingPlayer) in ["PlacePlayerUIDHere"]) then {
		clearWeaponCargo _bambiPlayer; 
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
		_bambiPlayer addVest "V_HarnessOGL_gry";
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemRadio";
		_bambiPlayer addWeapon "ItemGPS";
		_bambiPlayer addWeapon "Rangefinder";
		_bambiPlayer addItem "NVGoggles_INDEP";
		_bambiPlayer assignItem "NVGoggles_INDEP";
		_bambiPlayer addBackpack "B_Carryall_cbr";
		_bambiPlayer addItemToBackpack "HandGrenade";
		_bambiPlayer addWeapon "srifle_GM6_camo_F";
		_bambiPlayer addPrimaryWeaponItem "optic_KHS_blk";
		_bambiPlayer addMagazines ["5Rnd_127x108_Mag", 4];
		_bambiPlayer addWeapon "hgun_Pistol_heavy_01_F";
		_bambiPlayer addHandgunItem "muzzle_snds_acp";
		_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 3];
		_bambiPlayer addItemToVest "Exile_Item_EMRE";
		_bambiPlayer addItemToVest "Exile_Item_EnergyDrink";
		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
		_bambiPlayer addItemToVest "Exile_Item_DuctTape";
		_bambiPlayer addItemToUniform "Exile_Item_Bandage";
		_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
		};

//UID Loadout 3
	if((getPlayerUID _requestingPlayer) in ["PlacePlayerUIDHere"]) then {
		clearWeaponCargo _bambiPlayer; 
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
		_bambiPlayer addVest "V_HarnessOGL_gry";
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemGPS";
		_bambiPlayer addWeapon "Rangefinder";
		_bambiPlayer addItem "NVGoggles_INDEP";
		_bambiPlayer assignItem "NVGoggles_INDEP";
		_bambiPlayer addBackpack "B_Carryall_cbr";
		_bambiPlayer addItemToBackpack "HandGrenade";
		_bambiPlayer addWeapon "LMG_Zafir_F";
		_bambiPlayer addPrimaryWeaponItem "optic_DMS";
		_bambiPlayer addMagazines ["150Rnd_762x54_Box_Tracer", 2];
		_bambiPlayer addWeapon "hgun_Pistol_heavy_01_F";
		_bambiPlayer addHandgunItem "muzzle_snds_acp";
		_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 3];
		_bambiPlayer addItemToVest "Exile_Item_EMRE";
		_bambiPlayer addItemToVest "Exile_Item_EnergyDrink";
		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
		_bambiPlayer addItemToVest "Exile_Item_DuctTape";
		_bambiPlayer addItemToUniform "Exile_Item_Bandage";
		_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
		};
		
//UID Loadout 4
	if((getPlayerUID _requestingPlayer) in ["PlacePlayerUIDHere"]) then {
		clearWeaponCargo _bambiPlayer; 
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
		_bambiPlayer addVest "V_HarnessOGL_gry";
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemGPS";
		_bambiPlayer addWeapon "Rangefinder";
		_bambiPlayer addItem "NVGoggles_INDEP";
		_bambiPlayer assignItem "NVGoggles_INDEP";
		_bambiPlayer addBackpack "B_Carryall_cbr";
		_bambiPlayer addItemToBackpack "HandGrenade";
		_bambiPlayer addWeapon "LMG_Zafir_F";
		_bambiPlayer addPrimaryWeaponItem "optic_DMS";
		_bambiPlayer addMagazines ["150Rnd_762x54_Box_Tracer", 2];
		_bambiPlayer addWeapon "hgun_Pistol_heavy_01_F";
		_bambiPlayer addHandgunItem "muzzle_snds_acp";
		_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 3];
		_bambiPlayer addItemToVest "Exile_Item_EMRE";
		_bambiPlayer addItemToVest "Exile_Item_EnergyDrink";
		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
		_bambiPlayer addItemToVest "Exile_Item_DuctTape";
		_bambiPlayer addItemToUniform "Exile_Item_Bandage";
		_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
		};
		
//UID Loadout 5		
	if((getPlayerUID _requestingPlayer) in ["PlacePlayerUIDHere"]) then {
		clearWeaponCargo _bambiPlayer; 
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
		_bambiPlayer addVest "V_HarnessOGL_gry";
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemRadio";
		_bambiPlayer addWeapon "ItemGPS";
		_bambiPlayer addWeapon "Rangefinder";
		_bambiPlayer addItem "NVGoggles_INDEP";
		_bambiPlayer assignItem "NVGoggles_INDEP";
		_bambiPlayer addBackpack "B_Carryall_cbr";
		_bambiPlayer addItemToBackpack "HandGrenade";
		_bambiPlayer addWeapon "srifle_GM6_camo_F";
		_bambiPlayer addPrimaryWeaponItem "optic_KHS_blk";
		_bambiPlayer addMagazines ["5Rnd_127x108_Mag", 4];
		_bambiPlayer addWeapon "hgun_Pistol_heavy_01_F";
		_bambiPlayer addHandgunItem "muzzle_snds_acp";
		_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 3];
		_bambiPlayer addItemToVest "Exile_Item_EMRE";
		_bambiPlayer addItemToVest "Exile_Item_EnergyDrink";
		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
		_bambiPlayer addItemToVest "Exile_Item_DuctTape";
		_bambiPlayer addItemToUniform "Exile_Item_Bandage";
		_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
	} else {
	
//If players are not given a loadout by UID number they will automatically be given loadouts below this line based on how much respect they have.	
   case (_Respect > 0 && _Respect < 4999):
   //Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 	//3 defines how many magazines the player will spawn with. _Tier1PrimaryWeapons point to weapon tier 1 above.
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
   
   case (_Respect > 5000 && _Respect < 9999):
   //Bambi Plus
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 10000 && _Respect < 14999):
    //Super Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 15000 && _Respect < 19999):
    //Definetly Not a Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 20000 && _Respect < 24999):
    //Woodman
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 25000 && _Respect < 29999):
    //Robber
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier2PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 30000 && _Respect < 34999):
    //Hunter
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier2PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 35000 && _Respect < 39999):
    //Worker
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier2PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 40000 && _Respect < 44999):
    //Murderer
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier2PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 45000 && _Respect < 49999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier2PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 50000 && _Respect < 59999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier3PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 60000 && _Respect < 69999):
    //KUT AK
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier3PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 70000 && _Respect < 79999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier4PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 80000 && _Respect < 89999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier4PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 90000 && _Respect < 99999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier4PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 100000 && _Respect < 9999999):
    //Prisoner
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier4PrimaryWeapons,3] call bis_fnc_addWeapon; 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
   default
    {  
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem  "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem  "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
     _bambiplayer addMagazines ["30Rnd_556x45_Stanag", 5];
     _bambiPlayer addWeapon "arifle_Mk20_plain_F";
     };
	};
};

if((canTriggerDynamicSimulation _bambiPlayer) isEqualTo false) then 
{
    _bambiPlayer triggerDynamicSimulation true; 
};
_bambiPlayer addMPEventHandler ["MPKilled", {_this call ExileServer_object_player_event_onMpKilled}];
_bambiPlayer call ExileServer_object_player_database_insert;
_bambiPlayer call ExileServer_object_player_database_update;
[
    _sessionID, 
    "createPlayerResponse", 
    [
        _bambiPlayer, 
        _parachuteNetID, 
        str (_accountData select 0),
        (_accountData select 1),
        (_accountData select 2),
        100,
        100,
        0,
        (getNumber (configFile >> "CfgSettings" >> "BambiSettings" >> "protectionDuration")) * 60, 
        _clanData,
        _spawnType
    ]
] 
call ExileServer_system_network_send_to;
[_sessionID, _bambiPlayer] call ExileServer_system_session_update;
true