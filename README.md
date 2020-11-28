# Bambi-Loadout
By Crito 11/27/2020

Loadout script with player UID's or respect based with randomized weapon tiers.

INSTALLATION:

Put the ExileServer_object_player_createBambi.sqf inside a folder named custom and place it into your mission.map.pbo or if you already have a custom folder in your mission.map.pbo then just paste this file into it.

Next you need to add the following code to the custom code section of  your config.cpp file found in your mission.map.pbo. 

ExileServer_object_player_createBambi = "custom\ExileServer_object_player_createBambi.sqf";

ABOUT THIS SCRIPT AND HOW IT ALL WORKS.

In this script you will find 4 weapons tiers that you can change or add any weapons in each tier to your liking.
Below the weapon tiers are 5 loaduts based on Player UID's. This is where you will put together a loadout that only 1 player is able to spawn in with and no one else.
Below the 5 UID based loadouts you will find the loadouts based off of player respect.
If the player does not have a UID assigned to loadout in the UID loadout section then they will automatically be using the respect based loadouts.
In each respect based loadout you will notice there is no specific weapon or ammo assigned to the loadouts. That is what This line of code is for [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; 
_Tier1PrimaryWeapons points to the weapon tier that will randomly be selected for the player and the ammo will automatically be given for whatever weapon they end up with.
,3] is the number of magazines you want the player to have when they spawn in, but if you give them alot of ammo you need to make sure you give them the ability to carry all ammo and items you can not give them a uniform and no vest or backpack and expect them to carry 10 magazines and food, water, ect.
If giving them weapon attachments you need to make sure that the weapons in the tiers can support the attachments otherwise they may not work out to well.
You can remove [_bambiPlayer,_Tier1PrimaryWeapons,3] call bis_fnc_addWeapon; and add a specific weapon to the loadouts but you will have to also define the ammo for that weapon in the loadout as well. Im sure if you just replace _Tier1PrimaryWeapons in [_bambiPlayer,_Tier1PrimaryWeapons,3] with a specific weapon enclosed in quotes it will also work and you shouldnt have to define the ammo if done this way but I have not tested it.
