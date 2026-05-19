local function RotationToDirection(rotation)
    local rotZ = math.rad(rotation.z)
    local rotX = math.rad(rotation.x)
    local cosX = math.abs(math.cos(rotX))

    return vector3(
        -math.sin(rotZ) * cosX,
        math.cos(rotZ) * cosX,
        math.sin(rotX)
    )
end


local function RayCastGamePlayCamera(distance)
    local camRot = GetGameplayCamRot(2)
    local camCoord = GetGameplayCamCoord()

    local direction = RotationToDirection(camRot)

    local destination = vector3(
        camCoord.x + direction.x * distance,
        camCoord.y + direction.y * distance,
        camCoord.z + direction.z * distance
    )

    local ray = StartShapeTestRay(
        camCoord.x,
        camCoord.y,
        camCoord.z,
        destination.x,
        destination.y,
        destination.z,
        16,
        PlayerPedId(),
        0
    )

    local _, hit, endCoords, _, entity =
        GetShapeTestResult(ray)

    return hit, endCoords, entity
end


RegisterCommand("doorhash", function()

    local hit, coords, entity =
        RayCastGamePlayCamera(10.0)

    if hit == 0 or entity == 0 then
        print("^1[HASHFINDER]^7 Nothing targeted.")
        return
    end

    local model = GetEntityModel(entity)
    local heading = GetEntityHeading(entity)

    print("^2========== HASH DEBUG ==========")
    print("Entity ID:", entity)
    print("Model Hash:", model)

    print(("Coords: %.3f %.3f %.3f")
        :format(coords.x, coords.y, coords.z))

    print(("Heading: %.2f")
        :format(heading))

    print("=================================")

end, false)