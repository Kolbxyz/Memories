local NPCs = workspace.NPCs

local Dialogs = {
	--[[
	["0001"] = {
		["IsQuest"] = true;
		["NumberOfTasks"] = 2;
		["NPC"] = NPCs:WaitForChild("0001");
		["Name"] = "Dummy";
		["Dialogs"] = {
			["Quests"] = {
				["Start"] = {
					{
						{
							["Content"] = "Hello! Could you help me?";
							["Choices"] = {
								["Yes"] = true;
								["No"] = false;
							}
						};
						{
							["Content"] = "I lost my key somewhere!";
							["Choices"] = nil
						}
					};
				};

				["Finish"] = {
					{
						"Oh! Thank you so much!!";
					};
					{
						"I'm really sorry, I won't lose it ever again!"
					};
				};
			};
			
			["Answers"] = {
				{
					["true"] = "Great! Thank you so much!";
					["false"] = "Aw, ok..";
				};
				{
					["true"] = "Great! Tank you so much!";
					["false"] = "Aw, ok, sad..";
				};
			};
			
			["Random"] = {
				{
					"What a beautiful day!";
				};
			}
		};
		["Rewards"] = {
			{
				["Item"] = "Chocolate";
				["Quantity"] = 2;
			};
			{
				["Item"] = "Sugar";
				["Quantity"] = 5;
			}
		}
	};
	--]]
	
	["0001"] = {
		["IsQuest"] = false;
		["NumberOfTasks"] = nil;
		["NPC"] = NPCs:WaitForChild("Kolbxyz");
		["Name"] = "Kolbxyz";
		["Action"] = "Talk";
		["Dialogs"] = {
			["Quests"] = {};
			["Random"] = {
				{
					{
						["Content"] = string.format("Hi! 2022 ends in %d hours!", (1672527600-DateTime.now().UnixTimestamp)/3600);
						["Choices"] = nil
					};
				};
				{
					{
						["Content"] = "Hi! 2022 has been an incredible year for me! Do you want to know the stats of the game?";
						["Choices"] = {
							["Yes!"] = true;
							["No, thanks."] = false;
						}
					};
				};
			};
			["Answers"] = {
				{};
				{
					{
						["true"] = [[Since the game was created on 8/15/2022 I recorded:
						169 visits on the game; 53 players sent a message; 57 messages created
						It may not be a lot but It's already something!
						]];
						["false"] = "Alright, have a good day, merry christmas & happy new year!!";
					};
				};
			};
		};
		
			["Rewards"] = {}
	};
}

return Dialogs