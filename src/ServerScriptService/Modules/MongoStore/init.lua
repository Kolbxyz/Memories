--[[

	MongoStore is an alternative to DataStoreService
	which uses the Rongo module as an interface to
	MongoDB.
	
	MongoStore includes quite a few of the functions
	which DataStoreService has and it aims to make the
	transition from DataStoreService as smooth as possible
	
	You will need a MongoDB account to use MongoStore
	
	Version: 1.0.0
	License: MIT License
	Contributors:
		- Starnamics (Creator)
	Documentation: N/A

--]]

MONGOSTORE_CLUSTER = "Cluster0"

local warn = function(...) return warn("[MongoStore]",...) end
local print = function(...) return print("[MongoStore]",...) end

local Rongo = require(script:WaitForChild("Rongo"))
local Client = nil	

local MongoStore = {}

local MongoDataStore = {}
MongoDataStore.__index = MongoDataStore

function MongoStore:Authorize(API_ID:string,API_KEY:string,Cluster: string?): boolean?
	if Cluster then MONGOSTORE_CLUSTER = Cluster end
	Client = Rongo.new(API_ID,API_KEY)
	return true
end

function MongoStore:GetDataStore(Name: string,Scope: string)
	if not Client then repeat task.wait() until Client end
	local DataStore = {}
	setmetatable(DataStore,MongoDataStore)
	DataStore.Name = Name
	DataStore.Scope = Scope
	return DataStore
end

function MongoDataStore:GetAsync(Key: string): {[string]: any?}?
	local Collection = Client:GetCluster(MONGOSTORE_CLUSTER):GetDatabase(self.Name):GetCollection(self.Scope)
	local Document = Collection:FindOne({["key"] = Key})
	if Document then return Document["data"] else return nil end
end

function MongoDataStore:RemoveAsync(Key: string): boolean
	local Collection = Client:GetCluster(MONGOSTORE_CLUSTER):GetDatabase(self.Name):GetCollection(self.Scope)
	local Result = Collection:DeleteOne({["key"] = Key})
	if not Result or Result == 0 then return false end
	return true
end

function MongoDataStore:SetAsync(Key: string,Value: any): boolean
	local Collection = Client:GetCluster(MONGOSTORE_CLUSTER):GetDatabase(self.Name):GetCollection(self.Scope)
	local Result = Collection:ReplaceOne({["key"] = Key},{["key"] = Key,["data"] = Value},true)
	if not Result or Result.modifiedCount == 0 then return false end
	return true
end

function MongoDataStore:UpdateAsync(Key: string,Value: any): boolean
	local Collection = Client:GetCluster(MONGOSTORE_CLUSTER):GetDatabase(self.Name):GetCollection(self.Scope)
	local Result = Collection:UpdateOne({["key"] = Key},{["key"] = Key,["data"] = Value},true)
	if not Result or Result.modifiedCount == 0 then return false end
	return true
end

return MongoStore