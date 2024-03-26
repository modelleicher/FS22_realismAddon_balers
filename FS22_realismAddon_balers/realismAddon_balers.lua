-- by modelleicher ( Farming Agency )


realismAddon_balers = {};

realismAddon_balers.fillTypePowerMultiplicator = {}
realismAddon_balers.fillTypePowerMultiplicator["WETGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["GRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYGRASS_WINDROW"] = 1.0
realismAddon_balers.fillTypePowerMultiplicator["STRAW"] = 1.1

realismAddon_balers.fillTypePowerMultiplicator["BARLEYSTRAW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["OATSTRAW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["SPELTSTRAW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["RYESTRAW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["TRITICALESTRAW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["MAIZESTRAW"] = 1.1

realismAddon_balers.fillTypePowerMultiplicator["WETPASTUREGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["PASTUREGRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYPASTUREGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYPASTUREGRASS_WINDROW"] = 1.0

realismAddon_balers.fillTypePowerMultiplicator["WETHERBGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["HERBGRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYHERBGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYHERBGRASS_WINDROW"] = 1.0

realismAddon_balers.fillTypePowerMultiplicator["WETFIELDGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["FIELDGRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYFIELDGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYFIELDGRASS_WINDROW"] = 1.0

realismAddon_balers.fillTypePowerMultiplicator["WETHORSEGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["HORSEGRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYHORSEGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYHORSEGRASS_WINDROW"] = 1.0
                 
realismAddon_balers.fillTypePowerMultiplicator["WETCLOVERGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["CLOVERGRASS_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYCLOVERGRASS_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYCLOVERGRASS_WINDROW"] = 1.0	

realismAddon_balers.fillTypePowerMultiplicator["WETCLOVERGRASS_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["CLOVER_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYCLOVER_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYCLOVER_WINDROW"] = 1.0	
			 
realismAddon_balers.fillTypePowerMultiplicator["WETALFALFA_WINDROW"] = 1.3
realismAddon_balers.fillTypePowerMultiplicator["ALFALFA_WINDROW"] = 1.2
realismAddon_balers.fillTypePowerMultiplicator["SEMIDRYALFALFA_WINDROW"] = 1.1
realismAddon_balers.fillTypePowerMultiplicator["DRYALFALFA_WINDROW"] = 1.0					 



function realismAddon_balers.onLoad(self, superFunc, savegame)

	local returnValue = superFunc(self, savegame)

	local spec = self.spec_baler

	spec.realismAddon_balers = {}

	
	-- check if baler is roundbaler or square baler and load required variables accordingly
	local defaultBaleType = spec.baleTypes[1]

	-- power calculation for both round and square balers

	-- average intake over the last millisecond divider
	spec.realismAddon_balers.intakeAverage = 0
	spec.realismAddon_balers.lastMilisecond = 0
	spec.realismAddon_balers.milisecondAverage = 500 -- over how many miliseconds the average is taken
	spec.realismAddon_balers.intakePowerReference = 120 -- l/milisecondAverage - how many liters per milisecondAverage amount 		
	spec.realismAddon_balers.lastIntakeTotal = 0 -- intake total since last milisecondAverage

	-- multiplicators for later
	spec.realismAddon_balers.powerMuliplicator = 1
	spec.realismAddon_balers.fillTypePowerMultiplicator = 1	
	
	-- current total power used
	spec.realismAddon_balers.totalPower = 0	



	if defaultBaleType.isRoundBale then -- stuff for roundbalers only
		print("is Roundbaler")
		spec.realismAddon_balers.isRoundbaler = true

		spec.realismAddon_balers.fillLevelNormalized = 0 -- current fillLevel / capacity		

		-- unload unfinished bales
		spec.unfinishedBaleThreshold = self:getFillUnitCapacity(spec.fillUnitIndex) * 0.6
		spec.canUnloadUnfinishedBale = true

	else						-- stuff for squarebalers only
		print("is Squarebaler")
		spec.realismAddon_balers.isSquarebaler = true

		-- fill level buffer for animation 
		spec.realismAddon_balers.fillLevelBuffer = 0
		spec.realismAddon_balers.pickedUpLiters = {}

		-- plunger power calculateion
		spec.realismAddon_balers.plungerPower = 0
	end

	return returnValue
end
Baler.onLoad = Utils.overwrittenFunction(Baler.onLoad, realismAddon_balers.onLoad)

function realismAddon_balers.getConsumedPtoTorque(self, superFunc, expected, ignoreTurnOnPeak)
	
	local powerConsumer =  self.spec_powerConsumer
	local baler = self.spec_baler
	local rpm = powerConsumer.ptoRpm

	-- square baler power calculation
	if self.spec_baler ~= nil and self.spec_baler.realismAddon_balers ~= nil and self.spec_baler.realismAddon_balers.isSquarebaler then

		local turnOnPeakPowerMultiplier = math.max(math.max(math.min(powerConsumer.turnOnPeakPowerTimer / powerConsumer.turnOnPeakPowerDuration, 1), 0) * powerConsumer.turnOnPeakPowerMultiplier, 1)

		if ignoreTurnOnPeak == true then
			turnOnPeakPowerMultiplier = 1
		end
			-- custom power calculation 
		if self:getDoConsumePtoPower() or expected ~= nil and expected then
			-- first we have the constant power of the machine running 
			-- we take neededMinPtoPower for that, half for constant load and the other half for the plunger load
			-- on many balers neededMinPtoPower is the same as maxPtoPower so needs adjusting in the baler
			local constantPower = powerConsumer.neededMinPtoPower * 0.5 + ((powerConsumer.neededMinPtoPower * 0.5) * baler.realismAddon_balers.plungerPower)

			-- next we have the load on the knives and pickup and all that
			-- take 50% of neededMaxPtoPower and multiply that by the intake percentage
			-- if below intakePowerReference the value is smaller than 50%neededMaxPtoPower, otherwise its bigger 
			local intakePower = (powerConsumer.neededMaxPtoPower * 0.5) * (baler.realismAddon_balers.intakeAverage / baler.realismAddon_balers.intakePowerReference )

			-- and last we have the power of the plunger 
			-- take 50% of neededMaxPtoPower and multiply that by the plungerPower 
			-- the intake average is also referenced here since the plunger is harder to push with more material
			local plungerPower = (powerConsumer.neededMaxPtoPower * 0.5) * ((baler.realismAddon_balers.intakeAverage / baler.realismAddon_balers.intakePowerReference ) * baler.realismAddon_balers.plungerPower)

			--print("constantPower: "..tostring(constantPower))
			--print("intakePower: "..tostring(intakePower))
			--print("plungerPower: "..tostring(plungerPower))		
			--print("fillTypePowerMultiplicator: "..tostring(baler.realismAddon_balers.fillTypePowerMultiplicator))	
				
			local totalPower = (constantPower + intakePower + (plungerPower * 1.5)) * baler.realismAddon_balers.fillTypePowerMultiplicator * baler.realismAddon_balers.powerMuliplicator 
			
			baler.realismAddon_balers.totalPower = baler.realismAddon_balers.totalPower * 0.6 + totalPower * 0.4

			return baler.realismAddon_balers.totalPower / (rpm * math.pi / 30), powerConsumer.virtualPowerMultiplicator * turnOnPeakPowerMultiplier
		end
		

	-- roundbaler power calculation
	elseif self.spec_baler ~= nil and self.spec_baler.realismAddon_balers ~= nil and self.spec_baler.realismAddon_balers.isRoundbaler then
		
		local turnOnPeakPowerMultiplier = math.max(math.max(math.min(powerConsumer.turnOnPeakPowerTimer / powerConsumer.turnOnPeakPowerDuration, 1), 0) * powerConsumer.turnOnPeakPowerMultiplier, 1)

		if ignoreTurnOnPeak == true then
			turnOnPeakPowerMultiplier = 1
		end

		-- first we have the constant power of the machine running 
		-- we take neededMinPtoPower for that - but we add the fill amount to that
		local constantPower = powerConsumer.neededMinPtoPower * 0.5 + ((powerConsumer.neededMinPtoPower * 0.5) * baler.realismAddon_balers.fillLevelNormalized)
		
		-- next we have the load on the knives and pickup and all that
		-- take 50% of neededMaxPtoPower and multiply that by the intake percentage
		-- if below intakePowerReference the value is smaller than 50%neededMaxPtoPower, otherwise its bigger 
		local intakePower = (powerConsumer.neededMaxPtoPower * 0.5) * (baler.realismAddon_balers.intakeAverage / baler.realismAddon_balers.intakePowerReference )

		-- 50% intake power is only based on intake alone (knives, moving material)
		-- other 50% is based on intakePower * fillLevel nonlinear 
		-- normalized is shifted by 0.2 to have a range from 0.2 - 1.2
		local fillLevelNormalizedAdjusted = baler.realismAddon_balers.fillLevelNormalized + 0.2
		local fillPower = intakePower * (fillLevelNormalizedAdjusted * fillLevelNormalizedAdjusted)

		-- increase power requirement drastically in the last few %
		if fillLevelNormalizedAdjusted > 1 then
			fillPower = fillPower * fillLevelNormalizedAdjusted * fillLevelNormalizedAdjusted
		end

		--print("constantPower: "..tostring(constantPower))
		--print("intakePower: "..tostring(intakePower))
		--print("fillPower: "..tostring(fillPower))	

		local totalPower = (constantPower + intakePower + fillPower) * baler.realismAddon_balers.fillTypePowerMultiplicator * baler.realismAddon_balers.powerMuliplicator 
		baler.realismAddon_balers.totalPower = baler.realismAddon_balers.totalPower * 0.6 + totalPower * 0.4
		
		return baler.realismAddon_balers.totalPower / (rpm * math.pi / 30), powerConsumer.virtualPowerMultiplicator * turnOnPeakPowerMultiplier		

	else
		return superFunc(self, expected, ignoreTurnOnPeak)
	end


	return 0, 1
end
PowerConsumer.getConsumedPtoTorque = Utils.overwrittenFunction(PowerConsumer.getConsumedPtoTorque, realismAddon_balers.getConsumedPtoTorque)



function realismAddon_balers.onUpdate(self, superFunc, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	superFunc(self, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)


	local spec = self.spec_baler
	local turnOnVehicle = self.spec_turnOnVehicle

	if spec.realismAddon_balers ~= nil then

		if self:getIsTurnedOn() then
			-- squarebaler stuff only
			-- the square baler adds fillLevel only on power stroke, synchronized to the animation
			if spec.realismAddon_balers.isSquarebaler then	
				-- only if we have turnOn Animation - also use the first animation.. no idea how to check which animation is the plunger animation -> assume there is only 1
				local turnedOnAnimation = turnOnVehicle.turnedOnAnimations[1]
				if turnedOnAnimation.name ~= nil then
					local animTime = self:getAnimationTime(turnedOnAnimation.name)

					-- animTime 0 - 0.5 -> plunger moving rear
					-- 0.5 - 1 plunger moving front 
					-- none of that is standard or default.. so.. crap

					-- add bale pressure between 2 values | change later / add offset to synchronize
					local minValue = 0.1
					local maxValue = 0.5

					spec.realismAddon_balers.fillTypePowerMultiplicator = 1

					local range = maxValue - minValue
					if animTime > minValue and animTime < maxValue then
						
						-- get the amount left to add 
						for fillTypeIndex, _ in pairs(spec.realismAddon_balers.pickedUpLiters) do
							local amountLeft = spec.realismAddon_balers.pickedUpLiters[fillTypeIndex]

							-- calculate % of amount to add 
							local amountToAdd = amountLeft - (1 - (animTime-minValue / range))

							-- add amount 
							spec.pickupFillTypes[fillTypeIndex] = spec.pickupFillTypes[fillTypeIndex] + amountToAdd
							spec.workAreaParameters.lastPickedUpLiters = spec.workAreaParameters.lastPickedUpLiters + amountToAdd
							
							-- remove 
							spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] = spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] - amountToAdd

							local fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillTypeIndex)

							if realismAddon_balers.fillTypePowerMultiplicator[fillTypeName] ~= nil then
								spec.realismAddon_balers.fillTypePowerMultiplicator = spec.realismAddon_balers.fillTypePowerMultiplicator * realismAddon_balers.fillTypePowerMultiplicator[fillTypeName]
							else
								spec.realismAddon_balers.fillTypePowerMultiplicator = spec.realismAddon_balers.fillTypePowerMultiplicator 
							end
						
						end

						Baler.onEndWorkAreaProcessing(self, dt, false)
					end
					
					local power = 0
					if animTime < 0.5 then
						power = animTime * 2
					end

					if animTime > 0.45 and animTime < 0.55 then
						if spec.realismAddon_balers.forcePlus == nil then
							local force = getMass(self.rootNode) / 3							
							addImpulse(self.rootNode, 0, 0.000, -force, 0, 0, 0, true)
							spec.realismAddon_balers.forcePlus = true
							spec.realismAddon_balers.forceMinus = nil

							--print("impulse -")
						end
					end

					if animTime > 0.95 or animTime < 0.05 then
						if spec.realismAddon_balers.forceMinus == nil then
							local force = getMass(self.rootNode) / 3							
							addImpulse(self.rootNode, 0, 0.000, force, 0, 0, 0, true)
							spec.realismAddon_balers.forceMinus = true
							spec.realismAddon_balers.forcePlus = nil
							--print("impulse +")
						end					
					end

					spec.realismAddon_balers.plungerPower = power
				end


			

			elseif spec.realismAddon_balers.isRoundbaler then -- roundbaler specific stuff

				local capacity = self:getFillUnitCapacity(spec.fillUnitIndex)
				local fillLevel = self:getFillUnitFillLevel(spec.fillUnitIndex)

				spec.realismAddon_balers.fillLevelNormalized = fillLevel / capacity

					

			end

			-- stuff that is equal for both square and round baler
			-- get average intake power per milisecond amount 
			spec.realismAddon_balers.lastMilisecond = spec.realismAddon_balers.lastMilisecond + dt 
			if spec.realismAddon_balers.lastMilisecond > spec.realismAddon_balers.milisecondAverage then

				spec.realismAddon_balers.intakeAverage = spec.realismAddon_balers.lastIntakeTotal
				
				spec.realismAddon_balers.lastIntakeTotal = 0
				spec.realismAddon_balers.lastMilisecond = 0	
			end	


		end
	end



end
Baler.onUpdate = Utils.overwrittenFunction(Baler.onUpdate, realismAddon_balers.onUpdate)



function realismAddon_balers.processBalerArea(self, superFunc, workArea, dt)

	local spec = self.spec_baler
	if spec.realismAddon_balers ~= nil then
		if spec.realismAddon_balers.isSquarebaler == true then

			local lsx, lsy, lsz, lex, ley, lez, lineRadius = DensityMapHeightUtil.getLineByArea(workArea.start, workArea.width, workArea.height)

			if self.isServer then
				spec.fillEffectType = FillType.UNKNOWN
			end

			for fillTypeIndex, _ in pairs(spec.pickupFillTypes) do
				local pickedUpLiters = -DensityMapHeightUtil.tipToGroundAroundLine(self, -math.huge, fillTypeIndex, lsx, lsy, lsz, lex, ley, lez, lineRadius, nil, nil , false, nil)

				if pickedUpLiters > 0 then
					if self.isServer then
						spec.fillEffectType = fillTypeIndex

						if spec.additives.available then
							local fillTypeSupported = false

							for i = 1, #spec.additives.fillTypes do
								if fillTypeIndex == spec.additives.fillTypes[i] then
									fillTypeSupported = true

									break
								end
							end

							if fillTypeSupported then
								local additivesFillLevel = self:getFillUnitFillLevel(spec.additives.fillUnitIndex)

								if additivesFillLevel > 0 then
									local usage = spec.additives.usage * pickedUpLiters

									if usage > 0 then
										local availableUsage = math.min(additivesFillLevel / usage, 1)
										pickedUpLiters = pickedUpLiters * (1 + 0.05 * availableUsage)

										self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.additives.fillUnitIndex, -usage, self:getFillUnitFillType(spec.additives.fillUnitIndex), ToolType.UNDEFINED)
									end
								end
							end
						end
					end

					--print(tostring(pickedUpLiters))


					spec.realismAddon_balers.lastIntakeTotal = spec.realismAddon_balers.lastIntakeTotal + (pickedUpLiters * 0.99)

					if spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] == nil then
						spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] = 0
					end
					spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] = spec.realismAddon_balers.pickedUpLiters[fillTypeIndex] + (pickedUpLiters * 0.99)

					-- send a tiny amount back right away to keep particles coming 
					spec.pickupFillTypes[fillTypeIndex] = spec.pickupFillTypes[fillTypeIndex] + (pickedUpLiters * 0.01)
					spec.workAreaParameters.lastPickedUpLiters = spec.workAreaParameters.lastPickedUpLiters + (pickedUpLiters * 0.01) 

			

					return pickedUpLiters, pickedUpLiters
				end
			end

			return 0, 0
		end
		if spec.realismAddon_balers.isRoundbaler == true then


			local pickedUpLiters = superFunc(self, workArea, dt)
			--return superFunc(self, workArea, dt)
			--print(pickedUpLiters)

			spec.realismAddon_balers.lastIntakeTotal = spec.realismAddon_balers.lastIntakeTotal + pickedUpLiters

			return pickedUpLiters, pickedUpLiters
		end

		return 0, 0	
	else

		return superFunc(self, workArea, dt)
	end
end
Baler.processBalerArea = Utils.overwrittenFunction(Baler.processBalerArea, realismAddon_balers.processBalerArea)


--[[
function realismAddon_balers:addFillUnitFillLevel(superFunc, farmId, fillUnitIndex, fillLevelDelta, fillTypeIndex, toolType, fillPositionData)
	
	local spec = self.spec_baler

	if spec ~= nil and spec.realismAddon_balers ~= nil and spec.realismAddon_balers.isRoundbaler == true then

		local fillUnit = self.spec_fillUnit.fillUnits[fillUnitIndex]
		
		if fillUnitIndex == spec.fillUnitIndex then
		
			-- backup original capacity
			local capacityOriginal = fillUnit.capacity			
			-- capacity is temporarily raised 
			fillUnit.capacity = fillUnit.capacity * 1.2
			-- call original function while capacity is temporarily raised and with loss-added delta 
			local returnValue = superFunc(self, farmId, fillUnitIndex, fillLevelDelta, fillTypeIndex, toolType, fillPositionData)
			-- reset capacity
			fillUnit.capacity = capacityOriginal
			
			return returnValue
		else
			return superFunc(self, farmId, fillUnitIndex, fillLevelDelta, fillTypeIndex, toolType, fillPositionData)
		end
	else
		return superFunc(self, farmId, fillUnitIndex, fillLevelDelta, fillTypeIndex, toolType, fillPositionData)
	end
	
end
FillUnit.addFillUnitFillLevel = Utils.overwrittenFunction(FillUnit.addFillUnitFillLevel, realismAddon_balers.addFillUnitFillLevel)


function realismAddon_balers:getFillUnitAllowsFillType(superFunc, fillUnitIndex, fillType)
	local spec = self.spec_baler
	if spec ~= nil and spec.realismAddon_balers ~= nil and spec.realismAddon_balers.isRoundbaler == true then
	
		local fillUnit = self.spec_fillUnit.fillUnits[fillUnitIndex]		
		if fillUnitIndex == spec.fillUnitIndex then

			-- backup original capacity	
			local capacityOriginal = fillUnit.capacity
			-- capacity is temporarily raised by realismAddon_fillables.capacityMultiplier 
			fillUnit.capacity = fillUnit.capacity * 1.2
			-- call original function while capacity is temporarily raised 
			local returnValue = superFunc(self, fillUnitIndex, fillType)
			
			-- reset capacity
			fillUnit.capacity = capacityOriginal
			
			return returnValue
		else
			return superFunc(self, fillUnitIndex, fillType)
		end
	else
		return superFunc(self, fillUnitIndex, fillType)
	end
end
FillUnit.getFillUnitAllowsFillType = Utils.overwrittenFunction(FillUnit.getFillUnitAllowsFillType, realismAddon_balers.getFillUnitAllowsFillType)


function realismAddon_balers:getFillUnitFreeCapacity(superFunc, fillUnitIndex, fillTypeIndex, farmId)
	local spec = self.spec_baler
	if spec ~= nil and spec.realismAddon_balers ~= nil and spec.realismAddon_balers.isRoundbaler == true then
	
		local fillUnit = self.spec_fillUnit.fillUnits[fillUnitIndex]	
	
		if fillUnitIndex == spec.fillUnitIndex then
			-- backup original capacity	
			local capacityOriginal = fillUnit.capacity
			-- capacity is temporarily raised by realismAddon_fillables.capacityMultiplier 
			fillUnit.capacity = fillUnit.capacity * 1.2
			-- call original function while capacity is temporarily raised 	
			local returnValue = superFunc(self, fillUnitIndex, fillTypeIndex, farmId)	
			-- reset capacity
			fillUnit.capacity = capacityOriginal
			
			return returnValue
		else
			return superFunc(self, fillUnitIndex, fillTypeIndex, farmId)		
		end
	else
		return superFunc(self, fillUnitIndex, fillTypeIndex, farmId)
	end
end
FillUnit.getFillUnitFreeCapacity = Utils.overwrittenFunction(FillUnit.getFillUnitFreeCapacity, realismAddon_balers.getFillUnitFreeCapacity)



function realismAddon_balers.onReadUpdateStream(self, superFunc, streamId, timestamp, connection)
	
	if self.spec_baler ~= nil and self.spec_baler.realismAddon_balers ~= nil and self.spec_baler.realismAddon_balers.isRoundbaler == true then

		local spec = self.spec_fillUnit
		
		-- go through all fillUnits and set capacities if neccesary 
		for i = 1, table.getn(spec.fillUnits) do
			local fillUnit = spec.fillUnits[i]		
			if i == self.spec_baler.fillUnitIndex then
				-- backup original capacity	
				fillUnit.capacityOriginal = fillUnit.capacity
				-- capacity is temporarily raised by realismAddon_fillables.capacityMultiplier 
				fillUnit.capacity = fillUnit.capacity * 1.2			
			end
		end
		-- call original function while capacity is temporarily raised 	
		local returnValue = superFunc(self, streamId, timestamp, connection)
		-- go through all fillUnits and reset capacities if neccesary 
		for i = 1, table.getn(spec.fillUnits) do
			local fillUnit = spec.fillUnits[i]		
			if i == self.spec_baler.fillUnitIndex then
				-- reset capacity back 
				-- check if capacityOriginal backup exists first because if fillUnit fillType changed during call of the original function it might not have been affected by the capacity change this call 
				if fillUnit.capacityOriginal ~= nil then
					fillUnit.capacity = fillUnit.capacityOriginal
				end
			end
		end	
		return returnValue		
	else
		return superFunc(self, streamId, timestamp, connection)
	end

end
FillUnit.onReadUpdateStream = Utils.overwrittenFunction(FillUnit.onReadUpdateStream, realismAddon_balers.onReadUpdateStream)

function realismAddon_balers.onWriteUpdateStream(self, superFunc, streamId, connection, dirtyMask)

	if self.spec_baler ~= nil and self.spec_baler.realismAddon_balers ~= nil and self.spec_baler.realismAddon_balers.isRoundbaler == true then
		local spec = self.spec_fillUnit

		-- go through all fillUnits and set capacities if neccesary 
		for i = 1, table.getn(spec.fillUnits) do
			local fillUnit = spec.fillUnits[i]		
			if i == self.spec_baler.fillUnitIndex then
				-- backup original capacity	
				fillUnit.capacityOriginal = fillUnit.capacity
				-- capacity is temporarily raised by realismAddon_fillables.capacityMultiplier
				fillUnit.capacity = fillUnit.capacity * 1.2			
			end
		end
		-- call original function while capacity is temporarily raised 	
		local returnValue = superFunc(self, streamId, connection, dirtyMask)	
		-- go through all fillUnits and reset capacities if neccesary 
		for i = 1, table.getn(spec.fillUnits) do
			local fillUnit = spec.fillUnits[i]		
			if i == self.spec_baler.fillUnitIndex then
				-- reset capacity back 
				fillUnit.capacity = fillUnit.capacityOriginal					
			end
		end		
		
		return returnValue	
	else
		return superFunc(self, streamId, connection, dirtyMask)
	end
end
FillUnit.onWriteUpdateStream = Utils.overwrittenFunction(FillUnit.onWriteUpdateStream, realismAddon_balers.onWriteUpdateStream)

]]