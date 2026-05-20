Config = {}

Config.Debug = true
Config.UseLoJobsCreator = true

-- Optional fallback: if true, players in these lo_jobscreator job types can use
-- police commands even when their exact job name is not listed in Config.AllowedJobs.
-- Keep this false if you only want the exact Config.AllowedJobs jobs to have access.
Config.AllowLoJobTypeFallback = false
Config.AllowedJobTypes = {
    'leo'
}

Config.AllowedJobs = {
    'valentine_sheriff',
    'blackwater_sheriff',
    'saint_denis_police',
    'us_marshal'
}

-- Add full identifiers here for development/testing access bypasses.
-- Examples: 'license:xxxxxxxx', 'steam:110000xxxxxxxxx', 'fivem:123456'
Config.AdminIdentifiers = {}

-- Maximum distance (in game units/meters) an officer can be from the selected jail
-- location to perform a /jail booking.
Config.JailBookingMaxDistance = 50.0

Config.DefaultIndefiniteLabels = {
    indefinite = 'Pending trial',
    hold = 'Awaiting sentencing',
    manual = 'Manual record'
}


-- Optional per-station jail permissions for UI location filtering.
-- If a station key is missing or has an empty list, any allowed police job can use that location.
Config.StationPermissions = {
    valentine = { 'valentine_sheriff', 'us_marshal' },
    blackwater = { 'blackwater_sheriff', 'us_marshal' },
    saint_denis = { 'saint_denis_police', 'us_marshal' }
}

Config.Stations = {
    valentine = {
        label = 'Valentine Sheriff Office',
        releaseCoords = vector4(0.0, 0.0, 0.0, 0.0)
    },
    blackwater = {
        label = 'Blackwater Police Department',
        releaseCoords = vector4(-762.1951, -1229.3816, 35.5071, 270.5755)
    },
    saint_denis = {
        label = 'Saint Denis Police Department',
        releaseCoords = vector4(0.0, 0.0, 0.0, 0.0)
    }
}

-- Replace these placeholder coordinates with your server's actual cells.
Config.Cells = {
    {
        id = 1,
        station = 'blackwater',
        label = 'Cell 001',
        jailCoords = vector4(-760.5576, -1237.1240, 35.4471, 269.4535)
    },
    {
        id = 2,
        station = 'blackwater',
        label = 'Cell 002',
        jailCoords = vector4(-760.0083, -1240.0150, 35.4471, 275.0790)
    },
    {
        id = 3,
        station = 'blackwater',
        label = 'Cell 003',
        jailCoords = vector4(-760.0474, -1242.7747, 35.4471, 288.4084)
    },
    {
        id = 4,
        station = 'blackwater',
        label = 'Cell 004',
        jailCoords = vector4(-763.7719, -1246.6923, 35.4471, 180.3489)
    },
    {
        id = 5,
        station = 'blackwater',
        label = 'Cell 005',
        jailCoords = vector4(-766.5684, -1246.8185, 35.4473, 200.5505)
    },
    {
        id = 6,
        station = 'blackwater',
        label = 'Cell 006',
        jailCoords = vector4(-769.7299, -1246.7349, 35.4475, 195.8313)
    },
    {
        id = 7,
        station = 'blackwater',
        label = 'Cell 007',
        jailCoords = vector4(-773.7864, -1243.2373, 35.4472, 178.2344)
    },
    {
        id = 8,
        station = 'blackwater',
        label = 'Cell 008',
        jailCoords = vector4(-773.9820, -1240.5831, 35.4472, 101.2017)
    },
    {
        id = 9,
        station = 'blackwater',
        label = 'Cell 009',
        jailCoords = vector4(-773.7784, -1237.5500, 35.4471, 98.9663)
    },
    {
        id = 10,
        station = 'blackwater',
        label = 'Cell 010',
        jailCoords = vector4(-773.8057, -1234.7286, 35.4472, 53.8345)
    },
    {
        id = 3,
        station = 'valentine',
        label = 'Valentine Cell 2',
        jailCoords = vector4(0.0, 0.0, 0.0, 0.0)
    }
}
