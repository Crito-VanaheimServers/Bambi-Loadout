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

//Weapon Tier, Suppressor tier and optics is to randomize what weapon and its attachments the player spawns in with.
//If a weapon that does not support an attachment is added to the tiers it is ok the attachment will be ignored.
//if using the weapon tiers code found in the respect based loadouts below do not define ammo because it is automatically coded to give the ammo specific to the random gun players end up with.
private _Tier1PrimaryWeapons = selectRandom
											[		//5.56mm
												"arifle_Mk20_plain_F",				
												"arifle_TRG20_F",
												"arifle_SPAR_01_blk_F",				
												"Exile_Weapon_M16A4",
												"Exile_Weapon_M4"
											];	
											
private _Tier1Suppressors = selectRandom
											[
												"muzzle_snds_M"
											];
				
	
private _Tier2PrimaryWeapons = selectRandom
											[		//6.5mm
												"LMG_Mk200_F",
												"arifle_Katiba_F",
												"arifle_MXC_Black_F",
												"srifle_DMR_07_blk_F",
												"arifle_ARX_blk_F"
											];
											
private _Tier2Suppressors = selectRandom	
											[
												"muzzle_snds_H"
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

private _Tier3Suppressors = selectRandom	
											[
												"muzzle_snds_B",
												"muzzle_snds_H_MG_blk_F"
											];


private _Tier4PrimaryWeapons = selectRandom
											[	//Random High Calib.
												"srifle_DMR_05_hex_F",
												"MMG_01_tan_F",
												"srifle_DMR_02_F",
												"MMG_02_black_F",
												"srifle_GM6_F"
											];
											
private _Tier4Suppressors = selectRandom	
											[
												"muzzle_snds_93mmg",
												"muzzle_snds_338_black"
											];

private _RndmOptic = selectRandom 
											[
												"optic_AMS",
												"optic_DMS",
												"optic_Arco_blk_F",
												"optic_Hamr",
												"optic_LRPS",
												"optic_KHS_blk",
												"optic_Nightstalker",
												"optic_Yorris",
												"optic_ERCO_blk_F",
												"optic_SOS",
												"optic_ACO_grn"
											];

switch (true) do 
{

//Loadouts by UID place the player UID in "PlacePlayerUIDHere" inside the quotations.

//UID Loadout 1												//Wullf
        if ((getPlayerUID _requestingPlayer) isEqualTo ("76561198144781827"))exitWith 
        {
			clearWeaponCargo _bambiPlayer; 
			clearMagazineCargo _bambiPlayer;
			_bambiPlayer forceAddUniform "U_B_Protagonist_VR"; // adds uniforms
			_bambiPlayer addVest "V_PlateCarrierGL_blk";
			_bambiPlayer addBackpack "B_ViperHarness_blk_F";
			_bambiPlayer addHeadgear "H_HelmetO_ViperSP_ghex_F";
			[_bambiPlayer,"srifle_DMR_05_blk_F",5] call bis_fnc_addWeapon;
			_bambiPlayer addPrimaryWeaponItem "muzzle_snds_93mmg";
			_bambiPlayer addPrimaryWeaponItem "bipod_01_F_blk";
			_bambiPlayer addPrimaryWeaponItem "optic_LRPS";
			[_bambiPlayer,"hgun_ACPC2_F",2] call bis_fnc_addWeapon;
			_bambiPlayer addWeapon "Exile_Item_XM8";
			_bambiPlayer addWeapon "ItemCompass";
			_bambiPlayer addWeapon "ItemMap";
			_bambiPlayer addWeapon "ItemRadio";
			_bambiPlayer addWeapon "ItemGPS";
			_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
			_bambiPlayer addItemToUniform "Exile_Item_EMRE";
			_bambiPlayer addItemToUniform "Exile_Item_BeefParts";
			_bambiPlayer addItemToUniform "Exile_Item_BeefParts";
			_bambiPlayer addItemToVest "Exile_Item_Defibrillator";
			_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
			_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
			_bambiPlayer addItemToVest "Exile_Item_Wrench";
			_bambiPlayer addItemToVest "Exile_Item_ExtensionCord";
		};	

//UID Loadout 2												//Kooter
        if ((getPlayerUID _requestingPlayer) isEqualTo ("76561198396847748"))exitWith
        {
			clearWeaponCargo _bambiPlayer; 
			clearMagazineCargo _bambiPlayer;
			_bambiPlayer forceAddUniform "U_O_FullGhillie_sard"; // adds uniforms
			_bambiPlayer addVest "V_PlateCarrierGL_blk";
			_bambiPlayer addBackpack "B_Carryall_khk";
			_bambiPlayer addHeadgear "H_HelmetO_ViperSP_ghex_F";
			_bambiPlayer addWeapon "Exile_Item_XM8";
			_bambiPlayer addWeapon "ItemCompass";
			_bambiPlayer addWeapon "ItemMap";
			_bambiPlayer addWeapon "ItemRadio";
			_bambiPlayer addWeapon "ItemGPS";
			_bambiPlayer addWeapon "Rangefinder";
			[_bambiPlayer,"MMG_02_black_F",5] call bis_fnc_addWeapon;
			[_bambiPlayer,"hgun_ACPC2_F",2] call bis_fnc_addWeapon;
			_bambiPlayer addHandgunItem "acc_flashlight_pistol";
			_bambiPlayer addItemToBackpack "MineDetector";
			_bambiPlayer addItemToBackpack "Exile_Item_InstaDoc";
			_bambiPlayer addItemToBackpack "Exile_Item_InstaDoc";
			_bambiPlayer addItemToBackpack "Exile_Item_InstaDoc";
			_bambiPlayer addItemToBackpack "Exile_Item_InstaDoc";
			_bambiPlayer addItemToBackpack "Exile_Item_Defibrillator";
			_bambiPlayer addItemToBackpack "Exile_Item_EMRE";
			_bambiPlayer addItemToBackpack "Exile_Item_EMRE";
			_bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleCoffee";
			_bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleCoffee";
			_bambiPlayer addItemToBackpack "Exile_Item_ExtensionCord";
			_bambiPlayer addItemToBackpack "Exile_Item_Wrench";
        };	
		
//UID Loadout 3									
        if ((getPlayerUID _requestingPlayer) isEqualTo ("PlacePlayerUIDHere"))exitWith 
        {
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
			_bambiPlayer addMagazines ["5Rnd_127x108_Mag", 3];
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
        if ((getPlayerUID _requestingPlayer) isEqualTo ("PlacePlayerUIDHere"))exitWith 
        {
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
			_bambiPlayer addWeapon "LMG_Zafir_F";
			_bambiPlayer addPrimaryWeaponItem "optic_KHS_blk";
			_bambiPlayer addMagazines ["150Rnd_762x54_Box", 3];
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
        if ((getPlayerUID _requestingPlayer) isEqualTo ("PlacePlayerUIDHere"))exitWith 
        {
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
			_bambiPlayer addMagazines ["5Rnd_127x108_Mag", 3];
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


//If players are not given a loadout by UID number they will automatically be given loadouts below this line based on how much respect they have.	
   case (_Respect > 0 && _Respect < 4999):
   //Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_BambiOverall";
	 _bambiplayer addVest "V_Rangemaster_belt";
	 [_bambiPlayer,_Tier1PrimaryWeapons,5] call bis_fnc_addWeapon; 	//3 defines how many magazines the player will spawn with. _Tier1PrimaryWeapons point to weapon tier 1 above.
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
   
   case (_Respect > 5000 && _Respect < 9999):
   //Bambi Plus
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_BambiOverall";
	 _bambiplayer addVest "V_BandollierB_blk";
	 [_bambiPlayer,_Tier1PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 10000 && _Respect < 14999):
    //Super Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_BambiOverall";
	 _bambiplayer addVest "V_BandollierB_blk";
	 _bambiPlayer addBackpack "B_AssaultPack_blk";
	 [_bambiPlayer,_Tier1PrimaryWeapons,5] call bis_fnc_addWeapon; 
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 15000 && _Respect < 19999):
    //Definetly Not a Bambi
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_BambiOverall";
	 _bambiplayer addVest "V_BandollierB_blk";
	 _bambiPlayer addBackpack "B_AssaultPack_blk";
	 [_bambiPlayer,_Tier1PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addPrimaryWeaponItem _Tier1Suppressors;
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Binocular";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
 
    case (_Respect > 20000 && _Respect < 24999):
    //Woodman
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_BambiOverall";
	 _bambiplayer addVest "V_BandollierB_blk";
	 _bambiPlayer addBackpack "B_AssaultPack_blk";
	 _bambiPlayer addHeadgear "H_HelmetB_plain_blk";
	 [_bambiPlayer,_Tier1PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addPrimaryWeaponItem _Tier1Suppressors;	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Binocular";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 25000 && _Respect < 29999):
    //Robber
    {
	clearWeaponCargo _bambiPlayer; 
	clearMagazineCargo _bambiPlayer;
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_AssaultPack_blk";
	 _bambiPlayer addHeadgear "H_HelmetB_plain_blk";
	 [_bambiPlayer,_Tier2PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Binocular";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 30000 && _Respect < 34999):
    //Hunter
    {
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_AssaultPack_blk";
	 _bambiPlayer addHeadgear "H_HelmetB_plain_blk";
	 [_bambiPlayer,_Tier2PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 35000 && _Respect < 39999):
    //Worker
    {
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_FieldPack_blk";
	 _bambiPlayer addHeadgear "H_HelmetB_plain_blk";
	 [_bambiPlayer,_Tier2PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;	 	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 40000 && _Respect < 44999):
    //Murderer
    {
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_FieldPack_blk";
	 _bambiPlayer addHeadgear "H_HelmetSpecB_paint2";
	 [_bambiPlayer,_Tier2PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;	
	 _bambiPlayer addPrimaryWeaponItem _Tier2Suppressors;	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 45000 && _Respect < 49999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "Exile_Uniform_Woodland";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetSpecB_paint2";
	 [_bambiPlayer,_Tier2PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_flashlight";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;	
	 _bambiPlayer addPrimaryWeaponItem _Tier2Suppressors;	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 50000 && _Respect < 59999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetSpecB_paint2";
	 [_bambiPlayer,_Tier3PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 60000 && _Respect < 69999):
    //KUT AK
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetSpecB_paint2";
	 [_bambiPlayer,_Tier3PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_pointer_IR";
	 _bambiPlayer addPrimaryWeaponItem _Tier3Suppressors;	 
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 70000 && _Respect < 79999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrier1_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetLeaderO_ocamo";
	 [_bambiPlayer,_Tier3PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_pointer_IR";
	 _bambiPlayer addPrimaryWeaponItem _Tier3Suppressors;	 
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 80000 && _Respect < 89999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrierGL_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetLeaderO_ocamo";
	 [_bambiPlayer,_Tier4PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_pointer_IR";
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 90000 && _Respect < 99999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrierGL_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetLeaderO_ocamo";
	 [_bambiPlayer,_Tier4PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_pointer_IR";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
    };
	
    case (_Respect > 100000 && _Respect < 9999999):
    //Prisoner
    {
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard";
	 _bambiplayer addVest "V_PlateCarrierGL_rgr";
	 _bambiPlayer addBackpack "B_Carryall_cbr";
	 _bambiPlayer addHeadgear "H_HelmetLeaderO_ocamo";
	 [_bambiPlayer,_Tier4PrimaryWeapons,5] call bis_fnc_addWeapon;
	 _bambiPlayer addPrimaryWeaponItem "acc_pointer_IR";
	 _bambiPlayer addPrimaryWeaponItem _RndmOptic;
	 _bambiPlayer addPrimaryWeaponItem _Tier4Suppressors;	 
	 _bambiPlayer addItem "NVGoggles_INDEP";
	 _bambiPlayer assignItem "NVGoggles_INDEP";	 
	 _bambiPlayer addWeapon "Exile_Item_XM8";
	 _bambiPlayer addWeapon "ItemCompass";
	 _bambiPlayer addWeapon "ItemMap";
	 _bambiPlayer addWeapon "ItemRadio";
	 _bambiPlayer addWeapon "ItemGPS";
	 _bambiPlayer addWeapon "Rangefinder";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiplayer addItem "Exile_Item_InstaDoc";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
	 _bambiPlayer addItemToBackpack "HandGrenade";
     _bambiplayer addItem "Exile_Item_PlasticBottleCoffee";
	 _bambiplayer addItem "Exile_Item_EMRE";
     _bambiplayer addItem "Exile_Item_ExtensionCord";
	 _bambiPlayer addItemToBackpack "Exile_Item_Wrench";
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